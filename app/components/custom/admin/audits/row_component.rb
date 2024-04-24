class Admin::Audits::RowComponent < ApplicationComponent
  with_collection_parameter :audit
  attr_reader :audit

  use_helpers :field_name, :audit_value, :new_value, :old_value

  def initialize(audit:)
    @audit = audit
  end
end
