module Admin::WizardsHelper

  def wizard_path(name)
    case name
    when "installation"
      new_admin_wizards_installer_path
    when "verification"
      new_admin_wizards_verification_path
    end
  end

  def next_step_path(step)
    case step
    when "handlers"
      first_field_assignments_step
    when "remote_census"
      remote_census_next_field_assignments_step
    when "residents"
      residents_next_field_assignments_step
    else
      admin_wizards_verification_finish_path
    end
  end

  def back_step_path(step)
    case step
    when "remote_census"
      admin_wizards_verification_fields_path
    when "residents"
      residents_previous_field_assignments_step
    when "sms"
      sms_previous_field_assignments_step
    when "finish"
      finish_previous_field_assignments_step
    end
  end

  def first_field_assignments_step
    if Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_field_assignments_path(:remote_census)
    elsif Setting["custom_verification_process.residents"].present?
      admin_wizards_verification_field_assignments_path(:residents)
    elsif Setting["custom_verification_process.sms"].present?
      admin_wizards_verification_field_assignments_path(:sms)
    else
      admin_wizards_verification_finish_path
    end
  end

  def remote_census_next_field_assignments_step
    if Setting["custom_verification_process.residents"].present?
      admin_wizards_verification_field_assignments_path(:residents)
    elsif Setting["custom_verification_process.sms"].present?
      admin_wizards_verification_field_assignments_path(:sms)
    else
      admin_wizards_verification_finish_path
    end
  end

  def residents_next_field_assignments_step
    if Setting["custom_verification_process.sms"].present?
      return admin_wizards_verification_field_assignments_path(:sms)
    else
      admin_wizards_verification_finish_path
    end
  end

  def residents_previous_field_assignments_step
    if Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_field_assignments_path(:remote_census)
    else
      admin_wizards_verification_fields_path
    end
  end

  def sms_previous_field_assignments_step
    if Setting["custom_verification_process.residents"].present?
      admin_wizards_verification_field_assignments_path(:residents)
    elsif Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_field_assignments_path(:remote_census)
    else
      admin_wizards_verification_fields_path
    end
  end

  def finish_previous_field_assignments_step
    if Setting["custom_verification_process.sms"].present?
      admin_wizards_verification_field_assignments_path(:sms)
    elsif Setting["custom_verification_process.residents"].present?
      admin_wizards_verification_field_assignments_path(:residents)
    elsif Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_field_assignments_path(:remote_census)
    else
      admin_wizards_verification_fields_path
    end
  end

  def wrong_configuration?
    Setting["feature.custom_verification_process"].blank? ||
    Setting["feature.user.skip_verification"].present? ||
    Setting["feature.remote_census"].present?
  end

  def render_related_setting_table?(handler)
    remote_census_handler?(handler) || sms_handler?(handler)
  end

  def remote_census_handler?(handler)
    handler == "remote_census"
  end

  def sms_handler?(handler)
    handler == "sms"
  end

  def display_checkbox_link(field)
    unless field.checkbox?
      "display:none"
    end
  end

  def display_field_verification_options_section(field)
    unless field.selector?
      "display:none"
    end
  end

  def visible_value(field)
    field.visible.nil? ? true : field.visible?
  end
end
