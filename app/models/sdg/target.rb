class SDG::Target < ApplicationRecord
  validates :code, presence: true, uniqueness: { scope: :goal_id }
  validates :goal, presence: true

  belongs_to :goal

  def title
    I18n.t("sdg.goals.goal_#{goal.code}.targets.target_#{code_key}.title")
  end

  private

    def code_key
      code.gsub(".", "_")
    end
end
