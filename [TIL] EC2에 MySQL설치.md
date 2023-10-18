# EC2 MySQL설치

<aside>
💡 명령어 정리 [https://velog.io/@marbea6282/리눅스-언어-정리](https://velog.io/@marbea6282/%EB%A6%AC%EB%88%85%EC%8A%A4-%EC%96%B8%EC%96%B4-%EC%A0%95%EB%A6%AC)
</aside>

1. AWS 계정 생성, 결제 수단 등록
2. EC2 인스턴스 생성
    - 전부 프리티어 기본값 혹은 최저성능으로 설정
3. 아래 사이트에서 버전에 해당하는 MySQL최신버전 다운
    - DB복제에 마스터로 사용할 DB의 MySQL버전이 8.0.32이므로 그와 같거나 높은 버전을 설치해주어야 한다. 동일한 버전으로 설치해주었다.
    
    `$ sudo dnf install [https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm](https://dev.mysql.com/get/mysql80-community-release-el6-9.noarch.rpm) -y`
    
    `$ sudo dnf install mysql-community-server-8.0.32-1.el9.x86_64`
    

### 에러

- `$ cat /etc/system-release` 명령을 수행했을 때 **Amazon Linux release 2023**버전 이라면 아래 에러가 발생할 수 있다.

```
Error: 
 Problem: conflicting requests
  - nothing provides libcrypto.so.10()(64bit) needed by mysql-community-server-8.0.11-1.el7.x86_64
  - nothing provides libssl.so.10()(64bit) needed by mysql-community-server-8.0.11-1.el7.x86_64
  - nothing provides libcrypto.so.10(libcrypto.so.10)(64bit) needed by mysql-community-server-8.0.11-1.el7.x86_64
  - nothing provides libssl.so.10(libssl.so.10)(64bit) needed by mysql-community-server-8.0.11-1.el7.x86_64
  - nothing provides libcrypto.so.10()(64bit) needed by mysql-community-server-8.0.12-1.el7.x86_64
  - nothing provides libssl.so.10()(64bit) needed by mysql-community-server-8.0.12-1.el7.x86_64
...
```

- 옛날버전이라면 yum 패키지나 [`https://dev.mysql.com/get/mysql80-community-release-el6-9.noarch.rpm`](https://dev.mysql.com/get/mysql80-community-release-el6-9.noarch.rpm) 와 같은 파일을 사용해야 한다. 이 부분은 본인의 환경에 맞게 확인필요
