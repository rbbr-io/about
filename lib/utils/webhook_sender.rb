require 'json'
require 'net/http'
require 'uri'
require 'yaml'

module Utils
  class WebhookSender
    attr_reader :webhook_url, :payload

    def initialize(webhook_url = nil)
      # Пытаемся получить URL вебхука из .sitedock файла, если URL не указан явно
      @webhook_url = webhook_url || fetch_webhook_url_from_sitedock
      raise ArgumentError, "Webhook URL is required" unless @webhook_url
    end

    # Отправляет данные на вебхук в формате JSON
    def send_json(payload = {})
      @payload = payload

      # Добавляем метаданные для логирования
      @payload[:metadata] ||= {}
      @payload[:metadata][:sent_at] = Time.now.utc.iso8601
      @payload[:metadata][:source] = 'webhook_sender'

      # Выполняем HTTP запрос
      response = post_to_webhook

      # Возвращаем результат выполнения запроса
      {
        success: response.code.to_i >= 200 && response.code.to_i < 300,
        status_code: response.code,
        response_body: response.body,
        payload: @payload
      }
    end

    # Отправляет данные из шаблона письма как JSON
    def send_email_template(template_path = 'views/template.txt')
      # Парсим шаблон письма
      email_data = parse_email_template(template_path)

      # Создаем структуру для JSON
      payload = {
        email: email_data,
        action: "deploy",
        timestamp: Time.now.utc.iso8601
      }

      # Отправляем JSON
      send_json(payload)
    end

    private

    # Получаем URL вебхука из файла .sitedock
    def fetch_webhook_url_from_sitedock
      begin
        sitedock_content = File.read('.sitedock')
        if sitedock_content =~ /deploy_hook:\s*(https?:\/\/\S+)/
          return $1.strip
        else
          lines = sitedock_content.split("\n")
          hook_index = lines.index { |line| line.strip =~ /deploy_hook:/ }
          if hook_index && hook_index < lines.size - 1
            return lines[hook_index + 1].strip
          end
        end
      rescue StandardError => e
        puts "Error reading .sitedock file: #{e.message}"
      end
      nil
    end

    # Выполняем POST запрос на webhook
    def post_to_webhook
      uri = URI.parse(@webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = @payload.to_json

      http.request(request)
    end

    # Парсим шаблон письма
    def parse_email_template(template_path)
      content = File.read(template_path)

      # Простой парсер для формата email template
      lines = content.split("\n")
      email_data = {}

      current_key = nil
      current_value = []

      lines.each do |line|
        if line =~ /^([a-z_]+):(.*)$/
          # Сохраняем предыдущий ключ и значение, если они есть
          if current_key
            email_data[current_key] = current_value.join("\n").strip
            current_value = []
          end

          current_key = $1.strip
          value = $2.strip

          # Если значение начинается с -|, это многострочное значение
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

      # Сохраняем последний ключ и значение, если они есть
      if current_key && !current_value.empty?
        email_data[current_key] = current_value.join("\n").strip
      end

      email_data
    end
  end
end