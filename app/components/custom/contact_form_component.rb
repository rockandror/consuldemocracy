class ContactFormComponent < ApplicationComponent
  attr_reader :form
  delegate :current_user, to: :helpers

  def initialize(form)
    @form = form
  end
end
