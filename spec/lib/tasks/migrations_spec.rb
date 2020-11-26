require "rails_helper"

describe "Migration tasks" do
  describe "budget_phases_summary_to_description" do
    let(:run_rake_task) do
      Rake::Task["migrations:budget_phases_summary_to_description"].reenable
      Rake.application.invoke_task("migrations:budget_phases_summary_to_description")
    end

    it "appends the content of summary to the content of description" do
      budget = create(:budget)
      budget_phase = budget.phases.informing
      budget_phase.update!(
        description_en: "English description",
        description_es: "Spanish description",
        summary_en: "English summary")

      run_rake_task

      budget_phase.reload
      expect(budget_phase.description_en).to eq "English description<br>English summary"
      expect(budget_phase.description_es).to eq "Spanish description"
    end
  end
end
