전 글에서 생성한 Azure 가상머신에 MariaDB를 설치하고 Standalone 하나를 기동해보자

## 1. 가상머신 접속

설치를 하려면 당연히 가상머신에 접속해야한다!
mobaxterm, putty, xshell 다양한 접속도구가 있으니 편한 것을 사용하자.

> [👉 XShell로 Cloud 가상머신 접속하기](https://velog.io/@deaf52/Linux-XShell%EB%A1%9C-Cloud-%EA%B0%80%EC%83%81%EB%A8%B8%EC%8B%A0-%EC%A0%91%EC%86%8D%ED%95%98%EA%B8%B0)

</br>

## 2. MariaDB 설치하기

```bash
DBA_RDB@MariaDB-1:~$ sudo apt update
## update 완료 ##
```
OS에 처음 접속했으니 우분투의 패키지 관리자인 apt를 업데이트 해준다.

</br>

```bash
# 버전 확인
DBA_RDB@MariaDB-1:~$ apt list mariadb-server -a
Listing... Done
mariadb-server/noble-updates,noble-security 1:10.11.8-0ubuntu0.24.04.1 arm64
mariadb-server/noble 1:10.11.7-2ubuntu2 arm64

# 설치
DBA_RDB@MariaDB-1:~$ sudo apt install mariadb-server -y
```

설치할 수 있는 마리아DB 버전을 확인하니 10.11 버전대가 있다.
최신버전은 11.4.4이지만 안정화된 버전을 설치하자.

원하는 버전이 따로 있다면 아래의 링크에서 원하는 버전, OS를 골라서 리포지토리를 추가해야한다.

[👉 MariaDB 공식 홈페이지 - 다운로드](https://mariadb.org/download/?t=mariadb&p=mariadb&r=10.11.10&os=Linux&cpu=x86_64&i=systemd&mirror=blendbyte)


</br>

## 3. 설치 확인

```bash
# 설치된 버전 확인
DBA_RDB@MariaDB-1:~$ mariadb --version
mariadb  Ver 15.1 Distrib 10.11.8-MariaDB, for debian-linux-gnu (aarch64) using  EditLine wrapper


# 구동 확인
DBA_RDB@MariaDB-1:~$ sudo netstat -tulpn |grep maria
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      6076/mariadbd 
```
확인했던 10.11.8버전으로 정상적으로 설치되었고

netstat으로 포트를 조회해보면 `3306`포트로 데몬이 실행되어있다.


</br>

## 4. sudo 접속, 초기세팅

```bash
# 접속되지 않음
DBA_RDB@MariaDB-1:~$ mariadb
ERROR 1698 (28000): Access denied for user 'DBA_RDB'@'localhost'

# 수도권한으로 접속
DBA_RDB@MariaDB-1:~$ sudo mariadb
Welcome to the MariaDB monitor.  Commands end with ; or \g.
```

첫 접속은 수도권한 없이는 할 수 없다.
이 때 다음과 같은 선택지가 있다.

1. sudo로 접속하여 계속 사용
2. sudo로 접속하여 root계정 비밀번호 변경
3. sudo로 접속 후 일반 계정 생성

1번은 수도권한이 계속 필요하고
나머지는 수도권한 없이도 DB운영을 할 수 있다.

sudo권한은 비즈니스 상황에 따라 있을 수도, 없을 수도 있으니 계정을 만들어 사용해보자

</br>

```sql
# 루트 계정 비밀번호 생성
MariaDB [(none)]> ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
Query OK, 0 rows affected (0.004 sec)

# 기본 권한만 가진 사용자 계정(deaf) 생성
MariaDB [mysql]> CREATE USER 'deaf'@'%' IDENTIFIED BY 'deaf';
Query OK, 0 rows affected (0.004 sec)

MariaDB [mysql]> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX ON *.* TO 'deaf'@'%';
Query OK, 0 rows affected (0.006 sec)
```
위와 같이 생성하면 된다. 확인해보자

</br>

```sql
MariaDB [(none)]> use mysql

MariaDB [mysql]> select user, password, host from user;
+-------------+-------------------------------------------+-----------+
| User        | Password                                  | Host      |
+-------------+-------------------------------------------+-----------+
| mariadb.sys |                                           | localhost |
| root        | *81F5E21E35407D884A6CD4A731AEBFB6AF209E1B | localhost |
| mysql       | invalid                                   | localhost |
| deaf        | *BA1288D11ED3BA379F3BC1FD1589111AB63D40E5 | %         |
+-------------+-------------------------------------------+-----------+
4 rows in set (0.001 sec)
```

host는 접속가능한 주소를 말한다. root는 기본적으로 원격에선 접속이 안된다.
deaf계정은 원격에서도 접속이 가능하게 생성했다.

➕추가 정보

1. mariadb 10.4 이상에서는 암호화를 위해 `password()` 함수를 쓰지 않아도 된다. 자동적용됨.
	```sql
    -- password함수를 사용하지 않아도 암호화됨
    CREATE USER 'deaf'@'%' IDENTIFIED BY password('deaf')
    ```

2. `flush privileges`구문은 직접 테이블을 조작할 때만 사용하면 된다.
	```sql
    -- 예시
	INSERT INTO mysql.user (user, password, host) VALUES ('deaf', password('deaf'), '%');
    flush privileges;
	```


</br>

## 5. 유저 접속, CRUD 테스트

```bash
# 접속종료 (단축키 ctrl d)
MariaDB [mysql]> exit
Bye

# deaf계정으로 접속
DBA_RDB@MariaDB-1:~$ mariadb -u deaf -p
Enter password: deaf

# DB 생성
MariaDB [(none)]> create database testdb;
Query OK, 1 row affected (0.001 sec)

# DB 전환
MariaDB [(none)]> use testdb;
Database changed

# 간단한 테이블 생성
MariaDB [testdb]> create table employees(enum int primary key auto_increment, name varchar(8));
Query OK, 0 rows affected (0.029 sec)

# insert TEST
MariaDB [testdb]> insert into employees(name) values ("lee"),("park"),("kim"),("do");
Query OK, 4 rows affected (0.007 sec)
Records: 4  Duplicates: 0  Warnings: 0

# 데이터 조회
MariaDB [testdb]> select * from employees;
+------+------+
| enum | name |
+------+------+
|    1 | lee  |
|    2 | park |
|    3 | kim  |
|    4 | do   |
+------+------+
4 rows in set (0.000 sec)
```

데이터 테스트까지 했으니 이로써 설치가 완료됐다고 말할 수 있다.
다음 글에선 부하분산을 위한 MMM, MHA를 설정해볼 것이다.