#!/bin/bash

# Обновление и установка необходимых пакетов
sudo apt update
sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common nano

# Установка Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Проверка установки Docker Compose
docker-compose --version

# Создание директории проекта, если не существует
if [ ! -d "~/my_project" ]; then
    mkdir ~/my_project
fi
cd ~/my_project

# Запрос адреса кошелька у пользователя
read -p "Введите ваш адрес кошелька: " wallet_address

# Проверка, что адрес кошелька не пустой
if [ -z "$wallet_address" ]; then
    echo "Адрес кошелька не может быть пустым!"
    exit 1
fi

# Создание файла docker-compose.yml
cat <<EOL > docker-compose.yml
services:
  verifier:
    image: whoami39/cysic-verifier:latest
    container_name: verifier
    environment:
      - EVM_ADDR="$wallet_address"  # Используем введенный адрес
    volumes:
      - ./data/data:/app/data
      - ./data/cysic/:/root/.cysic/
    network_mode: "host"
    restart: unless-stopped
EOL

# Запуск Docker Compose
docker-compose up -d

echo "Установка завершена. Подождите 2 минуты, затем выполните следующие команды:"
echo "cd ~/my_project"
echo "docker-compose restart"
echo "docker-compose logs -f"
