require "rails_helper"

feature "Auto moderated content" do
  let(:admin) { create(:administrator) }
  let(:vulgar_word) { create(:moderated_text, text: "vulgar") }
  let(:my_debate) { create(:debate) }

  let!(:comment) {
    create(:comment,
      body: "vulgar comment",
      commentable: my_debate,
      user: admin.user
    )
  }

  let!(:another_comment) {
    create(:comment,
      body: "not a comment",
      commentable: my_debate,
      user: admin.user
    )
  }

  let!(:a_new_comment) {
    create(:comment,
      body: "I'm not vulgar",
      commentable: my_debate,
      user: admin.user
    )
  }

  let!(:offense) { create(:moderated_content, moderable: comment, moderated_text: vulgar_word) }
  let!(:another_offense) { create(:moderated_content, moderable: a_new_comment, moderated_text: vulgar_word) }

  background do
    login_as(admin.user)
  end

  context "Index" do
    it "lists comments deemed offensive" do
      visit admin_auto_moderated_content_index_path

      expect(page).to have_content(comment.body)
      expect(page).not_to have_content(another_comment.body)
    end
  end

  describe "#show_again" do
    it "allows a comment to be shown again", :js do
      visit debate_path(my_debate)

      expect(page).to have_content(another_comment.body)
      expect(page).not_to have_content(comment.body)
      expect(page).not_to have_content(a_new_comment.body)

      visit admin_auto_moderated_content_index_path

      expect(page).to have_content(comment.body)
      expect(page).to have_content(a_new_comment.body)
      expect(page).not_to have_content(another_comment.body)

      within "#comment_#{a_new_comment.id}" do
        accept_confirm "Are you sure you want to show this comment again?" do
          click_link "Show again"
        end
      end

      visit debate_path(my_debate)

      expect(page).to have_content(a_new_comment.body)
      expect(page).to have_content(another_comment.body)
      expect(page).not_to have_content(comment.body)
    end
  end

  describe "#confirm_moderation" do
    it "does not allow a comment to be shown again", :js do
      visit debate_path(my_debate)

      expect(page).to have_content(another_comment.body)
      expect(page).not_to have_content(comment.body)
      expect(page).not_to have_content(a_new_comment.body)

      visit admin_auto_moderated_content_index_path

      expect(page).to have_content(comment.body)
      expect(page).to have_content(a_new_comment.body)
      expect(page).not_to have_content(another_comment.body)

      within "#comment_#{a_new_comment.id}" do
        accept_confirm "Are you sure you want to hide this comment permanently?" do
          click_link "Confirm moderation"
        end
      end

      visit debate_path(my_debate)

      expect(page).to have_content(another_comment.body)
      expect(page).not_to have_content(comment.body)
      expect(page).not_to have_content(a_new_comment.body)
    end
  end

  describe "Filters" do
    describe "Pending moderation" do
      it "only shows pending comments", :js do
        visit debate_path(my_debate)

        expect(page).not_to have_content(comment.body)
        expect(page).not_to have_content(a_new_comment.body)

        visit admin_auto_moderated_content_index_path

        expect(page).to have_content(comment.body)
        expect(page).to have_content(a_new_comment.body)

        within "#comment_#{a_new_comment.id}" do
          accept_confirm "Are you sure you want to hide this comment permanently?" do
            click_link "Confirm moderation"
          end
        end

        expect(page).not_to have_content(a_new_comment.body)
        expect(page).to have_content(comment.body)
      end
    end

    describe "Confirmed moderation" do
      it "only shows moderated comments deemed offensive by admins", :js do
        visit debate_path(my_debate)

        expect(page).not_to have_content(comment.body)
        expect(page).not_to have_content(a_new_comment.body)

        visit admin_auto_moderated_content_index_path

        expect(page).to have_content(comment.body)
        expect(page).to have_content(a_new_comment.body)

        within "#comment_#{a_new_comment.id}" do
          accept_confirm "Are you sure you want to hide this comment permanently?" do
            click_link "Confirm moderation"
          end
        end

        click_link "Confirmed moderation"

        expect(page).to have_content(a_new_comment.body)
        another_offense.reload
        confirmed_at = I18n.l(another_offense.confirmed_at, format: :datetime)
        expect(page).to have_content("This comment has been moderated already on #{confirmed_at}")
        expect(page).not_to have_content(comment.body)
      end
    end

    describe "Declined moderation" do
      it "only shows moderated comments deemed non-offensive by admins", :js do
        visit debate_path(my_debate)

        expect(page).not_to have_content(comment.body)
        expect(page).not_to have_content(a_new_comment.body)

        visit admin_auto_moderated_content_index_path

        expect(page).to have_content(comment.body)
        expect(page).to have_content(a_new_comment.body)

        within "#comment_#{a_new_comment.id}" do
          accept_confirm "Are you sure you want to show this comment again?" do
            click_link "Show again"
          end
        end

        click_link "Declined moderation"

        expect(page).to have_content(a_new_comment.body)
        another_offense.reload
        declined_at = I18n.l(another_offense.declined_at, format: :datetime)
        expect(page).to have_content("This comment has been moderated already on #{declined_at}")
        expect(page).to have_content("This comment has been moderated already")
        expect(page).not_to have_content(comment.body)
      end
    end
  end
end
