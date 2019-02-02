module Globalizable
  extend ActiveSupport::Concern

  included do
    globalize_accessors
    accepts_nested_attributes_for :translations, allow_destroy: true

    before_validation :force_current_locale_translation,
      if: -> { locales_not_marked_for_destruction.empty? },
      on: :update

    def locales_not_marked_for_destruction
      translations.reject(&:_destroy).map(&:locale)
    end

    def description
      self.read_attribute(:description).try :html_safe
    end

    if self.paranoid?
      translation_class.send :acts_as_paranoid, column: :hidden_at
    end

    private

    def force_current_locale_translation
      translation = self.translations.select{|t| t.locale == I18n.locale}.first
      if translation.present?
        translation.reload
        self.translated_attribute_names.each do |field|
          Globalize.with_locale translation.locale do
            translation.send "#{field}=", nil
          end
        end
      else
        self.translations << self.class.translation_class.new(locale: I18n.locale)
      end
    end
  end

  class_methods do


    def validates_translation(method, options = {})
      validates(method, options.merge(if: lambda {|resource| resource.locales_not_marked_for_destruction.empty? }))
      if options.include?(:length)
        lenght_validate = { length: options[:length] }
        translation_class.instance_eval { validates method, lenght_validate.merge(if: lambda { |translation| translation.locale == I18n.default_locale })}
        translation_class.instance_eval { validates method, options.reject { |key| key == :length } } if options.count > 1
      else
        translation_class.instance_eval { validates method, options }
      end
    end

    def translation_class_delegate(method)
      translation_class.instance_eval { delegate method, to: :globalized_model }
    end
  end
end
