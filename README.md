# MRZ Rails 8 Template

A comprehensive Rails 8 application template to quickly scaffold new projects with your preferred configuration.

## Usage

### Local Usage
```bash
rails new my_app --template=/path/to/mrz-template/template.rb
```

### Remote Usage (GitHub)
```bash
rails new my_app --template=https://raw.githubusercontent.com/YOUR_USERNAME/mrz-template/main/template.rb
```

### With Specific Options
```bash
# PostgreSQL database
rails new my_app --database=postgresql --template=https://raw.githubusercontent.com/YOUR_USERNAME/mrz-template/main/template.rb

# API only
rails new my_app --api --template=https://raw.githubusercontent.com/YOUR_USERNAME/mrz-template/main/template.rb
```

## What This Template Does

The template automatically sets up:

1. **Gems**: Adds commonly used gems to your Gemfile
2. **Initializers**: Sets up custom configuration files
3. **Generators**: Configures Rails generators with sensible defaults
4. **Routes**: Adds custom routes
5. **Database**: Configures database settings
6. **Frontend**: Optionally sets up frontend frameworks
7. **Authentication**: Optionally sets up authentication
8. **Git**: Initializes a Git repository with initial commit

## Customization

Edit `template.rb` to customize the template for your needs.

## Testing Your Template

Test locally before deploying:

```bash
cd /tmp
rails new test_app --template=/path/to/mrz-template/template.rb
cd test_app
rails server
```

## Contributing

Feel free to fork and customize this template for your own use!

## Rails Template DSL Quick Reference

- `gem 'gem_name'` - Add a gem to Gemfile
- `gem_group :development, :test do ... end` - Add gems to specific groups
- `run 'command'` - Run arbitrary shell commands
- `rails_command 'db:migrate'` - Run Rails commands
- `generate 'model User'` - Run Rails generators
- `initializer 'filename.rb', "code"` - Create initializer
- `route "root 'pages#home'"` - Add routes
- `after_bundle { ... }` - Execute code after bundle install
- `git :init` - Run git commands
- `ask 'Question?'` - Prompt user for input
- `yes? 'Question?'` - Ask yes/no questions
- `say 'message', :color` - Print colored messages
