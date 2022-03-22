class Legislation::Annotations::Exporter
  require "csv"

  def initialize(process)
    @process = process
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @process.draft_versions.each do |version|
        version.annotations.each do |annotation|
          annotation.comments.each { |comment| csv << csv_values(version, annotation, comment) }
        end
      end
    end
  end

  private

    def headers
      [
        I18n.t("admin.legislation.annotations.comments.export_list.id"),
        I18n.t("admin.legislation.annotations.comments.export_list.comment_text"),
        I18n.t("admin.legislation.annotations.comments.export_list.author"),
        I18n.t("admin.legislation.annotations.comments.export_list.draft_id"),
        I18n.t("admin.legislation.annotations.comments.export_list.draft_vesion"),
        I18n.t("admin.legislation.annotations.comments.export_list.annotation_id"),
        I18n.t("admin.legislation.annotations.comments.export_list.annotation_text")
      ]
    end

    def csv_values(version, annotation, comment)
      [
        comment.id.to_s,
        comment.body,
        comment.user.id,
        version.id,
        version.title,
        annotation.id,
        annotation.quote
      ]
    end
end
