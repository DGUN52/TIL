- 원본게시글 : https://velog.io/@deaf52/%EC%97%90%EB%9F%AC-Problem-conflicting-requests
### 에러 상세내용
>
```bash
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

### 발생상황
: AWS EC2 콘솔에서 MySQL설치 명령어 입력 시 발생
`$ sudo yum install https://dev.mysql.com/get/mysql80-community-release-el6-9.noarch.rpm -y`

### 원인
: AWS의 linux 버전에서 지원하지 않는 패키지(yum) 및 설치파일(el6-9) 사용

### 해결방법
- `$ cat /etc/system-release` 으로 확인한 리눅스 버전은 **Amazon Linux release 2023**이다.
- 2023버전에선 `dnf`패키지 및 9-1 버전 사용 필요
- 아래 명령어로 패키지 다운 및 설치 시 성공
  `$ sudo dnf install https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -y`
  `$ sudo dnf install mysql-community-server-8.0.32-1.el9.x86_64`
