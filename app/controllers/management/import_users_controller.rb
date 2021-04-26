class Management::ImportUsersController < Management::BaseController
    def new
        @import = ImportUser.new
    end

    def create
        @import = ImportUser.new(import_users_params)
        @logs = @import.save
        if @logs == true
            redirect_to management_import_users_path, notice: t("admin.moderated_texts.imports.create.notice")
        else
            render :new
        end
    end
    
    private

        def import_users_params
            params.require(:import_user).permit(:file)
        end
    
end
