## # 리눅스, 왜 알아야 하는가?

Q. 실무에서 리눅스 얼마나 사용하는지?

A. 
![](https://velog.velcdn.com/images/deaf52/post/c63fd4b6-5587-4503-9f1b-ff9c6390ac90/image.png)

당신의 직무가 프론트든, 백엔드든, 서버든 앱이든 DB든 뭐든간에 **CLI환경 없이 모든 업무를 수행할 수 있을 확률은 매우 낮다.**

백엔드/데브옵스/서버의 경우 당연히 '말해뭐해'고
그 외라도 서버 관리, 배포, 자동화 등의 작업에서 CLI환경은 필수적이다.

GUI보다 자원 대비 비용, 속도 등 많은 부분에서 효율적인 **CLI의 대표주자는 단연 Linux와 Bash이다.** (맥의 `zsh`도 있긴 하다)

MariaDB 게시글을 작성하다 문득 리눅스 입문글도 작성하지 않았다는 사실을 깨닫고
부랴부랴 입문자용 가이드를 작성해보려 한다.

> **🎯목표 : 입문자 탈출하기**
뭐가됐던 고도화의 길은 멀고도 험하다.
기본적으로 쓰는 명령어들로 간단하게 익혀보자.

---

### 1) 계정 관련 명령어
1-1) `whoami`  : 나의 계정명은?
```bash
DBA_RDB@MariaDB-1:~$ whoami
DBA_RDB # 계정명 : 'DBA_RDB'
```
- 계정별로 권한이 나뉜다는 것을 유념해야한다. 추가적인 정보는 나중의 글에서...
</br>

1-2) `sudo` : root권한 얻기 

```bash
# 3가지 방법

## root 비밀번호를 아는 경우
DBA_RDB@MariaDB-1:~$ su root
Password: 

## 계정에 root권한이 있는 경우
root@MariaDB-1:/home/DBA_RDB$ sudo su
root@MariaDB-1:/home/DBA_RDB$ sudo -i
```
- sudo = **S**uper **U**ser **DO**
- su = **S**witch **U**ser
- root = 최고권한을 갖는 리눅스 기본 생성 계정
</br>

1-3) `exit` : 로그아웃 (단축키 ctrl+d)
```bash
root@MariaDB-1:~$ exit
```

---

### 2) 시스템 관련 명령어

2-1) `cat /etc/*release*` : OS정보 조회

```bash
DBA_RDB@MariaDB-1:~$ cat /etc/*release*
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=24.04
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="Ubuntu 24.04.1 LTS"
# 생략
```
</br>

2-2) HW정보 조회
- 사용빈도가 낮으니 필요 시 사용하자. 
```bash
uname -a	# 전체 시스템 정보
hostname	# 시스템의 호스트 이름
top			# CPU, 메모리 사용량, 프로세스 정보 등
df -h		# 디스크 공간의 사용량
free -h		# 메모리의 사용량, 가용량, 스왑 영역 등을 표시
lscpu		# CPU 정보
lsblk		# 연결된 디스크와 파티션 정보를 트리 형태로 표시
sudo lshw	# 시스템의 하드웨어 구성에 대한 상세 정보 출력
uptime		# 시스템의 가동 시간과 평균 부하 정보
dmesg		# 커널 메시지 출력 (시스템 부팅 메시지 등)
```

---

### 3) ⭐ 파일시스템 ⭐
- 단연코 자주 쓰는 명령어들이다.

3-1) 디렉터리 관련; `pwd`, `ls`, `ll`, `mkdir`, `cd`
```bash
# 현재 위치 확인 (print working directory)
DBA_RDB@MariaDB-1:~$ pwd
/home/DBA_RDB

# 현재 위치의 파일 확인 (list)
DBA_RDB@MariaDB-1:~$ ls

# 파일 확인 자세하게 (ls -l)
DBA_RDB@MariaDB-1:~$ ll

# 디렉터리 생성 (make directory)
DBA_RDB@MariaDB-1:~$ mkdir mariadb	# mariadb 폴더 생성

# 경로 이동 (change directory)
DBA_RDB@MariaDB-1:~$ cd mariadb/	# mariadb 폴더로 이동
DBA_RDB@MariaDB-1:~/mariadb$ pwd
/home/DBA_RDB/mariadb				# 현재 위치가 바뀌었다.
```

- 절대경로, 상대경로
  - 절대경로는 루트경로`/`부터 입력하는 것
  - 상대경로는 현재경로`.`부터 입력하는 것
   - `ls /home/DBA_RDB/mariadb` = `ls ./mariadb`
- 경로 지정 단축어
  - `cd ..` 하위 디렉터리로 이동
  - `cd .` 현재 디렉터리로 이동
  - `cd ~` 홈 디렉터리로 이동
  - `cd -` 이전 디렉터리로 이동
- 자동완성
  - `tab`
  괴랄한 경로나 파일명을 다 칠 필요 없이 `tab`을 눌러서 자동완성을 할 수 있다.
- 만능취소 ★
  - `ctrl + c` 오타? 잘못실행? 뭐든 일단 취소해보자
</br>

3-2) 파일조작; `touch`, `cp`, `rm`, `mv`
```bash
# 빈 파일 생성
DBA_RDB@MariaDB-1:~/mariadb$ touch abc.txt
DBA_RDB@MariaDB-1:~/mariadb$ ls
abc.txt

# 파일 복사 (copy)
DBA_RDB@MariaDB-1:~/mariadb$ cp abc.txt def.txt			# abc.txt 복사
DBA_RDB@MariaDB-1:~/mariadb$ ll
-rw-rw-r-- 1 DBA_RDB DBA_RDB    0 Jan 14 12:34 abc.txt
-rw-rw-r-- 1 DBA_RDB DBA_RDB    0 Jan 14 12:35 def.txt

# 파일 제거 (remove)
DBA_RDB@MariaDB-1:~/mariadb$ rm def.txt
DBA_RDB@MariaDB-1:~/mariadb$ ls
abc.txt 
```
- 디렉터리(폴더)의 경우 -r 옵션을 지정해야한다. (recursive)
이 -r 옵션은 여러 명령어에서 '디렉터리/통째로'의 뜻으로 자주 사용된다.
  - `cp -r` 디렉터리 통째로 복사
  - `rm -r` 디렉터리 삭제
- 비슷하게 통용되는 옵션으로 -f 가 있다. (강제로, 확인절차 없이)

</br>

3-3) 파일조작 2; `vi`, `view`, `cat`
```bash
# 파일 편집
DBA_RDB@MariaDB-1:~/mariadb$ vi abc.txt
```
vi 편집기 내에선 다양한 단축키를 사용할 수 있다.
기본적으론
- `esc`/`ctrl+c` 커서 초기화 ☆
- `i` 편집 시작
- `:` 명령어 입력
  - `:w` 저장하기
  - `:q` 나가기
  - `:wq` 저장하고 나가기
  - `:q!` 저장하지 않고 나가기
- `/` 검색 시작

이정도만 알면 간단한 편집은 무리없이 할 수 있다.
뭔가 잘못 누른거 같으면 `esc :q!` 콤보를 반드시 기억하자😉

abc.txt에 아무말이나 치고 `:wq` 저장하고 나가보자.

```bash
# 파일 내용 출력 (concatenate)
DBA_RDB@MariaDB-1:~/mariadb$ cat abc.txt
dfasdfas # 파일 내용이 터미널로 출력됨

# 파일 내용 조회
DBA_RDB@MariaDB-1:~/mariadb$ view abc.txt
```
`view`는 편집기를 이용하여 읽기전용으로 조회하는 것
`cat`으로 대용량의 파일을 출력했다간 터미널이 꽉꽉 들어차버리므로 `vi`/`view`를 이용해 편집기를 이용하는 것도 선호된다.

이외에도 로그 조회에 자주 사용되는 `tail -f`, `head` 등이 있다.


>
**TMI🙃**
- `vim`이라는 `vi`의 향상버전이 있다.
- 사실 대부분의 `vi`는 `vim`이다.
```bash
$ ll /etc/alternatives/vi
lrwxrwxrwx 1 root root 18 Nov  3 09:51 /etc/alternatives/vi -> /usr/bin/vim.basic
```
- `view`도 `vim`이다.
```bash
$ ll /etc/alternatives/view
lrwxrwxrwx 1 root root 18 Nov  3 09:51 /etc/alternatives/view -> /usr/bin/vim.basic
```

---



### 자 이게 클릭이야 💀

![](https://velog.velcdn.com/images/deaf52/post/a76a85c0-5c63-4cef-a80c-03ba6bda648b/image.webp)

**여러분은 이제 클릭을 할 수 있게 되었다.**
다음 글에선 걸음마를 뗄 수 있도록 해보자.
(걸음마가 천리행군일 수도 있다는건 안비밀)