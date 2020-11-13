require "rails_helper"

describe SDG::Target do
  it "is valid" do
    expect(build(:sdg_target, code: "1.Z", goal: SDG::Goal.find_by(code: "1"))).to be_valid
  end

  it "is not valid without a code" do
    expect(build(:sdg_target, code: nil)).not_to be_valid
  end

  it "is not valid without a goal" do
    target = build(:sdg_target, goal: nil)

    expect(target).not_to be_valid
  end

  it "is not valid when code is duplicated for the same parent goal" do
    goal = SDG::Goal.find_by!(code: "1")
    create(:sdg_target, code: "1.Z", goal: goal)

    expect(build(:sdg_target, code: "1.Z", goal: goal)).not_to be_valid
  end

  it "translates description" do
    target = SDG::Target.find_by!(code: "1.1", goal: SDG::Goal.find_by(code: "1"))

    expect(target.title).to start_with "1.1 By 2030, eradicate extreme poverty"

    I18n.with_locale(:es) do
      expect(target.title).to start_with "1.1 Para 2030, erradicar la pobreza extrema"
    end

    target = SDG::Target.find_by!(code: "17.11", goal: SDG::Goal.find_by(code: "17"))

    expect(target.title).to start_with "17.11 Significantly increase the exports of developing countries"

    I18n.with_locale(:es) do
      expect(target.title).to start_with "17.11 Aumentar significativamente las exportaciones de los países"
    end
  end
end
