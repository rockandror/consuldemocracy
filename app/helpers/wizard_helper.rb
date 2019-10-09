module WizardHelper

  def display_checkbox_link(kind)
    unless kind.checkbox?
      "display:none"
    end
  end

end
