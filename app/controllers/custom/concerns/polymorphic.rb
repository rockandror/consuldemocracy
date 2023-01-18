require_dependency Rails.root.join("app", "controllers", "concerns", "polymorphic").to_s

module Polymorphic
  private

    def resource
      if resource_model.to_s == "Budget::Investment"
        @resource ||= instance_variable_get("@investment")
      elsif resource_model.to_s == "Legislation::Proposal"
        @resource ||= instance_variable_get("@proposal")
      elsif resource_model.to_s == "Legislation::Process"
        @resource ||= instance_variable_get("@process")
      else
        @resource ||= instance_variable_get("@#{resource_name}")
      end
    end
end
