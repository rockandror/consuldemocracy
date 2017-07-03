RSpec.shared_examples "followable" do |followable_class_name, followable_path, followable_path_arguments|
  include ActionView::Helpers

  let!(:arguments) { {} }
  let!(:followable) { create(followable_class_name) }
  let!(:followable_dom_name) { followable_class_name.gsub('_', '-') }

  before do
    followable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": followable.send(path_to_value))
    end
  end

  scenario "Should not show follow button when there is no logged user" do
    visit send(followable_path, arguments)

    within "##{dom_id(followable)}" do
      expect(page).not_to have_link("Follow")
    end
  end

  scenario "Should show follow button when user is logged in" do
    user = create(:user)
    login_as(user)

    visit send(followable_path, arguments)

    within "##{dom_id(followable)}" do
      expect(page).to have_link("Follow")
    end
  end

  scenario "Following", :js do
    user = create(:user)
    login_as(user)

    visit send(followable_path, arguments)
    within "##{dom_id(followable)}" do
      click_link "Follow"
      page.find("#follow-#{followable_dom_name}-#{followable.id}").click

      expect(page).to have_css("#unfollow-expand-#{followable_dom_name}-#{followable.id}")
    end

    expect(Follow.followed?(user, followable)).to be
  end

  scenario "Show unfollow button when user already follow this followable" do
    user = create(:user)
    follow = create(:follow, user: user, followable: followable)
    login_as(user)

    visit send(followable_path, arguments)

    expect(page).to have_link("Unfollow")
  end

  scenario "Unfollowing", :js do
    user = create(:user)
    follow = create(:follow, user: user, followable: followable)
    login_as(user)

    visit send(followable_path, arguments)
    within "##{dom_id(followable)}" do
      click_link "Unfollow"
      page.find("#unfollow-#{followable_dom_name}-#{followable.id}").click

      expect(page).to have_css("#follow-expand-#{followable_dom_name}-#{followable.id}")
    end

    expect(Follow.followed?(user, followable)).not_to be
  end

  scenario "Show follow button when user is not following this followable" do
    user = create(:user)
    login_as(user)

    visit send(followable_path, arguments)

    expect(page).to have_link("Follow")
  end

  scenario "Followers list on followable show" do
    user = create(:user)
    follow = create(:follow, user: user, followable: followable)

    visit send(followable_path, arguments)
    click_link "Followers (1)"

    within("#tab-followers") do
      expect(page).to have_content(user.name)
      expect(page).to have_link(user.name)
    end
  end

  scenario "Followers list by order username on followable show" do
    user1 = create(:user, username: "Andrew")
    user2 = create(:user, username: "Barry")
    user3 = create(:user, username: "Charles")
    create(:follow, followable: followable, user: user1)
    create(:follow, followable: followable, user: user2)
    create(:follow, followable: followable, user: user3)

    visit send(followable_path, arguments)

    expect(user1.username).to appear_before(user2.username)
    expect(user2.username).to appear_before(user3.username)
  end

  scenario "Show text when have not followers" do
    user = create(:user)

    visit send(followable_path, arguments)
    click_link "Followers (0)"

    within("#tab-followers") do
      expect(page).to have_content("Don't have followers")
    end
  end

  scenario "Followers tab count should be updated after new follow created", :js do
    user = create(:user)
    login_as(user)

    visit send(followable_path, arguments)
    within "##{dom_id(followable)}" do
      click_link "Follow"
      page.find("#follow-#{followable_dom_name}-#{followable.id}").click
    end

    expect(page).to have_link("Followers (1)")
  end

  scenario "Followers tab content should new follower after new follow created", :js do
    user = create(:user)
    login_as(user)

    visit send(followable_path, arguments)
    within "##{dom_id(followable)}" do
      click_link "Follow"
      page.find("#follow-#{followable_dom_name}-#{followable.id}").click
    end
    click_link "Followers (1)"

    within "#tab-followers" do
      expect(page).to have_link(user.username)
    end
  end

  scenario "Followers tab count should be updated after follow destroyed", :js do
    user = create(:user)
    follow = create(:follow, user: user, followable: followable)
    login_as(user)

    visit send(followable_path, arguments)
    within "##{dom_id(followable)}" do
      click_link "Unfollow"
      page.find("#unfollow-#{followable_dom_name}-#{followable.id}").click
    end

    expect(page).to have_link("Followers (0)")
  end

  scenario "Followers tab content should not show user after follow destroyed", :js do
    user = create(:user)
    follow = create(:follow, user: user, followable: followable)
    login_as(user)

    visit send(followable_path, arguments)
    within "##{dom_id(followable)}" do
      click_link "Unfollow"
      page.find("#unfollow-#{followable_dom_name}-#{followable.id}").click
    end
    click_link "Followers (0)"

    within "#tab-followers" do
      expect(page).not_to have_link(user.username)
      expect(page).to have_content("Don't have followers")
    end
  end

end