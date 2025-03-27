# Docker 환경 구축 - PHP 7.2, Apache2, MySQL 5.7, XpressEngine (XE)

이 프로젝트는 Docker를 사용하여 PHP 7.2, Apache2, MySQL 5.7을 기반으로 한 XpressEngine (XE) 환경을 설정하는 방법을 설명합니다. 아래 단계별로 Dockerfile 작성과 컨테이너 실행 과정을 정리했습니다.

## Dockerfile 설명

Dockerfile은 PHP 7.2, Apache2, 그리고 MySQL 5.7을 설치하여 XpressEngine을 실행하는 환경을 구축합니다. 주요 단계는 다음과 같습니다:

1. **베이스 이미지 설정**: `ubuntu:22.04` 이미지를 사용합니다.
2. **PHP 7.2 설치를 위한 PPA 추가**: PHP 7.2를 설치하기 위해 필요한 PPA를 추가합니다.
3. **Apache2와 PHP 7.2 패키지 설치**: Apache2와 PHP 7.2, 그리고 필요한 PHP 확장 모듈을 설치합니다.
4. **XpressEngine 파일 복사**: 로컬의 `./xe` 디렉토리 내용을 컨테이너의 `/var/www/html/xe` 디렉토리로 복사합니다.
5. **디렉토리 권한 설정**: Apache가 XE 폴더에 접근할 수 있도록 권한을 설정합니다.
6. **Apache2 실행 설정**: 컨테이너가 실행될 때 Apache2가 백그라운드에서 실행되도록 설정합니다.

```dockerfile
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
```

## Docker 명령어

아래 명령어들은 Docker 이미지를 빌드하고, MySQL과 XpressEngine을 실행하는 데 필요한 명령어들입니다.

### 1. Docker 이미지 빌드

먼저 `Dockerfile`이 있는 디렉토리에서 이미지를 빌드합니다.

```bash
docker build -t xe:blue .
```

### 2. MySQL 컨테이너 실행

MySQL 5.7 이미지를 사용하여 데이터베이스를 실행합니다. 이때 `MYSQL_ROOT_PASSWORD`와 `MYSQL_DATABASE`를 설정하여 기본 데이터베이스를 `xe`로 지정합니다.

```bash
docker container run -d --name db1 -e MYSQL_ROOT_PASSWORD=test123 -e MYSQL_DATABASE=xe mysql:5.7
```

### 3. XpressEngine (XE) 실행

이제 MySQL 컨테이너와 연결된 `xe:blue` 이미지를 사용하여 XpressEngine을 실행합니다. `db1` 컨테이너와 연결하고, 포트 8008을 80번 포트에 바인딩합니다.

```bash
docker container run -d --name xe1 --link db1:mysql -p 8008:80 xe:blue
```

### 4. Docker 이미지 태그 및 푸시

로컬에서 만든 `xe:blue` 이미지를 Docker Hub 또는 개인 레지스트리로 푸시하려면, 먼저 이미지를 태그하고 푸시합니다.

```bash
docker tag xe:blue 13.124.183.113:5000/crystal:xe
docker push 13.124.183.113:5000/crystal:xe
```

## MySQL 접속 및 데이터베이스 확인

1. **MySQL 접속**: MySQL 컨테이너에 접속하여 데이터베이스 작업을 할 수 있습니다. `docker exec` 명령어를 사용하여 MySQL에 접속합니다.

    ```bash
    docker exec -it db1 mysql -u root -p
    ```

    `test123` 비밀번호를 입력하여 MySQL 쉘에 접속합니다.

2. **데이터베이스 생성**: XE를 위한 `xe` 데이터베이스를 생성합니다.

    ```sql
    CREATE DATABASE XE;
    ```

3. **XE 데이터베이스 사용**: `xe` 데이터베이스로 전환합니다.

    ```sql
    USE xe;
    ```

4. **테이블 생성**: 예시로 사용자 정보를 저장할 `USER` 테이블을 생성합니다.

    ```sql
    CREATE TABLE USER (
        id INT,
        name VARCHAR(20),
        age INT
    );
    ```

## XpressEngine 실행 후 접속

이제 XpressEngine이 설정되었으므로, 웹 브라우저에서 `http://<서버_ip>:8008` 주소로 접속하여 XpressEngine을 사용할 수 있습니다.

![image](https://github.com/user-attachments/assets/8bef5e72-ed5e-4f5a-9218-0ddc3796bc38)

