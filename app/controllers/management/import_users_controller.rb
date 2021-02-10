class Management::ImportUsersController < Management::BaseController
    def new
        @import = ImportUser.new
    end

    def create
        @import = ImportUser.new(import_users_params)
        @logs = {}
        if @import.save
            notice = t("admin.moderated_texts.imports.create.notice")
            error = t("admin.moderated_texts.imports.create.error")
            if @logs.blank? 
                redirect_to management_import_users_path, notice: notice 
            else
                redirect_to management_import_users_path(@logs), alert: error
            end
        else
            render :new
        end
    end
    
    private

        def import_users_params
            params.require(:import_user).permit(:file)
        end
    
end
