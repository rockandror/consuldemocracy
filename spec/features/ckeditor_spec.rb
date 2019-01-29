require 'rails_helper'

feature 'CKEditor' do
  before do
    skip("fix specs")
  end
  scenario 'is present before & after turbolinks update page', :js do
    author = create(:user)
    login_as(author)

    visit new_debate_path

    expect(page).to have_css "#cke_debate_translations_attributes_2_description"

    click_link 'Debates'
    click_link 'Start a debate'

    expect(page).to have_css "#cke_debate_translations_attributes_2_description"
  end

end
