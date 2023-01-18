require_dependency Rails.root.join("app", "controllers", "admin", "stats_controller").to_s

class Admin::StatsController
  def audited_records
    @records = Audited.audit_class.where.not(user_id: nil).order(created_at: :desc)
    if params[:search]
      user = User.find_by(email: params[:search])
      @records = @records.where('CAST(created_at AS text) ILIKE ? OR user_id = ?', "%#{params[:search]}%", user&.id)
    end
    @records = @records.page(params[:page])
  end

  def access_logs
    @logs = ActivityLog.all.order(created_at: :desc)
    if params[:search]
      search = "%#{params[:search]}%"
      @logs = @logs.where('CAST(created_at AS text) ILIKE ? OR payload ILIKE ?', search, search)
    end
    @logs = @logs.page(params[:page])
  end

  def tags
    @tags = Tag.all.order(taggings_count: :desc).page(params[:page])
  end
end
