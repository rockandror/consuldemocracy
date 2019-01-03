require 'rails_helper'

describe RemotelyTranslatable do

  class FakeController < ApplicationController; end

  controller(FakeController) do
    include RemotelyTranslatable

    skip_authorization_check

    def index
      detect_remote_translations([Proposal.first])
      render text: "Fake text"
    end
  end

  before do
    Setting["feature.remote_translations"] = true
  end

  it "Should detect remote_translations when not defined in request locale" do
    create(:proposal)

    get :index, locale: :es

    expect(assigns(:remote_translations).count).to eq 1
  end

  it "Should not detect remote_translations when defined in request locale" do
    create(:proposal)

    get :index

    expect(assigns(:remote_translations)).to eq []
  end

end
