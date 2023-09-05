require "rails_helper"

describe Admin::Audits::ShowComponent do
  let(:proposal) { create(:proposal, title: "Initial proposal title") }

  before do
    allow(Rails.application.config).to receive(:auditing_enabled).and_return(true)
    proposal.update!(title: "Updated proposal title")
  end

  it "works with deleted auditable record" do
    audit = Audit.last
    proposal.really_destroy!

    render_inline Admin::Audits::ShowComponent.new(audit)

    expect(page).to have_content("Initial proposal title")
    expect(page).to have_content("Updated proposal title")
  end
end
