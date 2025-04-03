# RBBR Landing Page

Landing page for RBBR with guides subscription form.

## Local Development

1. Install Ruby (version 3.3.2 recommended)
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

5. Click "Deploy"

## Environment Variables Setup

Create a `.env` file in the project root (it won't be added to the repository):

```
PORT=4567
WEBHOOK_URL=https://your-n8n-instance.com/webhook-test/your-webhook-id
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

## Troubleshooting Deployment

If the service doesn't start in Easypanel and gets stuck in "Waiting for service to start...", try these steps:

1. **Check Logs**
   - In Easypanel, go to your service and click "Logs"
   - Look for specific errors in the startup process

2. **Environment Variables**
   - Make sure all required environment variables are set:
     - `PORT=4567`
     - `WEBHOOK_URL=https://your-webhook-url`

3. **Memory & Resources**
   - Ensure the service has enough memory (at least 512MB)
   - If using a small VPS, increase swap space

4. **Manual Command Test**
   - SSH into the server and try running the application manually:
   ```
   cd /path/to/deployment
   bundle exec ruby app.rb -o 0.0.0.0
   ```

5. **Networking**
   - Check if port 4567 is accessible
   - Make sure there are no firewall issues

6. **File Permissions**
   - Ensure all files have correct permissions
   - The entrypoint.sh script needs to be executable

If all else fails, try deploying from scratch with a new service.