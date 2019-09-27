class Verification::Handler
  include ActiveModel::Model

  attr_accessor :response, :user
  delegate :success, to: :response, allow_nil: true
  alias :success? :success

  def initialize(attributes = {})
    define_verification_form_fields

    super
  end

  def verify(params)
    @response = if defined?(super)
                  super(params)
                else
                  build_response(params)
                end
  end

  class << self
    attr_reader :id

    def register_as(id = nil)
      @id = id.to_s
      Verification::Configuration.available_handlers[@id] = self
    end

    def requires_confirmation(value = true)
      @requires_confirmation = value
    end

    def requires_confirmation?
      @requires_confirmation == true
    end
  end

  private

    def build_response(params)
      Verification::Handlers::Response.new true, I18n.t("verification_handler_success"), params, nil
    end

    def define_verification_form_fields
      Verification::Field.all.select { |f| f.handlers.include?(self.class.id.to_s) }.pluck(:name).each do |attr|
        define_singleton_method attr do
          instance_variable_get "@#{attr}"
        end

        define_singleton_method "#{attr}=" do |arg|
          instance_variable_set "@#{attr}", arg
        end
      end
    end
end
Dir[Rails.root.join("app/models/verification/handlers/*.rb")].each {|file| require_dependency file }
