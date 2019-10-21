require "rails_helper"

describe Verification::Handler do
  let!(:handler) do
    Class.new(Verification::Handler) do
      register_as :my_handler
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

  describe "#response" do
    subject { handler.new }

    it "is nil before calling verify method" do
      expect(subject.response).to be_blank
    end

    it "returns succesful response when handler does not implement verify method" do

      expect do
        subject.verify({})
      end.to change { subject.response }.from(nil).to(Verification::Handlers::Response)
      expect(subject.success?).to be true
      expect(subject.success).to be true
    end

    describe "when verify method is overriden by handler" do
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

      it "returns successful response when handler does implement verify method" do
        expect do
          subject.verify({ email: "user@email.com", email_cofirmation: "user@email.com" })
        end.to change { subject.response }.from(nil).to(Verification::Handlers::Response)
        expect(subject.success?).to be true
      end

      it "returns error response when handler does implement verify method" do
        expect do
          subject.verify({ email: "user@email.com", email_cofirmation: "user@email.net" })
        end.to change { subject.response }.from(nil).to(Verification::Handlers::Response)
        expect(subject.success?).to be false
      end
    end
  end

  describe "#success" do
    subject { handler.new }

    it { should respond_to(:success) }
  end
end
