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

    it "should return true when explicitly enabled at handler" do
      handler.class_eval do
        requires_confirmation true
      end

      expect(handler.requires_confirmation?).to eq(true)
    end

    it "should return false when not declared" do
      expect(handler.requires_confirmation?).to eq(false)
    end

    it "should return false when explicitly disabled at handler" do
      handler.class_eval do
        requires_confirmation false
      end

      expect(handler.requires_confirmation?).to eq(false)
    end
  end

  describe "#response" do
    subject { handler.new }

    it "should be nil before calling verify method" do
      expect(subject.response).to be_blank
    end

    it "should build a succesful as default response when handler does not implement
        verify method" do

      expect{ subject.verify({}) }.to change{ subject.response }.from(nil).to(Verification::Handlers::Response)
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

      it "should build a successful response when handler does implement verify method" do
        expect{ subject.verify({email: "user@email.com", email_cofirmation: "user@email.com"}) }.to change{ subject.response }.from(nil).to(Verification::Handlers::Response)
        expect(subject.success?).to be true
      end

      it "should build an error response when handler does implement verify method" do
        expect{ subject.verify({email: "user@email.com", email_cofirmation: "user@email.net"}) }.to change{ subject.response }.from(nil).to(Verification::Handlers::Response)
        expect(subject.success?).to be false
      end
    end
  end

  describe "#success" do
    subject { handler.new }

    it "Should return nil when no response defined" do
      expect(subject.success).to be_blank
    end
    it "Should return false when response is successful" do
      subject = Verification::Handlers::Response.new(true, "success")
      expect(subject.success).to be(true)
    end
    it "Should return false when response is error" do
      subject = Verification::Handlers::Response.new(false, "error")
      expect(subject.success).to be(false)
    end
  end
end
