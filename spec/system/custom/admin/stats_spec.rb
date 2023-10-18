require "rails_helper"

describe "Stats", :admin do
  context "Tags" do
    scenario "List all tags, most used first" do
      sport = create(:tag, name: "sport", taggables: [create(:proposal), create(:budget_investment)])
      health = create(:tag, name: "health", taggables: [create(:debate)])

      visit tags_admin_stats_path

      within "#tag_#{sport.id}" do
        expect(page).to have_content "sport"
        expect(page).to have_content "2"
      end
      within "#tag_#{health.id}" do
        expect(page).to have_content "health"
        expect(page).to have_content "1"
      end
      expect("sport").to appear_before("health")
    end
  end
end
