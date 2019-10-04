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
      return admin_wizards_verification_handler_field_assignments_path(:remote_census) if Setting["custom_verification_process.census_soap"].present?
      return admin_wizards_verification_handler_field_assignments_path(:resident) if Setting["custom_verification_process.census_local"].present?
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
      admin_wizards_verification_handlers_path
    when "remote_census"
      return admin_wizards_verification_handler_field_assignments_path(:resident) if Setting["custom_verification_process.census_local"].present?
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
       admin_wizards_verification_finish_path
    when "resident"
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
    when "resident"
      return admin_wizards_verification_handler_field_assignments_path(:remote_census)  if  Setting["custom_verification_process.census_soap"].present?
      admin_wizards_verification_handlers_path
    when "sms"
      return admin_wizards_verification_handler_field_assignments_path(:resident) if Setting["custom_verification_process.census_local"].present?
      return admin_wizards_verification_handler_field_assignments_path(:remote_census)  if  Setting["custom_verification_process.census_soap"].present?
      admin_wizards_verification_handlers_path
    when "finish"
      return admin_wizards_verification_handler_field_assignments_path(:sms) if Setting["custom_verification_process.sms"].present?
      return admin_wizards_verification_handler_field_assignments_path(:resident) if Setting["custom_verification_process.census_local"].present?
      return admin_wizards_verification_handler_field_assignments_path(:remote_census) if Setting["custom_verification_process.census_soap"].present?
      admin_wizards_verification_handlers_path
    end
  end

  def wrong_configuration
    !Setting["feature.custom_verification_process"].present? || Setting["feature.user.skip_verification"].present?
  end

  def remote_census_handler?(handler)
    handler == "remote_census"
  end

  def sms_handler?(handler)
    handler == "sms"
  end

end
