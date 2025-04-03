require 'net/http'
require 'uri'
require 'json'
require 'logger'

# Client for working with external webhooks
class WebhookClient
  attr_reader :logger

  def initialize(webhook_url, logger: nil)
    @webhook_url = webhook_url
    @logger = logger || Logger.new(STDOUT)
    @connection_options = { open_timeout: 10, read_timeout: 10 }
  end

  # Send data to webhook
  # @param data [Hash] Data to send
  # @return [Hash] Send result
  def send_data(data)
    logger.info "Sending data to #{@webhook_url}: #{data.inspect}"

    begin
      uri = URI(@webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = @connection_options[:open_timeout]
      http.read_timeout = @connection_options[:read_timeout]

      # Log request details
      logger.info "Preparing request to: #{uri}"
      logger.info "SSL enabled: #{http.use_ssl?}"

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["User-Agent"] = "RBBR WebhookClient/1.0"
      request.body = data.to_json

      logger.info "Sending request... (waiting for response)"
      response = http.request(request)

      # Detailed response logging
      logger.info "Response received. Status: #{response.code}"
      logger.info "Response headers: #{response.to_hash.inspect}"
      logger.info "Response body: #{response.body.inspect[0..200]}..."

      # Specific handling for different status codes
      case response.code.to_i
      when 200..299
        logger.info "Success (2xx): Webhook delivered successfully"
      when 400..499
        logger.warn "Error (4xx): Client error when delivering webhook. Check URL and data format."
      when 500..599
        logger.error "Error (5xx): Server error when delivering webhook. The receiving service may be down."
      end

      { status: response.code.to_i, message: response.body }
    rescue => e
      logger.error "Error sending webhook: #{e.class.name} - #{e.message}"
      logger.error e.backtrace.join("\n")
      { status: 500, error: e.class.name, message: e.message }
    end
  end
end