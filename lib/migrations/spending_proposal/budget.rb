require_dependency "spending_proposal"

class Migrations::SpendingProposal::Budget
  attr_accessor :budget

  def initialize
    @budget = find_budget
  end

  def pre_rake_tasks
    update_heading_price
    update_heading_population
    update_selected_investments
  end

  def post_rake_tasks
    remove_forum_votes
    remove_forum_ballots
    update_cached_votes
    update_cached_ballots
    calculate_winners
  end

  private

    def update_heading_price
      update_city_heading_price
      update_district_heading_price
    end

    def update_city_heading_price
      budget.headings.where(name: "Toda la ciudad").first&.update(price: 24000000)
    end

    def update_district_heading_price
      price_by_heading.each do |heading_name, price|
        budget.headings.where(name: heading_name).first&.update(price: price)
      end
    end

    def price_by_heading
      {
        "Arganzuela"          => 1556169,
        "Barajas"             => 433589,
        "Carabanchel"         => 3247830,
        "Centro"              => 1353966,
        "Chamartín"           => 1313747,
        "Chamberí"            => 1259587,
        "Ciudad Lineal"       => 2287757,
        "Fuencarral-El Pardo" => 2441608,
        "Hortaleza"           => 1827228,
        "Latina"              => 2927200,
        "Moncloa-Aravaca"     => 1129851,
        "Moratalaz"           => 1067341,
        "Puente de Vallecas"  => 3349186,
        "Retiro"              => 1075155,
        "Salamanca"           => 1286657,
        "San Blas-Canillejas" => 1712043,
        "Tetuán"              => 1677256,
        "Usera"               => 1923216,
        "Vicálvaro"           => 879529,
        "Villa de Vallecas"   => 1220810,
        "Villaverde"          => 2030275
      }
    end

    def update_heading_population
      update_city_heading_population
      update_district_heading_population
    end

    def update_city_heading_population
      budget.headings.where(name: "Toda la ciudad").first&.update(population: city_population)
    end

    def update_district_heading_population
      population_by_heading.each do |heading_name, population|
        budget.headings.where(name: heading_name).first&.update(population: population)
      end
    end

    def city_population
      population_by_heading.collect {|district, population| population}.sum
    end

    def population_by_heading
      {
        "Arganzuela"          => 131429,
        "Barajas"             =>  37725,
        "Carabanchel"         => 205197,
        "Centro"              => 120867,
        "Chamartín"           => 123099,
        "Chamberí"            => 122280,
        "Ciudad Lineal"       => 184285,
        "Fuencarral-El Pardo" => 194232,
        "Hortaleza"           => 146471,
        "Latina"              => 204427,
        "Moncloa-Aravaca"     =>  99274,
        "Moratalaz"           =>  82741,
        "Puente de Vallecas"  => 194314,
        "Retiro"              => 103666,
        "Salamanca"           => 126699,
        "San Blas-Canillejas" => 127800,
        "Tetuán"              => 133972,
        "Usera"               => 112158,
        "Vicálvaro"           =>  55783,
        "Villa de Vallecas"   =>  82504,
        "Villaverde"          => 117478
      }
    end

    def update_selected_investments
      ::SpendingProposal.feasible.valuation_finished.each do |spending_proposal|
        find_budget_investment(spending_proposal)&.update(selected: true)
      end
    end

    def remove_forum_votes
      forums.each do |forum|
        forum.user.votes.where(votable: budget.investments).destroy_all
      end
    end

    def remove_forum_ballots
      forums.each do |forum|
        Budget::Ballot.where(user: forum.user).first&.destroy
      end
    end

    def update_cached_votes
      budget.investments.map(&:update_cached_votes)
    end

    def update_cached_ballots
      budget.investments.each do |investment|
        ballot_lines_count = budget.lines.where(investment: investment).count
        investment.update(ballot_lines_count: ballot_lines_count)
      end
    end

    def calculate_winners
      budget.headings.each do |heading|
        Budget::Result.new(budget, heading).calculate_winners
      end
    end

    def forums
      Forum.all
    end

    def find_budget_investment(spending_proposal)
      budget.investments.where(original_spending_proposal_id: spending_proposal.id).first
    end

    def find_budget
      ::Budget.where(slug: 2016).first
    end

end
