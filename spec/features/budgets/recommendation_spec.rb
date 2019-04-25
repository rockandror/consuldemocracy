require "rails_helper"

feature "Recommendations" do

  context "Load" do

    let(:user)   { create(:user) }
    let!(:budget) { create(:budget, slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_recommendations_path("budget_slug", user_id: user.id)

      expect(page).to have_content budget.name
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_recommendations_path("wrong_budget", user_id: user.id)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_recommendations_path(0, user_id: user.id)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "without a user id shows recommendations for current user" do
      create(:budget_recommendation,
             user: user,
             investment: create(:budget_investment, budget: budget, description: "More Festivals!")
      )

      create(:budget_recommendation,
             user: create(:user),
             investment: create(:budget_investment, budget: budget, description: "Less Festivals!")
      )

      login_as(user)
      visit budget_recommendations_path(budget)

      expect(page).to have_content "More Festivals!"
      expect(page).not_to have_content "Less Festivals!"
    end

    scenario "without a user id redirects to sign in if user isn't authenticated" do
      visit budget_recommendations_path(budget)

      expect(page).to have_current_path new_user_session_path
      expect(page).to have_content "You must sign in or register to continue"
    end
  end

  scenario "Create by phase" do
    heading = create(:budget_heading)
    budget = heading.budget

    investment_to_select = create(:budget_investment, :feasible, heading: heading)
    investment_to_ballot = create(:budget_investment, :selected, heading: heading)

    user = create(:user)
    login_as(user)

    budget.update!(phase: "selecting")
    visit root_path
    click_link "Delegation"

    expect(page).to have_content "You have not selected any investment project for the selecting phase."
    fill_in "recommendation_investment_id", with: investment_to_select.id
    click_button "Add to my list"

    expect(page).to have_content "Investment project added to the list"
    expect(page).to have_link(investment_to_select.title, href: budget_investment_path(budget, investment_to_select))

    budget.update!(phase: "balloting")
    visit root_path
    click_link "Delegation"

    expect(page).to have_content "You have not selected any investment project for the final voting phase."
    fill_in "recommendation_investment_id", with: investment_to_ballot.id
    click_button "Add to my list"

    expect(page).to have_content "Investment project added to the list"
    expect(page).to have_link(investment_to_ballot.title, href: budget_investment_path(budget, investment_to_ballot))

    budget.update!(phase: "selecting")
    visit budget_recommendations_path(budget, user_id: user.id)

    expect(page).to have_content investment_to_select.title
    expect(page).not_to have_content investment_to_ballot.title

    budget.update!(phase: "balloting")
    visit budget_recommendations_path(budget, user_id: user.id)

    expect(page).to have_content investment_to_ballot.title
    expect(page).not_to have_content investment_to_select.title
  end

  scenario "Create (errors)" do
    investment = create(:budget_investment)

    user = create(:user)
    login_as(user)

    visit root_path
    click_link "Delegation"

    fill_in "recommendation_investment_id", with: 9999
    click_button "Add to my list"

    expect(page).to have_content "Invalid ID"
    expect(page).not_to have_content investment.title
  end

  scenario "Index" do
    user1 = create(:user)
    user2 = create(:user)

    heading = create(:budget_heading)

    investment1 = create(:budget_investment, heading: heading)
    investment2 = create(:budget_investment, heading: heading)
    investment3 = create(:budget_investment, heading: heading)

    recommendation1 = create(:budget_recommendation, user: user1, investment: investment1)
    recommendation2 = create(:budget_recommendation, user: user1, investment: investment2)
    recommendation3 = create(:budget_recommendation, user: user2, investment: investment3)

    login_as(user2)
    visit user_path(user1)
    click_link "List of recommended investments projects"

    expect(page).to have_content "Investment projects recommended by: #{user1.username}"

    expect(page).to have_content recommendation1.investment.title
    expect(page).to have_content recommendation2.investment.title

    expect(page).not_to have_content recommendation3.investment.title
  end

  scenario "Support another person's recommendation", :js do
    user1 = create(:user)
    user2 = create(:user, :level_two)

    investment = create(:budget_investment, :feasible)
    create(:budget_recommendation, investment: investment, user: user1)
    investment.budget.update(phase: "selecting")

    login_as(user2)
    visit user_path(user1)

    click_link "List of recommended investments projects"
    expect(page).to have_content "Investment projects recommended"

    within(".supports") do
      find(".in-favor a").click

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this investment project. Share it!"
    end
  end

  scenario "Balloting another person's recommendation", :js do
    user1 = create(:user)
    user2 = create(:user, :level_two)

    investment = create(:budget_investment, :selected)
    budget = investment.budget
    budget.update!(phase: "balloting")
    create(:budget_recommendation, investment: investment, user: user1, phase: "balloting")

    login_as(user2)
    visit user_path(user1)

    click_link "List of recommended investments projects"

    within(".ballot") do
      find(".in-favor a").click

      expect(page).to have_content "Remove vote"
    end
  end

  scenario "Destroy" do
    investment = create(:budget_investment)
    user = create(:user)
    create(:budget_recommendation, investment: investment, user: user)

    login_as(user)

    visit root_path
    click_link "Delegation"

    expect(page).to have_content investment.title
    click_link "Delete from my list"

    expect(page).to have_content "Investment project removed from the list"
    expect(page).not_to have_content investment.title
  end

end
