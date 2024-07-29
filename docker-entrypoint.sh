#!/bin/sh
set -e

# 如果 .env 文件不存在，則複製 .env.example
if [ ! -f .env ]; then
  cp .env.example .env
fi

# 確保我們等待 MySQL 服務可用
until mysql -h "${DB_HOST}" -u"${DB_USERNAME}" -p"${DB_PASSWORD}" -e "SELECT 1" > /dev/null 2>&1; do
  echo "Waiting for MySQL..."
  sleep 3
done

# 填充 .env 文件中的環境變量
sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST}/" .env
sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT}/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env

# 生成應用程序密鑰
php artisan key:generate

# 運行數據庫遷移
php artisan migrate --force

# 運行數據庫填充
php artisan db:seed --force

# 清理緩存
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec "$@"
