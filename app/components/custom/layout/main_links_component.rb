class Layout::MainLinksComponent < ApplicationComponent
  delegate :image_path_for, to: :helpers
end
