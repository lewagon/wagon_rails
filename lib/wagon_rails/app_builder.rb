module WagonRails
  class AppBuilder < Rails::AppBuilder
    include WagonRails::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def raise_on_delivery_errors
      %w(development production).each do |environment|
        replace_in_file "config/environments/#{environment}.rb",
          'raise_delivery_errors = false', 'raise_delivery_errors = true'
        config = "config.action_mailer.raise_delivery_errors = true"
        uncomment_lines("config/environments/#{environment}.rb", config)
      end
    end

    def set_development_delivery_method
      inject_into_file(
        "config/environments/development.rb",
        "\n  config.action_mailer.delivery_method = :letter_opener",
        after: "config.action_mailer.raise_delivery_errors = true",
      )
    end

    def raise_on_unpermitted_parameters
      config = <<-RUBY
    config.action_controller.action_on_unpermitted_parameters = :raise
      RUBY

      inject_into_class "config/application.rb", "Application", config
    end

    def enable_embed_authenticity_token_in_remote_forms
      config = <<-RUBY
    config.embed_authenticity_token_in_remote_forms = true
      RUBY

      inject_into_class "config/application.rb", "Application", config
    end

    def configure_generators
      config = <<-RUBY

    config.generators do |generate|
      generate.helper true
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      # generate.test_framework :rspec
      generate.view_specs false
    end

      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_smtp
      copy_file 'smtp.rb', 'config/smtp.rb'

      prepend_file 'config/environments/production.rb',
        %{require Rails.root.join("config/smtp")\n}

      config = <<-RUBY

  config.action_mailer.delivery_method = :smtp
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => 'config.action_mailer.raise_delivery_errors = true'
    end

    def enable_rack_deflater
      config = <<-RUBY

  # Enable deflate / gzip compression of controller-generated responses
  config.middleware.use Rack::Deflater
      RUBY

      inject_into_file(
        "config/environments/production.rb",
        config,
        after: serve_static_files_line
      )
    end

    def disallow_wrapping_parameters
      remove_file "config/initializers/wrap_parameters.rb"
    end

    def create_partials_directory
      empty_directory 'app/views/shared'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb', 'app/views/shared/_flashes.html.erb'
    end

    def create_application_layout
      template 'wagon_rails_layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        force: true
    end

    def use_postgres_config_template
      template 'postgresql_database.yml.erb', 'config/database.yml',
        force: true
    end

    def create_database
      bundle_command 'exec rake db:create db:migrate'
    end

    def replace_gemfile
      remove_file 'Gemfile'
      template 'Gemfile.erb', 'Gemfile'
    end

    def set_ruby_to_version_being_used
      create_file '.ruby-version', "#{WagonRails::RUBY_VERSION}\n"
    end

    def enable_database_cleaner
      copy_file 'database_cleaner_rspec.rb', 'spec/support/database_cleaner.rb'
    end

    def configure_i18n_for_missing_translations
      raise_on_missing_translations_in("development")
      raise_on_missing_translations_in("test")
    end

    def configure_rack_timeout
      copy_file 'rack_timeout.rb', 'config/initializers/rack_timeout.rb'
    end

    def configure_simple_form
      bundle_command "exec rails generate simple_form:install --bootstrap"
    end

    def configure_action_mailer
      action_mailer_host "development", %{"localhost:#{port}"}
      action_mailer_host "production", %{ENV.fetch("HOST")}
    end

    def fix_i18n_deprecation_warning
      config = <<-RUBY
    config.i18n.enforce_available_locales = true
      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_puma
      copy_file 'puma.rb', 'config/puma.rb'
    end

    def setup_foreman
      copy_file 'Procfile', 'Procfile'
    end

    def copy_application_yml
      copy_file 'application.yml', 'config/application.yml'
    end

    def setup_paperclip
      copy_file 'paperclip.rb', 'config/initializers/paperclip.rb'
    end

    def setup_stylesheets
      run 'rm -rf app/assets/stylesheets'
      run 'curl -L https://github.com/lewagon/rails-stylesheets/archive/master.zip > app/assets/stylesheets.zip'
      run 'cd app/assets &&  unzip stylesheets.zip && rm stylesheets.zip && mv rails-stylesheets-master stylesheets & cd ../..'
    end

    def setup_javascripts
      remove_file 'app/assets/javascripts/application.js'
      copy_file 'application.js', 'app/assets/javascripts/application.js'
      run 'mkdir app/assets/javascripts/app'
      run 'touch app/assets/javascripts/app/.keep'
    end

    def gitignore_files
      remove_file '.gitignore'
      copy_file 'wagon_rails_gitignore', '.gitignore'
      # [
      #   'app/views/shared'
      # ].each do |dir|
      #   run "mkdir #{dir}"
      #   run "touch #{dir}/.keep"
      # end
    end

    def init_git
      run 'git init'
    end

    def commit(message)
      run "git add ."
      run "git commit -m '#{message}'"
    end

    def create_heroku_app
      region = "eu"  # or 'us'
      run_heroku "create #{heroku_app_name} --region #{region}"
    end

    def set_heroku_remote
      run "git remote add heroku git@heroku.com:#{heroku_app_name}.git"
    end

    def add_host_to_application_yml
      host = <<-EOF
production:
  HOST: https://#{heroku_app_name}.herokuapp.com
      EOF

      append_file "config/application.yml", host
    end

    def push_env_to_heroku
      run "figaro heroku:set -e production"
    end

    def provide_deploy_script
      copy_file "bin_deploy", "bin/deploy"

      instructions = <<-MARKDOWN

## Deploying

    $ bin/deploy
      MARKDOWN

      append_file "README.md", instructions
      run "chmod u+x bin/deploy"
    end

    def create_github_repo
      path_addition = override_path_for_tests
      run "#{path_addition} hub create"
    end

    def copy_miscellaneous_files
      copy_file "errors.rb", "config/initializers/errors.rb"
      copy_file "json_encoding.rb", "config/initializers/json_encoding.rb"
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset="utf-8" />
  <meta name="ROBOTS" content="NOODP" />
  <meta name="viewport" content="initial-scale=1" />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Rails\.application\.routes\.draw do.*end/m,
        "Rails.application.routes.draw do\nend"
    end

    def copy_home
      copy_file 'wagon_rails_home.html.erb', 'app/views/pages/home.html.erb'
    end

    def configure_high_voltage
      copy_file 'high_voltage.rb', 'config/initializers/high_voltage.rb'
    end

    def disable_xml_params
      copy_file 'disable_xml_params.rb', 'config/initializers/disable_xml_params.rb'
    end

    def generate_devise
      generate 'devise:install'
    end

    def generate_user
      generate 'devise User'
    end

    # def generate_pundit
    #   generate 'pundit:install'
    # end

    def generate_annotate
      generate 'annotate:install'
    end

    def install_navbar
      run 'curl https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_with_login.html.erb > app/views/shared/_navbar.html.erb'
      run 'curl http://lorempixel.com/200/50/abstract/ > app/assets/images/logo.jpg'
    end

    def generate_devise_views
      generate 'devise:views:i18n_templates'
      remove_file 'app/views/devise/registrations/new.html.erb'
      copy_file 'devise_registrations_new.html.erb', 'app/views/devise/registrations/new.html.erb'
      remove_file 'app/views/devise/sessions/new.html.erb'
      copy_file 'devise_sessions_new.html.erb', 'app/views/devise/sessions/new.html.erb'
    end

    def setup_application_controller
      remove_file 'app/controllers/application_controller.rb'
      copy_file 'application_controller.rb', 'app/controllers/application_controller.rb'
    end

    def first_push
      run "git push -u origin master"
    end

    private

    def raise_on_missing_translations_in(environment)
      config = 'config.action_view.raise_on_missing_translations = true'

      uncomment_lines("config/environments/#{environment}.rb", config)
    end

    def override_path_for_tests
      if ENV['TESTING']
        support_bin = File.expand_path(File.join('..', '..', 'spec', 'fakes', 'bin'))
        "PATH=#{support_bin}:$PATH"
      end
    end

    def run_heroku(command)
      path_addition = override_path_for_tests
      run "#{path_addition} heroku #{command}"
    end

    def heroku_app_name
      "#{app_name}-production"
    end

    def generate_secret
      SecureRandom.hex(64)
    end

    def port
      @port ||= 3000
    end

    def serve_static_files_line
      "config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?\n"
    end
  end
end
