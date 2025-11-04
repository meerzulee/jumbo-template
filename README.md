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
- **Multi-database setup** - Configured for primary, cache, queue, and cable databases
- **Environment-specific credentials** - Separate encrypted credentials for development, staging, and production
- **Environment-specific seeds** - Organized seed files per environment

## Development Tips

### Testing Solid Cache in Development

If you want to test Solid Cache in the development environment, add this to `config/environments/development.rb`:

```ruby
config.cache_store = :solid_cache_store
```

## Before Deploying

Before deploying your application with Kamal, you need to configure the deployment files:

### 1. Update `config/deploy.yml`

Replace the following placeholders:
- `APP_NAME` - Your application name (e.g., `my_app`)
- `REGISTRY_USERNAME` - Your Docker registry username

### 2. Update `config/deploy.staging.yml`

Replace the following placeholders:
- `STAGING_SERVER_IP` - Your staging server IP address
- `staging.example.com` - Your staging domain
- `deploy` - Your SSH username
- `22` - Your SSH port (if different)
- `APP_NAME` - Your application name (should match deploy.yml)

### 3. Update `config/deploy.production.yml`

Replace the following placeholders:
- `PRODUCTION_SERVER_IP` - Your production server IP address
- `example.com` - Your production domain
- `deploy` - Your SSH username
- `22` - Your SSH port (if different)
- `APP_NAME` - Your application name (should match deploy.yml)

### 4. Set up Kamal secrets

Configure your `.kamal/secrets` file with the required environment variables:
- `KAMAL_REGISTRY_SERVER` - Docker registry server
- `KAMAL_REGISTRY_USERNAME` - Docker registry username
- `KAMAL_REGISTRY_PASSWORD` - Docker registry password
- `RAILS_MASTER_KEY` - Rails master key (from `config/credentials/production.key` or `config/credentials/staging.key`)
- `POSTGRES_PASSWORD` - PostgreSQL password

### 5. Deploy

```bash
# Deploy to staging
kamal deploy -d staging

# Deploy to production
kamal deploy -d production
```

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
