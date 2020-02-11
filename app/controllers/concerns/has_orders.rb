module HasOrders
  extend ActiveSupport::Concern

  class_methods do
    def has_orders(valid_orders, *args)
      before_action(*args) do |c|
        @valid_orders = valid_orders.respond_to?(:call) ? valid_orders.call(c) : valid_orders.dup
        @valid_orders.delete("relevance") if params[:search].blank?
        if @recommended_proposals.present?
          @valid_orders.insert(0,@valid_orders[4])
          @valid_orders.delete_at(5)
          @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
        else
          @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
        end
      end
    end
  end
end
