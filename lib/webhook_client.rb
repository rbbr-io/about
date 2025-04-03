require 'net/http'
require 'uri'
require 'json'
require 'logger'

# Класс для работы с внешними вебхуками
class WebhookClient
  attr_reader :logger

  # Инициализация с настройками
  # @param webhook_url [String] URL вебхука
  # @param logger [Logger] объект для логирования (опционально)
  # @param debug_mode [Boolean] режим отладки (опционально)
  def initialize(webhook_url, logger: nil, debug_mode: false)
    @webhook_url = webhook_url
    @logger = logger || Logger.new(STDOUT)
    @debug_mode = debug_mode
    @connection_options = { open_timeout: 10, read_timeout: 10 }
  end

  # Установка режима отладки
  # @param value [Boolean] включить/выключить режим отладки
  def debug_mode=(value)
    @debug_mode = !!value
    logger.info "Режим отладки #{@debug_mode ? 'включен' : 'отключен'}"
  end

  # Проверка доступности вебхука
  # @return [Hash] результат проверки в формате {status: код, message: сообщение, body: тело ответа}
  def test_connection
    logger.info "Проверка соединения с #{@webhook_url}"

    begin
      response = Net::HTTP.get_response(URI(@webhook_url))
      logger.info "Ответ: #{response.code} #{response.message}"

      { status: response.code.to_i, message: "Тест выполнен: #{response.message}", body: response.body }
    rescue => e
      logger.error "Ошибка соединения: #{e.message}"
      { status: 500, error: e.class.name, message: e.message }
    end
  end

  # Отправка данных на вебхук
  # @param data [Hash] данные для отправки
  # @return [Hash] результат отправки
  def send_data(data)
    logger.info "Отправка данных: #{data.inspect}"

    if @debug_mode
      logger.info "ТЕСТОВЫЙ РЕЖИМ: #{@webhook_url}"
      return { status: 200, message: "Debug: имитация отправки на #{@webhook_url}" }
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
      logger.info "Ответ: #{response.code} #{response.body.inspect[0..100]}"

      { status: response.code.to_i, message: response.body }
    rescue => e
      logger.error "Ошибка: #{e.message}"
      { status: 500, error: e.class.name, message: e.message }
    end
  end

  # Обработка формы с гайдами
  # @param params [Hash] параметры из формы
  # @return [Hash] результат отправки
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