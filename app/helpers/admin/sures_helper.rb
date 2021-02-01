module Admin::SuresHelper
    require 'json' 
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


    def parse_data_json(data)
        eval(JSON.parse(data.to_s)).to_h
    rescue
        eval(data)
    end


    def get_filter_sures_search_tab
        [
            {name: I18n.t('admin.sures.searchs_settings.filter.search'), type: 'search'},
            {name: I18n.t('admin.sures.searchs_settings.filter.order'), type: 'order'}
        ]
    end

    def get_sures_search_types_data
        [
            [I18n.t('admin.sures.searchs_settings.types_data.select'), 'select'],
            [I18n.t('admin.sures.searchs_settings.types_data.order'), 'order'],
            [I18n.t('admin.sures.searchs_settings.types_data.text'), 'text'],
            [I18n.t('admin.sures.searchs_settings.types_data.fulltext'), 'fulltext']
        ]
    end

    def get_sures_search_rules
        [
            [I18n.t('admin.sures.searchs_settings.rules.default_asc'), 'default;asc'],
            [I18n.t('admin.sures.searchs_settings.rules.default_desc'), 'default;desc'],
            [I18n.t('admin.sures.searchs_settings.rules.asc'), 'asc'],
            [I18n.t('admin.sures.searchs_settings.rules.desc'), 'desc']
        ]
    end
end