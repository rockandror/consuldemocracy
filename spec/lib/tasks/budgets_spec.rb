require "rails_helper"

describe Budget do
  let(:run_update_drafting_budgets_task) do
    Rake::Task["budgets:update_drafting_budgets"].reenable
    Rake.application.invoke_task("budgets:update_drafting_budgets")
  end

  it "does not change anything if there are not budgets in draft mode" do
    budget = create(:budget)

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be true

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "accepting"
    expect(budget.published).to be true
  end

  it "changes the published attribut to false" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")

    expect(budget.published).to be true

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.published).to be false
  end

  it "changes the phase to the first enabled phase" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")
    budget.phases.informing.update!(enabled: false)

    expect(budget.phase).to eq "drafting"

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "accepting"
  end

  it "enables and select the informing phase if there are not any enabled phases" do
    budget = create(:budget)
    budget.update_columns(phase: "drafting")
    budget.phases.each { |phase| phase.update!(enabled: false) }

    expect(budget.phase).to eq "drafting"

    run_update_drafting_budgets_task
    budget.reload

    expect(budget.phase).to eq "informing"
    expect(budget.phases.informing.enabled).to be true
  end
end
