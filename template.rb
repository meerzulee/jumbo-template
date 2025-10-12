# Rails 8 Application Template
# Usage: rails new my_app --template=https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/template.rb

def add_gems
  # General gems
  gem "trailblazer-rails"
  gem "local_time"
  gem "honeybadger", "~> 6.0"
  gem "authentication-zero", "~> 4.0"
  gem "rest-client", "~> 2.1"

  # Development and test gems
  gem_group :development, :test do
    gem "pgreset"
  end

  # Development only gems
  gem_group :development do
    gem "annotaterb"
    gem "letter_opener"
    gem "solargraph"
    gem "solargraph-rails"
    gem "rbs"
    gem "rubocop"
    gem "good_migrations"
  end
end

def setup_initializers
  # Create custom initializers
  # You can use your generator or create files directly

  # Example: Create a custom initializer
  # initializer 'custom_config.rb', <<~RUBY
  #   Rails.application.config.custom_setting = true
  # RUBY
end

def setup_generators
  # Configure Rails generators
  initializer 'generators.rb', <<~RUBY
    Rails.application.config.generators do |g|
      g.test_framework :test_unit, fixture: false
      g.stylesheets false
      g.javascripts false
      g.helper false
    end
  RUBY
end

def add_routes
  # Add custom routes
  # route "root 'pages#home'"
end

def setup_database
  # Database configuration changes if needed
  # rails_command "db:create"
  # rails_command "db:migrate"
end

def setup_frontend
  # Frontend setup (Tailwind, etc.)
  # rails_command "tailwindcss:install" if yes?("Install Tailwind CSS?")
end

def setup_authentication
  # Authentication setup
  # generate "devise:install" if yes?("Install Devise for authentication?")
end

def setup_git
  # Git setup
  git :init
  git add: "."
  git commit: "-m 'Initial commit with custom template'"
end

def create_custom_files
  # Create any custom files or directories
  # directory "app/services"
  # create_file "app/services/.keep"
end

# Add gems to Gemfile (before bundle install)
add_gems

# Main execution flow (runs after bundle install)
after_bundle do
  say "Setting up initializers...", :green
  setup_initializers
  setup_generators

  say "Configuring routes...", :green
  add_routes

  say "Setting up database...", :green
  setup_database

  say "Setting up frontend...", :green
  setup_frontend if yes?("Would you like to configure frontend?")

  say "Setting up authentication...", :green
  setup_authentication if yes?("Would you like to set up authentication?")

  say "Creating custom files and directories...", :green
  create_custom_files

  say "Setting up Git repository...", :green
  setup_git if yes?("Initialize Git repository?")

  say "=" * 60, :green
  say "Template applied successfully!", :green
  say "=" * 60, :green
  say "Next steps:", :yellow
  say "  1. cd #{app_name}", :yellow
  say "  2. rails server", :yellow
  say "=" * 60, :green
end
