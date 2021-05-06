module UsersHelper

  def humanize_document_type(document_type)
    case document_type
    when "1"
      t "verification.residence.new.document_type.spanish_id"
    when "2"
      t "verification.residence.new.document_type.passport"
    when "3"
      t "verification.residence.new.document_type.residence_card"
    end
  end

  def comment_commentable_title(comment)
    commentable = comment.commentable
    if commentable.nil?
      deleted_commentable_text(comment)
    elsif commentable.hidden?
      content_tag(:del, commentable.title) + " " +
      content_tag(:span, "(" + deleted_commentable_text(comment) + ")", class: "small")
    else
      link_to(commentable.title, comment)
    end
  end

  def deleted_commentable_text(comment)
    case comment.commentable_type
    when "Proposal"
      t("users.show.deleted_proposal")
    when "Debate"
      t("users.show.deleted_debate")
    when "Budget::Investment"
      t("users.show.deleted_budget_investment")
    else
      t("users.show.deleted")
    end
  end

  def current_only_admins?
    current_user && (!Superadministrator.find_by(user_id: current_user.id).blank? || !Administrator.find_by(user_id: current_user.id).blank? || !Manager.find_by(user_id: current_user.id).blank?)
  end

  def current_administrator?
    current_user && (current_user.administrator? || current_user.profiles_id.to_s == "2" )
  end

  def current_sures?
    current_user && (current_user.sures? || current_user.profiles_id.to_s == "3")
  end

  def current_super_administrator?
    current_user && (current_user.super_administrator? || current_user.profiles_id.to_s == "1")
  end

  def current_editor?
    current_user && (current_user.editor? || current_user.profiles_id.to_s == "8")
  end

  def current_consultant?
    current_user && (current_user.consultant? || current_user.profiles_id.to_s == "8")
  end

  def current_moderator?
    current_user && (current_user.moderator? || current_user.profiles_id.to_s == "6")
  end

  def current_valuator?
    current_user && (current_user.valuator? || current_user.profiles_id.to_s == "7")
  end

  def current_manager?
    current_user && (current_user.manager? || current_user.profiles_id.to_s == "5")
  end

  def current_section_administrator?
    current_user && (current_user.section_administrator? || current_user.profiles_id.to_s == "4")
  end

  def current_poll_officer?
    current_user && current_user.poll_officer?
  end

  def show_admin_menu?(user = nil)
    unless namespace == "officing"
      current_administrator? || current_sures? || current_editor? || current_consultant? || current_moderator? || current_valuator? || current_manager? || current_section_administrator? ||
      (user && (user.administrator? || user.sures? || user.super_administrator? || user.section_administrator?)) || current_poll_officer? ||  current_super_administrator?
    end
  end

  def interests_title_text(user)
    if current_user == user
      t("account.show.public_interests_my_title_list")
    else
      t("account.show.public_interests_user_title_list")
    end
  end

  def is_moderated?(comment)
    comment.moderated_contents.any? &&
    !comment.moderated_contents.map(&:declined_at).all?
  end

  def moderated_label_text(comment)
    return t("users.show.labels.confirmed_moderation") if comment.confirmed_moderation?
    t("users.show.labels.pending_moderated")
  end

  def moderated_label_class(comment)
    return "alert" if comment.confirmed_moderation?
    "warning"
  end

end
