FROM ubuntu:22.04
RUN apt-get update
RUN apt install -y software-properties-common
RUN apt install -y apt-utils
# Install PHP packages
RUN add-apt-repository ppa:ondrej/php
RUN DEBIAN_FRONTEND="noninteractive" TZ="Europe/London" apt-get -y install php
RUN apt-get purge apache2 -y
RUN apt-get install nginx -y
RUN apt-get install -y tmux curl wget php8.1-fpm php8.1-cli php8.1-curl php8.1-gd php8.1-intl
RUN apt-get install -y php8.1-mysql php8.1-mbstring php8.1-zip php8.1-xml unzip php8.1-soap php8.1-redis

# redis
RUN apt-get install -y redis
RUN mkdir -p /usr/local/etc/redis
COPY ./docker_configs/redis.conf /usr/local/etc/redis/redis.conf

# set the nginx configs
COPY ./docker_configs/nginx /etc/nginx/
RUN ln -s /etc/nginx/sites-available/rocketstack.conf /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

#PHP FPM configs
COPY ./docker_configs/fpm/php.ini /etc/php/8.1/fpm/php.ini
COPY ./docker_configs/fpm/www.conf /etc/php/8.1/fpm/pool.d/www.conf

# Create needed folders
RUN mkdir -p /var/www/cache
RUN mkdir -p /var/www/cache/rocketstack
RUN mkdir -p /var/www/rocketstack
COPY ./bedrock/ /var/www/rocketstack
RUN chmod a+rwx -R /var/www/

# Letsencrypt ssl
RUN add-apt-repository -y universe
RUN add-apt-repository -y ppa:certbot/certbot
RUN apt-get install -y python-certbot-nginx
RUN certbot --nginx --non-interactive --agree-tos -m reflipd@gmail.com -d app.explode.live

CMD service nginx restart && service php8.1-fpm start && redis-server /usr/local/etc/redis/redis.conf  && tail -f /dev/null
