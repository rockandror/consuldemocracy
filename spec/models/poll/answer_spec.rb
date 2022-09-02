require "rails_helper"

describe Poll::Answer do
  describe "validations" do
    let(:answer) { build(:poll_answer) }

    it "is valid" do
      expect(answer).to be_valid
    end

    it "is not valid wihout a question" do
      answer.question = nil
      expect(answer).not_to be_valid
    end

    it "is not valid without an author" do
      answer.author = nil
      expect(answer).not_to be_valid
    end

    it "is not valid without an answer" do
      answer.answer = nil
      expect(answer).not_to be_valid
    end

    it "is not valid when user already reached multiple answers question max votes" do
      user = create(:user)
      question = create(:poll_question_multiple)
      question.votation_type.update!(max_votes: 2)
      question_answers = create_list(:poll_question_answer, 3, question: question)
      question_answers[0..1].each do |question_answer|
        create(:poll_answer, author: user, question: question, answer: question_answer.title)
      end
      poll_answer = build(:poll_answer, author: user, question: question, answer: question_answers[2].title)

      expect(poll_answer).not_to be_valid
    end

    it "validates max votes when creating answers at the same time", :race_condition do
      author = create(:user, :level_two)
      question = create(:poll_question_multiple, :with_answers, with_answers_count: 3, max_votes: 2)
      create(:poll_answer, question: question, answer: "Answer A", author: author)
      answer = build(:poll_answer, question: question, answer: "Answer B", author: author)
      other_answer = build(:poll_answer, question: question, answer: "Answer C", author: author)

      [answer, other_answer].map do |a|
        Thread.new { a.save }
      end.each(&:join)

      expect(Poll::Answer.count).to be 2
    end

    it "is valid for answers included in the Poll::Question's question_answers list" do
      question = create(:poll_question)
      create(:poll_question_answer, title: "One", question: question)
      create(:poll_question_answer, title: "Two", question: question)
      create(:poll_question_answer, title: "Three", question: question)

      expect(build(:poll_answer, question: question, answer: "One")).to be_valid
      expect(build(:poll_answer, question: question, answer: "Two")).to be_valid
      expect(build(:poll_answer, question: question, answer: "Three")).to be_valid

      expect(build(:poll_answer, question: question, answer: "Four")).not_to be_valid
    end
  end

  describe "#save_and_record_voter_participation" do
    let(:author) { create(:user, :level_two) }
    let(:poll) { create(:poll) }
    let(:question) { create(:poll_question, :yes_no, poll: poll) }

    it "creates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")
      expect(answer.poll.voters).to be_blank

      answer.save_and_record_voter_participation
      expect(poll.reload.voters.size).to eq(1)
      voter = poll.voters.first

      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
      expect(voter.officer_id).to eq(nil)
    end

    it "updates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")
      answer.save_and_record_voter_participation

      expect(poll.reload.voters.size).to eq(1)

      answer = create(:poll_answer, question: question, author: author, answer: "No")
      answer.save_and_record_voter_participation

      expect(poll.reload.voters.size).to eq(1)

      voter = poll.voters.first
      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
    end

    it "does not save the answer if the voter is invalid" do
      allow_any_instance_of(Poll::Voter).to receive(:valid?).and_return(false)
      answer = build(:poll_answer)

      expect do
        answer.save_and_record_voter_participation
      end.to raise_error(ActiveRecord::RecordInvalid)

      expect(answer).not_to be_persisted
    end
  end

  describe "#prioritized_value" do
    it "returns prioritized answer value considering user prioritization and question max_votes" do
      user = create(:user)
      question = create(:poll_question_prioritized, :with_answers, with_answers_count: 4, max_votes: 4)
      question.question_answers.reverse.each_with_index do |question_answer, index|
        create(:poll_answer, question: question,
                             author: user,
                             order: index + 1,
                             answer: question_answer.title)
      end
      answer_d, answer_c, answer_b, answer_a = question.answers.order(:order)

      expect(answer_a.order).to eq(4)
      expect(answer_a.prioritized_value).to eq(1)

      expect(answer_b.order).to eq(3)
      expect(answer_b.prioritized_value).to eq(2)

      expect(answer_c.order).to eq(2)
      expect(answer_c.prioritized_value).to eq(3)

      expect(answer_d.order).to eq(1)
      expect(answer_d.prioritized_value).to eq(4)
    end
  end
end
