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

---

# Operations Framework Reference

When the `operations` feature is enabled, the template copies `app/core/application_operation.rb` and `app/core/result.rb` into the generated app. Source files live in `src/template/core/`.

## Operation DSL

```ruby
class MyOperation < ApplicationOperation
  step :method_name                    # success track — false/nil = failure
  step :risky, rescue_from: [SomeErr]  # catches exception → fail track
  step Nested(OtherOperation)          # runs another operation inline
  fail_step :cleanup                   # runs only on failure track
end
```

### Template

```ruby
# app/operations/{plural_domain}/{action}.rb
module {PluralDomain}
  class {Action} < ApplicationOperation
    step :validate
    step :{main_logic}
    step :persist
    fail_step :handle_failure

    private

    def validate
      ctx[:some_field].present? || fail!("Field required")
    end

    def persist
      ctx[:record].save || fail!("Save failed: #{ctx[:record].errors.full_messages.join(', ')}")
    end

    def handle_failure
      Rails.logger.warn "[{PluralDomain}::{Action}] #{@errors}"
    end
  end
end
```

### Critical Rules

1. Steps that call `fail!` conditionally **MUST** end with `true`
2. Steps are `private`
3. Read context: `ctx[:key]` — Write context: `ctx[:key] = value`
4. `rescue_from:` only for **expected** exceptions
5. `Nested(OtherOp)` shares and merges context

### Controller Pattern

```ruby
def {action}
  result = {Domain}::{Action}.call(user: current_user, **params)
  result.success? ? redirect_to(path, notice: "Done") : redirect_back(alert: result.error)
end
```

## Result

```ruby
Result.success(order: order, total: 69.97)
Result.failure("Something broke", order: order)

result.success?  / result.failure?
result.error     # string on failure
result.order     # method access to data
result[:order]   # hash-style access
result.to_h      # all data as hash
```

Immutable (frozen). Requires Ruby 3.2+ (`Data.define`).

## Naming Conventions

```
app/operations/{plural_domain}/{action}.rb    → module {PluralDomain}::{Action}
```

## Common Mistakes

```ruby
# ❌ fail! without ending with true
def validate
  fail!("bad") if something_wrong
end

# ✅ explicit true
def validate
  fail!("bad") if something_wrong
  true
end
```
