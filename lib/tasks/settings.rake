namespace :settings do
  desc "Remove deprecated settings"
  task remove_deprecated_settings: :environment do
    ApplicationLogger.new.info "Removing deprecated settings"

    deprecated_keys = [
      "place_name",
      "winner_text",
      "banner-style.banner-style-one",
      "banner-style.banner-style-two",
      "banner-style.banner-style-three",
      "banner-img.banner-img-one",
      "banner-img.banner-img-two",
      "banner-img.banner-img-three",
      "min_age_to_verify",
      "proposal_improvement_path",
      "analytics_url",
      "feature.spending_proposals",
      "feature.spending_proposal_features.phase1",
      "feature.spending_proposal_features.phase2",
      "feature.spending_proposal_features.phase3",
      "feature.spending_proposal_features.voting_allowed",
      "feature.spending_proposal_features.final_voting_allowed",
      "feature.spending_proposal_features.open_results_page",
      "feature.spending_proposal_features.valuation_allowed"
    ]

    deprecated_keys.each do |key|
      Setting.where(key: key).first&.destroy
    end
  end

  desc "Rename existing settings"
  task rename_setting_keys: :environment do
    Setting.rename_key from: "map_latitude",  to: "map.latitude"
    Setting.rename_key from: "map_longitude", to: "map.longitude"
    Setting.rename_key from: "map_zoom",      to: "map.zoom"

    Setting.rename_key from: "feature.debates",     to: "process.debates"
    Setting.rename_key from: "feature.proposals",   to: "process.proposals"
    Setting.rename_key from: "feature.polls",       to: "process.polls"
    Setting.rename_key from: "feature.budgets",     to: "process.budgets"
    Setting.rename_key from: "feature.legislation", to: "process.legislation"

    Setting.rename_key from: "per_page_code_head", to: "html.per_page_code_head"
    Setting.rename_key from: "per_page_code_body", to: "html.per_page_code_body"

    Setting.rename_key from: "feature.homepage.widgets.feeds.proposals", to: "homepage.widgets.feeds.proposals"
    Setting.rename_key from: "feature.homepage.widgets.feeds.debates",   to: "homepage.widgets.feeds.debates"
    Setting.rename_key from: "feature.homepage.widgets.feeds.processes", to: "homepage.widgets.feeds.processes"
    Setting.rename_key from: "feature.homepage.widgets.feeds.topics",   to: "homepage.widgets.feeds.topics"
  end

  desc "Add new settings"
  task add_new_settings: :environment do
    Setting.add_new_settings
  end


  desc "Add new settings"
  task add_stting_mount: :environment do
    Setting.create(:key => "months_to_double_verification", :value => 3)
  end

  task add_youtube_settings: :environment do
    Setting.create(:key => "youtube_connect", :value => "KpgTWGu7ecI")
    Setting.create(:key => "youtube_playlist_connect", :value => "PLhnvwI6F9eqXTZQc1yUGl4GX9s96u1AmK")
  end

  task add_agend_youtube_settings: :environment do
    Setting.create(:key => "agend_youtube_connect", :value => "KpgTWGu7ecI")
    Setting.create(:key => "agend_youtube_playlist_connect", :value => "PLhnvwI6F9eqXTZQc1yUGl4GX9s96u1AmK")
    Setting.create(:key => "text_agend", :value => "<div class='row'>
      <div class='small-12 column'>
          <h1>Semana de la Administración Abierta 2021</h1>
          <h2>Si participas, decides Madrid 2021</h2>
          <p>Los días 18, 19 y 20 de mayo de 2021 celebramos las jornadas \"Si participas, decides Madrid 2021\", en el marco de la
          <a href='#'>Semana de la Administración Abierta</a>, con el ánimo de acercar las políticas y programas de participación ciudadana y 
          transparencia del Ayuntamiento de Madrid a la ciudadanía</p>
          <p>Este evento de la Dirección General de Participación Ciudadana forma parte de la iniciativa <a href='#'>OpenGov Week</a> impulsada
           a nivel mundial por la Alianza para el Gobierno Abierto (<a href='#'>Open Government Partnership</a>). Su objetivo es reforzar los 
           vínculos entre las instituciones y la ciudadanía, poniendo de manifiesto su compromiso con el desarrollo de los valores de la
           transparencia, la participación ciudadana y la colaboración de las Administraciones Públicas con la sociedad</p>
      </div></div>")
  end

  task add_other_proposal_settings: :environment do
    Setting.create(:key => "other_proposal_declaration_1", :value => "Soy el representante legal")
    Setting.create(:key => "other_proposal_declaration_2", :value => "Declaración responsable")
  end

  task add_permit_text_settings: :environment do
    Setting.create(:key => "proposal_permit_text", :value => "Texto especial para propuestas")
  end

  task add_madrid_balcon_settings: :environment do
    Setting.create(:key => "text_madrid_balcon", :value => "<div class='row'>
      <div class='small-12 column'>
          <h1>Conectados</h1>
          <h3>Encuentros digitales con expertos</h3>
      </div>
      </div>
      <div class='row'>
          <div class='small-12 column'>
              <p>Te ponemos en contacto con técnicos del Ayuntamiento para que puedas resolver tus dudas sobre el <b>COVID-19</b> en todos los ámbitos de actuación.</p>
              <br>
              <p>Cada lunes, un experto contestará en directo a tus preguntas.</p>
              <p><b>Próximo encuentro:</b> Diariamente</p>
          </div>
      </div>")
  end

  task add_eventos_settings: :environment do
    Setting.create(:key => "eventos_youtube_connect", :value => "KpgTWGu7ecI")
    Setting.create(:key => "eventos_youtube_playlist_connect", :value => "PLhnvwI6F9eqXTZQc1yUGl4GX9s96u1AmK")
    Setting.create(:key => "text_eventos", :value => "<div class='row'>
      <div class='small-12 column'>
          <h1>Eventos</h1>
      </div>")
  end

  task add_permit_html: :environment do 
    ["proposal_permit_text", "other_proposal_declaration_1", 
      "other_proposal_declaration_2", "text_madrid_balcon", "text_eventos"].each do |key|
        setting = Setting.find_by(key: key)

        if setting.blank?
          puts "No existe el setting con key: #{key}"
        else 
          setting.permit_html_safe = true
          if setting.save
            puts "Se ha actualizado el setting con key: #{setting.key}"
          else
            puts "ERROR: no se ha actualizado el setting con key: #{key} -> #{setting.errors.full_messages}"
          end
        end
    end
  end

  task add_homepage_topic: :environment do
    if Setting.new(key: "homepage.widgets.feeds.topics", value: "").save!
      puts "Temas añadidos a la página principal"
    end
  end

  task add_video_content_types: :environment do
    if Setting.new(key: "uploads.videos.content_types", value: "video/mp4").save!
      puts "Tipos de videos añadidos a la página principal"
    end
  end
end
