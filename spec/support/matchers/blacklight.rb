# frozen_string_literal: true

RSpec::Matchers.define :have_blacklight_field do |field|
  match do |_actual|
    find("dd.blacklight-#{field}").has_content?(@value)
  end

  chain :with do |value|
    @value = value
  end
end

RSpec::Matchers.define :have_blacklight_label do |field|
  match do |_actual|
    find("dt.blacklight-#{field}").has_content?(@value)
  end

  chain :with do |value|
    @value = value
  end
end
