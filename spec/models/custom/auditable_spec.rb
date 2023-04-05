require "rails_helper"

describe "Auditable" do
  describe ".auditing_enabled" do
    it "responds true to classes we want to keep track of changes" do
      ApplicationRecord.audited_class_names.sample do |model|
        expect(model.constantize.auditing_enabled).to be(true)
      end
    end

    it "responds false to classes we do not want to keep track of changes" do
      expect(ApplicationRecord.auditing_enabled).to be(false)
      expect(Administrator.auditing_enabled).to be(false)
      expect(Globalize::ActiveRecord::Translation.auditing_enabled).to be(false)
      expect(Visit.auditing_enabled).to be(false)
    end

    it "responds true to translation classes when globalized_model has enabled auditing" do
      expect(Proposal::Translation.auditing_enabled).to be(true)
      expect(Budget::Translation.auditing_enabled).to be(true)
      expect(Debate::Translation.auditing_enabled).to be(true)
    end

    it "responds false to translation classes when globalized_model has disabled auditing" do
      expect(Proposal::Translation.auditing_enabled).to be(true)

      allow(Proposal).to receive(:audited_class_names).and_return([])

      expect(Proposal::Translation.auditing_enabled).to be(false)
    end
  end

  describe ".audited_columns" do
    context "on globalize translation classes" do
      it "returns the globalized model translatable attributes and the foreign key" do
        audited_columns = %w[proposal_id title description summary retired_explanation]

        expect(Proposal::Translation.audited_columns).to include(*audited_columns)

        ignored_attributes = %w[hidden_at locale]

        expect(Proposal::Translation.audited_columns).not_to include(*ignored_attributes)
        expect(Debate::Translation.audited_columns).not_to include(*ignored_attributes)
        expect(Banner::Translation.audited_columns).not_to include(*ignored_attributes)
        expect(Budget::Investment::Translation.audited_columns).not_to include(*ignored_attributes)
      end
    end

    context "on application record subclasses" do
      it "returns all the columns but the translations" do
        proposal_columns = %w[author_id hidden_at flags_count ignored_flag_at cached_votes_up comments_count
          tsv geozone_id retired_at retired_reason community_id published_at selected]

        expect(Proposal.audited_columns).to include(*proposal_columns)
        expect(Proposal.audited_columns).not_to include(*Proposal.translated_attribute_names)
      end
    end
  end

  describe "on auditable create" do
    it "does not keep track of changes" do
      expect { create(:proposal) }.not_to change { Audit.count }
      expect { create(:debate) }.not_to change { Audit.count }
      expect { create(:poll) }.not_to change { Audit.count }
      expect { create(:widget_card) }.not_to change { Audit.count }
    end
  end

  describe "on auditable destroy" do
    context "when auditable has translations" do
      it "keeps track of model and translation" do
        proposal = create(:proposal)

        expect { proposal.destroy! }.to change { Audit.count }.by(2)
      end
    end

    context "when auditable does not have translations" do
      it "keeps track of model" do
        setting = create(:setting)

        expect { setting.destroy! }.to change { Audit.count }.by(1)
      end
    end
  end

  describe "on auditable update" do
    it "keeps track of resources and theirs translations from auditing enabled classes" do
      investment = create(:budget_investment)

      expect { investment.update!(title: "Updated title") }.to change { Audit.count }.by(1)
    end

    it "keeps track of resources translatable fields but ignores excluded columns" do
      translation = create(:budget_investment).translation

      expect { translation.update!(title: "Updated title") }.to change { Audit.count }.by(1)
      expect { translation.update!(hidden_at: Time.current, locale: "es") }.not_to change { Audit.count }
    end

    it "translation related audits are associated with the globalized model instance" do
      translation = create(:budget_investment).translation

      expect { translation.update!(title: "Updated title") }.to change { Audit.count }.by(1)
      expect(Audit.last.associated).to eq(translation.globalized_model)
    end

    it "does not keep track of explicitly excluded fields" do
      user = create(:user)

      expect(User.audited_columns).not_to be_empty
      expect(User.audited_columns).not_to include(*%w[sign_in_count last_sign_in_at current_sign_in_at])
      expect { user.update!(sign_in_count: 2) }.not_to change { Audit.count }
    end

    it "does not keep track of resources from auditing disabled classes" do
      allow(Budget::Investment).to receive(:auditing_enabled).and_return(false)
      investment = create(:budget_investment)

      expect { investment.update!(title: "Updated title") }.not_to change { Audit.count }

      visit = create(:visit)

      expect { visit.update!(user_agent: "firefox") }.not_to change { Audit.count }
    end
  end
end
