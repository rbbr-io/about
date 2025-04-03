require 'sinatra'
require 'uri'
require 'json'
require 'erb'
require 'logger'
require_relative 'lib/webhook_client'

# Включаем логирование
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

# Настраиваем сервер
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'
set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')

# Режим отладки (без реальной отправки в n8n)
set :debug_mode, ENV['DEBUG'] == 'true'

# Создаем клиент для работы с вебхуками
WEBHOOK_URL = ENV['WEBHOOK_URL'] || 'http://localhost:5678/webhook-test/example'
webhook_client = WebhookClient.new(WEBHOOK_URL, logger: logger, debug_mode: settings.debug_mode)

# Главная страница
get '/' do
  erb :index
end

# Маршрут для тестирования формы
get '/test-form' do
  erb :test_form
end

# Обработка формы - проксирование запроса к n8n
post '/send-guides' do
  # Обрабатываем JSON, если Content-Type application/json
  if request.content_type == 'application/json'
    request.body.rewind
    begin
      params.merge!(JSON.parse(request.body.read, symbolize_names: true))
    rescue JSON::ParserError => e
      logger.error "Ошибка парсинга JSON: #{e.message}"
    end
  end

  # Используем клиент для обработки формы
  result = webhook_client.process_guides_form(params)

  # Возвращаем результат клиенту
  content_type :json
  result.to_json
end

# Маршрут для простой проверки соединения с n8n
get '/test-webhook' do
  result = webhook_client.test_connection

  content_type :json
  result.to_json
end

# Маршрут для переключения режима отладки
post '/toggle-debug' do
  debug_value = params[:debug] == 'true'
  webhook_client.debug_mode = debug_value
  settings.debug_mode = debug_value

  content_type :json
  { debug: settings.debug_mode }.to_json
end