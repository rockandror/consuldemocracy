module Auditable
  extend ActiveSupport::Concern

  included do
    audited on: [:update, :destroy]
    has_associated_audits

    class << self
      alias_method :original_auditing_enabled, :auditing_enabled

      def auditing_enabled
        original_auditing_enabled &&
          (audited_class_names.include?(name) ||
          (translation_class? && module_parent.auditing_enabled))
      end

      def audited_class_names
        %w[
          Banner
          Banner::Section
          Budget
          Budget::Ballot
          Budget::Ballot::Line
          Budget::ContentBlock
          Budget::Group
          Budget::Heading
          Budget::Investment
          Budget::Phase
          Budget::ReclassifiedVote
          Budget::ValuatorAssignment
          Budget::ValuatorGroupAssignment
          BudgetAdministrator
          BudgetValuator
          Campaign
          Comment
          Community
          Dashboard::Action
          Dashboard::AdministratorTask
          Dashboard::ExecutedAction
          Debate
          Document
          FailedCensusCall
          Flag
          Follow
          Geozone
          GeozonesPoll
          I18nContent
          I18nContentTranslation
          Identity
          Image
          Legislation::Annotation
          Legislation::Answer
          Legislation::DraftVersion
          Legislation::Process
          Legislation::Proposal
          Legislation::Question
          Legislation::QuestionOption
          Link
          LocalCensusRecord
          MapLocation
          Milestone
          Milestone::Status
          Newsletter
          Notification
          Organization
          Poll
          Poll::Answer
          Poll::Ballot
          Poll::BallotSheet
          Poll::Booth
          Poll::BoothAssignment
          Poll::Officer
          Poll::OfficerAssignment
          Poll::PartialResult
          Poll::Question
          Poll::Question::Answer
          Poll::Question::Answer::Video
          Poll::Recount
          Poll::Shift
          Poll::Voter
          ProgressBar
          Proposal
          ProposalNotification
          RelatedContent
          RelatedContentScore
          Report
          SDG::Goal
          SDG::LocalTarget
          SDG::Manager
          SDG::Phase
          SDG::Relation
          SDG::Review
          SDG::Target
          Setting
          Signature
          SignatureSheet
          SiteCustomization::ContentBlock
          SiteCustomization::Image
          SiteCustomization::Page
          StatsVersion
          Tenant
          Topic
          User
          Valuator
          ValuatorGroup
          VerifiedUser
          VotationType
          WebSection
          Widget::Card
          Widget::Feed
        ]
      end

      def translation_class?
        (self < Globalize::ActiveRecord::Translation) == true
      end

      def audit_associated_with
        :globalized_model if translation_class?
      end

      protected

        # As audited gem does not support a proc for :only and :expect configuration
        # options we override the method that calculates the non audited columns
        def calculate_non_audited_columns
          non_audited_columns = default_ignored_attributes
          if excluded_columns_by_class[key]
            non_audited_columns += excluded_columns_by_class[key]
          end
          if respond_to?(:globalize_attribute_names?)
            non_audited_columns += translated_attribute_names.map(&:to_s)
          end
          if translation_class?
            non_audited_columns += excluded_columns_by_class[:translation]
          end
          non_audited_columns
        end

        # Add the class and the fields you want to ignore using downcase and underscored names
        def excluded_columns_by_class
          {
            user: %w[sign_in_count last_sign_in_at current_sign_in_at],
            translation: %w[locale hidden_at]
          }
        end

        def key
          name.snakecase.gsub("/", "_").to_sym
        end
    end
  end
end
