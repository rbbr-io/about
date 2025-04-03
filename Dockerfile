FROM ruby:3.3.2-slim

# Install build dependencies
RUN apt-get update && apt-get install -y build-essential git curl gnupg2 pkg-config

# Install additional dependencies for appsignal
RUN apt-get install -y libssl-dev

# Set working directory
WORKDIR /app

# Copy dependency files
COPY Gemfile Gemfile.lock* ./

# Install dependencies
RUN bundle config set --local build.appsignal "--with-ssl-dir=$(openssl version -d | awk '{print $2}' | tr -d '"')"
RUN bundle install

# Copy all application files
COPY . .

# Set permissions for entrypoint
RUN chmod +x /app/entrypoint.sh

# Set environment variables
ENV PORT=4567
ENV RACK_ENV=production

# Show directory listing for debugging
RUN ls -la

# Expose port
EXPOSE 4567

# Set entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]