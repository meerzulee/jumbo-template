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

# Ask for project name if not provided
if [ -z "$APP_NAME" ]; then
  printf "Project name: "
  read -r APP_NAME
fi

if [ -z "$APP_NAME" ]; then
  echo "Error: Project name required"
  exit 1
fi

echo ""
echo "Creating $APP_NAME..."
echo ""

rails new "$APP_NAME" --database=postgresql --skip-javascript -m=https://rails.mrz.sh/t
