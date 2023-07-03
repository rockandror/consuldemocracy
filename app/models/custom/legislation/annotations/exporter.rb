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
        I18n.t("admin.legislation.annotations.comments.export_list.draft_id"),
        I18n.t("admin.legislation.annotations.comments.export_list.draft_vesion"),
        I18n.t("admin.legislation.annotations.comments.export_list.annotation_id"),
        I18n.t("admin.legislation.annotations.comments.export_list.annotation_text"),
        I18n.t("admin.legislation.annotations.comments.export_list.author_id"),
        I18n.t("admin.legislation.annotations.comments.export_list.author_date_of_birth"),
        I18n.t("admin.legislation.annotations.comments.export_list.author_location"),
        I18n.t("admin.legislation.annotations.comments.export_list.author_gender")
      ]
    end

    def csv_values(version, annotation, comment)
      [
        comment.id.to_s,
        comment.body,
        version.id,
        version.title,
        annotation.id,
        annotation.quote,
        comment.user.id,
        comment.user.date_of_birth,
        get_location(comment.user.location),
        get_gender(comment.user.gender)
      ]
    end

    def get_gender(gender_key)
      if gender_key
        return I18n.t("activemodel.models.user.gender.#{gender_key}")
      else
        return ""
      end
    end

    def get_location(location_key)
      if location_key
        return I18n.t("activemodel.models.user.locations.values.#{location_key}")
      else
        return ""
      end
    end
end
