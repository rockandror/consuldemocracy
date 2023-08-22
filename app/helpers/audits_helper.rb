module AuditsHelper
  def truncate_audit_value(value)
    truncate(audit_value(value), length: 50)
  end

  def audit_value(value)
    return value.join(",") if value.is_a?(Array)

    return "" if value.blank?

    value.to_s
  end

  def field_name(audit, field)
    audit.auditable_type.constantize.human_attribute_name(field)
  rescue NameError
    field
  end
end
