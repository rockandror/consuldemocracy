class Legislation::Answers::Exporter
  require "csv"

  def initialize(process)
    @process = process
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @process.questions.each do |question|
        question.comments.each { |comment| csv << csv_values(question, comment) }
        answers = get_answers(question)
        answers.each { |answer| csv << answers_csv_values(answer) }
      end
    end
  end

  private

    def get_answers(question)
      Legislation::Answer.where(question: question)
    end

    def headers
      [
        I18n.t("admin.legislation.answers.export_list.id"),
        I18n.t("admin.legislation.answers.export_list.type"),
        I18n.t("admin.legislation.answers.export_list.legislation_question_id"),
        I18n.t("admin.legislation.answers.export_list.legislation_question_text"),
        I18n.t("admin.legislation.answers.export_list.legislation_question_comment_text"),
        I18n.t("admin.legislation.answers.export_list.author")
      ]
    end

    def answers_csv_values(answer)
      [
        answer.id,
        "Opcional",
        answer.question.id,
        answer.question.title,
        answer.question_option.value,
        answer.user.id
      ]
    end

    def csv_values(question, comment)
      [
        comment.id.to_s,
        "Libre",
        question.id,
        question.title,
        comment.body,
        comment.user.id
      ]
    end
end
