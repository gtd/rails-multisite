# Extend the Base ActionController to support multiple site
ActionController::Base.class_eval do 

  attr_accessor :current_site

  # Use this in your controller just like the <tt>layout</tt> macro.
  # Example:
  #
  #  site 'maybe_domain'
  #
  # -or-
  #
  #  site :get_site
  #
  #  def get_site
  #    'maybe_domain'
  #  end
  def self.site(site_name)
    write_inheritable_attribute "site", site_name
    before_filter :add_multisite_path
  end

  # Retrieves the current set site
  def current_site(passed_site=nil)
    site = passed_site || self.class.read_inheritable_attribute("site")

    @active_site = case site
      when Symbol then send(site)
      when Proc   then site.call(self)
      when String then site
    end
  end

  protected
  def add_multisite_path
    if current_site
      raise "Multisite plugin is incompatible with template caching.  You must set config.action_view.cache_template_loading to false in your environment." if ActionView::Base.cache_template_loading
      raise "Multisite plugin is incompatible with template extension caching.  You must set config.action_view.cache_template_extensions to false in your environment." if ActionView::Base.cache_template_extensions
      new_path = File.join(RAILS_ROOT, 'sites', @active_site, 'views')
      @template.prepend_view_path(new_path)
      logger.info "  Template View Paths: #{@template.view_paths.inspect}"
    end
    return true
  end
end