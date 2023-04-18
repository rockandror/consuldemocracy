require "rails_helper"

describe Admin::Audits::IndexComponent do
  include Rails.application.routes.url_helpers

  let(:proposal) { create(:proposal, title: "Initial proposal title") }

  before do
    allow(Rails.application.config).to receive(:auditing_enabled).and_return(true)
    sign_in(create(:administrator).user)
    proposal.update!(title: "Updated proposal title")
  end

  it "shows attributes previous and current values" do
    render_inline Admin::Audits::IndexComponent.new(audits: Audit.page(1))

    expect(page).to have_content("Initial proposal title")
    expect(page).to have_content("Updated proposal title")
  end

  it "shows links to show page" do
    audits = Audit.page(1)

    render_inline Admin::Audits::IndexComponent.new(audits: audits)

    expect(page).to have_link("Show", href: admin_audit_path(audits.first))
  end
end
