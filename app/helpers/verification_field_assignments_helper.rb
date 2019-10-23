module VerificationFieldAssignmentsHelper
  def title_for_fields_assignments_by(handler)
    t("admin.wizards.verification.handler.field_assignments.index.title.handlers.#{handler}")
  end

  def description_for_fields_assignments_by(handler)
    t("admin.wizards.verification.handler.field_assignments.index.description.handlers.#{handler}")
  end

  def verification_field_assignment_style(field_assignment)
    "display: none;" unless field_assignment&.verification_field&.date?
  end

  def options_for_verification_fields
    to_collect = lambda { |field| [field.name, field.id, data: { "field-kind": field.kind }] }

    Verification::Field.all.order(:position).collect(&to_collect)
  end
end
