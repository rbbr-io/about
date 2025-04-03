require 'sinatra'
require 'uri'
require 'json'
require 'erb'
require 'logger'
require 'dotenv'
require_relative 'lib/webhook_client'

# Load environment variables from .env file
Dotenv.load

# Enable logging
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

# Configure server
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'
set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')

# Create webhook client
WEBHOOK_URL = ENV['WEBHOOK_URL'] || 'http://localhost:5678/webhook-test/example'
webhook_client = WebhookClient.new(WEBHOOK_URL, logger: logger)

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
  logger.info "=== FORM SUBMISSION RECEIVED ==="
  logger.info "Original params: #{params.inspect}"

  # Process JSON if Content-Type is application/json
  if request.content_type == 'application/json'
    request.body.rewind
    begin
      json_params = JSON.parse(request.body.read, symbolize_names: true)
      logger.info "Parsed JSON params: #{json_params.inspect}"
      params.merge!(json_params)
    rescue JSON::ParserError => e
      logger.error "JSON parsing error: #{e.message}"
    end
  end

  logger.info "Webhook URL: #{WEBHOOK_URL}"

  # Use client to process the form
  logger.info "Processing form with parameters: #{params.inspect}"
  result = webhook_client.process_guides_form(params)

  # Log the result
  logger.info "Webhook result: #{result.inspect}"

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

get '/services-reference' do
  erb :services_reference
end