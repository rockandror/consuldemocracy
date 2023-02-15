require "rails_helper"

describe "Stats", :admin do
  context "Activity logs" do
    scenario "List all activity logs, last created first" do
      1.upto(3) do |index|
        ActivityLog.create!(activity: %w[register login].sample,
                            result: %w[ok error].sample,
                            payload: "user#{index}@example.org")
      end

      visit access_logs_admin_stats_path

      expect("user3@example.org").to appear_before("user2@example.org")
      expect("user2@example.org").to appear_before("user1@example.org")
    end

    scenario "Filters by payload" do
      1.upto(2) do |index|
        ActivityLog.create!(activity: %w[register login].sample,
                            result: %w[ok error].sample,
                            payload: "user#{index}@example.org")
      end

      visit access_logs_admin_stats_path(search: "user2@example.org")

      expect(page).to have_content("user2@example.org")
      expect(page).not_to have_content("user1@example.org")
    end

    scenario "Filters by date, time and parts" do
      travel_to(3.days.ago) do
        ActivityLog.create!(activity: "login",
                            result: "ok",
                            payload: "user1@example.org")
      end
      ActivityLog.create!(activity: "login",
                          result: "error",
                          payload: "user2@example.org")
      created_at = ActivityLog.first.created_at.utc
      search = I18n.l(created_at, format: "%Y-%m-%d %H:%M:%S")
      visit access_logs_admin_stats_path(search: search, locale: :es)

      expect(page).to have_content("user1@example.org")
      expect(page).not_to have_content("user2@example.org")

      search = I18n.l(created_at, format: "%Y-%m-%d %H:%M")
      visit access_logs_admin_stats_path(search: search, locale: :es)

      expect(page).to have_content("user1@example.org")
      expect(page).not_to have_content("user2@example.org")

      search = I18n.l(created_at, format: "%Y-%m-%d %H")
      visit access_logs_admin_stats_path(search: search, locale: :es)

      expect(page).to have_content("user1@example.org")
      expect(page).not_to have_content("user2@example.org")

      search = I18n.l(created_at, format: "%Y-%m-%d")
      visit access_logs_admin_stats_path(search: search, locale: :es)

      expect(page).to have_content("user1@example.org")
      expect(page).not_to have_content("user2@example.org")
    end

    scenario "Paginates records" do
      allow(ActivityLog).to receive(:default_per_page).and_return(1)
      1.upto(2) do |index|
        ActivityLog.create!(activity: %w[register login].sample,
                            result: %w[ok error].sample,
                            payload: "user#{index}@example.org")
      end

      visit access_logs_admin_stats_path

      expect(page).to have_selector("ul.pagination")
    end
  end

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

  context "Audited records" do
    before do
      travel_to(3.days.ago.beginning_of_day) do
        login_as(create(:user, email: "john@doe.com"))
        visit new_debate_path
        fill_in "Debate title", with: "A title for a debate"
        fill_in_ckeditor "Initial debate text", with: "This is very important because..."
        check "debate_terms_of_service"
        click_button "Start a debate"
      end

      login_as(create(:user, email: "judy@doe.com"))
      visit new_proposal_path
      fill_in "Proposal title", with: "Help refugees"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in_ckeditor "Proposal text", with: "This is very important because..."
      fill_in "External video URL", with: "https://www.youtube.com/watch?v=yPQfcG-eimk"
      fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"
      fill_in "Tags", with: "Refugees, Solidarity"
      check "I agree to the Privacy Policy and the Terms and conditions of use"
      click_button "Create proposal"

      login_as(create(:administrator).user)
    end

    scenario "List audited records with an associated user, last created first" do
      visit audited_records_admin_stats_path

      within "#audited_records" do
        expect(page).to have_content "Debate"
        expect(page).to have_content "Proposal"
        expect("Proposal").to appear_before "Debate"
      end
    end

    scenario "Filters by date, time and parts" do
      visit audited_records_admin_stats_path

      within "#audited_records" do
        expect(page).to have_content("Debate")
        expect(page).to have_content("Proposal")
      end

      search = I18n.l(3.days.ago.beginning_of_day.utc, format: "%Y-%m-%d %H:%M:%S")
      visit audited_records_admin_stats_path(search: search)

      within "#audited_records" do
        expect(page).to have_content("Debate")
        expect(page).not_to have_content("Proposal")
      end

      search = I18n.l(3.days.ago.beginning_of_day.utc, format: "%Y-%m-%d %H:%M")
      visit audited_records_admin_stats_path(search: search)

      within "#audited_records" do
        expect(page).to have_content("Debate")
        expect(page).not_to have_content("Proposal")
      end

      search = I18n.l(3.days.ago.beginning_of_day.utc, format: "%Y-%m-%d %H")
      visit audited_records_admin_stats_path(search: search)

      within "#audited_records" do
        expect(page).to have_content("Debate")
        expect(page).not_to have_content("Proposal")
      end

      search = I18n.l(3.days.ago.beginning_of_day.utc, format: "%Y-%m-%d")
      visit audited_records_admin_stats_path(search: search)

      within "#audited_records" do
        expect(page).to have_content("Debate")
        expect(page).not_to have_content("Proposal")
      end
    end

    scenario "Filters by full user email" do
      visit audited_records_admin_stats_path(search: "john@doe.com")

      within "#audited_records" do
        expect(page).to have_content("Debate")
        expect(page).not_to have_content("Proposal")
      end

      visit audited_records_admin_stats_path(search: "judy@doe.com")

      within "#audited_records" do
        expect(page).not_to have_content("Debate")
        expect(page).to have_content("Proposal")
      end

      visit audited_records_admin_stats_path(search: "john@doe", locale: :es)

      expect(page).not_to have_selector("#audited_records")
      expect(page).to have_content("No hay registro de actividad")
    end

    scenario "Paginates records" do
      allow(Audit).to receive(:default_per_page).and_return(1)

      visit audited_records_admin_stats_path

      expect(page).to have_selector("ul.pagination")
    end
  end
end
