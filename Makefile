.PHONY: install start docker-build docker-run

# Установка зависимостей
install:
	bundle install

# Запуск сервера разработки
start:
	bundle exec ruby app.rb

# Быстрый запуск для разработки без установки зависимостей
dev: install start

# Сборка Docker-образа
docker-build:
	docker build -t rbbr-landing .

# Запуск Docker-контейнера
docker-run:
	docker run -p 4567:4567 rbbr-landing

# Полный цикл: сборка и запуск в Docker
docker: docker-build docker-run

# Проверка работоспособности
check:
	@echo "Проверка доступности сервера..."
	@curl -s http://localhost:4567 > /dev/null && echo "Сервер работает!" || echo "Сервер не запущен!"

# Помощь
help:
	@echo "Доступные команды:"
	@echo "  make install     - Установка зависимостей"
	@echo "  make start       - Запуск сервера разработки"
	@echo "  make dev         - Установка зависимостей и запуск сервера"
	@echo "  make docker-build - Сборка Docker-образа"
	@echo "  make docker-run  - Запуск Docker-контейнера"
	@echo "  make docker      - Сборка и запуск Docker-контейнера"
	@echo "  make check       - Проверка работоспособности сервера"

# По умолчанию - показать помощь
default: help