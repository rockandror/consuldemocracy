require_dependency Rails.root.join("app", "components", "shared", "tag_list_component").to_s

class Shared::TagListComponent
  private

    alias_method :consul_taggables_path, :taggables_path

    def taggables_path(taggable, tag_name)
      case taggable.class.name
      when "Legislation::Process"
        legislation_processes_path(search: tag_name)
      else
        consul_taggables_path(taggable, tag_name)
      end
    end
end
