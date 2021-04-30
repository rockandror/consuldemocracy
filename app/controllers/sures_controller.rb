class SuresController < SuresBaseController
    include Admin::SuresHelper
    
    def index
        @cards = Sures::CustomizeCard.body
    end

    # def search
    #     @resultado = ""
    #     @actuations = []
    #     @sures_searchs_settings = Sures::SearchSetting.search_settings.order(id: :asc)
    #     @sures_orders_filter = Sures::SearchSetting.order_settings.order(id: :asc)
       
       
    #     run_search(params)
    # end

    # def actuation
    #     @actuation = Sures::Actuation.find_by(id: params[:id])
    # end

    private

    def run_search(parametrize)
        aux_active = false

        aux_fields = @sures_searchs_settings.map {|f| f.title.parameterize.underscore.to_s }
        aux_fields.push('search')

        aux_fields.each do |f|
            if !parametrize[f.to_sym].blank?
                aux_active = true
                break
            end
        end

        @search_terms = aux_active
        if aux_active
            @actuations = Sures::Actuation.joins(:translations).all
            @resultado =  @resultado + (@resultado.blank? ? parametrize[:search] : "/#{parametrize[:search]}")
            if !parametrize[:search].blank?
                @actuations = @actuations.where("translate(UPPER(cast(proposal_title as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(proposal_objective as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(territorial_scope as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(location_performance as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(technical_visibility as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(actions_taken as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(other as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(tracking as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU')",
                    "%#{parametrize[:search]}%", "%#{parametrize[:search]}%", "%#{parametrize[:search]}%",
                    "%#{parametrize[:search]}%", "%#{parametrize[:search]}%", "%#{parametrize[:search]}%",
                    "%#{parametrize[:search]}%", "%#{parametrize[:search]}%"
                )
            end

            if !parametrize[:show_fields].blank? && parametrize[:show_fields].to_s != "true"
                aux_fields.each do |f|
                    if !parametrize[f.to_sym].blank? && f.to_s != "search"
                        aux_field_search = @sures_searchs_settings.select {|x| x.title.parameterize.underscore.to_s == f.to_s }[0]
                        if !aux_field_search.blank?
                            parse_data_json(aux_field_search.data).each do |k,v| 
                                if v.to_s == parametrize[f.to_sym].to_s
                                    @resultado =  @resultado + (@resultado.blank? ? k : "/#{k}")
                                    break
                                end
                            end
                            
                            @actuations = @actuations.where("translate(UPPER(cast(#{aux_field_search.field} as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU')", "%#{parametrize[f.to_sym]}%")
                        end
                    end
                end
            end

            aux_order = "updated_at desc"
            if  @sures_orders_filter.blank?
                @type = ""
            elsif !params[:type].blank?
                aux = @sures_orders_filter.select {|order| order.title.parameterize.underscore == params[:type] }.first
                aux_order = "#{aux.field} #{aux.rules.split(';').length > 1 ? aux.rules.split(';')[1] : aux.rules }"
                @type = params[:type]
            else
                aux = @sures_orders_filter.select {|order| order.rules.to_s.include?('default') }.first
                if aux.blank?
                    aux = @sures_orders_filter.first
                end
                aux_order = "#{aux.field} #{aux.rules.split(';').length > 1 ? aux.rules.split(';')[1] : aux.rules }"
                @type = aux.title.parameterize.underscore
            end
            @actuations = @actuations.order(aux_order)
            @actuations = @actuations.page(params[:page])
        end
    end
end