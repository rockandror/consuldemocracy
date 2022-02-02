class Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def price(heading)
      if budget.show_money?
        tag.span(budget.formatted_heading_price(heading))
      end
    end
end
