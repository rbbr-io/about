require 'sinatra'
require 'uri'
require 'json'
require 'erb'
require 'logger'
require 'dotenv'
require 'yaml'
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

WEBHOOK_URL = ENV['WEBHOOK_URL']

# Main page
get '/' do
  erb :index, :layout => :home_layout
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

    json_params = JSON.parse(request.body.read, symbolize_names: true)
    logger.info "Parsed JSON params: #{json_params.inspect}"
    params.merge!(json_params)
  end

  logger.info "Webhook URL: #{WEBHOOK_URL}"

  # Use client to process the form
  logger.info "Processing form with parameters: #{params.inspect}"

  webhook_client = WebhookClient.new(WEBHOOK_URL, logger: logger)
  yaml_data = YAML.load_file('views/send_guides.yml')

  result = webhook_client.send_data(yaml_data.merge(params))
  # result = webhook_client.process_guides_form(params)

  # Log the result
  logger.info "Webhook result: #{result.inspect}"

  # Return result to client
  content_type :json
  result.to_json
end

# Route for sending email template as JSON via webhook
get '/send-template' do
  logger.info "=== SENDING EMAIL TEMPLATE ==="

  template_path = params[:path] || 'views/send_guides.yml'
  logger.info "Template path: #{template_path}"

  begin
    # Parse email template
    email_data = parse_email_template(template_path)
    logger.info "Parsed email template: #{email_data.inspect}"

    # Create payload
    payload = {
      email_template: email_data,
      action: "email_template",
      timestamp: Time.now.utc.iso8601
    }

    # Send to webhook
    result = webhook_client.send_data(payload)
    logger.info "Webhook result: #{result.inspect}"

    content_type :json
    {
      success: result[:status] >= 200 && result[:status] < 300,
      template: email_data,
      webhook_result: result
    }.to_json
  rescue => e
    logger.error "Error sending template: #{e.message}"
    status 500
    content_type :json
    { error: e.message }.to_json
  end
end


get '/services-reference' do
  erb :services_reference
end