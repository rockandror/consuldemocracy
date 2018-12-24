shared_examples "remotely_translatable" do |factory_name, path_name, path_arguments|

  let(:path) { send(path_name, arguments) }
  let(:arguments)     { {} }
  let!(:resource) { create(factory_name) }

  before do
    Setting["feature.remote_translations"] = true
    path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": resource.send(path_to_value))
    end
  end

  after do
    Setting["feature.remote_translations"] = false
  end

  context "Remote translations button" do

    scenario "Should not be present when current locale translation exists", :js do
      visit path

      expect(page).not_to have_button("Translate page")
    end

    scenario "Should be present when current locale translation does not exists", :js do
      visit path

      select('Español', from: 'locale-switcher')

      expect(page).to have_button("Traducir página")
    end

    scenario "Should not be present when new current locale translation exists", :js do
      add_translations(resource)
      visit path
      expect(page).not_to have_button("Translate page")

      select('Español', from: 'locale-switcher')

      expect(page).not_to have_button("Traducir página")
    end

    scenario "Should not be present when there is no resources to translate", :js do
      skip("only index_path") if show_path?(path_name)
      resource.destroy
      visit path

      select('Español', from: 'locale-switcher')

      expect(page).not_to have_button("Traducir página")
    end

    scenario "Should be present when exist an equal RemoteTranslation is enqueued", :js do
      Delayed::Worker.delay_jobs = true

      create(:remote_translation, remote_translatable: resource, from: :en, to: :es)
      visit path

      select('Español', from: 'locale-switcher')

      expect(page).to have_button("Traducir página")

      Delayed::Worker.delay_jobs = false
    end

    describe "Should ignore missing translations on resource comments" do

      before do
        if show_path?(path_name) || !commentable?(resource)
          skip("only index_path")
        end
      end

      scenario "is not present when exists resource translations but his comment has not tanslations", :js do
        add_translations(resource)
        create(:comment, commentable: resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).not_to have_button("Traducir página")
      end

    end

    describe "Should evaluate missing translations on resource comments" do

      before do
        if index_path?(path_name)
          skip("only show_path")
        end
      end

      scenario "display when exists resource translations but his comment has not tanslations", :js do
        add_translations(resource)
        create(:comment, commentable: resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).to have_button("Traducir página")
      end

      scenario "not display when exists resource translations but his comment has tanslations", :js do
        add_translations(resource)
        create_comment_with_translations(resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).not_to have_button("Traducir página")
      end

    end

  end

  context "After request translations" do

    describe "with delayed jobs" do

      before do
        Delayed::Worker.delay_jobs = true
      end

      after do
        Delayed::Worker.delay_jobs = false
      end

      scenario "Should be present remote translations button", :js do
        visit path
        select('Español', from: 'locale-switcher')

        click_button "Traducir página"

        expect(page).to have_button("Traducir página")
      end

      scenario "Should be present enqueued notice", :js do
        visit path
        select('Español', from: 'locale-switcher')

        click_button "Traducir página"

        expect(page).to have_content("Las traducciones solicitadas estan pendientes de traducir. En un breve peridodo de tiempo refrescando la página podrá ver las traducciones.")
      end

    end

    describe "without delayed jobs" do

      scenario "Should be present remote translations resource", :js do
        stub_microsoft_translate_client_response(resource)
        visit path
        select('Español', from: 'locale-switcher')

        click_button "Traducir página"

        expect(page).to have_content("CAMPO TRADUCIDO")
      end

      describe "Should be translated resources comments" do

        before do
          if index_path?(path_name)
            skip("only show_path")
          end
        end

        scenario "when exists resource translations but his comment has not tanslations", :js do
          stub_microsoft_translate_client_response(resource)
          add_translations(resource)
          create(:comment, commentable: resource)
          visit path
          select('Español', from: 'locale-switcher')

          click_button "Traducir página"

          within "#comments" do
            expect(page).to have_content("CAMPO TRADUCIDO")
          end
        end

      end

    end

  end

end

def add_translations(resource)
  new_translation = resource.translations.first.dup
  new_translation.update(locale: :es)
  resource
end

def create_comment_with_translations(resource)
  comment = create(:comment, commentable: resource)
  add_translations(comment)
end

def index_path?(path)
  ["debates_path", "proposals_path", "root_path"].include?(path)
end

def show_path?(path)
  !index_path?(path)
end

def commentable?(resource)
  Comment::COMMENTABLE_TYPES.include?(resource.class.to_s)
end

def stub_microsoft_translate_client_response(resource)
  response = []
  Globalize.with_locale(:es) do
    resource.translated_attribute_names.each_with_index do |field, index|
      value = index == 0 ? "CAMPO TRADUCIDO" : resource.send(:"#{field}")
      response << value
    end
  end
  expect_any_instance_of(MicrosoftTranslateClient).to receive(:call).and_return(response)
end
