require 'rails_helper'

describe "Translations migrations" do
  it_behaves_like "hidden translations", :banner
  it_behaves_like "hidden translations", :legislation_draft_version
  it_behaves_like "hidden translations", :legislation_process
  it_behaves_like "hidden translations", :legislation_question_option
  it_behaves_like "hidden translations", :legislation_question
  it_behaves_like "hidden translations", :poll
  it_behaves_like "hidden translations", :poll_question
end
