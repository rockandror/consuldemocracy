require_dependency Rails.root.join("app", "models", "audit")

class Audit
  scope :by_class_and_id, ->(class_name, id) do
    where("(auditable_type = :class_name and auditable_id = :id) or
           (associated_type = :class_name and associated_id = :id)",
          class_name: class_name,
          id: id)
  end
end
