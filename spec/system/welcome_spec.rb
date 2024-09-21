require "rails_helper"

describe "Welcome screen" do
  let(:budget) { create(:budget) }

  it_behaves_like "remotely_translatable", :proposal, "root_path", {}
  it_behaves_like "remotely_translatable", :debate, "root_path", {}
  it_behaves_like "remotely_translatable", :legislation_process, "root_path", {}
end
