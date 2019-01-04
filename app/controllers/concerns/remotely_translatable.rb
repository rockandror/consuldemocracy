module RemotelyTranslatable

  private

    def detect_remote_translations(*args)
      @remote_translations = []
      if Setting["feature.remote_translations"].present?
        args.compact.each do |resources_group|
          resources_group.each do |resource|
            add_resource(resource, @remote_translations)
          end
        end
      end
      return_remote_translations(@remote_translations)
    end

    def add_resource(resource, remote_translations)
      remote_translations << add_remote_translation(resource) if translation_empty?(resource)
    end

    def add_remote_translation(resource)
      remote_translation = { remote_translatable_id: resource.id.to_s,
                             remote_translatable_type: resource.class.to_s,
                             from: :en,
                             to: locale }
    end

    def translation_empty?(resource)
      resource.translations.where(locale: locale).empty?
    end

    def return_remote_translations(remote_translations)
      remote_translations.present? ? remote_translations.to_json : remote_translations
    end

end
