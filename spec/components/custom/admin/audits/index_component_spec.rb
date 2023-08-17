require "rails_helper"

describe Admin::Audits::IndexComponent do
  include Rails.application.routes.url_helpers

  let(:proposal) { create(:proposal, title: "Initial proposal title") }

  before do
    allow(Rails.application.config).to receive(:auditing_enabled).and_return(true)
    sign_in(create(:administrator).user)
    proposal.update!(title: "Updated proposal title")
  end

  it "shows a message when the database is empty" do
    Audit.delete_all

    render_inline Admin::Audits::IndexComponent.new(audits: Audit.none.page(1))

    expect(page).to have_content("There are no changes logged")
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

  it "shows a message when there are no search results" do
    allow(controller).to receive(:params).and_return({ search: "Budget#1" })

    render_inline Admin::Audits::IndexComponent.new(audits: Audit.none.page(1))

    expect(page).to have_content("No results found.")
  end

  it "works with deleted auditable records" do
    proposal.really_destroy!

    render_inline Admin::Audits::IndexComponent.new(audits: Audit.page(1))

    expect(page).to have_content("Initial proposal title")
    expect(page).to have_content("Updated proposal title")
  end
end
