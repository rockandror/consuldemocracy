(function() {
  "use strict";

  App.DashboardGraphs = {
    graphs: [],
    initialize: function() {
      $("[data-proposal-graph-url]").each(function() {
        var graph = new ProposalGraph($(this).data("proposal-graph-url"));
        graph.successfulProposalDataUrl = $(this).data("successful-proposal-graph-url");
        graph.proposalAchievementsUrl = $(this).data("proposal-achievements-url");
        graph.targetId = $(this).attr("id");
        graph.groupBy = $(this).data("proposal-graph-group-by");
        graph.progressLabel = $(this).data("proposal-graph-progress-label");
        graph.supportsLabel = $(this).data("proposal-graph-supports-label");
        graph.successLabel = $(this).data("proposal-graph-success-label");
        graph.proposalSuccess = parseInt($(this).data("proposal-success"), 10);
        graph.resourcesUrl = $(this).data("proposal-resources-url");
        graph.refresh();
        App.DashboardGraphs.graphs.push(graph);
      });
    },
    destroy: function() {
      App.DashboardGraphs.graphs.forEach(function(graph) {
        graph.destroy();
      });
      App.DashboardGraphs.graphs = [];
    }
  };
}).call(this);
