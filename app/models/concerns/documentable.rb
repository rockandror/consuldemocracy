module Documentable
  extend ActiveSupport::Concern

  included do
    has_many :documents, as: :documentable, dependent: :destroy
  end

  module ClassMethods
    attr_reader :max_documents_allowed, :max_file_size, :accepted_content_types,
                :documents_enabled, :additiontal_image

    private

    def documentable(options= {})
      @documents_enabled = options[:documents_enabled]
      @max_documents_allowed = options[:max_documents_allowed]
      @max_file_size = options[:max_file_size]
      @accepted_content_types = options[:accepted_content_types]
      @additiontal_image = options[:additiontal_image]
    end

  end

end
