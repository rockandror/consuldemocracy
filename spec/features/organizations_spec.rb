require 'rails_helper'

feature 'Organizations' do

  scenario 'Organizations can be created' do
    user = User.organizations.where(email: 'green@peace.com').first
    expect(user).not_to be

    visit new_organization_registration_path

    fill_in 'user_organization_attributes_name', with: 'Greenpeace'
    fill_in 'user_organization_attributes_responsible_name', with: 'Dorothy Stowe'
    fill_in 'user_email',                         with: 'green@peace.com'
    fill_in "user_password",                      with: "Greenpeace1234"
    fill_in "user_password_confirmation",         with: "Greenpeace1234"
    check 'user_terms_of_service'

    click_button 'Register'

    user = User.organizations.where(email: 'green@peace.com').first
    expect(user).to be
    expect(user).to be_organization
    expect(user.organization).not_to be_verified
  end

  scenario 'Create with invisible_captcha honeypot field', :broken do
    visit new_organization_registration_path

    fill_in 'user_organization_attributes_name',  with: 'robot'
    fill_in 'user_address',                       with: 'This is the honeypot field'
    fill_in 'user_organization_attributes_responsible_name', with: 'Robots are more responsible than humans'
    fill_in 'user_email',                         with: 'robot@robot.com'
    fill_in "user_password",                      with: "DestroyHumans1234"
    fill_in "user_password_confirmation",         with: "DestroyHumans1234"

    check 'user_terms_of_service'

    click_button 'Register'

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(organization_registration_path)
  end

  scenario 'Create organization too fast', :broken do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)
    visit new_organization_registration_path
    fill_in 'user_organization_attributes_name', with: 'robot'
    fill_in 'user_organization_attributes_responsible_name', with: 'Robots are more responsible than humans'
    fill_in 'user_email',                         with: 'robot@robot.com'
    fill_in "user_password",                      with: "DestroyHumans1234"
    fill_in "user_password_confirmation",         with: "DestroyHumans1234"

    click_button 'Register'

    expect(page).to have_content 'Sorry, that was too quick! Please resubmit'

    expect(page).to have_current_path(new_organization_registration_path)
  end

  scenario 'Errors on create' do
    visit new_organization_registration_path

    click_button 'Register'

    expect(page).to have_content error_message
  end

  scenario 'Shared links' do
    # visit new_user_registration_path
    # expect(page).to have_link "Sign up as an organization / collective"

    # visit new_organization_registration_path
    # expect(page).to have_link "Sign up"

    visit new_user_session_path

    expect(page).to have_link "Sign up"
    expect(page).not_to have_link "Sign up as an organization"
  end

  scenario "when create organization render error when unchecked reCAPTCHA" do
    allow_any_instance_of(Organizations::RegistrationsController).to receive(:verify_recaptcha).and_return(false)
    visit new_organization_registration_path

    fill_in "Name of organisation", with: "Greenpeace"
    fill_in "Person responsible for the group", with: "Dorothy Stowe"
    fill_in "Email", with: "green@peace.com"
    fill_in "Password", with: "greenpeace"
    fill_in "Confirm password", with: "greenpeace"
    check "By registering you accept the terms and conditions of use"

    click_button "Register"

    expect(page).to have_content "reCAPTCHA human verification is missing. Please try again."
  end

  scenario "validate organization when unchecked reCAPTCHA and avoid lose values for form fields filled" do
    allow_any_instance_of(Organizations::RegistrationsController).to receive(:verify_recaptcha).and_return(false)
    visit new_organization_registration_path

    fill_in "Name of organisation", with: ""
    fill_in "Person responsible for the group", with: "Dorothy Stowe"
    fill_in "Email", with: "green@peace.com"
    fill_in "Password", with: "Greenpeace1234"
    fill_in "Confirm password", with: "Greenpeace1234"
    check "By registering you accept the terms and conditions of use"

    click_button "Register"

    expect(page).to have_content "reCAPTCHA human verification is missing. Please try again."
    expect(page).to have_content "1 error prevented this Account from being saved."
    expect(page).to have_field "Email", with: "green@peace.com"
   end
end
