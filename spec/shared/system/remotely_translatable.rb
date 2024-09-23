require "sessions_helper"

shared_examples "remotely_translatable" do |factory_name, path_name, path_arguments|
  let(:arguments) do
    path_arguments.transform_values { |path_to_value| resource.send(path_to_value) }
  end
  let(:path) { send(path_name, arguments) }
  let!(:resource) { create(factory_name) }

  before do
    Setting["feature.remote_translations"] = true
    available_locales_response = %w[de en es fr pt zh-Hans]
    expect(RemoteTranslations::Microsoft::AvailableLocales)
      .to receive(:locales).at_most(4).times
      .and_return(available_locales_response)
    allow(Rails.application.secrets).to receive(:microsoft_api_key).and_return("123")
  end

  context "After click remote translations button" do
    describe "without delayed jobs" do
      scenario "request a translation of an already translated text" do
        response = generate_response(resource)
        expect_any_instance_of(RemoteTranslations::Microsoft::Client).to receive(:call).and_return(response)

        in_browser(:one) do
          visit path
          select "Español", from: "Language:"

          expect(page).to have_button "Traducir página"
        end

        in_browser(:two) do
          visit path
          select "Español", from: "Language:"
          click_button "Traducir página"

          expect(page).to have_content "Se han solicitado correctamente las traducciones"
        end

        in_browser(:one) do
          click_button "Traducir página"

          expect(page).not_to have_button "Traducir página"
        end
      end
    end
  end
end

def add_translations(resource, locale)
  new_translation = resource.translations.first.dup
  new_translation.update!(locale: locale)
  resource
end

def create_comment_with_translations(resource, locale)
  comment = create(:comment, commentable: resource)
  add_translations(comment, locale)
end

def index_path?(path)
  ["debates_path", "proposals_path", "root_path", "budget_investments_path"].include?(path)
end

def show_path?(path)
  !index_path?(path)
end

def commentable?(factory_name)
  Comment::COMMENTABLE_TYPES.include?(FactoryBot.factories[factory_name].build_class.to_s)
end

def generate_response(resource)
  field_text = Faker::Lorem.characters(number: 10)
  resource.translated_attribute_names.map { field_text }
end
