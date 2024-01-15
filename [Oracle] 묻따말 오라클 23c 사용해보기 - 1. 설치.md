> **Oracle 23c**의 가장 큰 특징은 '벡터 검색'의 도입이다. 이는 대 AI시대에서 RDBMS의 한계를 극복할 수 있는 차이점이 아닐 수 없다. 그 외에도 JSON데이터의 저장 지원 등 다양한 기능을 지원한다.

이 시리즈에선 묻지도 따지지도 말고 **도커를 이용해 오라클 23c를 설치하고 다양한 기능들을 사용**해보자.

[👉공식 홈페이지 Quick Start](https://www.oracle.com/database/free/get-started/#quick-start)

공식문서는 linux환경에 대한 설치 가이드가 있으며 windows용 설치는 현재 제공되고 있지 않다.

# 설치

## #1 도커 이미지 pull, run

```bash
docker pull container-registry.oracle.com/database/free:latest

# pull 완료시
docker run -d --name oracle container-registry.oracle.com/database/free:latest

# 로그 확인
docker logs oracle
```

`oracle`라는 이름으로 컨테이너를 실행하였다.
기본적으로 1521포트가 열린다.

아래와 같은 로그가 확인되었고 이상은 없는 듯 하다.

```bash
Starting Oracle Net Listener.
Oracle Net Listener started.
Starting Oracle Database instance FREE.
Oracle Database instance FREE started.

The Oracle base remains unchanged with value /opt/oracle
#########################
DATABASE IS READY TO USE!
#########################
The following output is now a tail of the alert.log:
2024-01-15T09:23:39.774805+00:00
===========================================================
Dumping current patch information
===========================================================
No patches have been applied
===========================================================
2024-01-15T09:23:40.505245+00:00
FREEPDB1(3):Opening pdb with Resource Manager plan: DEFAULT_PLAN
Completed: Pluggable database FREEPDB1 opened read write
Completed: ALTER DATABASE OPEN
2024-01-15T09:25:37.164072+00:00
FREEPDB1(3):Resize operation completed for file# 13, fname /opt/oracle/oradata/FREE/FREEPDB1/sysaux01.dbf, old size 317440K, new size 327680K
2024-01-15T09:25:37.180469+00:00
FREEPDB1(3):Resize operation completed for file# 13, fname /opt/oracle/oradata/FREE/FREEPDB1/sysaux01.dbf, old size 327680K, new size 337920K
```

> **Trouble Shooting** : SGA 용량 부족 에러가 발생한다면 도커 스펙을 늘려준다
참고 [👉 .wslconfig 으로 도커 스펙 관리하기](https://velog.io/@deaf52/wsl-.wslconfig%EC%9C%BC%EB%A1%9C-%EB%8F%84%EC%BB%A4-%EC%8A%A4%ED%8E%99-%EA%B4%80%EB%A6%AC%ED%95%98%EA%B8%B0)

## #2 컨테이너 접속, 비밀번호 설정, 실행
```bash
docker exec -it oracle bash

# 초기 비밀번호를 'pw'로 설정한다.
./setPassword.sh pw

# sqlplus 실행
sqlplus
system
pw
```
![](https://velog.velcdn.com/images/deaf52/post/f8eccc73-d983-4ae7-9ed9-c3329a452ba5/image.png)
