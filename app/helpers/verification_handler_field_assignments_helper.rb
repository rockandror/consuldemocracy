module VerificationHandlerFieldAssignmentsHelper
  def title_for_fields_assignments_by(handler)
    t("admin.wizards.verification.handler.field_assignments.index.title.handlers.#{handler}")
  end

  def description_for_fields_assignments_by(handler)
    t("admin.wizards.verification.handler.field_assignments.index.description.handlers.#{handler}")
  end
end
