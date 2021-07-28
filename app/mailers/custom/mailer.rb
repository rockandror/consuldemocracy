require_dependency Rails.root.join("app", "mailers", "mailer").to_s

class Mailer < ApplicationMailer

  def voting_review(proposal)
    @proposal = proposal
    @email_to = @proposal.author.email
    @author = @proposal.author

    with_user(@author) do
      mail(to: @email_to, subject: t("mailers.proposal.voting_review.subject"))
    end
  end
end
