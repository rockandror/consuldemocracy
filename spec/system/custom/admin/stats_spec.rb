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
end
