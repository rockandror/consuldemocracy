# This module is expanded in order to make it easier to use polymorphic
# routes with nested resources.
# HACK: is there a way to avoid monkey-patching here? Using helpers is
# a similar use of a global namespace too...
module ActionDispatch::Routing::UrlFor
  def resource_hierarchy_for(resource)
    resolve = resolve_for(resource)

    return resource unless resolve
    resolve.last.is_a?(Hash) ? [resolve.first, *resolve.last.values] : resolve
  end

  def admin_polymorphic_path(resource, options = {})
    if %w[Budget::Group Budget::Heading Poll::Booth Poll::Officer
          Poll::Question Poll::Question::Answer::Video].include?(resource.class.name)
      resolve = resolve_for(resource)
      resolve_options = resolve.pop

      polymorphic_path([:admin, *resolve], options.merge(resolve_options))
    else
      polymorphic_path([:admin, *resource_hierarchy_for(resource)], options)
    end
  end

  private

    def resolve_for(resource)
      polymorphic_mapping(resource)&.send(:eval_block, self, resource, {})
    end
end
