require "rails_helper"

describe "Custom routes" do
  describe "custom budget stats route" do
    it "recognizes standard routes" do
      expect(get: "/budgets/1/stats").to route_to(
        controller: "budgets/stats", action: "show", budget_id: "1"
      )
    end

    it "recognizes custom routes" do
      expect(get: "/presupuestos/presupuestos-2018/estadisticas").to route_to(
        controller: "budgets/stats", action: "show", budget_id: "presupuestos-2018"
      )
    end

    it "generates custom routes" do
      budget = create(:budget, slug: "presupuestos-2018")

      expect(budget_stats_path(budget)).to eq "/presupuestos/presupuestos-2018/estadisticas"
    end
  end

  describe "custom budget results route" do
    it "recognizes standard routes" do
      expect(get: "/budgets/1/results").to route_to(
        controller: "budgets/results", action: "show", budget_id: "1"
      )
    end

    it "recognizes custom routes" do
      expect(get: "/presupuestos/presupuestos-2018/resultados").to route_to(
        controller: "budgets/results", action: "show", budget_id: "presupuestos-2018"
      )
    end

    it "generates custom routes" do
      budget = create(:budget, slug: "presupuestos-2018")

      expect(budget_results_path(budget)).to eq "/presupuestos/presupuestos-2018/resultados"
    end
  end

  describe "custom budget executions route" do
    it "recognizes standard routes" do
      expect(get: "/budgets/1/executions").to route_to(
        controller: "budgets/executions", action: "show", budget_id: "1"
      )
    end

    it "recognizes custom routes" do
      expect(get: "/presupuestos/presupuestos-2018/ejecuciones").to route_to(
        controller: "budgets/executions", action: "show", budget_id: "presupuestos-2018"
      )
    end

    it "generates custom routes" do
      budget = create(:budget, slug: "presupuestos-2018")

      expect(budget_executions_path(budget)).to eq "/presupuestos/presupuestos-2018/ejecuciones"
    end
  end
end
