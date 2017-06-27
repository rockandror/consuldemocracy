module InterestsHelper

  def show_follow_action?(interestable)
    current_user && !interested?(interestable)
  end

  def show_unfollow_action?(interestable)
    current_user && interested?(interestable)
  end

  def follow_entity_text(entity)
    t('shared.follow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  def unfollow_entity_text(entity)
    t('shared.unfollow_entity', entity: t("activerecord.models.#{entity}.one").downcase)
  end

  private

    def interested?(interestable)
      Interest.interested?(current_user, interestable)
    end

end
