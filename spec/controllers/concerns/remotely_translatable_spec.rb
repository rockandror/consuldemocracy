require 'rails_helper'

describe RemotelyTranslatable do

  class FakeController < ActionController::Base; end

  controller(FakeController) do
    include RemotelyTranslatable

    def index
      detect_remote_translations([Proposal.first])
      render text: "Fake text"
    end
  end

  before do
    Setting["feature.remote_translations"] = true
  end

  it "has remote_translations filled when resource has not tanslation" do
    Globalize.with_locale(:es) { create(:proposal) }

    get :index

    expect(assigns(:remote_translations).count).to eq 1
  end

  it "has remote_translations empty when resource has tanslation" do
    create(:proposal)

    get :index

    expect(assigns(:remote_translations)).to eq []
  end

end
