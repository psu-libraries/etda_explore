# frozen_string_literal: true

require 'zip'

module EtdaExplore
  class SolrConfig
    CONFIG_PATH = '/solr/admin/configs'
    COLLECTION_PATH = '/solr/admin/collections'

    def solr_username
      ENV.fetch('SOLR_USERNAME', nil)
    end

    def solr_password
      ENV.fetch('SOLR_PASSWORD', nil)
    end

    def solr_host
      ENV.fetch('SOLR_HOST', 'localhost')
    end

    def solr_port
      ENV.fetch('SOLR_PORT', '8983')
    end

    def url
      "http://#{solr_host}:#{solr_port}"
    end

    def config_url
      "#{url}#{CONFIG_PATH}"
    end

    def collection_url
      "#{url}#{COLLECTION_PATH}"
    end

    def query_url
      if solr_username && solr_password
        solr_auth = "#{solr_username}:#{URI.encode_www_form_component(solr_password)}"
        "http://#{solr_auth}@#{solr_host}:#{solr_port}/solr/#{collection_name}"
      else
        "http://#{solr_host}:#{solr_port}/solr/#{collection_name}"
      end
    end

    def dir
      ENV.fetch('SOLR_CONFIG_DIR', 'solr/conf')
    end

    def collection_name
      ENV.fetch('SOLR_COLLECTION', 'blacklight-core')
    end

    def num_shards
      ENV.fetch('SOLR_NUM_SHARDS', '1')
    end

    def configset_name
      @configset_name ||= "configset-#{solr_md5}"
    end

    def tempfile
      tmp = Tempfile.new('configset')
      Zip::File.open(tmp, create: true) do |zipfile|
        add_config_files(zipfile)
        add_solr_jars(zipfile)
      end
      tmp
    end

    private

      # Returns a combined MD5 digest for all files in solr config directory
      def solr_md5
        digest = []
        Dir.glob("#{dir}/**/*").each do |f|
          digest.push(Digest::MD5.hexdigest(File.read(f))) if File.file?(f)
        end
        Digest::MD5.hexdigest(digest.join)
      end

      def add_config_files(zipfile)
        Dir["#{dir}/**/**"].each do |file|
          next unless File.file?(file)

          zipfile.add(file.sub("#{dir}/", ''), file)
        end
      end

      def add_solr_jars(zipfile)
        solr_install = ENV.fetch('SOLR_INSTALL_DIR', nil)
        return unless solr_install.present?

        candidates = [
          File.join(solr_install, 'modules', 'analysis-extras', 'lib'),
          File.join(solr_install, 'contrib', 'analysis-extras', 'lib'),
          File.join(solr_install, 'dist', 'contrib', 'analysis-extras', 'lib')
        ]

        candidates.each do |libdir|
          next unless Dir.exist?(libdir)

          Dir[File.join(libdir, '*')].each do |jar|
            next unless File.file?(jar)

            zipfile.add(File.join('lib', File.basename(jar)), jar)
          end
        end
      end
  end
end
