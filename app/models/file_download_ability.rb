# frozen_string_literal: true

class FileDownloadAbility
  include CanCan::Ability

  def initialize(user, solr_document)
    user ||= User.new(guest: true)

    current_access_level = solr_document.access_level.current_access_level

    can :read, solr_document if current_access_level == 'open_access'

    can :read, solr_document unless user.guest?
  end
end
