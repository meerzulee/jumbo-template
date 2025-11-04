# Jumbo Rails Template

A custom Rails application template for quickly bootstrapping new Rails projects with PostgreSQL and your preferred configuration.

## Usage

### Creating a new Rails app with this template

```bash
rails new {project_name} --database=postgresql --skip-javascript -m=template.rb
```

Or using a remote URL:

```bash
rails new {project_name} --database=postgresql --skip-javascript -m=https://raw.githubusercontent.com/username/jumbo-template/master/template.rb
```

### Template Configuration

This template is designed to work with:
- **PostgreSQL** as the database
- **No JavaScript** setup (--skip-javascript flag)
- **Inertia.js** for modern SPA development with Rails

## What's Included

### Gems
- **inertia_rails** (3.x) - Build modern single-page apps with Rails backend
- **pgreset** - Quick PostgreSQL database reset tool
- **annotaterb** - Automatically annotate models with schema information
- **letter_opener** - Preview emails in browser during development

### Frontend Stack (via Inertia installer)
- **React** with **TypeScript**
- **Tailwind CSS** for styling
- **Vite** for fast frontend bundling
- **Bun** as the package manager
- Example page to get started quickly

### Configuration
- **Procfile.dev** - Set up to run both Rails server and Vite dev server simultaneously

## Development

To work on this template:

1. Clone this repository
2. Make your changes to `template.rb`
3. Test by creating a new Rails app with the template
4. Commit and push your changes

## Testing the Template

```bash
# Create a test Rails app
rails new test_app --database=postgresql --skip-javascript -m=template.rb

# Clean up after testing
rm -rf test_app
```

## Contributing

This is a personal template, but feel free to fork and customize for your own needs.

## License

MIT
