class Verification::Configuration

  class << self
    def available_handlers
      Verification::Handler.descendants.each_with_object({}) do |handler, hash|
        hash[handler.id] = handler
      end
    end

    def ids
      available_handlers.keys.map(&:to_s)
    end

    def active_handlers
      Verification::Handler::FieldAssignment.where(handler: Verification::Configuration.ids).pluck(:handler).uniq
    end

    def required_confirmation_handlers
      available_handlers.select{|_, handler| handler.requires_confirmation?}
    end

    def confirmation_fields
      handlers = available_handlers.select{ |id, handler| active_handlers.include?(id) && handler.requires_confirmation? }

      handlers.keys.each_with_object([]) do |handler, fields|
        handler_name = handler.downcase.underscore

        fields << "#{handler_name}_confirmation_code"
      end
    end
  end
end
Dir[Rails.root.join("app/models/verification/handlers/*.rb")].each {|file| require_dependency file }
