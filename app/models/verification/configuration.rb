class Verification::Configuration
  def self.available_handlers
    @@available_handlers ||= {}
  end

  def self.ids
    available_handlers.keys.map(&:to_s)
  end

  def self.required_confirmation_handlers
    @@available_handlers.select{|_, handler| handler.requires_confirmation?}
  end
end
Dir[Rails.root.join("app/models/verification/handlers/*.rb")].each {|file| require_dependency file }
