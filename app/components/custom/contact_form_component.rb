class ContactFormComponent < ApplicationComponent
  attr_reader :form
  delegate :current_user, :new_window_link_to, to: :helpers

  def initialize(form)
    @form = form
  end
end
