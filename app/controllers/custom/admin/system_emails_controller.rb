require_dependency Rails.root.join("app", "controllers", "admin", "system_emails_controller").to_s

class Admin::SystemEmailsController
  def index
    @system_emails = {
      proposal_notification_digest: %w[view preview_pending],
      budget_investment_created:    %w[view edit_info],
      budget_investment_selected:   %w[view edit_info],
      budget_investment_unfeasible: %w[view edit_info],
      budget_investment_unselected: %w[view edit_info],
      comment:                      %w[view edit_info],
      reply:                        %w[view edit_info],
      direct_message_for_receiver:  %w[view edit_info],
      direct_message_for_sender:    %w[view edit_info],
      email_verification:           %w[view edit_info],
      user_invite:                  %w[view edit_info],
      evaluation_comment:           %w[view edit_info],
      remove_voting_review:         %w[view edit_info],
      voting_disabled:              %w[view edit_info],
      voting_enabled:               %w[view edit_info],
      voting_review:                %w[view edit_info]
    }
  end

  def view
    case @system_email
    when "proposal_notification_digest"
      load_sample_proposal_notifications
    when /\Abudget_investment/
      load_sample_investment
    when /\Adirect_message/
      load_sample_direct_message
    when "comment"
      load_sample_comment
    when "reply"
      load_sample_reply
    when "email_verification"
      load_sample_user
    when "user_invite"
      @subject = t("mailers.user_invite.subject", org_name: Setting["org_name"])
    when "evaluation_comment"
      load_sample_valuation_comment
    when "remove_voting_review"
      load_sample_remove_voting_review
    when "voting_disabled"
      load_sample_voting_disabled
    when "voting_enabled"
      load_sample_voting_enabled
    when "voting_review"
      load_sample_voting_review
    end
  end

  private

    def load_sample_remove_voting_review
      if Proposal.any?
        @proposal = Proposal.last
        @subject = t("mailers.proposal.#{@system_email}.subject")
        @author = @proposal.author
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_proposals")
      end
    end

    def load_sample_voting_disabled
      if Proposal.any?
        @proposal = Proposal.last
        @subject = t("mailers.proposal.#{@system_email}.subject")
        @author = @proposal.author
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_proposals")
      end
    end

    def load_sample_voting_enabled
      if Proposal.any?
        @proposal = Proposal.last
        @subject = t("mailers.proposal.#{@system_email}.subject")
        @author = @proposal.author
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_proposals")
      end
    end

    def load_sample_voting_review
      if Proposal.any?
        @proposal = Proposal.last
        @subject = t("mailers.proposal.#{@system_email}.subject")
        @author = @proposal.author
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_proposals")
      end
    end
end
