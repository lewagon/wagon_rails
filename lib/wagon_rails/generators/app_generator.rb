require 'colorize'
require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module WagonRails
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, type: :string, aliases: "-d", default: "postgresql",
      desc: "Configure for selected database (options: #{DATABASES.join("/")})"

    class_option :skip_heroku, type: :boolean, default: false,
      desc: "Create production Heroku app"

    class_option :skip_github, type: :boolean, default: false,
      desc: "Create GitHub repository"

    class_option :skip_test_unit, type: :boolean, aliases: "-T", default: true,
      desc: "Skip Test::Unit files"

    class_option :skip_turbolinks, type: :boolean, default: true,
      desc: "Skip turbolinks gem"

    class_option :skip_bundle, type: :boolean, aliases: "-B", default: true,
      desc: "Don't run bundle install"

    def finish_template
      invoke :wagon_rails_customization
      super
    end

    def wagon_rails_customization
      invoke :setup_git
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_production_environment
      invoke :create_wagon_rails_views
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :setup_javascripts
      invoke :copy_miscellaneous_files
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :add_root_route
      invoke :setup_auth
      invoke :setup_database
      invoke :create_github_repo
      invoke :first_commit
      invoke :first_push
      invoke :create_heroku_app
      invoke :outro
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used

      bundle_command 'install'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' ==
        [:database]
        build :use_postgres_config_template
      end

      build :create_database
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_on_delivery_errors
      build :set_development_delivery_method
      build :raise_on_unpermitted_parameters
      build :configure_generators
      build :configure_i18n_for_missing_translations
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :configure_smtp
      build :enable_rack_deflater
    end

    def create_wagon_rails_views
      say 'Creating wagon_rails views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_application_layout
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :configure_rack_timeout
      build :configure_simple_form
      build :disable_xml_params
      build :fix_i18n_deprecation_warning
      build :configure_puma
      build :setup_foreman
      build :setup_paperclip
      build :copy_application_yml
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def setup_javascripts
      say 'Set up javascripts'
      build :setup_javascripts
    end

    def setup_git
      unless options[:skip_git]
        say 'Initializing git'
        invoke :setup_gitignore
        invoke :init_git
      end
    end

    def setup_auth
      build :generate_devise
      build :generate_user
      build :install_navbar
      build :generate_devise_views
      build :generate_pundit
      build :setup_application_controller
    end

    def create_heroku_app
      unless options[:skip_heroku]
        say "Creating Heroku app"
        build :create_heroku_app
        build :set_heroku_remote
        build :provide_deploy_script
        build :add_host_to_application_yml
        build :commit, "Add heroku deploy script"
      end
    end

    def create_github_repo
      unless options[:skip_github]
        say 'Creating Github repo'
        build :create_github_repo
      end
    end

    def setup_gitignore
      build :gitignore_files
    end

    def init_git
      build :init_git
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def add_root_route
      build :copy_home
      build :configure_high_voltage
    end

    def first_commit
      build :commit, "New rails app generated with lewagon/wagon-rails gem"
    end

    def first_push
      build :first_push
    end

    def outro
      say ""
      say "----> Open config/initializers/devise.rb and update the `mailer_sender`"
      say ""
      say "Congratulations! You're ready to rock!".colorize(:green)
    end

    protected

    def get_builder_class
      WagonRails::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
