# coding: utf-8
require 'rails_helper'

feature 'Debates' do

  scenario 'Disabled with a feature flag' do
    skip("all")
    Setting['feature.debates'] = nil
    expect{ visit debates_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    Setting['feature.debates'] = true
  end

  context "Concerns" do
    # it_behaves_like 'notifiable in-app', Debate
    # it_behaves_like 'relationable', Debate
    it_behaves_like 'remotely_translatable',
                    :debate,
                    'debates_path',
                    {}
    it_behaves_like 'remotely_translatable',
                    :debate,
                    'debate_path',
                    { 'id': 'id' }
    # context "Translatable at front end" do
    #   before do
    #     Setting['feature.translation_interface'] = true
    #   end
    #
    #   it_behaves_like 'translatable',
    #                   'debate',
    #                   'edit_debate_path',
    #                   %w[title],
    #                   { 'description' => :ckeditor }
    # end
  end

end
