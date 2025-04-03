require 'net/http'
require 'uri'
require 'json'
require 'logger'

# Client for working with external webhooks
class WebhookClient
  attr_reader :logger

  # Initialize with settings
  # @param webhook_url [String] Webhook URL
  # @param logger [Logger] Logger object (optional)
  # @param debug_mode [Boolean] Debug mode flag (optional)
  def initialize(webhook_url, logger: nil, debug_mode: false)
    @webhook_url = webhook_url
    @logger = logger || Logger.new(STDOUT)
    @debug_mode = debug_mode
    @connection_options = { open_timeout: 10, read_timeout: 10 }
  end

  # Set debug mode
  # @param value [Boolean] Enable/disable debug mode
  def debug_mode=(value)
    @debug_mode = !!value
    logger.info "Debug mode #{@debug_mode ? 'enabled' : 'disabled'}"
  end

  # Test webhook availability
  # @return [Hash] Test result in format {status: code, message: text, body: response_body}
  def test_connection
    logger.info "Testing connection to #{@webhook_url}"

    begin
      response = Net::HTTP.get_response(URI(@webhook_url))
      logger.info "Response: #{response.code} #{response.message}"

      { status: response.code.to_i, message: "Test completed: #{response.message}", body: response.body }
    rescue => e
      logger.error "Connection error: #{e.message}"
      { status: 500, error: e.class.name, message: e.message }
    end
  end

  # Send data to webhook
  # @param data [Hash] Data to send
  # @return [Hash] Send result
  def send_data(data)
    logger.info "Sending data: #{data.inspect}"

    if @debug_mode
      logger.info "DEBUG MODE: #{@webhook_url}"
      return { status: 200, message: "Debug: simulating send to #{@webhook_url}" }
    end

    begin
      uri = URI(@webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = @connection_options[:open_timeout]
      http.read_timeout = @connection_options[:read_timeout]

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = data.to_json

      response = http.request(request)
      logger.info "Response: #{response.code} #{response.body.inspect[0..100]}"

      { status: response.code.to_i, message: response.body }
    rescue => e
      logger.error "Error: #{e.message}"
      { status: 500, error: e.class.name, message: e.message }
    end
  end

  # Process guides form submission
  # @param params [Hash] Form parameters
  # @return [Hash] Processing result
  def process_guides_form(params)
    email = params[:email]
    selected_guides = params[:selected_guides] || []

    return { status: 400, error: "ValidationError", message: "Email is required" } if email.to_s.empty?

    send_data({
      email: email,
      selected_guides: selected_guides
    })
  end
end