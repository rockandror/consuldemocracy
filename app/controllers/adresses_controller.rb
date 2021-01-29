class AdressesController < ApplicationController
    load_and_authorize_resource
    respond_to :html, :js, :json
  
    def index
    end
  
    def show
    end
  
    def new
      @address = Address.new
      respond_with(@address)
    end
  
    def edit
    end
  
    def create
      respond_with(@address)
    end
  
    def update
      respond_with(@address)
    end
  
    def destroy
      respond_with(@address)
    end
  
    protected
    def address_params
      params.require(:adress).permit(:road_type, :road_name, :road_number, :floor, :gate, :door, :district, :borought, :postal_code)
    end
  end
  