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
    around_filter :temporarily_add_multisite_path
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
  def temporarily_add_multisite_path
    if current_site
      begin
        ActionController::Base.view_paths.unshift(File.join(RAILS_ROOT,'sites', @active_site, 'views'))
        logger.debug "paths: " + ActionController::Base.view_paths.join(":")
        yield
      ensure
        ActionController::Base.view_paths.shift
      end
    else
      true
    end
  end
end