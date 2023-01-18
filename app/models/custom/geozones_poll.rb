require_dependency Rails.root.join("app", "models", "geozones_poll").to_s

class GeozonesPoll
  audited on: [:create, :update, :destroy]
end
