require 'json'

# Parser for email templates
class EmailTemplateParser
  # Parse email template file into structured data
  # @param template_path [String] Path to template file
  # @return [Hash] Parsed email template data
  def self.parse(template_path)
    content = File.read(template_path)
    parse_content(content)
  end

  # Parse raw template content into structured data
  # @param content [String] Template content
  # @return [Hash] Parsed email template data
  def self.parse_content(content)
    lines = content.split("\n")
    email_data = {}

    current_key = nil
    current_value = []

    lines.each do |line|
      if line =~ /^([a-z_]+):(.*)$/
        # Save previous key and value if they exist
        if current_key
          email_data[current_key] = current_value.join("\n").strip
          current_value = []
        end

        current_key = $1.strip
        value = $2.strip

        # If value starts with -|, it's a multiline value
        if value == "-|"
          current_value = []
        else
          email_data[current_key] = value
          current_key = nil
        end
      elsif current_key
        current_value << line
      end
    end

    # Save the last key and value if they exist
    if current_key && !current_value.empty?
      email_data[current_key] = current_value.join("\n").strip
    end

    email_data
  end

  # Convert email template to webhook payload
  # @param template_path [String] Path to template file
  # @return [Hash] Webhook payload
  def self.to_webhook_payload(template_path)
    email_data = parse(template_path)

    {
      email_template: email_data,
      action: "deploy",
      timestamp: Time.now.utc.iso8601
    }
  end

  # Convert email template to JSON
  # @param template_path [String] Path to template file
  # @return [String] JSON string
  def self.to_json(template_path)
    to_webhook_payload(template_path).to_json
  end
end