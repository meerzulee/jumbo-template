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
    setup_zellij
    setup_bin_scripts
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
