class VotationTypes::FieldsComponent < ApplicationComponent
  attr_reader :form

  def initialize(form:)
    @form = form
  end

  def votation_types_options
    VotationType.vote_types.map { |key, _| [VotationType.human_attribute_name("vote_type_#{key}"), key] }
  end
end
