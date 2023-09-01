require "rails_helper"

describe "Registration form" do
  scenario "Allow save date_of_birth, gender and geozone" do
    create(:geozone, name: "Tegueste")
    visit new_user_registration_path

    fill_in "user_username",              with: "NewUserWithCode77"
    fill_in "user_email",                 with: "new@consul.dev"
    fill_in "user_password",              with: "password"
    fill_in "user_password_confirmation", with: "password"
    select "Tegueste",                    from: "user_geozone_id"
    select "Male",                        from: "user_gender"
    select "1997",                        from: "user_date_of_birth_1i"
    select "January",                     from: "user_date_of_birth_2i"
    select "1",                           from: "user_date_of_birth_3i"
    check "user_terms_of_service"

    click_button "Register"

    expect(page).to have_title "Confirm your email address"
    expect(page).to have_content "Thank you for registering"
  end

  scenario "Create with invisible_captcha honeypot field", :no_js do
    visit new_user_registration_path

    fill_in "user_username",              with: "robot"
    fill_in "user_address",               with: "This is the honeypot field"
    fill_in "user_email",                 with: "robot@robot.com"
    fill_in "user_password",              with: "destroyallhumans"
    fill_in "user_password_confirmation", with: "destroyallhumans"
    check "user_terms_of_service"

    click_button "Register"

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(user_registration_path)
  end

  scenario "Create organization too fast" do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)
    visit new_user_registration_path

    fill_in "user_username",              with: "robot"
    fill_in "user_email",                 with: "robot@robot.com"
    fill_in "user_password",              with: "destroyallhumans"
    fill_in "user_password_confirmation", with: "destroyallhumans"
    check "user_terms_of_service"

    click_button "Register"

    expect(page).to have_content "Sorry, that was too quick! Please resubmit"

    expect(page).to have_current_path(new_user_registration_path)
  end
end
