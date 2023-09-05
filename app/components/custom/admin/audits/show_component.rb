class Admin::Audits::ShowComponent < ApplicationComponent
  attr_reader :audit

  delegate :audit_value, :field_name, :new_value, :old_value, :sanitize, :wysiwyg, to: :helpers

  def initialize(audit)
    @audit = audit
  end
end
