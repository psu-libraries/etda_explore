require 'rails_helper'


RSpec.describe 'Searching', type: :feature do
    before do 
        @doc = FakeSolrDocument.new
        Blacklight.default_index.connection.add(@doc.doc)
        Blacklight.default_index.connection.commit
    end

  it 'returns expected results' do
    title = @doc.doc[:title_ssi]
    # binding.pry
    visit '/'
    select("Title", from: "search_field")
    fill_in 'q', with: title
    click_button 'Search'
    # save_and_open_page
    expect(page).to have_content '1 entry found'
    within '.document-title-heading' do
      expect(page).to have_content title
    end
  end

#   it 'searches for author last name' do 
#     last_name = @doc.doc[:last_name_tesi]
#     visit '/'
#     select("Author Last Name", from: "search_field")
#     fill_in 'q', with: last_name
#     click_button 'Search'
#     within '.document-title-heading' do 
#         expect(page).to have_content last_name
#     end
#   end


end
