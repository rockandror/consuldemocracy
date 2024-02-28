require_dependency Rails.root.join("app", "controllers", "admin", "stats_controller").to_s

class Admin::StatsController
  def tags
    @tags = Tag.order(taggings_count: :desc).page(params[:page])
  end
end
