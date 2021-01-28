module Admin::SuresHelper
    def get_list_sures_status       
        [
            [I18n.t("admin.sures.actuations.actuation.status_study"), "study"],
            [I18n.t("admin.sures.actuations.actuation.status_tramit"), "tramit"],
            [I18n.t("admin.sures.actuations.actuation.status_process"), "process"],
            [I18n.t("admin.sures.actuations.actuation.status_fhinish"), "fhinish"]
        ]
    end

    def get_list_sures_financing      
        [
            [I18n.t("admin.sures.actuations.actuation.financing_planed"), "planed"],
            [I18n.t("admin.sures.actuations.actuation.financing_tramit"), "tramit"],
            [I18n.t("admin.sures.actuations.actuation.financing_ifs"), "ifs"],
            [I18n.t("admin.sures.actuations.actuation.financing_other"), "other"]
        ]
    end
end