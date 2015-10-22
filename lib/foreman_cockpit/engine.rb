module ForemanCockpit
  class Engine < ::Rails::Engine
    engine_name 'foreman_cockpit'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    initializer 'foreman_cockpit.register_plugin', after: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_cockpit do
        requires_foreman '>= 1.7'
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        Host::Managed.send(:include, ForemanCockpit::HostExtensions)
        HostsHelper.send(:include, ForemanCockpit::HostsHelperExtensions)
      rescue => e
        Rails.logger.warn "ForemanCockpit: skipping engine hook (#{e})"
      end
    end

    initializer 'foreman_cockpit.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_cockpit'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
