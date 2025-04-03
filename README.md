# RBBR Landing Page

Лендинг страница для RBBR с формой подписки на гайды.

## Локальный запуск

1. Установите Ruby (рекомендуется версия 3.0+)
2. Установите зависимости:
   ```
   bundle install
   ```
3. Запустите приложение:
   ```
   bundle exec ruby app.rb
   ```
   или используя make:
   ```
   make dev
   ```
4. Откройте http://localhost:4567 в браузере

## Деплой в Easypanel

1. В Easypanel создайте новый сервис
2. Выберите опцию "Custom" или "Docker"
3. Настройте параметры:
   - Name: `rbbr-landing` (или любое другое)
   - Image: оставьте пустым, если используете GIT-репозиторий
   - Source: URL вашего Git-репозитория
   - Branch: `main` (или другая используемая)
   - Port: `4567`
   - Domains: настройте нужный домен

4. Добавьте переменные окружения:
   - `PORT=4567`
   - `WEBHOOK_URL=https://your-n8n-instance.com/webhook-test/your-webhook-id` (реальный URL вебхука)
   - `DEBUG=false` (для продакшена)

5. Нажмите "Deploy"

## Настройка переменных окружения

Создайте файл `.env` в корне проекта (он не будет добавлен в репозиторий):

```
PORT=4567
WEBHOOK_URL=https://your-n8n-instance.com/webhook-test/your-webhook-id
DEBUG=false
```

Для локальной разработки можно использовать:
```
PORT=4567
WEBHOOK_URL=http://localhost:5678/webhook-test/example
DEBUG=true
```

## Структура проекта

```
/
├── app.rb                 # Основной файл Sinatra-приложения
├── Gemfile                # Зависимости Ruby
├── Makefile               # Команды для разработки
├── Dockerfile             # Инструкции для сборки контейнера
├── public/                # Статические файлы
│   ├── css/               # CSS-стили
│   ├── js/                # JavaScript-файлы
│   └── images/            # Изображения
└── views/                 # Шаблоны ERB
    └── index.erb          # Шаблон главной страницы
```