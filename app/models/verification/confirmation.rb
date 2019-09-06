class Verification::Confirmation
  include ActiveModel::Model
  attr_accessor :fields, :user

  validates :user, presence: true

  def initialize(attributes = {})
    @fields = define_confirmation_fields

    super
  end

  def save
    valid?
  end

  private

    # Defines confirmation fields for each enabled handler that requires a
    # confirmation code
    def define_confirmation_fields
      condition = Proc.new {|handler| active_handlers.include?(handler) && handler.requires_confirmation?}
      handlers = Verification::Handler.descendants.select{condition}

      handlers.each_with_object([]) do |handler, fields|
        handler_name = handler.name.split('::').last.downcase
        attr = "#{handler_name}_code"

        define_singleton_method attr do
          instance_variable_get "@#{attr}"
        end

        define_singleton_method "#{attr}=" do |arg|
          instance_variable_set "@#{attr}", arg
        end

        fields << attr
      end
    end

    # Return enabled handlers that requires confirmation code
    def active_handlers
      Verification::Field.all.where.not(handlers: [nil, ""]).pluck(:handlers).flatten.uniq
    end
end
