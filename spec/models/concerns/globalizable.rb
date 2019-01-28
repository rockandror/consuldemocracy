require "spec_helper"

shared_examples_for "globalizable" do |factory_name|
  let(:record) { create(factory_name) }
  let(:field) { record.translated_attribute_names.first }

  describe "Fallbacks" do
    before do
      record.update_attribute(field, "In English")

      { es: "En español", de: "Deutsch" }.each do |locale, text|
        Globalize.with_locale(locale) do
          record.translated_attribute_names.each do |attribute|
            record.update_attribute(attribute, record.send(attribute))
          end

          record.update_attribute(field, text)
        end
      end
    end

    context "With a explicit defined fallback" do
      it "Falls back to the defined fallback" do
        Globalize.with_locale(:fr) do
          expect(record.send(field)).to eq "En español"
        end
      end
    end

    context "Without explicit defined fallback" do
      before do
        record.translations.where("locale != ?", :de).destroy_all
        record.reload
      end

      it "Falls back to the first available locale" do
        Globalize.with_locale(:fr) do
          expect(record.send(field)).to eq "Deutsch"
        end
      end
    end
  end
end
