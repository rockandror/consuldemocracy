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
      return admin_wizards_verification_handler_field_assignments_path(:remote_census) if Setting["custom_verification_process.remote_census"].present?
      return admin_wizards_verification_handler_field_assignments_path(:residents) if Setting["custom_verification_process.residents"].present?
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
      admin_wizards_verification_finish_path
    when "remote_census"
      return admin_wizards_verification_handler_field_assignments_path(:residents) if Setting["custom_verification_process.residents"].present?
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
       admin_wizards_verification_finish_path
    when "residents"
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
       admin_wizards_verification_finish_path
    when "sms"
       admin_wizards_verification_finish_path
    end
  end

  def back_step_path(step)
    case step
    when "remote_census"
      admin_wizards_verification_handlers_path
    when "residents"
      return admin_wizards_verification_handler_field_assignments_path(:remote_census)  if  Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_handlers_path
    when "sms"
      return admin_wizards_verification_handler_field_assignments_path(:residents) if Setting["custom_verification_process.residents"].present?
      return admin_wizards_verification_handler_field_assignments_path(:remote_census)  if  Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_handlers_path
    when "finish"
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
      return admin_wizards_verification_handler_field_assignments_path(:residents) if Setting["custom_verification_process.residents"].present?
      return admin_wizards_verification_handler_field_assignments_path(:remote_census) if Setting["custom_verification_process.remote_census"].present?
      admin_wizards_verification_handlers_path
    end
  end

  def wrong_configuration?
    !Setting["feature.custom_verification_process"].present? || Setting["feature.user.skip_verification"].present? || Setting["feature.remote_census"].present?
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

end
