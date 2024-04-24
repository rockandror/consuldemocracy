class Admin::Audits::ShowComponent < ApplicationComponent
  attr_reader :audit

  use_helpers :audit_value, :field_name, :new_value, :old_value, :sanitize, :wysiwyg

  def initialize(audit)
    @audit = audit
  end
end
