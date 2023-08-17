class Admin::Audits::IndexComponent < ApplicationComponent
  attr_reader :audits

  def initialize(audits:)
    @audits = audits
  end

  def empty_database?
    Audit.none?
  end

  def empty_search?
    audits.none? && params[:search].present?
  end

  def field_name(audit, field)
    audit.auditable_type.constantize.human_attribute_name(field)
  rescue NameError
    field
  end

  def join_value(value)
    return value.join(",") if value.is_a?(Array)

    return "" if value.blank?

    value.to_s
  end
end
