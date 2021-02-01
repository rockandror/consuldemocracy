namespace :search_settings do
  desc "Add new sures search settings dinamic"
  task add: :environment do
    ApplicationLogger.new.info "Adding sures searchs settings dinamic"

    ApplicationLogger.new.info "Adding searchs order"
    
    Sures::SearchSetting.find_or_create_by(title: 'Por relevancia de la información', data_type: 'order', data: nil, resource: "Sures::Actuation", field: "updated_at", rules: "asc") 
    Sures::SearchSetting.find_or_create_by(title: 'Por estrategia', data_type: 'order', data: nil, resource: "Sures::Actuation", field: "financig_performance", rules: "asc") 
    Sures::SearchSetting.find_or_create_by(title: 'Por actuación', data_type: 'order', data: nil, resource: "Sures::Actuation", field: "actions_taken", rules: "asc") 
    Sures::SearchSetting.find_or_create_by(title: 'Por distrito', data_type: 'order', data: nil, resource: "Sures::Actuation", field: "territorial_scope", rules: "asc") 
    Sures::SearchSetting.find_or_create_by(title: 'Por barrio', data_type: 'order', data: nil, resource: "Sures::Actuation", field: "location_performance", rules: "asc") 
    Sures::SearchSetting.find_or_create_by(title: 'Por estado de ejecución', data_type: 'order', data: nil, resource: "Sures::Actuation", field: "status", rules: "asc")

    ApplicationLogger.new.info "Adding searchs fields"

    Sures::SearchSetting.find_or_create_by(title: 'Estratégia', data_type: 'select', data: {
      "#{I18n.t("admin.sures.actuations.actuation.financing_planed")}": "planed",
      "#{I18n.t("admin.sures.actuations.actuation.financing_tramit")}": "tramit",
      "#{I18n.t("admin.sures.actuations.actuation.financing_ifs")}": "ifs",
      "#{I18n.t("admin.sures.actuations.actuation.financing_other")}": "other"
    }.to_s.to_json, resource: "Sures::Actuation", field: "financig_performance", rules: nil)
    Sures::SearchSetting.find_or_create_by(title: 'Actuación', data_type: 'text', data: nil, resource: "Sures::Actuation", field: "actions_taken", rules: nil)
    Sures::SearchSetting.find_or_create_by(title: 'Distrito', data_type: 'select', data: {}.to_s.to_json, resource: "Sures::Actuation", field: "territorial_scope", rules: nil)
    Sures::SearchSetting.find_or_create_by(title: 'Barrio', data_type: 'select', data: {}.to_s.to_json, resource: "Sures::Actuation", field: "location_performance", rules: nil)
    Sures::SearchSetting.find_or_create_by(title: 'Estado de ejecución de la actuación', data_type: 'select', data: {
      "#{I18n.t("admin.sures.actuations.actuation.status_study")}": "study",
      "#{I18n.t("admin.sures.actuations.actuation.status_tramit")}": "tramit",
      "#{I18n.t("admin.sures.actuations.actuation.status_process")}": "process",
      "#{I18n.t("admin.sures.actuations.actuation.status_fhinish")}": "fhinish"
    }.to_s.to_json, resource: "Sures::Actuation", field: "status", rules: nil)
  end
end
