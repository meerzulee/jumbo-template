# Jumbo Rails Template
# Usage: rails new {project_name} --database=postgresql --skip-javascript -m=template.rb

TEMPLATE_ROOT = __dir__

def add_gems
  # Inertia.js for building modern single-page apps
  gem 'inertia_rails', '~> 3.0'

  gem_group :development do
    # Quick PostgreSQL database reset
    gem 'pgreset'

    # Annotate models with schema information
    gem 'annotaterb'

    # Preview emails in browser
    gem 'letter_opener'
  end
end

def setup_inertia
  say 'Setting up Inertia.js with React, TypeScript, and Tailwind...', :blue
  rails_command 'generate inertia:install --framework=react --typescript --package-manager=bun --tailwind --vite --verbose --example-page --force'
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
  copy_file File.join(TEMPLATE_ROOT, '.rubocop.yml'), '.rubocop.yml', force: true
end

def copy_env_example
  say 'Copying .env.example...', :blue
  copy_file File.join(TEMPLATE_ROOT, '.env.example'), '.env.example', force: true
end

def copy_config_files
  say 'Copying cable, cache, queue, and recurring configurations...', :blue
  copy_file File.join(TEMPLATE_ROOT, 'config/cable.yml'), 'config/cable.yml', force: true
  copy_file File.join(TEMPLATE_ROOT, 'config/cache.yml'), 'config/cache.yml', force: true
  copy_file File.join(TEMPLATE_ROOT, 'config/queue.yml'), 'config/queue.yml', force: true
  copy_file File.join(TEMPLATE_ROOT, 'config/recurring.yml'), 'config/recurring.yml', force: true
end

def setup_zellij
  say 'Setting up Zellij configuration...', :blue
  directory File.join(TEMPLATE_ROOT, '.zellij'), '.zellij'
  copy_file File.join(TEMPLATE_ROOT, 'bin/ze'), 'bin/ze', force: true
  chmod 'bin/ze', 0755
end

def setup_bin_scripts
  say 'Setting up custom bin scripts...', :blue
  copy_file File.join(TEMPLATE_ROOT, 'bin/db-reset'), 'bin/db-reset', force: true
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

def setup_multi_db_migrations
  say 'Setting up multi-database migrations...', :blue

  # Copy migration directories for cable, cache, and queue databases
  %w[cable_migrate cache_migrate queue_migrate].each do |migrate_dir|
    directory File.join(TEMPLATE_ROOT, 'db', migrate_dir), "db/#{migrate_dir}"
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
  add_gems

  after_bundle do
    setup_inertia
    setup_procfile
    copy_rubocop_config
    copy_env_example
    copy_config_files
    setup_zellij
    setup_bin_scripts
    setup_database
    setup_multi_db_migrations
    setup_seeds
    setup_credentials

    say
    say 'Jumbo template successfully applied!', :green
    say
    say 'Gems installed:', :blue
    say '  • inertia_rails (3.x) - Modern SPA framework'
    say '  • pgreset - Quick database reset tool'
    say '  • annotaterb - Model annotations'
    say '  • letter_opener - Email previews'
    say
    say 'Inertia.js configured with:', :blue
    say '  • React + TypeScript'
    say '  • Tailwind CSS'
    say '  • Vite bundler (via Inertia installer)'
    say '  • Bun package manager'
    say '  • Example page included'
    say
  end
end

main
