require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  validate :postal_code_in_burgos
  validate :residence_in_burgos

  def postal_code_in_burgos
    return if valid_postal_code?

    errors.add(:postal_code, I18n.t("verification.residence.new.error_not_allowed_postal_code"))
  end

  def residence_in_burgos
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_burgos, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      postal_code =~ /^09/
    end
end
