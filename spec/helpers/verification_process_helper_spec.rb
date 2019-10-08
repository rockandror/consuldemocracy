require "rails_helper"

describe VerificationProcessHelper do

  describe "#checkbox_label" do
    it "render checkbox label field without link" do
      checkbox_field_without_link = create(:verification_field, label: "Sample Field",
                                                                name: "sample",
                                                                kind: "checkbox")
      expect(checkbox_label(checkbox_field_without_link)).to eq("Sample Field")
    end

    it "render checkbox label field with related link" do
      custom_page = create(:site_customization_page, slug: "new_page_slug")
      checkbox_field_with_link = create(:verification_field, label: "Sample Field",
                                                             name: "sample",
                                                             kind: "checkbox",
                                                             checkbox_link: custom_page.slug )

      expect(checkbox_label(checkbox_field_with_link)).to eq("Sample Field (<a target=\"_blank\" href=\"/new_page_slug\">link</a>)")
    end
  end

end
