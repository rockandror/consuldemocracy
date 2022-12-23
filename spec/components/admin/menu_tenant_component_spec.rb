require "rails_helper"

describe Admin::MenuTenantComponent do
  let(:component) { Admin::MenuTenantComponent.new }

  it "renders only Settings section" do
    render_inline component

    expect(page).to have_css "#admin_menu"
    expect(page).to have_link "Settings"
    expect(page).to have_css "li", count: 1
  end
end
