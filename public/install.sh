#!/bin/sh
set -e

echo ""
echo "  ╦╦ ╦╔╦╗╔╗ ╔═╗"
echo "  ║║ ║║║║╠╩╗║ ║"
echo " ╚╝╚═╝╩ ╩╚═╝╚═╝"
echo ""
echo "  Rails Template"
echo ""

APP_NAME="$1"
shift 2>/dev/null || true  # Remove first arg, keep the rest as flags

# Ask for project name if not provided
if [ -z "$APP_NAME" ]; then
  printf "Project name: "
  read -r APP_NAME
fi

if [ -z "$APP_NAME" ]; then
  echo "Error: Project name required"
  exit 1
fi

# Collect remaining arguments as skip flags
SKIP_FLAGS="$*"

echo ""
echo "Creating $APP_NAME..."
if [ -n "$SKIP_FLAGS" ]; then
  echo "Skip flags: $SKIP_FLAGS"
fi
echo ""

rails new "$APP_NAME" --database=postgresql --skip-javascript -m=https://rails.mrz.sh/t $SKIP_FLAGS
