require "rails_helper"

describe "Stats" do

  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  context "Load" do

    before { budget.update(slug: "budget_slug", phase: "finished", stats_enabled: true) }

    scenario "finds budget by slug" do
      visit budget_stats_path("budget_slug")

      expect(page).to have_content budget.name
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_stats_path("wrong_budget")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_stats_path(0)
      end.to raise_error ActiveRecord::RecordNotFound
    end

  end

  describe "Show" do
    describe "advanced stats" do
      let(:budget) { create(:budget, :finished) }

      scenario "advanced stats enabled" do
        budget.update(advanced_stats_enabled: true)

        visit budget_stats_path(budget)

        expect(page).to have_content "Advanced statistics"
      end

      scenario "advanced stats disabled" do
        visit budget_stats_path(budget)

        expect(page).not_to have_content "Advanced statistics"
      end
    end

    context "headings" do

      scenario "Displays headings ordered by name with city heading first" do
        allow_any_instance_of(Budget::Heading).to receive(:city_heading?) do |heading|
          heading.name == "City of New York"
        end

        budget.update(phase: "finished", stats_enabled: true, advanced_stats_enabled: true)

        city_group = create(:budget_group, budget: budget)
        district_group = create(:budget_group, budget: budget)

        create(:budget_heading, group: district_group, name: "Brooklyn")
        create(:budget_heading, group: district_group, name: "Queens")
        create(:budget_heading, group: district_group, name: "Manhattan")

        create(:budget_heading, group: city_group, name: "City of New York")

        visit budget_stats_path(budget)

        within("#headings") do
          expect("City of New York").to appear_before("Brooklyn")
          expect("Brooklyn").to appear_before("Manhattan")
          expect("Manhattan").to appear_before("Queens")
        end
      end
    end

  end
end
