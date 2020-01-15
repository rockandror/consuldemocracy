require "rails_helper"

feature "Moderated texts", type: :feature do
  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do
    scenario "Shows a message when no words are moderated" do
      visit admin_moderated_texts_path
      expect(page).to have_content('There are no moderated words')
    end
  end

  context "New" do
    scenario "Adds a new moderated word" do
      visit admin_moderated_texts_path
      click_link 'Create new text'

      expect(page).to have_content('New text')

      fill_in 'moderated_text_text', with: 'Bad word'
      click_button 'Create text'

      expect(page).to have_content('Bad word')
      expect(page).to have_content('Text created successfully')
    end
  end

  context "Delete" do
    background do
      bad_word = create(:moderated_text)
    end

    scenario "Removes a moderated word", :js do
      visit admin_moderated_texts_path
      expect(page).to have_content('bad word')

      accept_confirm { click_link 'Delete' }

      expect(page).to have_content('Word successfully deleted.')
      expect(page).not_to have_content('bad word')
    end
  end
end
