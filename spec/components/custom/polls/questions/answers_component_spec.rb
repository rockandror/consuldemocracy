require "rails_helper"

describe Polls::Questions::AnswersComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question_open, poll: poll) }
  let(:component) { Polls::Questions::AnswersComponent.new(question) }

  describe "open questions" do

    it "renders form to vote open question answers" do
      sign_in(create(:user, :verified))

      I18n.with_locale(:es) { render_inline component }

      expect(page).to have_button "Enviar"
      expect(page).not_to have_button "Enviado"
      expect(page).to have_css "textarea[id='open-answer-question-#{question.id}']"
    end

    it "renders custom button text when current user answers" do
      user = create(:user, :verified)
      create(:poll_answer, author: user, question: question, answer: "Yes")
      sign_in(user)

      I18n.with_locale(:es) { render_inline component }

      expect(page).not_to have_button "Enviar"
      expect(page).to have_button "Enviado"
    end

    it "when user is not signed in, renders submit button pointing to user sign in path" do
      I18n.with_locale(:es) { render_inline component }

      expect(page).to have_link "Enviar", href: new_user_session_path
    end

    it "when user is not verified, renders submit button pointing to user verification in path" do
      sign_in(create(:user))

      I18n.with_locale(:es) { render_inline component }

      expect(page).to have_link "Enviar", href: verification_path
    end

    it "when user already voted in booth it renders disabled answers" do
      user = create(:user, :level_two)
      create(:poll_voter, :from_booth, poll: poll, user: user)
      sign_in(user)

      I18n.with_locale(:es) { render_inline component }

      expect(page).to have_css "textarea[disabled='disabled']"
    end

    it "user cannot vote when poll expired it renders disabled form" do
      question = create(:poll_question_open, poll: create(:poll, :expired))
      sign_in(create(:user, :level_two))

      I18n.with_locale(:es) { render_inline Polls::Questions::AnswersComponent.new(question) }

      expect(page).to have_css "textarea[disabled='disabled']"
    end
  end
end
