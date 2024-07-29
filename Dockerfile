# 使用官方 PHP 8.2-FPM 映像作為基礎映像
FROM php:8.2-fpm

# 安裝系統依賴項
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    curl \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql zip exif pcntl bcmath opcache

# 安裝 Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 設置工作目錄
WORKDIR /var/www

# 使用 Composer 創建 Waterhole 項目
RUN composer create-project waterhole/waterhole .

# 複製入口點腳本
COPY docker-entrypoint.sh /usr/local/bin/

# 設置入口點腳本為可執行
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 暴露應用端口
EXPOSE 9000

# 設置入口點
ENTRYPOINT ["docker-entrypoint.sh"]

# 設置默認命令
CMD ["php-fpm"]
