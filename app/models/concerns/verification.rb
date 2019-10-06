module Verification
  extend ActiveSupport::Concern

  included do
    scope :residence_verified, -> { where.not(residence_verified_at: nil) }
    scope :level_three_verified, -> { where.not(verified_at: nil) }
    scope :level_two_verified, -> { where("users.level_two_verified_at IS NOT NULL OR (users.confirmed_phone IS NOT NULL AND users.residence_verified_at IS NOT NULL) AND verified_at IS NULL") }
    scope :level_two_or_three_verified, -> { where("users.verified_at IS NOT NULL OR users.level_two_verified_at IS NOT NULL OR (users.confirmed_phone IS NOT NULL AND users.residence_verified_at IS NOT NULL)") }
    scope :unverified, -> { where("users.verified_at IS NULL AND (users.level_two_verified_at IS NULL AND (users.residence_verified_at IS NULL OR users.confirmed_phone IS NULL))") }
    scope :incomplete_verification, -> { where("(users.residence_verified_at IS NULL AND users.failed_census_calls_count > ?) OR (users.residence_verified_at IS NOT NULL AND (users.unconfirmed_phone IS NULL OR users.confirmed_phone IS NULL))", 0) }
  end

  def skip_verification?
    Setting["feature.user.skip_verification"].present?
  end

  def legacy_verification?
    Setting["feature.user.skip_verification"].blank? &&
      Setting["feature.custom_verification_process"].blank?
  end

  def process_verification?
    Setting["feature.user.skip_verification"].blank? &&
      Setting["feature.custom_verification_process"].present?
  end

  def verification_email_sent?
    return true if skip_verification? || process_verification?

    email_verification_token.present?
  end

  def verification_sms_sent?
    return true if skip_verification? || process_verification?

    unconfirmed_phone.present? && sms_confirmation_code.present?
  end

  def verification_letter_sent?
    return true if skip_verification? || process_verification?

    letter_requested_at.present? && letter_verification_code.present?
  end

  def residence_verified?
    return true if skip_verification?

    return residence_verified_at.present? if legacy_verification?

    is_last_verification_process_verified?
  end

  def sms_verified?
    return true if skip_verification?

    return confirmed_phone.present? if legacy_verification?

    last_verification_process.present? && last_verification_process.verified_phone?
  end

  def level_two_verified?
    return true if skip_verification?

    return level_two_verified_at.present? || (residence_verified? && sms_verified?) if legacy_verification?

    is_last_verification_process_verified?
  end

  def level_three_verified?
    return true if skip_verification?

    return verified_at.present? if legacy_verification?

    is_last_verification_process_verified?
  end

  def level_two_or_three_verified?
    level_two_verified? || level_three_verified?
  end

  def unverified?
    !level_two_or_three_verified?
  end

  def failed_residence_verification?
    !residence_verified? && !failed_census_calls.empty?
  end

  def no_phone_available?
    !verification_sms_sent?
  end

  def user_type
    if level_three_verified?
      :level_3_user
    elsif level_two_verified?
      :level_2_user
    else
      :level_1_user
    end
  end

  def sms_code_not_confirmed?
    !sms_verified?
  end

  def last_verification_process
    verification_processes.last
  end

  def is_last_verification_process_verified?
    last_verification_process.present? && last_verification_process.verified?
  end
end
