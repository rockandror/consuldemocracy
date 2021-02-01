class SuresController < SuresBaseController
    
    def index
        @cards = Sures::CustomizeCard.body
    end

    def search
        @actuations = []
        @sures_searchs_settings = Sures::SearchSetting.search_settings.order(id: :asc)
        @sures_orders_filter = Sures::SearchSetting.order_settings.order(id: :asc)
       
       
        run_search(params)
    end

    def actuation
        @actuation = Sures::Actuation.find_by(id: params[:id])
    end

    private

    def run_search(parametrize)
        aux_active = false

        aux_fields = sures_searchs_settings.map {|f| f.title.parameterize.underscore.to_s }
        aux_fields.push('search')

        aux_fields.each do |f|
            if !parametrize[f.to_sym].blank?
                aux_active = true
                break
            end
        end

        if aux_active
            @actuations = Sures::Actuation.joins(:translations).all

            



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