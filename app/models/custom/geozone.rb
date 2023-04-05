require_dependency Rails.root.join("app", "models", "geozone").to_s

class Geozone
  audited

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).reject do |association|
      association.name == :audits || association.name == :associated_audits
    end.all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end
end
