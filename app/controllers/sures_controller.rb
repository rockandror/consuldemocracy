class SuresController < SuresBaseController
    #include FeatureFlags
    #include FlagActions

    #feature_flag :actuations
    
    def index
        @cards = Sures::CustomizeCard.body
    end

    def search
        @actuations = Sures::Actuation.all.page(params[:page])
    end

    def actuation
        @actuation = Sures::Actuation.find_by(id: params[:id])
    end
end