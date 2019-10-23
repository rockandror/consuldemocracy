module VerificationHandlerFieldAssignmentsHelper
  def title_for_fields_assignments_by(handler)
    t("admin.wizards.verification.handler.field_assignments.index.title.handlers.#{handler}")
  end

  def description_for_fields_assignments_by(handler)
    t("admin.wizards.verification.handler.field_assignments.index.description.handlers.#{handler}")
  end

  def verification_field_assignment_style(field_assignment)
    "display: none;" unless field_assignment&.verification_field&.date?
  end

  def options_for_verification_handler_field_assigment_verification_field
    Verification::Field.all.order(:position).collect{|field| [field.name, field.id, data: { "field-kind": field.kind }]}
  end
end
