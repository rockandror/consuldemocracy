class Management::ImportUsersController < Management::BaseController
    load_and_authorize_resource
    def new
        @import = ImportUser.new
    end

    def create
        @import = ImportUser.new(import_users_params)
        
        if @import.save
            notice = t("admin.moderated_texts.imports.create.notice")
            redirect_to management_import_users_path, notice: notice
        else
            render :new
        end
    end
    
    private

        def import_users_params
            params.require(:import_user).permit(:file)
        end
    
end
