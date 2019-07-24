require "rails_helper"

describe Verification::Handler do
  let!(:handler) do
    Class.new(Verification::Handler) do
      register_as :my_handler
    end
  end

  describe ".register_as" do
    it "sets handler's id" do
      expect(handler.id).to eq(:my_handler)
    end

    it "add handlers to Verification::Configuration available_handlers" do
      expect(Verification::Configuration.available_handlers).to include(:my_handler)
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
end
