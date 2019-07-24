require "rails_helper"

describe Verification::Configuration do
  let(:handler) do
    Class.new(Verification::Handler) do
      register_as :my_handler
    end
  end

  describe ".available_handlers" do
    it "should return registered handlers" do
      expect(described_class.available_handlers).to include({ my_handler: handler })
    end
  end

  describe ".required_confirmation_handlers" do
    let(:without_confirmation_handler) do
      Class.new(Verification::Handler) do
        register_as :my_handler
      end
    end

    it "should return handlers which requires user confirmation" do
      handler.class_eval do
        requires_confirmation true
      end

      expect(described_class.required_confirmation_handlers).to include({ my_handler: handler })
      expect(described_class.required_confirmation_handlers).not_to include without_confirmation_handler
    end
  end
end
