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
      Verification::Field.including_any_handlers(Verification::Configuration.ids).pluck(:handlers).flatten.uniq
    end

    def required_confirmation_handlers
      available_handlers.select{|_, handler| handler.requires_confirmation?}
    end

    def confirmation_fields
      condition = Proc.new {|handler| active_handlers.include?(handler) && handler.requires_confirmation?}
      handlers = available_handlers.select{condition}

      handlers.keys.each_with_object([]) do |handler, fields|
        handler_name = handler.downcase.underscore

        fields << "#{handler_name}_confirmation_code"
      end
    end
  end
end
Dir[Rails.root.join("app/models/verification/handlers/*.rb")].each {|file| require_dependency file }
