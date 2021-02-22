require "rails_helper"

describe MapLocationsHelper do
  context "#related_proposals_coordinates" do
    it "returns related proposals by any tag for given proposal" do
      proposal = create(:proposal, tag_list: "culture, sports", map_location: create(:map_location))
      sports_proposal = create(:proposal, tag_list: "sports", map_location: create(:map_location))
      culture_proposal = create(:proposal, tag_list: "culture", map_location: create(:map_location))
      draft_proposal = create(:proposal, :draft, tag_list: "culture", map_location: create(:map_location))
      archived_proposal = create(:proposal, :archived, tag_list: "sports", map_location: create(:map_location))
      retired_proposal = create(:proposal, :retired, tag_list: "culture", map_location: create(:map_location))
      unlocated_proposal = create(:proposal, tag_list: "sports")

      map_locations = map_related_proposals_coordinates(proposal)
      ids = map_locations.collect { |map_location| map_location[:proposal_id] }
      expect(ids).to include(sports_proposal.id, culture_proposal.id)
      expect(ids).not_to include(proposal.id, draft_proposal.id, archived_proposal.id, retired_proposal.id, unlocated_proposal.id)
    end
  end
end
