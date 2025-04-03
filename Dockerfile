FROM ruby:3.2-slim

# Устанавливаем зависимости для сборки
RUN apt-get update && apt-get install -y build-essential

# Создаем директорию приложения
WORKDIR /app

# Копируем файлы зависимостей
COPY Gemfile Gemfile.lock* ./

# Устанавливаем зависимости
RUN bundle install

# Копируем остальные файлы приложения
COPY . .

# Открываем порт
EXPOSE 4567

# Запускаем приложение
CMD ["bundle", "exec", "ruby", "app.rb"]