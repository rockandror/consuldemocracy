require_dependency Rails.root.join("app", "models", "legislation", "process").to_s

class Legislation::Process
  scope :for_render, -> { includes(:tags) }

  def after_hide
    tags.each { |t| t.decrement_custom_counter_for("Legislation::Process") }
  end

  def after_restore
    tags.each { |t| t.increment_custom_counter_for("Legislation::Process") }
  end
end
