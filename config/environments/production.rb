require Rails.root.join("config", "secret") if Rails.root.join("config", "secret.rb").file?
require_relative "../../lib/gemcutter/middleware/redirector"
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = {
    'Cache-Control' => 'max-age=315360000, public',
    'Expires' => 'Thu, 31 Dec 2037 23:55:55 GMT'
  }

  # Compress JavaScript using a preprocessor
  config.assets.js_compressor = :terser

  # Compress CSS using a preprocessor.
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = {
    hsts: { expires: 365.days, subdomains: false },
    redirect: {
      exclude: ->(request) { request.path.start_with?('/internal') }
    }
  }

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info
  config.rails_semantic_logger.format = :json
  config.rails_semantic_logger.semantic = true
  config.rails_semantic_logger.add_file_appender = false
  SemanticLogger.add_appender(io: $stdout, formatter: :json)

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "gemcutter_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: Gemcutter::HOST,
                                               protocol: Gemcutter::PROTOCOL }

  # roadie-rails recommends not setting action_mailer.asset_host and use its own configuration for URL options
  config.roadie.url_options = { host: Gemcutter::HOST, scheme: Gemcutter::PROTOCOL }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.cache_store = :mem_cache_store, ENV['MEMCACHED_ENDPOINT'], {
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2,
    compress: true,
    compression_min_size: 524_288,
    value_max_bytes: 2_097_152 # 2MB
  }

  config.middleware.use Gemcutter::Middleware::Redirector
end
