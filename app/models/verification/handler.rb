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

  module InstanceDSLMethods
    attr_accessor :response
    delegate :success, to: :response, allow_nil: true
    alias :success? :success

    def verify(params)
      @response = if defined?(super)
                    super(params)
                  else
                    build_response(params)
                  end
    end

    private

      def build_response(params)
        Verification::Handlers::Response.new true, I18n.t("verification_handler_success"), params, nil
      end
  end

  def self.inherited(receiver)
    receiver.extend(ClassDSLMethods)
    receiver.include(InstanceDSLMethods)
  end
end
