# Jumbo Rails Template
# Usage (local):  rails new {project_name} --database=postgresql --skip-javascript -m t
# Usage (remote): rails new {project_name} --database=postgresql --skip-javascript -m https://rails.mrz.sh/t

REMOTE_ROOT = "https://rails.mrz.sh/template"
LOCAL_ROOT = File.join(__dir__, "template")

# Feature groups that users can select during template generation
FEATURE_GROUPS = {
  inertia: {
    name: 'Inertia Rails',
    desc: 'React + TypeScript + Tailwind + shadcn/ui + Vite',
    skip_flag: '--skip-inertia'
  },
  multistaging: {
    name: 'Multi-staging Environment',
    desc: 'Kamal deploy + Docker + multi-DB + staging/production configs',
    skip_flag: '--skip-multistaging'
  },
  auth: {
    name: 'Authentication',
    desc: 'authentication-zero gem',
    skip_flag: '--skip-auth'
  },
  devtools: {
    name: 'Developer Tools',
    desc: 'RuboCop + Annotaterb + Zellij + Letter Opener',
    skip_flag: '--skip-devtools'
  },
  trailblazer: {
    name: 'Trailblazer',
    desc: 'Business logic organization framework',
    skip_flag: '--skip-trailblazer'
  }
}.freeze

# Parse command-line options
def parse_options
  skip_flags = FEATURE_GROUPS.keys.each_with_object({}) do |key, hash|
    hash[key] = ARGV.include?(FEATURE_GROUPS[key][:skip_flag])
  end

  {
    interactive: ARGV.include?('-i') || ARGV.include?('--interactive'),
    skip: skip_flags
  }
end

def remote?
  !File.exist?(LOCAL_ROOT)
end

def fetch_file(source, destination, options = {})
  if remote?
    get "#{REMOTE_ROOT}/#{source}", destination, options
  else
    copy_file File.join(LOCAL_ROOT, source), destination, options
  end
end

def fetch_directory(source, destination, files)
  if remote?
    empty_directory destination
    files.each { |f| get "#{REMOTE_ROOT}/#{source}/#{f}", "#{destination}/#{f}" }
  else
    directory File.join(LOCAL_ROOT, source), destination
  end
end

def select_features
  opts = parse_options

  # Show available flags in help mode
  if ARGV.include?('--help') || ARGV.include?('-h')
    say "\n=== Jumbo Template Options ===", :blue
    say "  -i, --interactive      Prompt for each feature"
    FEATURE_GROUPS.each do |_key, info|
      say "  #{info[:skip_flag].ljust(22)} Skip #{info[:name]}"
    end
    say "\nExamples:"
    say "  rails new myapp -m template.rb                    # All features (default)"
    say "  rails new myapp -m template.rb -i                 # Interactive mode"
    say "  rails new myapp -m template.rb --skip-auth        # All except auth"
    say "  rails new myapp -m template.rb --skip-inertia --skip-trailblazer"
    say ""
    return FEATURE_GROUPS.keys.each_with_object({}) { |k, h| h[k] = false }
  end

  selected = {}

  if opts[:interactive]
    # Interactive mode - prompt for each feature (default: yes)
    say "\n=== Select Feature Groups ===", :blue
    say "Choose which features to include in your app (press Enter to accept):\n", :white

    FEATURE_GROUPS.each do |key, info|
      response = ask("Include #{info[:name]}? (#{info[:desc]}) [Y/n]")
      selected[key] = response.blank? || response.match?(/^y/i)
    end
    say "\n", :white
  else
    # Default: accept all features except explicitly skipped ones
    skipped_names = opts[:skip].select { |_, v| v }.keys.map { |k| FEATURE_GROUPS[k][:name] }
    if skipped_names.any?
      say "\n=== Installing features (skipping: #{skipped_names.join(', ')}) ===", :blue
    else
      say "\n=== Installing all features ===", :blue
    end

    FEATURE_GROUPS.each do |key, info|
      if opts[:skip][key]
        say "  ✗ #{info[:name]}", :yellow
        selected[key] = false
      else
        say "  ✓ #{info[:name]}", :green
        selected[key] = true
      end
    end
    say ""
  end

  selected
end

def add_gems
  # Inertia Rails group
  if @features[:inertia]
    gem 'inertia_rails', '~> 3.0'
    gem 'js-routes'
    gem 'local_time'
  end

  # Trailblazer group
  gem 'trailblazer-rails' if @features[:trailblazer]

  # Authentication group
  gem 'authentication-zero' if @features[:auth]

  # Developer Tools group
  if @features[:devtools]
    gem_group :development do
      gem 'pgreset'
      gem 'annotaterb'
      gem 'letter_opener'
      gem 'solargraph'
      gem 'solargraph-rails'
      gem 'rbs'
      gem 'rubocop'
      gem 'good_migrations'
    end
  end
end

def setup_inertia
  say 'Setting up Inertia.js with React, TypeScript, and Tailwind...', :blue
  rails_command 'generate inertia:install --framework=react --typescript --package-manager=bun --tailwind --vite --verbose --example-page --force'

  # Workaround for vite_ruby bundler bug (uses deprecated --path flag)
  unless File.exist?('bin/vite')
    say 'Creating bin/vite binstub...', :yellow
    run 'bundle binstubs vite_ruby --force'
  end
end

def setup_shadcn
  say 'Configuring tsconfig files for shadcn/ui...', :blue

  # Configure tsconfig.app.json
  tsconfig_app_path = 'tsconfig.app.json'
  if File.exist?(tsconfig_app_path)
    tsconfig_app = JSON.parse(File.read(tsconfig_app_path))
    tsconfig_app['compilerOptions'] ||= {}
    tsconfig_app['compilerOptions']['baseUrl'] = '.'
    tsconfig_app['compilerOptions']['paths'] = {
      '@/*' => ['./app/frontend/*'],
      '~/*' => ['./app/frontend/*']
    }
    File.write(tsconfig_app_path, JSON.pretty_generate(tsconfig_app) + "\n")
    say "Updated: #{tsconfig_app_path}", :green
  else
    say "File not found: #{tsconfig_app_path}", :red
  end

  # Configure tsconfig.json (shadcn/ui requires different baseUrl and paths)
  tsconfig_path = 'tsconfig.json'
  if File.exist?(tsconfig_path)
    tsconfig = JSON.parse(File.read(tsconfig_path))
    tsconfig['compilerOptions'] ||= {}
    tsconfig['compilerOptions']['baseUrl'] = './app/frontend'
    tsconfig['compilerOptions']['paths'] = {
      '@/*' => ['./*']
    }
    File.write(tsconfig_path, JSON.pretty_generate(tsconfig) + "\n")
    say "Updated: #{tsconfig_path}", :green
  else
    say "File not found: #{tsconfig_path}", :red
  end

  say 'tsconfig files configured for Inertia.js + shadcn/ui', :green

  say 'Installing shadcn/ui...', :blue
  run 'bunx shadcn@latest init --defaults --yes'
  say 'shadcn/ui installed', :green
end

def setup_annotaterb
  say 'Installing annotaterb...', :blue
  rails_command 'generate annotate_rb:install'
  say 'Annotaterb installed', :green
end

def ensure_bun_package_manager
  say 'Ensuring bun is used as package manager...', :blue

  # Remove npm artifacts
  remove_file 'package-lock.json' if File.exist?('package-lock.json')

  # Reinstall with bun
  run 'bun install'

  say 'Bun package manager configured', :green
end

def setup_procfile
  procfile_content = <<~PROCFILE
    web: bin/rails s
    vite: bin/vite dev
  PROCFILE

  if File.exist?('Procfile.dev')
    current_content = File.read('Procfile.dev')
    if current_content != procfile_content
      say 'Updating Procfile.dev...', :yellow
      File.write('Procfile.dev', procfile_content)
    else
      say 'Procfile.dev already configured correctly', :green
    end
  else
    say 'Creating Procfile.dev...', :blue
    File.write('Procfile.dev', procfile_content)
  end
end

def copy_rubocop_config
  say 'Copying RuboCop configuration...', :blue
  fetch_file '.rubocop.yml', '.rubocop.yml', force: true
end

def copy_env_example
  say 'Copying .env.example...', :blue
  fetch_file '.env.example', '.env.example', force: true
end

def copy_dockerfile
  say 'Copying Dockerfile...', :blue
  app_name_value = app_const_base.underscore
  fetch_file 'Dockerfile', 'Dockerfile', force: true
  gsub_file 'Dockerfile', 'APP_NAME', app_name_value
  say 'Dockerfile configured for production deployment', :green
end

def copy_config_files
  say 'Copying cable, cache, queue, and recurring configurations...', :blue
  fetch_file 'config/cable.yml', 'config/cable.yml', force: true
  fetch_file 'config/cache.yml', 'config/cache.yml', force: true
  fetch_file 'config/queue.yml', 'config/queue.yml', force: true
  fetch_file 'config/recurring.yml', 'config/recurring.yml', force: true
end

def setup_deploy_configs
  say 'Setting up Kamal deploy configurations...', :blue

  # Get the app name
  app_name_value = app_const_base.underscore
  app_name_hyphen = app_name_value.gsub('_', '-')

  # Copy and replace APP_NAME in deploy files
  fetch_file 'config/deploy.yml', 'config/deploy.yml', force: true
  gsub_file 'config/deploy.yml', 'APP_NAME', app_name_hyphen

  fetch_file 'config/deploy.staging.yml', 'config/deploy.staging.yml', force: true
  gsub_file 'config/deploy.staging.yml', 'APP_NAME', app_name_value

  fetch_file 'config/deploy.production.yml', 'config/deploy.production.yml', force: true
  gsub_file 'config/deploy.production.yml', 'APP_NAME', app_name_value

  say 'Kamal deploy configurations created with app name: ' + app_name_hyphen, :green
end

def setup_kamal_secrets
  say 'Setting up Kamal secrets...', :blue

  # Remove the default secrets file if it exists
  remove_file '.kamal/secrets' if File.exist?('.kamal/secrets')

  # Copy the environment-specific secrets files
  fetch_file '.kamal/secrets-common', '.kamal/secrets-common', force: true
  fetch_file '.kamal/secrets.staging', '.kamal/secrets.staging', force: true
  fetch_file '.kamal/secrets.production', '.kamal/secrets.production', force: true

  say 'Kamal secrets configured:', :green
  say '  • .kamal/secrets-common (common environment variables)'
  say '  • .kamal/secrets.staging (staging RAILS_MASTER_KEY)'
  say '  • .kamal/secrets.production (production RAILS_MASTER_KEY)'
end

def setup_zellij
  say 'Setting up Zellij configuration...', :blue
  fetch_directory '.zellij', '.zellij', ['layout.kdl']
  fetch_file 'bin/ze', 'bin/ze', force: true
  chmod 'bin/ze', 0755
end

def setup_bin_scripts
  say 'Setting up custom bin scripts...', :blue
  fetch_file 'bin/db-reset', 'bin/db-reset', force: true
  chmod 'bin/db-reset', 0755
end

def setup_database
  say 'Setting up database configuration...', :blue

  # Get the app name and create proper formats
  app_name_value = app_const_base.underscore
  db_name = app_name_value.gsub('/', '_')
  host_name = db_name.gsub('_', '-')

  database_yml = <<~DATABASE
    default: &default
      adapter: postgresql
      encoding: unicode
      # For details on connection pooling, see Rails configuration guide
      # https://guides.rubyonrails.org/configuring.html#database-pooling
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

    development:
      primary: &primary_development
        <<: *default
        database: #{db_name}_development
        host: localhost
        username: postgres
        password: postgres
      cache:
        <<: *primary_development
        database: #{db_name}_development_cache
        migrations_paths: db/cache_migrate
      queue:
        <<: *primary_development
        database: #{db_name}_development_queue
        migrations_paths: db/queue_migrate
      cable:
        <<: *primary_development
        database: #{db_name}_development_cable
        migrations_paths: db/cable_migrate

    test:
      <<: *default
      database: #{db_name}_test
      host: localhost
      username: postgres
      password: postgres

    staging:
      primary: &primary_staging
        <<: *default
        host: #{host_name}-postgres
        database: #{db_name}_staging
        username: postgres
        password: <%= ENV["POSTGRES_PASSWORD"] %>
      trifecta: &trifecta_staging
        <<: *default
        host: #{host_name}-postgres-trifecta
        port: 5432
        username: postgres
        password: <%= ENV["POSTGRES_PASSWORD"] %>
      cache:
        <<: *trifecta_staging
        database: #{db_name}_staging_cache
        migrations_paths: db/cache_migrate
      queue:
        <<: *trifecta_staging
        database: #{db_name}_staging_queue
        migrations_paths: db/queue_migrate
      cable:
        <<: *trifecta_staging
        database: #{db_name}_staging_cable
        migrations_paths: db/cable_migrate

    production:
      primary: &primary_production
        <<: *default
        host: #{host_name}-postgres
        database: #{db_name}_production
        username: postgres
        password: <%= ENV["POSTGRES_PASSWORD"] %>
      trifecta: &trifecta_production
        <<: *default
        host: #{host_name}-postgres-trifecta
        port: 5432
        username: postgres
        password: <%= ENV["POSTGRES_PASSWORD"] %>
      cache:
        <<: *trifecta_production
        database: #{db_name}_production_cache
        migrations_paths: db/cache_migrate
      queue:
        <<: *trifecta_production
        database: #{db_name}_production_queue
        migrations_paths: db/queue_migrate
      cable:
        <<: *trifecta_production
        database: #{db_name}_production_cable
        migrations_paths: db/cable_migrate
  DATABASE

  remove_file 'config/database.yml'
  create_file 'config/database.yml', database_yml
  say 'Database configuration created with multi-database support', :green
end

def setup_database_simple
  say 'Setting up simple database configuration...', :blue

  app_name_value = app_const_base.underscore
  db_name = app_name_value.gsub('/', '_')

  database_yml = <<~DATABASE
    default: &default
      adapter: postgresql
      encoding: unicode
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

    development:
      <<: *default
      database: #{db_name}_development
      host: localhost
      username: postgres
      password: postgres

    test:
      <<: *default
      database: #{db_name}_test
      host: localhost
      username: postgres
      password: postgres

    production:
      <<: *default
      database: #{db_name}_production
      host: <%= ENV.fetch("DATABASE_HOST", "localhost") %>
      username: <%= ENV.fetch("DATABASE_USERNAME", "postgres") %>
      password: <%= ENV["DATABASE_PASSWORD"] %>
  DATABASE

  remove_file 'config/database.yml'
  create_file 'config/database.yml', database_yml
  say 'Simple database configuration created', :green
end

def setup_multi_db_migrations
  say 'Setting up multi-database migrations...', :blue

  # Copy migration directories for cable, cache, and queue databases
  migration_files = {
    'db/cable_migrate' => ['001_create_cable_table.rb'],
    'db/cache_migrate' => ['001_create_cache_table.rb'],
    'db/queue_migrate' => ['001_create_queue_table.rb']
  }

  migration_files.each do |migrate_dir, files|
    fetch_directory migrate_dir, migrate_dir, files
  end

  say 'Multi-database migrations created:', :green
  say '  • db/cable_migrate/'
  say '  • db/cache_migrate/'
  say '  • db/queue_migrate/'
end

def setup_seeds
  say 'Setting up environment-specific seeds...', :blue

  # Create db/seeds directory
  empty_directory 'db/seeds'

  # Create main seeds.rb file
  seeds_content = <<~SEEDS
    puts "Seeding \#{Rails.env.downcase} environment"

    # load the correct seeds file for our Rails environment
    load(Rails.root.join('db', 'seeds', "\#{Rails.env.downcase}.rb"))
  SEEDS

  remove_file 'db/seeds.rb'
  create_file 'db/seeds.rb', seeds_content

  # Create environment-specific seed files
  %w[development test staging production].each do |env|
    seed_file_content = <<~SEED_FILE
      # #{env.capitalize} environment seeds
      puts "Loading #{env} seeds..."

      # Add your #{env}-specific seed data here
    SEED_FILE

    create_file "db/seeds/#{env}.rb", seed_file_content
  end

  say 'Environment-specific seeds created:', :green
  say '  • db/seeds.rb (main loader)'
  say '  • db/seeds/development.rb'
  say '  • db/seeds/test.rb'
  say '  • db/seeds/staging.rb'
  say '  • db/seeds/production.rb'
end

def configure_development_environment
  say 'Configuring development environment...', :blue

  inject_into_file 'config/environments/development.rb', before: /^end\n\z/ do
    <<-RUBY

  config.hosts.clear
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
    RUBY
  end

  say 'Development environment configured', :green
end

def configure_production_environment
  say 'Configuring production environment...', :blue

  inject_into_file 'config/environments/production.rb', before: /^end\n\z/ do
    <<-RUBY

  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  config.assume_ssl = true
  config.force_ssl = true
    RUBY
  end

  say 'Production environment configured', :green
end

def create_staging_environment
  say 'Creating staging environment...', :blue

  # Copy production.rb to staging.rb
  run 'cp config/environments/production.rb config/environments/staging.rb'

  # Replace 'production' with 'staging' in the file
  gsub_file 'config/environments/staging.rb', /Rails\.application\.configure do.*?\n/, <<~RUBY
    # Staging environment (copy of production)
    Rails.application.configure do
  RUBY

  say 'Staging environment created (copy of production)', :green
end

def configure_application
  say 'Configuring application with UUID primary keys...', :blue

  inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
    <<-RUBY
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    RUBY
  end

  say 'Application configured with UUID primary keys', :green
end

def setup_credentials
  say 'Setting up environment-specific credentials...', :blue

  # Create credentials directory
  empty_directory 'config/credentials'

  # Move default credentials to development
  if File.exist?('config/master.key') && File.exist?('config/credentials.yml.enc')
    run 'mv config/master.key config/credentials/development.key'
    run 'mv config/credentials.yml.enc config/credentials/development.yml.enc'
    say 'Moved default credentials to development environment', :green
  else
    # Create development credentials if they don't exist
    secret = run("bin/rails secret", capture: true).strip
    credentials_content = "secret_key_base: #{secret}\n"
    tmp_file = "tmp_credentials_development.yml"
    File.write(tmp_file, credentials_content)
    run "EDITOR='cat #{tmp_file} >' bin/rails credentials:edit --environment development > /dev/null 2>&1", capture: true
    remove_file tmp_file
  end

  # Create staging and production credentials with secret_key_base
  %w[staging production].each do |env|
    # Generate a secret key
    secret = run("bin/rails secret", capture: true).strip

    # Create a temporary file with the credentials content
    credentials_content = "secret_key_base: #{secret}\n"
    tmp_file = "tmp_credentials_#{env}.yml"
    File.write(tmp_file, credentials_content)

    # Use the content file to initialize credentials (suppress all output)
    run "EDITOR='cat #{tmp_file} >' bin/rails credentials:edit --environment #{env} > /dev/null 2>&1", capture: true

    # Clean up temp file
    remove_file tmp_file
  end

  say 'Environment-specific credentials created:', :green
  say '  • config/credentials/development.key + development.yml.enc'
  say '  • config/credentials/staging.key + staging.yml.enc'
  say '  • config/credentials/production.key + production.yml.enc'
  say '  (All include secret_key_base)'
end

def main
  @features = select_features
  add_gems

  after_bundle do
    # Inertia Rails group
    if @features[:inertia]
      setup_inertia
      setup_shadcn
      ensure_bun_package_manager
      setup_procfile
    end

    # Multi-staging Environment group
    if @features[:multistaging]
      copy_dockerfile
      copy_config_files
      setup_deploy_configs
      setup_kamal_secrets
      setup_database
      setup_multi_db_migrations
      setup_seeds
      configure_production_environment
      create_staging_environment
      setup_credentials
    else
      setup_database_simple
    end

    # Developer Tools group
    if @features[:devtools]
      copy_rubocop_config
      copy_env_example
      setup_zellij
      setup_bin_scripts
      setup_annotaterb
      configure_development_environment
    end

    # Always run
    configure_application

    # Summary
    say
    say 'Jumbo template successfully applied!', :green
    say

    if @features.values.any?
      say 'Feature groups installed:', :blue

      if @features[:inertia]
        say '  • Inertia Rails: React + TypeScript + Tailwind + shadcn/ui'
      end

      if @features[:multistaging]
        say '  • Multi-staging: Kamal + Docker + staging/production configs'
      end

      if @features[:auth]
        say '  • Authentication: authentication-zero (run generator to setup)'
      end

      if @features[:devtools]
        say '  • Developer Tools: RuboCop, Annotaterb, Zellij, Letter Opener'
      end

      if @features[:trailblazer]
        say '  • Trailblazer: Business logic framework'
      end

      say
    else
      say 'No feature groups selected. Basic Rails app created.', :yellow
      say
    end
  end
end

main
