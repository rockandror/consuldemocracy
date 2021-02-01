class Admin::Sures::CustomizeCardsController < Admin::BaseController
    include Translatable
    include ImageAttributes
  
    def new
      if header_card?
        @card = ::Sures::CustomizeCard.new(header: header_card?)
      else
        @card = ::Sures::CustomizeCard.new(site_customization_page_id: params[:page_id])
      end
    end
  
    def create
      @card = ::Sures::CustomizeCard.new(card_params)
      if @card.save
        redirect_to_customization_page_cards_or_sures
      else
        render :new
      end
    end
  
    def edit
      @card = ::Sures::CustomizeCard.find(params[:id])
    end
  
    def update
      @card = ::Sures::CustomizeCard.find(params[:id])
      if @card.update(card_params)
        redirect_to_customization_page_cards_or_sures
      else
        render :edit
      end
    end
  
    def destroy
      @card = ::Sures::CustomizeCard.find(params[:id])
      @card.destroy
  
      redirect_to_customization_page_cards_or_sures
    end
  
    private
  
      def card_params
        params.require(:sures_customize_card).permit(
          :label, :title, :description, :link_text, :link_url, :position_image,
          :button_text, :button_url, :alignment, :header, :site_customization_page_id,
          :columns,
          translation_params(Sures::CustomizeCard),
          image_attributes: image_attributes
        )
      end
  
      def header_card?
        params[:header_card].present?
      end
  
      def redirect_to_customization_page_cards_or_sures
        notice = t("admin.site_customization.pages.cards.#{params[:action]}.notice")
  
       
        redirect_to admin_sures_customizes_url, notice: notice
      end
  
      def page
        ::SiteCustomization::Page.find(@card.site_customization_page_id)
      end
  
      def resource
        Sures::CustomizeCard.find(params[:id])
      end
  end