require "rails_helper"

describe "Admin budgets", :admin do
  it_behaves_like "nested imageable",
                  "budget",
                  "new_admin_budget_path",
                  {},
                  "imageable_fill_new_valid_budget",
                  "Create Budget",
                  "New participatory budget created successfully!"

  context "Load" do
    before { create(:budget, slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit edit_admin_budget_path("budget_slug")

      expect(page).to have_content("Edit Participatory budget")
    end
  end

  context "Index" do
    scenario "Displaying no open budgets text" do
      visit admin_budgets_path

      expect(page).to have_content("There are no budgets.")
    end

    scenario "Displaying budgets" do
      budget = create(:budget, :accepting)
      visit admin_budgets_path

      expect(page).to have_content budget.name
      expect(page).to have_content "Accepting projects"
    end

    scenario "Filters by phase" do
      create(:budget, :drafting, name: "Unpublished budget")
      create(:budget, :accepting, name: "Accepting budget")
      create(:budget, :selecting, name: "Selecting budget")
      create(:budget, :balloting, name: "Balloting budget")
      create(:budget, :finished, name: "Finished budget")

      visit admin_budgets_path

      expect(page).to have_content "Accepting budget"
      expect(page).to have_content "Selecting budget"
      expect(page).to have_content "Balloting budget"

      within "tr", text: "Unpublished budget" do
        expect(page).to have_content "Draft"
      end

      within "tr", text: "Finished budget" do
        expect(page).to have_content "COMPLETED"
      end

      click_link "Finished"

      expect(page).not_to have_content "Unpublished budget"
      expect(page).not_to have_content "Accepting budget"
      expect(page).not_to have_content "Selecting budget"
      expect(page).not_to have_content "Balloting budget"
      expect(page).to have_content "Finished budget"

      click_link "Open"

      expect(page).to have_content "Unpublished budget"
      expect(page).to have_content "Accepting budget"
      expect(page).to have_content "Selecting budget"
      expect(page).to have_content "Balloting budget"
      expect(page).not_to have_content "Finished budget"
    end

    scenario "Filters are properly highlighted" do
      filters_links = { "all" => "All", "open" => "Open", "finished" => "Finished" }

      visit admin_budgets_path

      expect(page).not_to have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each do |current_filter, link|
        visit admin_budgets_path(filter: current_filter)

        expect(page).not_to have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

    scenario "Delete budget from index", :js do
      budget = create(:budget)
      visit admin_budgets_path

      within "#budget_#{budget.id}" do
        click_link "Delete budget"
      end

      page.driver.browser.switch_to.alert do
        expect(page).to have_content "Are you sure? This action will delete the budget '#{budget.name}' "\
                                     "and can't be undone."
      end

      accept_confirm

      expect(page).to have_content("Budget deleted successfully")
      expect(page).to have_content("There are no budgets.")
      expect(page).not_to have_content budget.name
    end
  end

  context "New" do
    scenario "Create budget - Knapsack voting (default)" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create single heading budget"

      fill_in "Name", with: "M30 - Summer campaign"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      visit admin_budgets_path
      click_link "Edit budget"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Knapsack"
    end

    scenario "Create budget - Approval voting" do
      admin = Administrator.first

      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create single heading budget"

      fill_in "Name", with: "M30 - Summer campaign"
      select "Approval", from: "Final voting style"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"

      visit admin_budgets_path
      click_link "Edit budget"

      expect(page).to have_field "Name", with: "M30 - Summer campaign"
      expect(page).to have_select "Final voting style", selected: "Approval"

      click_link "Select administrators"

      expect(page).to have_field admin.name
    end

    scenario "Name is mandatory" do
      visit new_admin_budget_path
      click_button "Continue to groups"

      expect(page).not_to have_content "New participatory budget created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Name")
    end

    scenario "Name should be unique" do
      create(:budget, name: "Existing Name")

      visit new_admin_budget_path
      fill_in "Name", with: "Existing Name"
      click_button "Continue to groups"

      expect(page).not_to have_content "New participatory budget created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
    end

    scenario "Do not show results and stats settings on new budget" do
      visit new_admin_budget_path

      expect(page).not_to have_content "Show results and stats"
      expect(page).not_to have_field "Show results"
      expect(page).not_to have_field "Show stats"
      expect(page).not_to have_field "Show advanced stats"
    end
  end

  context "Create" do
    scenario "A new budget is always created in draft mode" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"

      click_button "Continue to groups"
      expect(page).to have_content "New participatory budget created successfully!"

      visit admin_budget_path(Budget.last)
      expect(page).to have_content "This participatory budget is in draft mode"
      expect(page).to have_link "Preview budget"
      expect(page).to have_link "Publish budget"
    end
  end

  context "Publish" do
    let(:budget) { create(:budget, :drafting) }

    scenario "Can preview budget before it is published" do
      visit edit_admin_budget_path(budget)

      within_window(window_opened_by { click_link "Preview budget" }) do
        expect(page).to have_current_path budget_path(budget)
      end
    end

    scenario "Can preview a budget after it is published" do
      visit edit_admin_budget_path(budget)

      accept_confirm { click_link "Publish budget" }

      expect(page).to have_content "Participatory budget published successfully"
      expect(page).not_to have_content "This participatory budget is in draft mode"
      expect(page).not_to have_link "Publish budget"

      within_window(window_opened_by { click_link "Preview budget" }) do
        expect(page).to have_current_path budget_path(budget)
      end
    end
  end

  context "Destroy" do
    let!(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, budget: budget) }

    scenario "Destroy a budget without investments" do
      visit admin_budgets_path
      click_link "Edit budget"

      accept_confirm { click_link "Delete budget" }

      expect(page).to have_content("Budget deleted successfully")
      expect(page).to have_content("There are no budgets.")
    end

    scenario "Destroy a budget without investments but with administrators and valuators" do
      budget.administrators << Administrator.first
      budget.valuators << create(:valuator)

      visit admin_budgets_path
      click_link "Edit budget"
      click_link "Delete budget"

      expect(page).to have_content "Budget deleted successfully"
      expect(page).to have_content "There are no budgets."
    end

    scenario "Try to destroy a budget with investments" do
      create(:budget_investment, heading: heading)

      visit admin_budgets_path
      click_link "Edit budget"

      accept_confirm { click_link "Delete budget" }

      expect(page).to have_content("You cannot delete a budget that has associated investments")
      expect(page).to have_content("There is 1 budget")
    end

    scenario "Try to destroy a budget with polls" do
      create(:poll, budget: budget)

      visit edit_admin_budget_path(budget)
      click_link "Delete budget"

      expect(page).to have_content("You cannot delete a budget that has an associated poll")
      expect(page).to have_content("There is 1 budget")
    end
  end

  context "Edit" do
    let(:budget) { create(:budget) }

    scenario "Show phases table" do
      travel_to(Date.new(2015, 7, 15)) do
        budget.update!(phase: "selecting")
        budget.phases.valuating.update!(enabled: false)

        visit edit_admin_budget_path(budget)

        expect(page).to have_select "Phase", selected: "Selecting projects"

        expect(page).to have_table "Phases", with_cols: [
          [
            "Information",
            "Accepting projects",
            "Reviewing projects",
            "Selecting projects Active",
            "Valuating projects",
            "Publishing projects prices",
            "Voting projects",
            "Reviewing voting"
          ],
          [
            "2015-07-15 00:00 - 2015-08-14 23:59",
            "2015-08-15 00:00 - 2015-09-14 23:59",
            "2015-09-15 00:00 - 2015-10-14 23:59",
            "2015-10-15 00:00 - 2015-11-14 23:59",
            "2015-11-15 00:00 - 2015-12-14 23:59",
            "2015-11-15 00:00 - 2016-01-14 23:59",
            "2016-01-15 00:00 - 2016-02-14 23:59",
            "2016-02-15 00:00 - 2016-03-14 23:59"
          ],
          [
            "Yes",
            "Yes",
            "Yes",
            "Yes",
            "No",
            "Yes",
            "Yes",
            "Yes"
          ]
        ]

        within_table "Phases" do
          within "tr", text: "Information" do
            expect(page).to have_link "Edit content"
          end
        end
      end
    end

    scenario "Show results and stats settings" do
      visit edit_admin_budget_path(budget)

      within_fieldset "Show results and stats" do
        expect(page).to have_field "Show results"
        expect(page).to have_field "Show stats"
        expect(page).to have_field "Show advanced stats"
      end
    end

    scenario "Show groups and headings settings" do
      visit edit_admin_budget_path(budget)

      expect(page).to have_content "GROUPS AND HEADINGS SETTINGS"
      expect(page).to have_link "Add group"
      expect(page).to have_link("Add heading", count: budget.groups.count)

      budget.groups.each do |group|
        expect(page).to have_content group.name
        expect(page).to have_content "Maximum number of headings in which a user can "\
                                     "vote #{group.max_votable_headings}"
        expect(page).to have_link "Edit group #{group.name}"
        expect(page).to have_link "Delete group #{group.name}"

        group.headings.each do |heading|
          expect(page).to have_content heading.name
          expect(page).to have_link "Edit heading #{heading.name}"
          expect(page).to have_link "Delete heading #{heading.name}"
        end
      end
    end

    scenario "Add group from edit view" do
      visit edit_admin_budget_path(budget)

      click_link "Add group"

      fill_in "Group name", with: "New group"
      click_button "Create new group"

      visit edit_admin_budget_path(budget)
      expect(page).to have_content "New group"
    end

    scenario "Add heading from edit view" do
      visit edit_admin_budget_path(budget)

      budget.groups.each do |group|
        within "#group_#{group.id}" do
          click_link "Add heading"

          fill_in "Heading name", with: "New heading for #{group.name}"
          fill_in "Money amount", with: "1000"
          click_button "Create new heading"
        end

        expect(page).to have_content "New heading for #{group.name}"
        expect(page).to have_content("€1,000", count: budget.groups.count)
      end
    end

    scenario "Show the number of votes allowed on approval style budgets" do
      visit edit_admin_budget_path(budget)

      budget.groups.each do |group|
        group.headings.each do |heading|
          expect(page).not_to have_content "Votes allowed"
          expect(page).not_to have_content "1"
        end
      end

      budget.update!(voting_style: "approval")

      budget.groups.each do |group|
        group.headings.each do |heading|
          expect(page).to have_content "Votes allowed"
          expect(page).to have_content "1"
        end
      end
    end

    scenario "Show CTA link in public site if added" do
      visit edit_admin_budget_path(budget)
      expect(page).to have_content("Main call to action (optional)")

      fill_in "Text on the link", with: "Participate now"
      fill_in "The link takes you to (add a link)", with: "https://consulproject.org"
      click_button "Update Budget"

      visit budgets_path
      expect(page).to have_link("Participate now", href: "https://consulproject.org")
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      budget.update!(published: false, name: "Old English Name")

      visit edit_admin_budget_path(budget)

      select "Español", from: :add_language
      fill_in "Name", with: "Spanish name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "old-english-name")

      expect(page).to have_content "Old English Name"

      visit edit_admin_budget_path(budget)

      select "English", from: :select_language
      fill_in "Name", with: "New English Name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "new-english-name")

      expect(page).to have_content "New English Name"
    end
  end

  context "Update" do
    scenario "Update budget" do
      budget = create(:budget)
      visit edit_admin_budget_path(budget)

      fill_in "Name", with: "More trees on the streets"
      click_button "Update Budget"

      expect(page).to have_field "Name", with: "More trees on the streets"
      expect(page).to have_current_path admin_budget_path(budget)
    end

    scenario "Deselect all selected staff" do
      admin = Administrator.first
      valuator = create(:valuator)

      budget = create(:budget, administrators: [admin], valuators: [valuator])

      visit edit_admin_budget_path(budget)
      click_link "1 administrator selected"
      uncheck admin.name

      expect(page).to have_link "Select administrators"

      click_link "1 valuator selected"
      uncheck valuator.name

      expect(page).to have_link "Select valuators"

      click_button "Update Budget"
      visit edit_admin_budget_path(budget)

      expect(page).to have_link "Select administrators"
      expect(page).to have_link "Select valuators"
    end
  end

  context "Calculate Budget's Winner Investments" do
    scenario "For a Budget in reviewing balloting" do
      budget = create(:budget, :reviewing_ballots)
      heading = create(:budget_heading, budget: budget, price: 4)
      unselected = create(:budget_investment, :unselected, heading: heading, price: 1,
                                                           ballot_lines_count: 3)
      winner = create(:budget_investment, :selected, heading: heading, price: 3,
                                                   ballot_lines_count: 2)
      selected = create(:budget_investment, :selected, heading: heading, price: 2, ballot_lines_count: 1)

      visit edit_admin_budget_path(budget)
      expect(page).not_to have_content "See results"
      click_link "Calculate Winner Investments"
      expect(page).to have_content "Winners being calculated, it may take a minute."
      expect(page).to have_content winner.title
      expect(page).not_to have_content unselected.title
      expect(page).not_to have_content selected.title

      visit edit_admin_budget_path(budget)
      expect(page).to have_content "See results"
    end

    scenario "For a finished Budget" do
      budget = create(:budget, :finished)
      allow_any_instance_of(Budget).to receive(:has_winning_investments?).and_return(true)

      visit edit_admin_budget_path(budget)

      expect(page).to have_content "Calculate Winner Investments"
      expect(page).to have_content "See results"
    end

    scenario "Recalculate for a finished Budget" do
      budget = create(:budget, :finished)
      create(:budget_investment, :winner, budget: budget)

      visit edit_admin_budget_path(budget)

      expect(page).to have_content "Recalculate Winner Investments"
      expect(page).to have_content "See results"
      expect(page).not_to have_content "Calculate Winner Investments"

      visit admin_budget_budget_investments_path(budget)
      click_link "Advanced filters"
      check "Winners"
      click_button "Filter"

      expect(page).to have_content "Recalculate Winner Investments"
      expect(page).not_to have_content "Calculate Winner Investments"
    end
  end
end
