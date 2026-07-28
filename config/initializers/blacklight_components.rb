# frozen_string_literal: true

# Blacklight 8.12 defines several default component properties as constants
# during initialization. In this app boot path, those component classes may
# not be loaded yet, so preload Blacklight's component files.
require 'blacklight'

blacklight_spec = Gem.loaded_specs['blacklight']

if blacklight_spec
  components_path = File.join(blacklight_spec.full_gem_path, 'app/components/blacklight')

  require File.join(components_path, 'skip_link_item_component')
  require File.join(components_path, 'skip_link_component')
  require File.join(components_path, 'header_component')
end
