require_dependency Rails.root.join("app", "controllers", "admin", "legislation", "processes_controller").to_s

class Admin::Legislation::ProcessesController
  include LegislationHelper

  def download
    respond_to do |format|
      format.zip
      format.csv do
        send_data ::Legislation::Processes::Exporter.new(@process).to_zip, type: 'application/zip', disposition: 'attachment', filename: "process.zip"
      end
    end
  end

  private

    alias_method :consul_allowed_params, :allowed_params

    def allowed_params
      consul_allowed_params + [:tag_list]
    end
end
