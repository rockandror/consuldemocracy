module Translatable
  extend ActiveSupport::Concern

  private

    def translation_params(resource_model, options = {})
      validate_params(resource_model)
      attributes = [:id, :locale, :_destroy]
      if options[:only]
        attributes += [*options[:only]]
      else
        attributes += resource_model.translated_attribute_names
      end
      { translations_attributes: attributes - [*options[:except]] }
    end

    def validate_params(resource_model)
      if resource_without_translations?(resource_model)
        avoid_destroy_last_translation
        invalidate_translated_attributes(resource_model)
      end
    end

    def resource_without_translations?(resource_model)
      translation_attributes = params[resource_model.class_name.downcase][:translations_attributes]
      translation_attributes.each do |translation_params|
        translation_params = translation_params.last
        return false if translation_params.dig("_destroy") == "false"
      end
      return true
    end

    def avoid_destroy_last_translation
      index_locale = I18n.available_locales.index(locale).to_s
      destroy_path = ["debate", "translations_attributes", index_locale, "_destroy"]
      update_value(params, destroy_path, "false")
    end

    def invalidate_translated_attributes(resource_model)
      index_locale = I18n.available_locales.index(locale).to_s
      resource_model.translated_attribute_names.each do |attribute|
        attribute_path = ["debate", "translations_attributes", index_locale, attribute]
        update_value(params, attribute_path, nil)
      end
    end

    def update_value(structure, path, value)
      *path, final_key = path
      to_set = path.empty? ? structure : structure.dig(*path)

       return unless to_set
      to_set[final_key] = value
    end
end
