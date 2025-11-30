# Jumbo

Production-ready Rails 8.1 in one command.

## Quick Start

```bash
curl -fsSL rails.mrz.sh | sh -s myapp
```

Or using the full command:

```bash
rails new myapp --skip-js -d=postgresql -m=https://rails.mrz.sh/t
```

## What's Included

### Frontend Stack
- **Inertia.js** + **React** - SPA experience without the complexity
- **TypeScript** - Type-safe frontend development
- **Tailwind CSS** - Utility-first styling
- **shadcn/ui** - Beautiful, accessible UI components
- **Vite** - Lightning-fast HMR and bundling
- **Bun** - Fast package manager

### Backend Stack
- **Rails 8.1** with PostgreSQL
- **Solid Queue** - Database-backed Active Job backend
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed Action Cable

### Deployment
- **Kamal** - Zero-downtime deployments
- **Multi-stage environments** - Development, staging, and production
- **Environment-specific credentials** - Separate encrypted credentials per environment
- **Environment-specific seeds** - Organized seed files per environment

### Developer Experience
- **Procfile.dev** - Run Rails + Vite simultaneously
- **pgreset** - Quick PostgreSQL database reset
- **annotaterb** - Auto-annotate models with schema
- **letter_opener** - Preview emails in browser

## Before Deploying

### 1. Update `config/deploy.yml`

Replace the placeholders:
- `APP_NAME` - Your application name
- `REGISTRY_USERNAME` - Your Docker registry username

### 2. Update `config/deploy.staging.yml`

Replace the placeholders:
- `STAGING_SERVER_IP` - Your staging server IP
- `staging.example.com` - Your staging domain
- `deploy` - Your SSH username
- `22` - Your SSH port (if different)

### 3. Update `config/deploy.production.yml`

Replace the placeholders:
- `PRODUCTION_SERVER_IP` - Your production server IP
- `example.com` - Your production domain
- `deploy` - Your SSH username
- `22` - Your SSH port (if different)

### 4. Set up Kamal secrets

Configure `.kamal/secrets`:
- `KAMAL_REGISTRY_PASSWORD` - Docker registry password
- `RAILS_MASTER_KEY` - From `config/credentials/production.key`
- `POSTGRES_PASSWORD` - PostgreSQL password

### 5. Deploy

```bash
# Deploy to staging
kamal deploy -d staging

# Deploy to production
kamal deploy -d production
```

## Roadmap

- [x] React shadcn/ui components

## Links

- Website: https://rails.mrz.sh
- GitHub: https://github.com/meerzulee/jumbo-template

## License

MIT
