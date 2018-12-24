class RemoteTranslationsCaller

  def call(remote_translation)
    resource = remote_translation.remote_translatable
    fields_values = prepare_fields_values(resource)
    locale_to = remote_translation.to

    translations = MicrosoftTranslateClient.new.call(fields_values, locale_to)

    update_resource(resource, translations, locale_to)
    destroy_remote_translation(resource, remote_translation)
  end

  private

  def prepare_fields_values(resource)
    fields_values = []
    resource.translated_attribute_names.each do |field|
      fields_values << resource.send(field)
    end
    fields_values
  end

  def update_resource(resource, translations, locale)
    Globalize.with_locale(locale) do
      resource.translated_attribute_names.each_with_index do |field, index|
        resource.send(:"#{field}=", translations[index])
      end
    end
    resource.save
  end

  def destroy_remote_translation(resource, remote_translation)
    if resource.valid?
      remote_translation.destroy
    else
      remote_translation.update(error_message: resource.errors.messages)
      ## TODO: Parsear los errores para gurdarlos? #{:"translations.title"=>["is too short (minimum is 4 characters)"]}
      ## TODO: A quien informamos de que ha sucedido un error en la traducción?
    end
  end

end
