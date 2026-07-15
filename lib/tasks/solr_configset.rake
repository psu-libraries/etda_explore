# frozen_string_literal: true

require 'fileutils'
namespace :solr do
    desc 'Package solr configset into configset.zip, optionally including analysis-extras jars from SOLR_INSTALL_DIR'
    task :package_configset do
    config_dir = 'solr/conf'
    build_dir = 'tmp/solr_configset_build'
    zip_file = 'configset.zip'

    FileUtils.rm_rf(build_dir)
    FileUtils.mkdir_p(build_dir)

    # Copy config files
    FileUtils.cp_r(Dir[File.join(config_dir, '**', '*')], build_dir)

    # Prepare lib dir inside the configset build for any jars we want to include
    lib_dir = File.join(build_dir, 'lib')
    FileUtils.mkdir_p(lib_dir)

    if ENV['SOLR_INSTALL_DIR'] && !ENV['SOLR_INSTALL_DIR'].empty?
        src_dirs = [
        File.join(ENV['SOLR_INSTALL_DIR'], 'modules', 'analysis-extras', 'lib'),
        File.join(ENV['SOLR_INSTALL_DIR'], 'modules', 'analysis-extras', 'lucene-libs')
    ]
    src_dirs.each do |d|
        if Dir.exist?(d)
            Dir.glob(File.join(d, '*')).each do |f|
            FileUtils.cp(f, lib_dir) if File.file?(f)
        end
        end
    end
    else
        puts "SOLR_INSTALL_DIR not set — ensure required jars (icu, analysis-extras) are present in #{config_dir}/lib"
    end

    # Create zip
    Dir.chdir(build_dir) do
        FileUtils.rm_f(File.join('..', '..', zip_file))
        system('zip', '-r', File.join('..', '..', zip_file), '.') || raise('zip failed')
    end

    puts "Created #{zip_file}"
end
end
