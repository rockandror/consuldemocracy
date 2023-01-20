class Layout::SocialComponent < ApplicationComponent
  attr_reader :list_options

  def initialize(**list_options)
    @list_options = list_options
  end
end
