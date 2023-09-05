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

  def old_value(audit, changes)
    if audit.action == "create"
      ""
    elsif audit.action == "update"
      changes&.first
    else
      changes
    end
  end

  def new_value(audit, changes)
    if audit.action == "create"
      changes
    elsif audit.action == "update"
      changes&.last
    else
      ""
    end
  end
end
