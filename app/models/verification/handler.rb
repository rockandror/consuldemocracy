class Verification::Handler
  module ClassDSLMethods
    attr_reader :id

    def register_as(id = nil)
      @id = id.to_sym
      Verification::Configuration.available_handlers[@id] = self
    end

    def requires_confirmation(value = false)
      @requires_confirmation = value
    end

    def requires_confirmation?
      @requires_confirmation == true
    end
  end

  def self.inherited(receiver)
    receiver.extend(ClassDSLMethods)
  end
end
