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
        name = resource_model_name(resource_model)
        avoid_destroy_last_translation(name)
        invalidate_translated_attributes(resource_model, name)
      end
    end

    def resource_model_name(resource_model)
      if params[resource_model.class_name.downcase].present?
        if params[resource_model.class_name.downcase][:translations_attributes].present?
          return resource_model.class_name.downcase
        end
      elsif params[resource_model.to_s.parameterize("_")].present?
        if params[resource_model.to_s.parameterize("_")][:translations_attributes].present?
          return resource_model.to_s.parameterize("_")
        end
      elsif resource_model == Legislation::DraftVersion
        if params[:legislation_draft_version][:translations_attributes].present?
          return "legislation_draft_version"
        end
      elsif resource_model == ActivePoll
        if params[:active_poll][:translations_attributes].present?
          return "active_poll"
        end
      elsif resource_model == AdminNotification
        if params[:admin_notification][:translations_attributes].present?
          return "admin_notification"
        end
      elsif resource_model == ProgressBar
        if params[:progress_bar][:translations_attributes].present?
          return "progress_bar"
        end
      elsif resource_model == SiteCustomization::Page
        if params[:site_customization_page][:translations_attributes].present?
          return "site_customization_page"
        end
      else
        return false
      end
    end

    def resource_without_translations?(resource_model)
      if params[resource_model.class_name.downcase].present?
        if params[resource_model.class_name.downcase][:translations_attributes].present?
          translation_attributes = params[resource_model.class_name.downcase][:translations_attributes]
        else
          return false
        end
      elsif params[resource_model.to_s.parameterize("_")].present?
        if params[resource_model.to_s.parameterize("_")][:translations_attributes].present?
          translation_attributes = params[resource_model.to_s.parameterize("_")][:translations_attributes]
        else
          return false
        end
      elsif resource_model == Legislation::DraftVersion
        if params[:legislation_draft_version][:translations_attributes].present?
          translation_attributes = params[:legislation_draft_version][:translations_attributes]
        else
          return false
        end
      elsif resource_model == ActivePoll
        if params[:active_poll][:translations_attributes].present?
          translation_attributes = params[:active_poll][:translations_attributes]
        else
          return false
        end
      elsif resource_model == AdminNotification
        if params[:admin_notification][:translations_attributes].present?
          translation_attributes = params[:admin_notification][:translations_attributes]
        else
          return false
        end
      elsif resource_model == ProgressBar
        if params[:progress_bar][:translations_attributes].present?
          translation_attributes = params[:progress_bar][:translations_attributes]
        else
          return false
        end
      elsif resource_model == SiteCustomization::Page
        if params[:site_customization_page][:translations_attributes].present?
          translation_attributes = params[:site_customization_page][:translations_attributes]
        else
          return false
        end
      else
        return false
      end

      # translation_attributes = params[resource_model.class_name.downcase].present? ? params[resource_model.class_name.downcase][:translations_attributes] : params[resource_model.to_s.parameterize("_")][:translations_attributes]
      translation_attributes.each do |translation_params|
        translation_params = translation_params.last
        return false if translation_params.dig("_destroy") == "false"
      end
      return true
    end

    def avoid_destroy_last_translation(resource_model_name)
      index_locale = I18n.available_locales.index(locale).to_s
      destroy_path = [resource_model_name, "translations_attributes", index_locale, "_destroy"]
      update_value(params, destroy_path, "false")
    end

    def invalidate_translated_attributes(resource_model, resource_model_name)
      index_locale = I18n.available_locales.index(locale).to_s
      resource_model.translated_attribute_names.each do |attribute|
        attribute_path = [resource_model_name, "translations_attributes", index_locale, attribute]
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
