require "rails_helper"

describe ContactForm do
  let(:contact_form) do
    ContactForm.new(name: "Fulanito",
                    email: "fulanito@example.org",
                    subject: "Support",
                    message: "Message body",
                    terms_of_service: true)
  end

  it "is valid when all mandatory fields are fullfiled" do
    expect(contact_form).to be_valid
  end

  it "is not valid without name" do
    contact_form.name = nil

    expect(contact_form).not_to be_valid
  end

  it "is not valid without email" do
    contact_form.email = nil

    expect(contact_form).not_to be_valid
  end

  it "is not valid without subject" do
    contact_form.subject = nil

    expect(contact_form).not_to be_valid
  end

  it "is not valid without message" do
    contact_form.message = nil

    expect(contact_form).not_to be_valid
  end

  it "is not valid when terms_of_service are not accepted" do
    contact_form.terms_of_service = false

    expect(contact_form).not_to be_valid

    contact_form.terms_of_service = nil

    expect(contact_form).not_to be_valid
  end
end
