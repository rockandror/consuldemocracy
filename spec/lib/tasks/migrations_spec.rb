require "rails_helper"

describe "Migration tasks" do
  describe "add_name_to_existing_budget_phases" do
    let(:run_rake_task) do
      Rake::Task["migrations:add_name_to_existing_budget_phases"].reenable
      Rake.application.invoke_task("migrations:add_name_to_existing_budget_phases")
    end

    it "adds the name to existing budget phases" do
      budget = create(:budget)
      informing_phase = budget.phases.informing
      accepting_pahse = budget.phases.accepting
      Budget::Phase::Translation.find_by(budget_phase_id: informing_phase.id).update_columns(name: "")
      expect(informing_phase.name).to eq ""
      expect(accepting_pahse.name).to eq "Accepting projects"

      run_rake_task

      expect(informing_phase.reload.name).to eq "Information"
      expect(accepting_pahse.reload.name).to eq "Accepting projects"
    end
  end

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
        name_es: "Spanish name",
        summary_en: "English summary")

      run_rake_task

      budget_phase.reload
      expect(budget_phase.description_en).to eq "English description<br>English summary"
      expect(budget_phase.description_es).to eq "Spanish description"
    end
  end
end
