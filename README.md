# RBBR Landing Page

Landing page for RBBR with guides subscription form.

## Local Development

1. Install Ruby (version 3.0+ recommended)
2. Install dependencies:
   ```
   bundle install
   ```
3. Run the application:
   ```
   bundle exec ruby app.rb
   ```
   or using make:
   ```
   make dev
   ```
4. Open http://localhost:4567 in your browser

## Deployment to Easypanel

1. Create a new service in Easypanel
2. Select "Custom" or "Docker" option
3. Configure parameters:
   - Name: `rbbr-landing` (or any other)
   - Image: leave empty if using a GIT repository
   - Source: URL of your Git repository
   - Branch: `main` (or other branch you use)
   - Port: `4567`
   - Domains: configure your domain

4. Add environment variables:
   - `PORT=4567`
   - `WEBHOOK_URL=https://your-n8n-instance.com/webhook-test/your-webhook-id` (real webhook URL)
   - `DEBUG=false` (for production)

5. Click "Deploy"

## Environment Variables Setup

Create a `.env` file in the project root (it won't be added to the repository):

```
PORT=4567
WEBHOOK_URL=https://your-n8n-instance.com/webhook-test/your-webhook-id
DEBUG=false
```

For local development, you can use:
```
PORT=4567
WEBHOOK_URL=http://localhost:5678/webhook-test/example
DEBUG=true
```

## Project Structure

```
/
├── app.rb                 # Main Sinatra application file
├── Gemfile                # Ruby dependencies
├── Makefile               # Development commands
├── Dockerfile             # Docker build instructions
├── public/                # Static files
│   ├── css/               # CSS styles
│   ├── js/                # JavaScript files
│   └── images/            # Images
└── views/                 # ERB templates
    └── index.erb          # Main page template
```