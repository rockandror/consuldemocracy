require_dependency Rails.root.join("app", "models", "legislation", "annotation").to_s

class Legislation::Annotation
  audited
end
