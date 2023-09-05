require "rails_helper"

describe Admin::Audits::RowComponent do
  include Rails.application.routes.url_helpers

  let(:proposal) { create(:proposal, title: "Initial proposal title") }

  before do
    allow(Rails.application.config).to receive(:auditing_enabled).and_return(true)
    sign_in(create(:administrator).user)
    proposal.update!(title: "Updated proposal title")
  end

  it "shows attributes previous and current values" do
    audit = proposal.own_and_associated_audits.find_by(action: "update")

    render_inline Admin::Audits::RowComponent.new(audit: audit)

    expect(page).to have_content("Initial proposal title")
    expect(page).to have_content("Updated proposal title")
  end

  it "shows links to show page" do
    audit = proposal.own_and_associated_audits.find_by(action: "update")

    render_inline Admin::Audits::RowComponent.new(audit: audit)

    expect(page).to have_link("Show", href: admin_audit_path(audit))
  end

  it "works with deleted auditable records" do
    audit = proposal.own_and_associated_audits.find_by(action: "update")
    proposal.really_destroy!

    render_inline Admin::Audits::RowComponent.new(audit: audit)

    expect(page).to have_content("Initial proposal title")
    expect(page).to have_content("Updated proposal title")
  end
end
