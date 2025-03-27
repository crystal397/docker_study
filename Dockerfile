FROM ubuntu:22.04

# DEBIAN_FRONTEND를 noninteractive로 설정하여 tzdata 대화형 메시지를 비활성화
ENV DEBIAN_FRONTEND=noninteractive

# PHP 7.2 설치를 위한 PPA 추가
RUN apt update && apt upgrade -y
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt update

# PHP 7.2와 Apache2 설치
RUN apt install -y php7.2 apache2 php7.2-gd php7.2-xml php7.2-mysql

# /var/www/html/xe 에 xpressengine 실행
COPY ./xe /var/www/html/xe

# 디렉토리 권한 설정 (Apache가 접근할 수 있도록)
RUN chown -R www-data:www-data /var/www/html/xe
RUN chmod -R 755 /var/www/html/xe

# Apache2 서버 실행을 위한 CMD 설정
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]