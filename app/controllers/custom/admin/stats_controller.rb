require_dependency Rails.root.join("app", "controllers", "admin", "stats_controller").to_s

class Admin::StatsController
  def access_logs
    @logs = ActivityLog.all.order(created_at: :desc)
    if params[:search]
      search = "%#{params[:search]}%"
      @logs = @logs.where("CAST(created_at AS text) ILIKE ? OR payload ILIKE ?", search, search)
    end
    @logs = @logs.page(params[:page])
  end

  def tags
    @tags = Tag.all.order(taggings_count: :desc).page(params[:page])
  end
end
