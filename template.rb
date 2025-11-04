# Jumbo Rails Template
# Usage: rails new {project_name} --database=postgresql --skip-javascript -m=template.rb

def source_paths
  [__dir__]
end

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
  copy_file '.rubocop.yml', '.rubocop.yml', force: true
end

def setup_zellij
  say 'Setting up Zellij configuration...', :blue
  directory '.zellij', '.zellij'
  copy_file 'bin/ze', 'bin/ze', force: true
  chmod 'bin/ze', 0755
end

def setup_bin_scripts
  say 'Setting up custom bin scripts...', :blue
  copy_file 'bin/db-reset', 'bin/db-reset', force: true
  chmod 'bin/db-reset', 0755
end

def main
  add_gems

  after_bundle do
    setup_inertia
    setup_procfile
    copy_rubocop_config
    setup_zellij
    setup_bin_scripts

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
