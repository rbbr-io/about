#!/bin/bash
set -e

# Print environment for debugging (excluding sensitive data)
echo "Environment:"
echo "PORT=$PORT"
echo "RACK_ENV=$RACK_ENV"
echo "Working directory: $(pwd)"
echo "Files in directory:"
ls -la

# Check if app.rb exists
if [ ! -f "app.rb" ]; then
  echo "ERROR: app.rb not found in $(pwd)"
  exit 1
fi

# Check if all required directories exist
echo "Checking required directories:"
for dir in "public" "views" "lib"; do
  if [ -d "$dir" ]; then
    echo "✅ $dir directory exists"
  else
    echo "❌ $dir directory missing!"
  fi
done

# Start the application
echo "Starting application..."
exec bundle exec ruby app.rb -o 0.0.0.0