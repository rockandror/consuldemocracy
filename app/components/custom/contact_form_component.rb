class ContactFormComponent < ApplicationComponent
  attr_reader :form
  use_helpers :current_user, :new_window_link_to

  def initialize(form)
    @form = form
  end
end
