require 'sinatra'
require 'uri'
require 'json'
require 'erb'
require 'logger'
require_relative 'lib/webhook_client'

# Enable logging
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

# Configure server
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'
set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')

# Debug mode (without actual sending to n8n)
set :debug_mode, ENV['DEBUG'] == 'true'

# Create webhook client
WEBHOOK_URL = ENV['WEBHOOK_URL'] || 'http://localhost:5678/webhook-test/example'
webhook_client = WebhookClient.new(WEBHOOK_URL, logger: logger, debug_mode: settings.debug_mode)

# Main page
get '/' do
  erb :index
end

# Test form route
get '/test-form' do
  erb :test_form
end

# Form processing - proxying request to n8n
post '/send-guides' do
  # Process JSON if Content-Type is application/json
  if request.content_type == 'application/json'
    request.body.rewind
    begin
      params.merge!(JSON.parse(request.body.read, symbolize_names: true))
    rescue JSON::ParserError => e
      logger.error "JSON parsing error: #{e.message}"
    end
  end

  # Use client to process the form
  result = webhook_client.process_guides_form(params)

  # Return result to client
  content_type :json
  result.to_json
end

# Route for simple connection test with n8n
get '/test-webhook' do
  result = webhook_client.test_connection

  content_type :json
  result.to_json
end

# Route for toggling debug mode
post '/toggle-debug' do
  debug_value = params[:debug] == 'true'
  webhook_client.debug_mode = debug_value
  settings.debug_mode = debug_value

  content_type :json
  { debug: settings.debug_mode }.to_json
end