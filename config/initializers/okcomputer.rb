# frozen_string_literal: true

OkComputer.mount_at = false

OkComputer::Registry.register(
  'version',
  HealthChecks::VersionCheck.new
)

OkComputer::Registry.register(
  'solr',
  HealthChecks::SolrCheck.new
)

OkComputer.make_optional %w(version)
