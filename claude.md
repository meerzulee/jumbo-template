# Claude Development Notes

This file contains notes and context for Claude when working on the Jumbo Rails template.

## Template Structure

- `template.rb` - Main template file executed by Rails
- `README.md` - User-facing documentation
- This file (`claude.md`) - Developer notes for AI assistance

## How Rails Templates Work

Rails templates use a DSL (Domain Specific Language) that provides helper methods:

### Key Methods

- `gem` / `gem_group` - Add gems to Gemfile
- `after_bundle` - Run code after bundle install completes
- `rails_command` - Execute Rails commands (e.g., generators)
- `git` - Execute git commands
- `inject_into_file` - Add content to existing files
- `copy_file` - Copy files from template to app
- `template` - Copy and process ERB template files
- `directory` - Copy entire directories
- `environment` - Add configuration to environment files
- `initializer` - Create initializer files
- `route` - Add routes
- `say` - Output colored messages to console

### Execution Flow

1. Template runs before `bundle install`
2. Code in `after_bundle` blocks runs after gems are installed
3. Git commands typically run at the end

## Development Guidelines

- Keep template.rb organized and commented
- Use `source_paths` to specify where template files are located
- Test thoroughly by creating new apps
- Consider making sections modular with methods
- Use `say` for user feedback during template execution

## Useful Resources

- [Rails Application Templates Guide](https://guides.rubyonrails.org/rails_application_templates.html)
- [Thor Actions](https://www.rubydoc.info/gems/thor/Thor/Actions) - Template DSL is based on Thor

## Template Goals

(Document what you want this template to accomplish as we build it)
