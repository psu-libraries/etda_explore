require 'rails_helper'

RSpec.describe 'Searching', type: :feature do
  before do 
    @doc = FakeSolrDocument.new
    Blacklight.default_index.connection.add(@doc.doc)
    Blacklight.default_index.connection.commit
  end

  it 'searches all fields' do
    title = @doc.doc[:title_ssi]
    visit '/'
    select("All Fields", from: "search_field")
    fill_in 'q', with: title
    click_button 'Search'
    expect( all('.document-title-heading').count ).to be > 0
    expect(page).to have_content @doc.doc[:last_name_ssi]
  end

  it 'searches for author name' do 
    last_name = @doc.doc[:last_name_ssi]
    visit '/'
    select("Author Name", from: "search_field")
    fill_in 'q', with: last_name
    click_button 'Search'
    expect( all('.document-title-heading').count ).to be > 0
    expect(page).to have_content @doc.doc[:title_ssi]
  end

  it 'searches for title' do 
    title = @doc.doc[:title_ssi]
    visit '/'
    select("Title", from: "search_field")
    fill_in 'q', with: title
    click_button 'Search'
    expect(all('.document-title-heading').count).to be > 0
    expect(page).to have_content @doc.doc[:last_name_ssi]
  end

  it 'searches for graduate program' do 
    program = @doc.doc[:program_name_ssi]
    visit '/'
    select("Graduate Program", from: "search_field")
    fill_in 'q', with: program
    click_button 'Search'
    expect(all('.document-title-heading').count).to be > 0
    expect(page).to have_selector '.blacklight-program_name_ssi', text: @doc.doc[:program_name_ssi]
  end

  it 'searches for keyword' do 
    keyword = @doc.doc[:keyword_ssi]
    visit '/'
    select("Keyword", from: "search_field")
    fill_in 'q', with: keyword
    click_button 'Search'
    expect(all('.document-title-heading').count).to be > 0
    expect(page).to have_selector '.blacklight-keyword_ssim', text: /#{@doc.doc[:keyword_ssi]}/
  end

  it 'searches for committee member' do 
    committee_member = @doc.doc[:committee_member_name_ssim].first
    visit '/'
    select("Committee Member", from: "search_field")
    fill_in 'q', with: committee_member
    click_button 'Search'
    expect(all('.document-title-heading').count).to be > 0
    expect(page).to have_content @doc.doc[:title_ssi]
  end

  it 'searches for abstract' do 
    abstract = @doc.doc[:abstract_tesi]
    visit '/'
    select("Abstract", from: "search_field")
    fill_in 'q', with: abstract
    click_button 'Search'
    expect(all('.document-title-heading').count).to be > 0
    expect(page).to have_content @doc.doc[:title_ssi]
  end
end
