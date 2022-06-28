# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy URLs are redirected', type: :feature do
  # EXAMPLE:
  #     "title_ssi": "Controlling Molecular Assemblies",
  #     "id": "6894",
  #     "db_legacy_old_id": "1177",
  #         "db_legacy_id": "1026",
  #         "db_id": "4",
  # These:
  # - https://etda.libraries.psu.edu/theses/approved/WorldWideIndex/EHT-1177/anythinggoes
  # - https://etda.libraries.psu.edu/paper/6894
  # Redirect to:
  # https://etda.libraries.psu.edu/catalog/6894

  before do
    doc = FakeSolrDocument.new(id: '6894', db_legacy_old_id: '1177').doc
    Blacklight.default_index.connection.add(doc)
    Blacklight.default_index.connection.commit
  end

  specify 'Old Legacy URLs(/theses/approved/WorldWideIndex/ETD-1177/index.html) should be redirected' do
    visit '/theses/approved/WorldWideIndex/ETD-1177/index.html'
    expect(page).to have_current_path('/catalog/6894')
    visit '/theses/approved/PSUonlyIndex/EHT-1177/index.html'
    expect(page).to have_current_path('/catalog/6894')
  end

  specify "Old Legacy URLs(/theses/approved/WorldWideIndex/ETD-1177/) should be accepted without 'index.html'" do
    visit '/theses/approved/WorldWideIndex/ETD-1177'
    expect(page).to have_current_path('/catalog/6894')
  end

  specify 'Old Legacy URLs(/theses/approved/WorldWideIndex/ETD-1177/) should be accepted with anything after ETD #' do
    visit '/theses/approved/WorldWideIndex/EHT-1177/anythinggoes'
    expect(page).to have_current_path('/catalog/6894')
  end

  specify 'Legacy URLs (/paper/id) should be redirected' do
    visit '/paper/6894'
    expect(page).to have_current_path('/catalog/6894')
  end

  specify 'Legacy URLS with paper id should be redirected to document (/paper/id/paperid)' do
    visit '/paper/6894/9999'
    expect(page).to have_current_path('/catalog/6894')
  end

  specify 'legacy search should redirect' do
    visit '/search'
    expect(page).to have_current_path('/catalog')
  end

  specify 'legacy browse should redirect' do
    visit '/browse'
    expect(page).to have_current_path('/catalog')
  end

  it 'renders 404 when no record is found' do
    visit '/theses/approved/WorldWideIndex/ETD-1178/index.html'
    expect(page.status_code).to eq(404)
  end
end
