module Polls
  def vote_for_poll_via_web(poll, question, answer)
    visit poll_path(poll)

    within("#poll_question_#{question.id}_answers") do
      click_button answer

      if question.unique? || question.votation_type.blank?
        expect(page).to have_css("span.answered", text: answer)
        expect(page).not_to have_button(answer)
      else
        expect(page).to have_button("You have voted #{answer}")
        expect(page).to have_selector("a.button.answered.expand", text: answer.to_s)
      end
    end
  end

  def vote_for_poll_via_booth
    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content poll.name

    first(:button, "Confirm vote").click
    expect(page).to have_content "Vote introduced!"

    expect(Poll::Voter.count).to eq(1)
  end

  def confirm_phone(user = nil)
    user ||= User.last

    fill_in "sms_phone", with: "611111111"
    click_button "Send"

    expect(page).to have_content "Enter the confirmation code sent to you by text message"

    fill_in "sms_confirmation_code", with: user.reload.sms_confirmation_code
    click_button "Send"

    expect(page).to have_content "Code correct"
  end
end
