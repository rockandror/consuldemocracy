class SuresController < SuresBaseController
    
    def index
        @cards = Sures::CustomizeCard.body
    end

    def search
    end
end