class Layout::ConsentBannerComponent < ApplicationComponent
  delegate :cookies, to: :helpers

  def render?
    !Rails.env.test?
  end
end
