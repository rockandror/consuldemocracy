shared_examples "translatable" do |factory_name, path_name, input_fields, textarea_fields = {}|
  let(:language_texts) do
    {
      es:      "en español",
      en:      "in English",
      fr:      "en Français",
      "pt-BR": "Português"
    }
  end

  let(:translatable_class) { build(factory_name).class }

  let(:input_fields) { input_fields } # So it's accessible by methods
  let(:textarea_fields) { textarea_fields } # So it's accessible by methods

  let(:fields) { input_fields + textarea_fields.keys }

  let(:attributes) do
    fields.product(%i[en es]).map do |field, locale|
      [:"#{field}_#{locale}", text_for(field, locale)]
    end.to_h
  end

  let(:optional_fields) do
    fields.select do |field|
      translatable.translations.last.dup.tap { |duplicate| duplicate.send(:"#{field}=", "") }.valid?
    end
  end

  let(:required_fields) do
    fields - optional_fields
  end

  let(:user) { create(:administrator).user }
  let(:translatable) { create(factory_name, attributes) }
  let(:path) { send(path_name, *resource_hierarchy_for(translatable)) }

  before do
    login_as(user)
    translatable.update(author: user) if front_end_path_to_visit?(path_name)
  end

  context "Manage translations" do
    before do
      if translatable_class.name == "I18nContent"
        skip "Translation handling is different for site customizations"
      end
    end

    scenario "Add a translation", :js do
      visit path

      select "Français", from: :translation_locale
      fields.each { |field| fill_in_field field, :fr, with: text_for(field, :fr) }
      click_button update_button_text

      visit path
      field = fields.sample

      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      select "Español", from: :globalize_locale
      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)

      select "Français", from: :globalize_locale
      expect_page_to_have_translatable_field field, :fr, with: text_for(field, :fr)
    end

    scenario "Add an invalid translation", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit path

      select "Français", from: :translation_locale
      fill_in_field field, :fr, with: ""
      click_button update_button_text

      expect(page).to have_css "#error_explanation"

      select "Français", from: :globalize_locale

      expect_page_to_have_translatable_field field, :fr, with: ""
    end

    scenario "Update a translation", :js do
      visit path

      select "Español", from: :translation_locale
      field = fields.sample
      updated_text = "Corrección de #{text_for(field, :es)}"

      fill_in_field field, :es, with: updated_text

      click_button update_button_text

      visit path

      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      select('Español', from: 'locale-switcher')

      expect_page_to_have_translatable_field field, :es, with: updated_text
    end

    scenario "Update a translation with invalid data", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit path
      select "Español", from: :translation_locale

      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)

      fill_in_field field, :es, with: ""
      click_button update_button_text

      expect(page).to have_css "#error_explanation"

      select "Español", from: :translation_locale

      expect_page_to_have_translatable_field field, :es, with: ""
    end

    scenario "Update a translation not having the current locale", :js do
      translatable.translations.destroy_all
      translatable.translations.create(
        fields.map { |field| [field, text_for(field, :fr)] }.to_h.merge(locale: :fr)
      )

      visit path
      expect_to_have_active_language('Français')
      expect_to_have_inactive_language('English')
      click_button update_button_text
      expect(page).not_to have_css "#error_explanation"
      visit path

      expect_to_have_active_language('Français')
      expect_to_have_inactive_language('English')
    end

    scenario "Remove a translation", :js do
      visit path
      expect_to_have_active_language 'Español'

      select "Español", from: :translation_locale
      click_link "Remove language"

      expect_to_have_inactive_language 'Español'

      click_button update_button_text

      visit path
      expect_to_have_inactive_language 'Español'
    end

    scenario "Remove a translation with invalid data", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit path

      select "Español", from: :translation_locale
      click_link "Remove language"

      select "English", from: :translation_locale
      fill_in_field field, :en, with: ""
      click_button update_button_text

      expect(page).to have_css "#error_explanation"
      expect_page_to_have_translatable_field field, :en, with: ""
      expect_to_have_active_language 'English'
      expect_to_have_inactive_language 'Español'

      visit path
      select "Español", from: :translation_locale

      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)
    end

    scenario 'Change value of a translated field to blank', :js do
      skip("can't have translatable blank fields") if optional_fields.empty?

      field = optional_fields.sample

      visit path
      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      fill_in_field field, :en, with: ''
      click_button update_button_text

      visit path
      expect_page_to_have_translatable_field field, :en, with: ''
    end

    scenario "Add a translation for a locale with non-underscored name", :js do
      visit path

      select "Português brasileiro", from: :translation_locale
      fields.each { |field| fill_in_field field, :"pt-BR", with: text_for(field, :"pt-BR") }
      click_button update_button_text

      visit path

      select 'Português brasileiro', from: :globalize_locale

      field = fields.sample
      expect_page_to_have_translatable_field field, :"pt-BR", with: text_for(field, :"pt-BR")
    end
  end

  context "Globalize javascript interface" do
    scenario "Select current locale when its translation exists", :js do
      visit path

      expect(page).to have_select "globalize_locale", selected: 'English'
    end

    scenario "Select first locale of existing translations when current locale translation does not exists", :js do
      translatable.translations.where(locale: :en).destroy_all
      visit path

      expect(page).to have_select "globalize_locale", selected: 'Español'
    end

    scenario "Show selected locale form", :js do
      visit path
      field = fields.sample

      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      select "Español", from: :globalize_locale

      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)
    end

    scenario "Select a locale and add it to the form", :js do
      visit path

      select "Français", from: :translation_locale

      expect_to_have_active_language("Français")
      expect_page_to_have_translatable_field fields.sample, :fr, with: ""
    end
  end
end

def text_for(field, locale)
  I18n.with_locale(locale) do
    "#{translatable_class.human_attribute_name(field)} #{language_texts[locale]}"
  end
end

def field_for(field, locale, visible: true)
  if translatable_class.name == "I18nContent"
    "contents_content_#{translatable.key}values_#{field}_#{locale}"
  else
    within(".translatable-fields[data-locale='#{locale}']") do
      find("input[id$='_#{field}'], textarea[id$='_#{field}']", visible: visible)[:id]
    end
  end
end

def fill_in_field(field, locale, with:)
  if input_fields.include?(field)
    fill_in field_for(field, locale), with: with
  else
    fill_in_textarea(field, textarea_fields[field], locale, with: with)
  end
end

def fill_in_textarea(field, textarea_type, locale, with:)
  if textarea_type == :markdownit
    click_link class: "fullscreen-toggle"
    fill_in field_for(field, locale), with: with
    click_link class: "fullscreen-toggle"
  elsif textarea_type == :ckeditor
    fill_in_ckeditor field_for(field, locale, visible: false), with: with
  end
end

def expect_page_to_have_translatable_field(field, locale, with:)
  if input_fields.include?(field)
    if translatable_class.name == "I18nContent" && with.blank?
      expect(page).to have_field field_for(field, locale)
    else
      expect(page).to have_field field_for(field, locale), with: with
    end
  else
    textarea_type = textarea_fields[field]

    if textarea_type == :markdownit
      click_link class: "fullscreen-toggle"
      expect(page).to have_field field_for(field, locale), with: with
      click_link class: "fullscreen-toggle"
    elsif textarea_type == :ckeditor
      within("div.js-globalize-attribute[data-locale='#{locale}'] .ckeditor ") do
        within_frame(0) { expect(page).to have_content with }
      end
    end
  end
end

# FIXME: button texts should be consistent. Right now, buttons don't
# even share the same colour.
def update_button_text
  case translatable_class.name
  when "Milestone"
    "Update milestone"
  when "AdminNotification"
    "Update notification"
  when "Budget::Investment"
    "Update"
  when "Poll"
    "Update poll"
  when "Poll::Question", "Poll::Question::Answer"
    "Save"
  when "SiteCustomization::Page"
    "Update Custom page"
  when "Widget::Card"
    "Save card"
  else
    "Save changes"
  end
end

def front_end_path_to_visit?(path)
  path[/admin|managment|valuation/].blank?
end

def expect_to_have_active_language(language)
  expect(find('#globalize_locale option', text: language)['style']).not_to include("display: none;")
end

def expect_to_have_inactive_language(language)
  expect(find('#globalize_locale option', text: language)['style']).to include("display: none;")
end