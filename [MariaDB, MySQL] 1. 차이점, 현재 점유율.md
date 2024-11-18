## MariaDB 그리고 MySQL

> **둘이 같은 거 아냐❓**

스치듯 접하기만 해 본 사람들은 둘이 같다고 생각할 수 있다.

아닌게 아니라 MySQL의 오라클 합병 후
MySQL의 창립자인 미카엘 몬티_Michael "Monty" Widenius_를 비롯한 개발자들이 fork하여 개발하게 된 것이 MariaDB이다.

따라서 MariaDB는 MySQL의 대부분에 호환성을 가지고
많은 부분에서 발전된 면모를 보인다.
<br>

## 한 눈에 보는 차이점
<table>
  <thead>
    <th scope=col></th>
  	<th>MariaDB</th>
  	<th>MySQL</th>
  </thead>
  <tbody>
    <tr>
      <th scope=row style="border: 1px solid grey;">JSON 데이터</th>
      <td style="border: 1px solid grey;">LONGTEXT로 저장</td>
      <td style="background-color:#B7F0B1;font-weight:bold;border: 1px solid grey;">바이너리 객체로 저장</td>
    </tr>
    <tr>
      <th scope=row style="border: 1px solid grey;">오라클과의 호환성</th>
      <td style="background-color:#B7F0B1; border: 1px solid grey;"><b>PL/SQL 지원(v10.3)</b><br>높은 호환성</td>
      <td style="border: 1px solid grey;">높은 호환성</td>
    </tr>
    <tr>
      <th scope=row style="border: 1px solid grey;">속도</th>
      <td style="background-color:#B7F0B1;font-weight:bold; border: 1px solid grey;">상대적으로 빠름</td>
      <td style="border: 1px solid grey;">상대적으로 느림</td>
    </tr>
    <tr>
      <th scope=row style="border: 1px solid grey;">기능</th>
      <td style="border: 1px solid grey;">보이지 않는 열<br>임시 테이블 공간</td>
      <td style="border: 1px solid grey;"> super 읽기 전용 함수<br>동적 열을 이용한 데이터 마스킹</td>
    </tr>
    <tr>
      <th scope=row style="border: 1px solid grey;">보안</th>
      <td style="border: 1px solid grey;">암호 보안<br>(validate_password)</td>
  	  <td style="background-color:#B7F0B1;font-weight:bold; border: 1px solid grey;">ed25519 암호 인증 플러그인(v10.4)</td>
    </tr>
    <tr>
      <th scope=row style="border: 1px solid grey;">스레드 풀</th>
      <td style="background-color:#B7F0B1;font-weight:bold; border: 1px solid grey;">20만개 이상의 연결 관리</td>
      <td style="border: 1px solid grey;">Enterprise 버전에 플러그인 있음</td>
    </tr>
    <tr>
      <th scope=row style="border: 1px solid grey;">스토리지 엔진</th>
      <td style="background-color:#B7F0B1;font-weight:bold; border: 1px solid grey;">다양함</td>
      <td style="border: 1px solid grey;">상대적으로 적음</td>
    </tr>
    <tr >
      <th scope=row style="border: 1px solid grey;">라이센스</th>
      <td style="border: 1px solid grey;">Community / Enterprise / Maxscale</td>
      <td style="border: 1px solid grey;">Community / Enterprise</td>
    </tr>
  <tbody>
</table>

MariaDB의 강점이 확연히 두드러져 보이지만 

MySQL이 지금까지 쌓아온 점유율과 신뢰성을 무시할 수 없다.

![](https://velog.velcdn.com/images/deaf52/post/bf0c795f-25b0-430d-b34f-db857496c244/image.png)

지속적으로 성장하던 MariaDB는 2023년 인수설이 돌던 시점부터 흔들리기 시작했고 

24년 중순부터 시작된 k-1으로의 주식 인수가 마무리되면서 오픈소스 정신 계승에 대한 우려,
Azure의 MariaDB 인스턴스 생성중단 

등 지속적인 악재로 인해 24년 들어서는 다소 하향세를 보인다.

>
[흔들리는 마리아DB…최대 피해자는 삼성?](https://www.itworld.co.kr/news/326710)
[GN⁺: K1, MariaDB 인수 및 새로운 CEO 임명](https://news.hada.io/topic?id=16721)
[Microsoft Azure의 MariaDB 지원 중단](https://learn.microsoft.com/ko-kr/azure/mariadb/migrate/whats-happening-to-mariadb)


그렇다고 MariaDB의 전망이 어둡다고 하기에는 많이 이르다.
아직도 많은 기업이 MariaDB로의 Migration을 수행하고 있다.

<br>

#### MariaDB와 MySQL 의 분산 시스템

DB 시스템을 얘기할 때 부하분산 시스템을 빼놓을 수 없다.

다음 글에선 백업/복구와 더불어서 DBMS의 알파이자 오메가인 분산시스템을 
MariaDB, MySQL에서 어떻게 수행하는지 알아보자.

<br>

![](https://velog.velcdn.com/images/deaf52/post/1dd77477-8653-4210-92b5-2b35e1c9938e/image.png)
Reference
https://aws.amazon.com/ko/compare/the-difference-between-mariadb-vs-mysql/
