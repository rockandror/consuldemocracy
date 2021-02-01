class Admin::Sures::SearchsSettingsController < Admin::BaseController
  respond_to :html, :js

  def index
    @type = params[:type].blank? ? 'search' : params[:type]
    @search_settings = ::Sures::SearchSetting.all
    if @type == 'search'
      @search_settings =  @search_settings.search_settings
    elsif @type == 'order'
      @search_settings =  @search_settings.order_settings
    end
    @search_settings =  @search_settings.order(id: :asc)
  end

  def create
    error = 0
    params.each do |x,y| 
      
      if x.to_s.include?('title_') 
        aux_id = x.split('title_')[1]
        aux_data = {}
        aux_count = 0

        searchs_setting = ::Sures::SearchSetting.find_by(id: aux_id.to_i)
        parametrize = {}
        parametrize[:title] = params["title_#{aux_id}".to_sym]
        parametrize[:resource] = searchs_setting.resource
        parametrize[:data_type] = params["data_type_#{aux_id}".to_sym]

        params.each {|s,v| s.to_s.include?("data_key_#{aux_id}") ? aux_count = aux_count + 1 : ''  } 
        if aux_count > 0
          (0..aux_count-1).each do |n|
            #if !params["data_key_#{aux_id}_#{n}".to_sym].blank?
              aux_data.merge!({"#{params["data_key_#{aux_id}_#{n}".to_sym]}": params["data_value_#{aux_id}_#{n}".to_sym]})
            #end
          end
        end

        parametrize[:data] = aux_data.to_json
        parametrize[:field] = params["field_#{aux_id}".to_sym]
        parametrize[:rules] = params["rules_#{aux_id}".to_sym]
        parametrize[:active] = !params["active_#{aux_id}".to_sym].blank?

        
        if !searchs_setting.update(parametrize)
          error = error + 1          
        end
      end
    end
    
    if error > 0
      redirect_to admin_sures_searchs_settings_path, error: I18n.t("admin.sures.searchs_settings.form.error")
    else
      redirect_to admin_sures_searchs_settings_path, notice: I18n.t("admin.sures.searchs_settings.form.notice")
    end
  end
end
