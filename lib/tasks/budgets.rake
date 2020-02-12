namespace :budgets do
  namespace :email do
    desc "Sends emails to authors of selected investments"
    task selected: :environment do
      Budget.last.email_selected
    end

    desc "Sends emails to authors of unselected investments"
    task unselected: :environment do
      Budget.last.email_unselected
    end
  end

  desc "Update existing budgets in drafting phase"
  task update_drafting_budgets: :environment do
    Budget.where(phase: "drafting").each do |budget|
      if budget.phases.enabled.first.present?
        next_enabled_phase = budget.phases.enabled.first.kind
      else
        next_enabled_phase = "informing"
        budget.phases.informing.update!(enabled: true)
      end
      budget.update!(phase: next_enabled_phase)
      budget.update!(published: false)
    end
  end
end
