class Admin::EventAgendsController < Admin::BaseController
    respond_to :html, :js
    load_and_authorize_resource

    def index
        @event_agends = EventAgend.all.page(params[:page])
    end

    def create
        @event_agend = EventAgend.new(event_agend_params)
        if @event_agend.save
            redirect_to admin_event_agends_path, notice: I18n.t('admin.event_agends.create.notice')
        else
            flash[:error] = I18n.t('admin.event_agends.create.error')
            render :new
        end
    end

    def update
        if @event_agend.update(event_agend_params)
            redirect_to admin_event_agends_path, notice: I18n.t('admin.event_agends.update.notice')
        else
            flash[:error] = I18n.t('admin.event_agends.update.error')
            render :edit
        end
    end

    def destroy
       if @event_agend.destroy
            redirect_to admin_event_agends_path, notice: I18n.t('admin.event_agends.destroy.notice')
       else
            flash[:error] = I18n.t('admin.event_agends.destroy.error')
            redirect_to admin_event_agends_path
       end
    end

    private

    def event_agend_params
        params.require(:event_agend).permit(:date_at, :hour_at, :hour_to, :content)
    end
end