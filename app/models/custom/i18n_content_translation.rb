require_dependency Rails.root.join("app", "models", "i18n_content_translation").to_s

class I18nContentTranslation
  audited on: [:create, :update, :destroy]
end
