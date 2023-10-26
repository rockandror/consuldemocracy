class Poll::Exporter
    require "csv"

    def initialize(poll_answers = [])
      @answers = poll_answers
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << headers
        @answers.each { |answer| csv << csv_values(answer) }
      end
    end

    private

      def headers
        [
          I18n.t("admin.polls.results.export_list.id"),
          I18n.t("admin.polls.results.export_list.question_id"),
          I18n.t("admin.polls.results.export_list.answer"),
          I18n.t("admin.polls.results.export_list.author_id")
        ]
      end

      def csv_values(answer)
        [
          answer.id.to_s,
          answer.question_id.to_s,
          answer.answer,
          answer.author_id.to_s
        ]
      end
  end
