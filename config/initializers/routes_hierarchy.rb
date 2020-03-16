# This module is expanded in order to make it easier to use polymorphic
# routes with nested resources.
# HACK: is there a way to avoid monkey-patching here? Using helpers is
# a similar use of a global namespace too...
module ActionDispatch::Routing::UrlFor
  def resource_hierarchy_for(resource)
    if polymorphic_mapping(resource)
      resolve = polymorphic_mapping(resource).send(:eval_block, self, resource, {})

      if resolve.last.is_a?(Hash)
        [*resolve[0..-2], *resolve.last.values].grep_v(Symbol)
      else
        resolve
      end
    else
      resource
    end
  end

  def admin_polymorphic_path(resource, options = {})
    polymorphic_path([:admin, *resource_hierarchy_for(resource)], options)
  end
end
