require "rails_helper"

describe Verification::Handler do
  let!(:handler) do
    Class.new(Verification::Handler) do
      register_as :my_handler

      def verify(attributes = {})
        @response = Verification::Handlers::Response.new true,
                                                         "Verification process was successfully completed!",
                                                         attributes,
                                                         nil
      end
    end
  end

  describe ".register_as" do
    it "sets handler's id" do
      expect(handler.id).to eq("my_handler")
    end

    it "add handlers to Verification::Configuration available_handlers" do
      expect(Verification::Configuration.available_handlers).to include("my_handler")
    end
  end

  describe ".requires_confirmation?" do
    it "returns true when explicitly enabled at handler" do
      handler.class_eval do
        requires_confirmation true
      end

      expect(handler.requires_confirmation?).to eq(true)
    end

    it "returns false when not declared" do
      expect(handler.requires_confirmation?).to eq(false)
    end

    it "returns false when explicitly disabled at handler" do
      handler.class_eval do
        requires_confirmation false
      end

      expect(handler.requires_confirmation?).to eq(false)
    end
  end

  describe "#initialize" do
    before do
      Setting["custom_verification_process.my_handler"] = true
      phone_field = create(:verification_field, name: :phone)
      create(:verification_handler_field_assignment, handler: :my_handler, verification_field: phone_field)
      handler.class_eval do
        requires_confirmation true
      end
    end

    it "creates attributes dynamically from verification handler fields assignments definition" do
      instance = handler.new

      expect(instance).to respond_to "phone"
      expect(instance).to respond_to "phone="
      expect(instance).to respond_to "my_handler_confirmation_code"
      expect(instance).to respond_to "my_handler_confirmation_code="
    end
  end

  describe "#verify" do
    it "when does not implement verify method raise an exception" do
      handler_test_class = Class.new(Verification::Handler) do
        register_as :invalid_handler_definition
      end

      expect do
        handler_test_class.new.verify
      end.to raise_error(Verification::Handler::MissingMethodImplementation,
                         "You must implement the verify method!")
    end

    it "when does implement verify method should raise an exception" do
      handler_test_class = Class.new(Verification::Handler) do
        register_as :invalid_handler_definition

        def verify; end
      end

      expect do
        handler_test_class.new.verify
      end.not_to raise_error
    end
  end

  describe "#confirm" do
    it "when handler does requires a confirmation step and does not implement confirm method
        should raise an exception" do
      handler_test_class = Class.new(Verification::Handler) do
        register_as :invalid_handler_definition
        requires_confirmation true

        def verify; end
      end

      expect do
        handler_test_class.new.confirm
      end.to raise_error(Verification::Handler::MissingMethodImplementation,
                         "You must implement the confirm method!")
    end

    it "when handler does not requires a confirmation step should not raise an exception" do
      handler_test_class = Class.new(Verification::Handler) do
        register_as :invalid_handler_definition
        requires_confirmation false

        def verify; end
      end

      expect do
        handler_test_class.new.confirm
      end.not_to raise_error
    end

    it "when handler does requires a confirmation step and does implement confirm method
        should not raise an exception" do
      handler_test_class = Class.new(Verification::Handler) do
        register_as :invalid_handler_definition
        requires_confirmation true

        def verify; end
        def confirm; end
      end

      expect do
        handler_test_class.new.confirm
      end.not_to raise_error
    end
  end

  describe "#response" do
    subject { handler.new }

    before do
      handler.class_eval do
        def verify(params)
          if params[:email] == params[:email_cofirmation]
            @response = Verification::Handlers::Response.new(true, "success", params, {})
          else
            @response = Verification::Handlers::Response.new(false, "error", params, {})
          end
        end
      end
    end

    it "is nil before calling verify method" do
      expect(subject.response).to be_blank
    end

    it "returns error response when handler after call verify with correct verification information" do
      expect do
        subject.verify({ email: "user@email.com", email_cofirmation: "user@email.com" })
      end.to change { subject.response }.from(nil).to(Verification::Handlers::Response)
      expect(subject.success?).to be true
    end

    it "returns error response when handler after call verify with wrong verification information" do
      expect do
        subject.verify({ email: "user@email.com", email_cofirmation: "user@email.net" })
      end.to change { subject.response }.from(nil).to(Verification::Handlers::Response)
      expect(subject.success?).to be false
    end
  end

  describe "#success" do
    subject { handler.new }

    it { should respond_to(:success) }
    it { should respond_to(:success?) }
  end
end
