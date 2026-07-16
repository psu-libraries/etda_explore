# frozen_string_literal: true

OkComputer.mount_at = false

OkComputer::Registry.register(
  'version',
  Healthchecks::VersionCheck.new
)

OkComputer::Registry.register(
  'solr',
  Healthchecks::SolrCheck.new
)

OkComputer.make_optional %w(version)
