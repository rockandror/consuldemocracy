class SuresBaseController < ApplicationController    
    skip_authorization_check
    before_action :loadHeader
    
    private 

    def loadHeader
        @header = Sures::CustomizeCard.header.first
    end
end