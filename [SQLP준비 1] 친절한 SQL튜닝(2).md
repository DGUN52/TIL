# 4 조인 튜닝

## 4.1 NL 조인

조인의 기본

### 4.1.1 기본 메커니즘

`사원`테이블에서 1996년 이후 입사한 직원을 찾고
`고객`테이블에서 그 사원이 관리하는 고객을 찾는 쿼리가 있을 때

- 절차 > 사원을 찾고 그에 해당하는 고객을 건건이 찾는다. → NL조인의 방식
2중 반복문과 같은 원리


- 이 때 사원이 `outer`쪽이고, 고객이 `inner`쪽이다.
- 기본적으로 NL조인은 양쪽 테이블의 인덱스를 사용하지만,
outer쪽 테이블이 크지 않다면 인덱스를 사용하지 않을 수 있다.

### 4.1.2 NL조인 실행계획 제어

```sql
-- ordered 힌트는 FROM절에 기술한 순서대로 조인 수행하라는 지시
select /*+ ordered use_nl(c) */ * 
from e, c

-- 여러 테이블을 조인 할 경우
select /*+ ordered use_nl(B) use_nl(C) use_hash(D) */ * 
from A, B, C, D

-- ordered 대신 leading 활용
select /*+ leading(C, A, D, B) use_nl(A) use_nl(D) use_hash(B) */ * 

-- ordered/leading 없이 사용 : 옵티마이저가 스스로 정함
select /*+ use_nl(A, B, C, D) */ * 
```

### 4.1.3 NL 조인 수행 과정 분석

** 262p NL조인 순서 분석 맞춰보기**

- NL조인은 각 단계를 완전히 끝낼때마다 넘어가는 것이 아니라
조건이 일치할 때 마다 다음 절차를 진행한다.(이중 반복, DFS와 동일)


### 4.1.4 NL 조인 튜닝 포인트

그림 4-7에서의 튜닝 포인트

1. 사원_X1인덱스를 읽고 사원 테이블을 액세스하는 부분
   - 필터링되는 비율이 높다면 부서코드를 인덱스에 추가하는 것을 고려할 만 하다.


2. 고객_X1를 탐색하는 부분
   - 어쩌라고?


3. 고객_X1 인덱스를 읽고 고객 테이블을 액세스 하는 부분
   - 여기서도 필터링 비율이 높다면 고객_X1 인덱스에 최종주문 금액 컬럼을 추가하는 방안 고려
   
   
그리고 기본적으로 사원_X1 인덱스에서 얻은 건수에 따라 전체 일량이 좌우됨

기본적 튜닝 방법으론 각 단계의 일량을 분석하고, 과도한 랜덤 액세스가 발생하는 지점을 파악한다.
그 후 조인 순서를 변경하거나 인덱스 변경/교체를 검토, 인덱스 추가/구성변경도 검토

최종적으로 성능향상요소를 찾기 어렵다면 `소트 머지 조인`/`해시 조인`을 검토


### 4.1.5 NL 조인 특징 요약
- 랜덤 액세스 위주의 조인 방식
  - 대량 데이터 조인에 불리함


- 한 레코드씩 순차적으로 진행
  - 대량 데이터 조인에는 불리하지만, 응답속도에서는 매우 빠름(부분 범위 처리 가능할 시)
  

- 먼저 액세스 되는 테이블의 범위에 따라 전체 일량이 결정됨

- 인덱스 구성 전략이 특히 중요


**→ 전체적으로 소량 데이터 혹은 부분 범위 처리에 특화된 조인**


### 4.1.6 NL 조인 튜닝 실습

- 첫 예시 쿼리의 실행계획을 통해 부하 지점 파악하기

- `cr` : consistent read, 읽은 블록 수, 버퍼 캐시에서 읽음
- `pr` : physical read, 디스크에서 읽어서 버퍼 캐시에 적재

- 두, 세번째 예시도 파악하기


### 4.1.7 NL 조인 확장 메커니즘

- Prefetch : 인덱스를 이용해 액세스하다가 디스크IO가 필요해지면 이어서 읽을 블록들도 미리 읽어오는 기능
  - 발동 시 실행계획 : 고전적인 Nested Loop에서 (최하단의) Table Access 계획이 최상단으로 올라가는 형태


- 배치 IO : 디스크IO를 쌓아뒀다가 한번에 처리
  - 발동 시 실행계획 : 고전적인 Nested Loop에서 (최하단의) Table Access 계획이 최하단에서 밖으로 나오는 형태, 최상단에 이를 감싸는 Nested Loops 문구 추가됨


배치IO가 발동할 시에는 데이터 정렬 순서도 바뀔 수 있다.
따라서 소트생략/부분범위 처리 등을 위해 배치IO가 발동하지 않길 원한다면 no_nlj_batching(b) 같은 힌트를 추가해야함



## 4.2 소트 머지 조인

인덱스가 없거나 대량 데이터 조인이라 인덱스의 효과가 없을 때
옵티마이저는 `소트 머지 조인` / `해쉬 조인`을 사용함


### 4.2.1 SGA vs PGA
- SGA : 여러 프로세스가 공유, 동시 액세스는 불가
  - 직렬화를 위한 락매커니즘 > Latch
  - 핵심 구성요소 : DB 버퍼캐시
- PGA : 프로세스의 고유 메모리 영역
  - PGA공간이 작을 때 > Temp Tablespace 사용
  - Latch 메커니즘 불필요 → 버퍼캐시에서 읽을 때 보다 빠름

### 4.2.2 기본 메커니즘
- 소트 머지 조인
  1. 소트 단계
     - 조인 컬럼 기준으로 정렬
  2. 머지 단계
     - 정렬한 집합을 Merge

- 4.1에서 사용했던 쿼리로 설명
  1. 사원 테이블의 결과집합을 정렬하여 `PGA`의 `Sort Area`에 저장, 공간 부족 할 시 `Temp Tablespace`에 저장
  2. 고객 테이블의 결과집합을 마찬가지로 정렬하여 저장

즉 조인컬럼 기준으로 정렬한 자체를 인덱스로 삼음


### 4.2.3 소트 머지 조인이 빠른 이유

- NL조인은 인덱스를 이용하기 때문에, 액세스하는 모든 블록을 랜덤 액세스 방식으로 DB 버퍼캐시를 경유해서 읽음.
  - 추가적인 `래치 경쟁`과 `캐시버퍼 체인 스캔` 과정을 거침. 버퍼캐시에서 못 찾을 경우 `DISK IO`도 발생


- 소트 머지 조인은 PGA에서 수행하므로 래치경쟁에서 비교적 자유로움
  - 소트 머지 조인도 조인 대상 집합을 읽을 때는 DB 버퍼캐시를 경유하고, 인덱스를 사용하기도 함.
  이때는 버퍼캐시 탐색 비용, 랜덤 액세스 비용을 피할 수 없음


### 4.2.4 소트 머지 조인의 주 용도

- 조인 조건이 `=` 조건이 아닌 대량 데이터 조인
- 조인 조건식이 아예 없는 카테시안(크로스) 조인


### 4.2.5 소트 머지 조인 제어하기

`SELECT /*+ ordered use_merge(c) *`


### 4.2.6 소트 머지 조인 특징 요약
소트 부하만 감수하면, 건건이 버퍼캐시를 경유하는 NL조인보다 빠르다
NL조인과 달리 인덱스 유무의 영향을 받지 않는다.

> 250217(월) 255p ~ 281p

## 4.3 해시 조인

`소트 머지 조인`과 `해시조인`은 인덱스가 필수적이지 않음
→ 대량 데이터 조인에 NL조인보다 빠르고, 일정한 성능을 보임 

해시조인은 테이블을 정렬하는 부하도 없음

### 4.3.1 기본 메커니즘

다른 조인과 마찬가지로 두 단계로 진행됨
(NL 조인 → outer에서 해당하는 로우를 찾고, inner에서 해당하는 로우를 건건히 찾음 (2중반복문)
소트머지조인 → 소트 단계; 조인 컬럼 기준으로 양쪾 테이블 정렬, 머지 단계; 정렬한 집합을 병합)

1. Build 단계
   - 작은 쪽 테이블 (Build Input)을 읽어 헤시 테이블(해시 맵)을 생성한다.
   - ex) 사원번호로 PGA의 Hash Area 혹은 Temp Tablespace에 해시 테이블을 생성
2. Probe 단계
   - 큰 쪽 테이블 (Probe Input)을 읽어 해시 테이블을 탐색하면서 조인한다.
   - ex) 최종주문금액 조건을 만족하는 로우 중에서 관리사원번호로 해쉬조인을 실시한다.

힌트 : `use_hash(a b)`


### 4.3.2 해시 조인이 빠른 이유

소트 머지 조인이 빠른 이유와 같음
- PGA에서 진행, 래치 경쟁 X

해시조인도 Build Input, Probe Input을 각 테이블에서 읽을 때는 DB 버퍼캐시를 경유하고, 인덱스를 사용하기도 한다.

- 해시테이블에는 조인 키값만이 아닌 쿼리에 사용되는 모든 컬럼이 포함된다.


- 소트 머지 조인의 준비 단계 : 양 테이블을 조인 키 값으로 정렬. 이 때 Temp Tablespace로 넘어갈 가능성이 높음
- 해시 조인의 준비 단계 : 작은 쪽 테이블을 읽어서 해시 테이블 생성. Temp Tablespace로 넘어가더라도 상대적으로 부하 적음
  - Temp Tablespace로 넘어가지 않고 PGA의 해시 공간에서 처리하는 것을 `인메모리 해시 조인`이라 칭함


### 4.3.3 대용량 Build Input 처리

양 쪽 테이블이 모두 대용량이라 인메모리 해시 조인이 불가능하다면
→ 분할 정복방식을 사용

1. 파티션 단계
   - 양쪽 집합 **(조인 이외 조건절을 만족하는 레코드)** 의 조인컬럼으로 얻은 해시값들을 바탕으로 동적으로 파티셔닝
     - 독립적으로 처리 가능한 여러 서브집합으로 짝이 맞게 분할
   - Temp Tablespace에 저장

2. 조인 단계
   - 각 짝으로 조인 수행
     - 이 때 테이블에 상관없이 작은 쪽이 Build Input, 큰 쪽이 Probe Input
     - Build Input으로 해시 테이블을 만들고, 반대쪽으로 해시테이블 탐색
     
     
### 4.3.4 해시 조인 실행계획 제어

힌트에 ordered없이 use_hash만 사용할 경우 옵티마이저는 조건절에 해당하는 카디널리티가 작은 테이블을 Build Input으로 선택한다.

Build Input을 지정하고 싶다면 ordered 혹은 leading절을 이용한다.
`swap_join_inputs(t)` 구문으로 직접 지정할 수도 있다.

```sql
select /*+ leading(a) use_hash(b) swap_join_inputs(b) */
```


#### 세 개 이상 테이블 해시 조인

- `swap_join_inputs`, `no_swap_join_inputs` 힌트를 이용해 Build Input을 지정하는 방법 기억하기
- 원하는 조인 순서에 따라 leading 힌트에 기술하고, Build Input으로 사용하고 싶은 테이블을 swap_join_inputs에 지정하면 된다.
  - 조인된 결과 집합을 Build Input으로 지정하고 싶다면 `no_swap_join_inputs`로 Probe Input을 지정하면 된다.
  
  
### 4.3.5 조인 메소드 선택 기준

- 일반적인 메소드 선택 기준
  1. 소량 데이터 조인 → NL조인
  2. 대량 데이터 조인 → 해시 조인
  3. 해시조인이 불가능 할 때 (`=`조건으로 조인하지 않을 때) → 소트 머지 조인


- 대량의 기준 : NL조인 기준으로 최적화했음에도 랜덤 액세스가 많고 성능이 문제라면 대량

- 해시조인이 매우 빠른 경우가 아니라면 NL조인이 바람직하다.

- 조인방식을 고를 때 NL조인을 먼저 고려해야하는 이유
  - 수행빈도가 높은 쿼리를 해시조인, 소트 머지 조인으로 처리하면 CPU와 메모리에 부담이 너무 커짐


## 4.4 서브쿼리 조인

실무에서는 두세개가 아닌 더 많은 테이블을 조인하기 때문에
서브쿼리 조인에 대한 이해가 있어야 한다.

### 4.4.1 서브 쿼리 변환이 필요한 이유

옵티마이저는 비용을 산출하기 전에
사용자가 제출한 쿼리를 최적화하기 쉽도록 변환

- 서브 쿼리 종류
  - 인라인 뷰
  - 중첩 서브쿼리
  - 스칼라 서브쿼리

### 4.4.2 서브쿼리와 조인

#### 필터 오퍼레이션

- exists에 사용한 서브쿼리문에 `/*+ no_unnest */` 기술하면 서브쿼리를 풀어내지 않음으로써 필터링을 위해 사용할 수 있다.

- NL조인과 필터 작동이 다른점
  - 스킵기능; 메인쿼리와 서브쿼리와 조인된 후에는 break; 서브쿼리의 다음을 계속 이행하지 않고, 메인쿼리의 다음 로우를 처리한다.
  - 캐싱기능; 서브쿼리에 입력하는 값에 따른 결과값을 캐싱하여 반복된 값에 대한 답을 바로 도출


- 서브쿼리는 항상 메인 쿼리에 종속됨. 메인쿼리가 드라이빙 집합


#### 서브쿼리 unnesting

계층구조를 풀어내고 flat하게 만들어줌

unnesting되면 `필터` 방식을 사용할순 없지만
조인문처럼 다양한 최적화 기법 사용 가능

- `nl 세미 조인` : nl조인과 같은 프로세스지만, 조인에 성공하면 진행을 멈추고 다음 메인 쿼리를 진행

이 외에도 다양한 기법이 활용될 수 있다는 장점

```sql
-- 서브쿼리를 메인쿼리보다 먼저 처리하게 힌트 기술
select /*+ leading(거래@subq) use_nl(c)*/ *
from table_c c
where exists (
	select /*+ qb_name(subq) unnest */ 'x'
    from 거래
    where c.col_a = 거래.col_a
    	and ~
)


-- unnset 후 hash 세미조인으로 처리하게 기술

select ~
from ~
where exists (
	select /*+ unnest hash_sj */ 'x'
    from ~
    where <조인문>
    	~
)
```

- `rownum<:n`으로 출력 수를 제한하는 방법을 서브쿼리에 사용하면 성능이 떨어질 수도 있다.
  - ex) exists에 사용하는 서브쿼리문에 rownum<=1 사용

rownum 조건은 여러 힌트를 작동하지 못하게함 (unnest 등)


#### 서브쿼리 pushing

일반적으로 unnest되지 않은 서브쿼리는 보통 필터 방식으로, 맨 마지막 순서로 처리됨

- 309p의 실행계획
  - 서브쿼리에서 필터링하는 데이터의 양이 상당하다.
  필터링을 먼저 하여 조인되는 양을 줄일 수 있다면 좋은 경우


- 서브쿼리 Pushing : 서브쿼리를 실행계획 안쪽으로 밀어넣음. 먼저 처리되게함. 
힌트 : `select /*+ no_unnest push_subq */ col_a, col_b`
  - **unnest되지 않은 서브쿼리에만 작동함**. 따라서 `no_unnest`와 같이 사용하는 것이 바람직
  

### 4.4.3 뷰(view)와 조인

- 최적화 단위는 기본적으로 쿼리 블록


- 311p 뷰와 조인하는 쿼리
  - 뷰 밖에선 전월 데이터만 읽는데, 뷰는 이미 모든 데이터를 읽는다.
  → `select /*+ merge */` 힌트를 이용해 메인 쿼리와 합침. 
  @ 이 때 변하는 실행계획 **확인하기** @
  
  - merge하여 수정된 내용으론 `nl join`방식을 사용하여 비효율은 줄었지만,
  전체를 group by 한 후 출력할 수 있기 때문에 부분범위 처리는 불가능하다.
  → 이런 경우 보통 `hash 조인`이 빠름

#### 조인 조건 pushdown

메인 쿼리의 조인 조건절 값을 뷰 안으로 밀어넣음
힌트 : `select /*+ no_merge push_pred */ col_a, col_b`

위 힌트를 써서 실행계획에 `VIEW PUSHED PREDICATE`가 발생한다면
기술된 쿼리의 같은 경우 당월 거래 데이터만 조회하고, 중간에 멈출 수도 있다. (부분범위 처리가 가능하다)

실행계획만 보면 고객데이터와 조인하기 전에 group by까지 수행한다.
조인조건이 pushdown됐으므로 `group by 조인조건`을 수행하여 부분범위처리가 가능한 것
`push down predicate` 라는 실행계획에 유의


- `Lateral`, `Outer apply`, `Cross Apply` 구문으로 인라인 뷰를 대체하면, 인라인 뷰에서 다른 테이블의 컬럼을 참조하고 조인할 수 있다. 
단 조인 조건 pushdown이 잘 작동하므로 대체할 정도는 아니고, 코드가 혼란해질 수 있다.

> 250218(화) 282p ~ 316p

### 4.4.4 스칼라 서브쿼리 조인

#### (1) 스칼라 서브쿼리의 특징

- PLSQL함수를 만들어서 select절에 사용하면 메인쿼리 건수만큼 '재귀적으로' 반복 실행됨
- 반면 스칼라 서브쿼리로 사용하면, 반복실행된다는 것은 맞지만 함수처럼 CTS를 유발하진 않음
  - 아래 sql은 아우터 조인처럼 수행된다는 것

```sql
select a, b, c, d
	, (select name from dept where dept.deptno = emp.deptno) dname
from emp
where ~

-- 위 쿼리는 아래처럼 아우터 조인처럼 수행됨

select /*+ ordered use_nl(d) */ a, b, c, d, dname
from emp, dept
where dept.deptno(+) = e.deptno
	and ~
```

차이점은 스칼라 서브쿼리는 `캐싱 작용`이 일어남.


#### (2) 스칼라 서브쿼리 캐싱 효과

스칼라 서브쿼리로 조인 시 입출력값이 캐싱됨
- 입력값 > 서브쿼리에서 참조하는 메인쿼리의 컬럼 값(조인컬럼)

이 캐싱효과를 이용하여 PLSQL함수에다 스칼라 쿼리를 덧씌워서 캐싱효과를 이끌어낼 수 있다.
ex) `select a, b, (select get_dname(emp.deptno) from dual) from emp where ~`


#### (3) 스칼라 서브쿼리 캐싱 부작용

반대로 입력값의 범위가 넓어서 캐싱효과를 거의 받지 못한다면 오히려 캐싱 확인으로 인한 부하만 증가한다.

또, 메인쿼리 집합의 크기가 작으면 캐시 재사용성이 떨어져서 성능에 악영향(캐시 영역에 저장만 하고 이용 X)


#### (4) 두 개 이상의 값 반환

스칼라 서브쿼리에서 여러 값을 뽑아내고 싶을 때

1. 스칼라 서브쿼리를 여러개 쓴다 → 비효율

2. 문자열 결합연산자를 이용해 묶어서 출력한 뒤 substring으로 빼낸다 → 비효율

3. OBJECT TYPE 사용 → 번거로움

4. 스칼라 서브쿼리 대신 인라인 뷰를 이용한다.
→ 인덱스 비효율이 있거나(no_merge), group by등으로 부분범위 불가(merge)등의 문제
→ 이럴 때 push_pred(조인 조건 푸시다운)이 유용


#### (5) 스칼라 서브쿼리 unnesting

**스칼라 서브쿼리는 NL방식으로 조인**되므로 캐싱효과가 미미하다면 랜덤IO 부담이 있다.
병렬 쿼리에선 특히 스칼라 서브쿼리를 사용하지 않아야함
대량 데이터를 처리하는 병렬 쿼리는 해시 조인으로 처리해야 효과적이기 때문
→ 서브쿼리 unnesting

unnesting되면 해시조인으로 처리 가능함


# 5장 소트 튜닝

## 5.1 소트 연산에 대한 이해

소팅, 해싱, 그룹핑에 PGA/Temp Tablespace를 사용함


### 5.1.1 소트 수행 과정

소팅 : 크기에 따라 두가지로 나뉨 - 메모리 / 디스크

- 디스크 소팅 과정
  - SGA 버퍼캐시 → PGA의 Sort Area → 양이 많을 경우 정렬된 중간집합은 Temp Tablespace에 저장(Sort run) → 반복
  - 정렬이 완료되면 템프 테이블스페이스의 소트 런들을 Merge (정렬된 순서대로 클라이언트로 전달)

→ 소팅은 메모리, CPU 부하를 일으키고, 양이 많으면 DISK IO까지 발생
부분 범위 처리도 할 수 없음.
피할 수 있으면 피하고, 피할 수 없다면 최대한 인메모리 소팅으로 진행되게 유도해야함


### 5.1.2 소트 오퍼레이션

소트를 발생시키는 오퍼레이션(실행계획)

#### (1) Sort Aggregate
- 전체 로우 대상으로 집계 수행 할 때 등장 (소팅은 아님)

실제로 정렬을 하진 않고 수학적 연산 수행(min max sum avg 등)
\> `sum` `count` `min` `max` 를 두고 값을 읽을 때마다 갱신해가는 연산과정 
→ 큰 sort area가 필요하지 않다. 

#### (2) sort order by
- 데이터 정렬 수행


5.1.1의 그림과 같은 과정 수행


#### (3) sort group by
- 그룹별 집계 수행


(1)처럼 갱신연산을 그룹마다 수행.
마찬가지로 큰 sort area가 필요하지 않다. (temp tablespace도 필요 없음)


- `hash group by`
: group by 절 후에 order by 절이 없으면 대부분 hash gorup by로 처리됨
group by 컬럼의 해시값으로 집계 항목 갱신


#### (4) sort unique

- Unnesting된 서브 쿼리가 M쪽 집합이거나 1쪽 집합이더라도 Unique 인덱스가 없으면,
메인 쿼리와 조인하기 전에 중복 레코드를 제거해야함.

- 만약 PK/Unique Constraint/Unique Index 속성이 있다면 Sort Unique 오퍼레이션은 생략됨

- 집합 연산자(union, minus, intersect)를 사용할 때도 위 실행계획이 나타남

- Distinct 연산에는 `Hash Unique` 방식이 등장 (order by 없을 때)


#### (5) Sort join
소트 머지 조인 수행 시 등장

#### (6) window sort
윈도우 함수 사용 시 등장

이로써 소트를 발생시키는 오퍼레이션 종류를 확인하였음.

## 5.2 소트가 발생하지 않도록 SQL 작성

### 5.2.1 Union vs Union ALL

중복제거연산이 필요한 게 아니라면 union all을 사용해야 sort unique 생략됨


```sql
-- 아래 쿼리는 중복 가능성 있음
select ~
from pay
where paydate = 20180316
UNION ---------------------
select ~
from order
where orderdate = 20180316


-- 아래와 같이 수정 가능
select ~
from pay
where paydate = 20180316
UNION ALL -----------------
select ~
from order
where orderdate = 20180316
	and paydate != 20180316
    
    
-- paydate가 nullable이면
select ~
from pay
where paydate = 20180316
UNION ALL -----------------
select ~
from order
where orderdate = 20180316
	and (paydate != 20180316 or paydate is null)
    -- 혹은 lnnvl(paydate = 20180316)
```

### 5.2.2 Exists 활용

- `distinct`는 전체 데이터를 읽고 중복을 비교해야해서 부하가 심함
  - `exists`문으로 대체할 수 있다.

→ 347p에서 바뀌는 쿼리 확인

- exists문은 1. 조인이 아니고, 2. 조건이 맞으면 다음 메인쿼리로 진행하기 때문에 중복데이터가 없다.
(단 exists문에 사용된 c의 정보를 출력하지 못함)


- `minus` 연산자는 `not exists`문으로 대체할 수 있다.


### 5.2.3 조인 방식 변경

인덱스가 적절히 있어도 hash join으로 진행되버리면 소트연산 생략 불가
→ 인덱스를 통해 NL조인 유도 `/*+ leading(t1) use_nl(t2)*/`

order by에 조인 컬럼으로 기술돼있으면 소트 머지 조인(`use_merge(t2)`)에서도 소트 생략 가능

> 250219(수) 317p ~ 349p

## 5.3 인덱스를 이용한 소트 연산 생략

### 5.3.1 Sort Order by 생략

인덱스가 적절히 있으면 order by구문이 있어도 소트연산 생략 가능

#### 아직도 부분범위 처리 튜닝이 유효한가

그렇다. 3-Tier 환경에서도 Top N 쿼리를 이용하면

### 5.3.2 Top N 쿼리

: 결과 중에서 상위 X개만 선택하는 쿼리

오라클의 경우 전체 쿼리를 한번 감싸서 인라인 뷰로 만든 다음 `where rownum < 10` 이런 구문을 사용해야함
쿼리가 나눠져있기 때문에 부분범위 처리가 불가능해 보여도 가능함

실행계획에는 `COUNT (STOPKEY)` 형식으로 표현됨
```sql
-- idx_a_01( col1, col2 ) 일 때 부분범위 처리 가능
select *
from (
  select ~
  from a
  where col1 = ~
      and col2 > ~
  order by col2
) a
where ronum < 10
```

#### 페이징 처리
```sql
select *
from (
  select *
  from (
    
    /* SQL Body */
    
  ) a
  where ronum < ( :page * 10 )
) b
where no >= (:page-1) * 10 + 1
```
→ 뒤쪽 페이지로 갈수록 안쪽 서브쿼리에서 읽는 양이 늘어나는 단점이 있지만
페이지 조회는 앞쪽에 집중돼있으므로 문제가 되지 않음

- 3-Tier환경에서 부분 범위 처리를 하려면
  - 부분범위 처리 가능하도록 SQL 작성한 후 실제로 작동하는지 테스트
    - 인덱스 사용 가능한 조건절 사용
    - NL조인 위주로 처리
    - order by 생략 가능한 인덱스 구성
  - 작성한 SQL문을 위 쿼리의 `SQL Body`에 입력한다.
  

#### 페이징 처리 ANTI 패턴

위에 나온 쿼리에서 서브쿼리 안쪽의 `rownum < (:page*10)` 부분을 바깥쪽으로 빼서
`between (:page-1)*10 + 1 and (:page * 10)` 과 같이 만들면 부분범위 처리가 불가능해질 수 있다.


### 5.3.3 최소값/최대값 구하기

MIN/MAX 연산에는 Sort Aggregate 오퍼레이션이 등장
정렬작업을 수행하진 않지만 전체 데이터를 스캔해야함

데이터가 정렬돼있는 경우 단 한건의 데이터 스캔으로 끝낼 수 있음
이럴 때 실행계획의 Sort Aggregate 하위목록으로 `INDEX (FULL SCAN (MIN/MAX))`라는 실행계획이 나타남


#### 인덱스를 이용한 최소/최대 구하기 조건
- 아래 인자들이 모두 인덱스에 있어야함
  - 조건절 컬럼
  - MIN/MAX() 함수의 인자

```sql
-- 한 쿼리에 아래 각각의 인덱스를 사용할 때 스캔 효율 생각해보기
-- create index emp_x1(DEPTNO, MGR, SAL)
-- create index emp_x2(DEPTNO, SAL, MGR)
-- create index emp_x3(SAL, DEPTNO, MGR)
-- create index emp_x4(DEPTNO, SAL)
SELECT MAX(SAL)
FROM EMP
WHERE DEPTNO = 30 AND MGR = 7698
;
```
위의 세 경우 모두 실행계획에는
```sql
SORT (AGGREGATE)
  FIRST ROW
    INDEX (RANGE SCAN (MIN/MAX) )
```
과 같이 나타난다.

4번인덱스의 경우 DEPTNO=30인 **전체를 읽어서** MGR=7698를 필터링한 후 MAX(SAL)값을 구한다. (Stopkey 작동 X)


#### Top N 쿼리 이용해 최소/최대 구하기

- 위의 쿼리에서 4번인덱스를 사용할 때
- `order by sal`를 추가한 후 인라인뷰로 만들고, rownum <= 1 이라 기술하면 min/max 구할 수 있음. (stopkey 조건 작동)


### 5.3.4 이력 조회

장비 ∈ 상태변경이력

이 구성에서 '최종 상태 변경일자'를 조회하려면...

#### 가장 단순한 이력 조회

이력 테이블을 조회할 때 First Row Stopkey/Top N Stopkey 방식이 작동할 수 있게 
인덱스 설계, SQL구현을 할 수 있어야한다.

```sql
select pid, pname, (select max(변경일자) from history h where h.pid = p.pid)
from p
where pcategory = 100
```
→ FIRST ROW - INDEX RANGE SCAN (MIN/MAX) 실행계획 등장함


#### 점점 복잡해지는 이력 조회

만약 위 쿼리에서 `변경일자`만이 아닌 `변경순번`까지 최종값을 구해야한다면 쿼리는 복잡해진다.
변경일자, 변경순번, 변경세부동작순서 이런식으로 하나 둘 추가되면 더더욱 복잡해진다.


#### INDEX_DESC 힌트 활용

조건이 많을 때 쿼리가 복잡하지 않으면서도 적당한 성능을 얻는 방법
370p 쿼리 확인하기.
서브쿼리 중첩이 아닌 여러 컬럼을 문자열 결합(||)한 후 데이터를 정렬시키고
substring으로 필요한 컬럼을 추출해서 사용.

여기에 INDEX_DESC 힌트와 rownum<=1 구문 활용

→ 인덱스 구성이 완벽해야 성능이 보장됨


#### 오라클 기능 활용

372p 쿼리 확인하기.

Predicate Pushing, 쿼리 변환이 작동한 것


- row limiting절
  - 인덱스로 소트를 생략할 수 있는 쿼리에 `window 함수(row_number() over())` = `Fetch 0 rows only` 구문을 사용하면 안된다.
    - row_number() over() 'no'절과 no=1 절을 사용하도록 변환되기 때문


- 페이징 처리
  - row_number() over()의 결과를 between조건으로 활용하여 페이징처리하는 경우
  - 소트를 생략하지 않는 경우가 생김(불완전함)


#### 상황에 따라 달라져야 하는 이력 조회 패턴

이력을 조회하는 패턴은 다양하다.

인덱스를 활용하는 것이 만사형통은 아니다.
\> 대용량 테이블에 index를 이용해서 소트를 생략한다고 인덱스 손익분기점이 돌아오진 않는다.

- 전체 장비의 이력을 조회하는 경우
  - window sort가 효과적 (376p)

#### 선분이력 모델
- 유효시작일자, 유효종료일자 컬럼을 갖는 이력테이블
  - 유효종료일자가 '99991231'이면 유효한 레코드란 의미
  - 조회시점을 옵션컬럼(:col)으로 입력하여 유효성 검증 가능 `:col between 유효시작 and 유효종료`

쿼리가 간단하여 성능상으로도 이점이 있다.


### 5.3.5 Sort Group by 생략

- 그룹핑 연산에 인덱스를 이용할 수 있다.
- group by에 명시된 컬럼이 선두인 인덱스를 사용하면 됨

실행계획에 `Sort Group By Nosort` 등장


## 5.4 Sort Area를 적게 사용하도록 SQL 작성

### 5.4.1 소트 데이터 줄이기

액세스량은 같아도 소트량을 줄여서 성능을 완화시킬 수있다.


### 5.4.2 Top N 쿼리의 소트 부하 경감 원리

- 인덱스를 사용하지 않을 때 Top N 쿼리의 소트 과정 (전체 1000 row 에서 Top 10일 경우)
  1. 테이블에서 1000개를 순차적으로 읽음
  2. 이 때 첫 10건은 바로 소트큐에 넣음
  3. 나머지 레코드는 읽을 때마다 소트큐에 비교해서 넣음

즉 테이블 액세스 수는 똑같지만
Top N 쿼리를 쓸 경우 소트 에어리어는 훨씬 적게 사용하기 때문에 부하가 경감된다.


### 5.4.3 Top N 쿼리가 아닐 때 발생하는 소트 부하

384p의 Top N 쿼리에서 rownum절을 제거하고, 밖의 쿼리에서 between절로 합쳐서 수행하면 

실행계획에서 `Stopkey`가 사라짐 (중단불가)
소트 시 메모리를 넘어서 DISK까지 이용해야하기 때문에 cr(논리IO)는 같지만 pr, pw가 발생한다.


### 5.4.4 분석함수에서의 Top N 소트

row_number(), rank()는 Top N 소트 알고리즘이 작동하기때문에 max()보다 부하가 적다.

> 250220(목) 350p ~ 389p

# 6장 DML 튜닝

## 6.1 기본 DML 튜닝

### 6.1.1 DML 성능에 영향을 미치는 요소

1) 인덱스
2) 무결성 제약
3) 조건절
4) 서브 쿼리
5) Redo 로깅, Undo 로깅
6) Lock
7) 커밋

#### 1) 인덱스와 DML 성능

- 데이터 INSERT 시
  - 테이블에 입력; Freelist를 통해 블록 할당
  - 인덱스에 입력; 인덱스 트리를 통해 블록 탐색
- 데이터 DELETE 시
  - 테이블 작업
  - 인덱스 작업

→ 한 로우를 삽입/삭제했을 때 해당하는 **'모든 인덱스'**도 삽입/수정을 해주어야하기 때문에 DML은 부하가 심함

- 데이터 UPDATE시
  - 테이블 작업
  - 기존 인덱스 삭제 후 변경된 값으로 변경된 위치에 삽입

→ 인덱스 수는 DML에 부하를 줌

#### 2) 무결성 제약과 DML 성능

- 개체 무결성
- 참조 무결성
- 도메인 무결성
- 사용자 정의 무결성

PK와 FK는 Check, Not Null 제약보다 성능에 영향이 큼


#### 3) 조건절과 DML성능

DML의 조건절은 인덱스 튜닝 방법을 그대로 적용할 수 있다.


#### 4) 서브쿼리와 DML성능

조인 튜닝방법을 적용할 수 있다. 특히 4.4절

#### 5) Redo로깅과 DML성능

DML수행시마다 Redo로그가 기록되기 때문에 성능에 영향이 있음

- Redo 로그 용도
  - Database 복구 (Media Fail - Archived Redo Log 이용하여 Media Recovery)
  - Cache 복구 (인스턴스 복구의 roll forward 단계)
  - Fast Commit : 디스크에 데이터를 반영할 때 redo로그에 기록된 정보로 Batch 방식으로 일괄 처리하는 방법(DBWR, Checkpoint 이용)


#### 6) Undo 로깅과 DML 성능

Undo도 redo와 마찬가지로 DML수행 시마다 기록되기 때문에 성능 영향 있음

- Undo 로그 용도
  - 트랜잭션 롤백
  - 트랜잭션 리커버리 (인스턴스 복구의 rollback 단계)
  - Read Consistency
    - 현재 상태에서 undo로그를 적용해 데이터를 호출한 시점의 데이터를 읽는다.


- MVCC모델
  - Current 모드 : 블록 상태 그대로를 읽음
  - Consistent mode : undo 로그 적용하여 읽음


- DML문은 Consistent 모드로 데이터를 찾고, Current 모드로 데이터를 변경한다.
  - 과거데이터에 변경을 적용할 순 없기 때문


#### 7) Lock과 DML성능

매우 크고 직접적인 영향을 가짐
적당한 레벨의 락, 적당한 길이로 사용해야함
데이터 품질과 성능은 trade-off 관계


#### 8) 커밋과 DML성능

1. DB 버퍼캐시
   - 버퍼캐시를 이용해 서버프로세스는 데이터를 읽고 씀
   
2. Redo 로그버퍼
Redo log가 append 방식으로 관리된다 해도 느림
따라서 Redo 로그버퍼를 두어 Redo로그에 기록되기 전에 기록한다.

LGWR이 기록된 로그버퍼를 Redo 로그에 기록한다.


3. 트랜잭션 데이터 저장 과정

a) Redo 로그버퍼에 기록
b) 버퍼블록에서 레코드 변경
c) 커밋
d) LGWR 프로세스가 Redo로그버퍼 → 로그파일 (Write ahead logging)
e) DBWR 프로세스가 버퍼캐시 → 데이터 파일

→ 항상 로그부터 기록함


- log force at commit : 커밋 이전에 redo 데이터를 파일에 반드시 저장

4. '커밋 = 저장버튼'
log force at commit이라는 작동방식처럼
commit 시 서버 프로세스는 최소 redo 로그 버퍼가 디스크에 기록되기 전까지 대기 상태로 전환된다.

redo 로그버퍼의 기록은 DISK IO작업이기 때문에 '커밋'은 느린 작업이다.


### 6.1.2 데이터베이스 Call과 성능

#### 데이터베이스 Call

- SQL의 세 단계 Call
  - Parse Call; 파싱, 최적화 (캐시에서 실행계획 찾을 시 최적화는 스킵)
  - Execute Call; 실행
  - Fetch Call; 사용자에게 전송(select문에만 존재), 데이터가 많으면 콜이 여러번 발생


- 발생지에 따른 Call의 종류
  - User Call : DBMS입장에선 표현층이 아닌 비즈니스층에서 발생하는 콜
  - Recursive Call : DBMS 내부 발생하는 콜; 데이터 딕셔너리 조회, PLSQL·트리거 조회 등

Call은 성능에 영향을 줌


#### 절차적 루프 처리

recursive call로 29초 걸리던 작업이
java program으로 수행(user call)하게 되면 218초가 걸렸다.


#### One SQL의 중요성

- One SQL 구현에 유용한 구문
  - Insert Into Select
  - 수정가능 조인 뷰
  - Merge 뷰


### 6.1.3 Array Processing 활용
Array Processing :배열 처리 = 묶음 처리

- PLSQL에서의 Array Processing : `fetch c bulk collect`
- JAVA에서의 Array Processing  : PreparedStatement에 FetchSize를 설정하여 수행

Array Processing 방법이 훨씬 빠르다


### 6.1.4 인덱스 및 제약 해제를 통한 대량 DML 튜닝

단지 성능을 위해 OLTP시스템에서 인덱스, 제약을 해제할 순 없다.

단 배치시스템에선 대량 데이터 적재 시 이 기능들을 잠시 해제하여 성능효과를 얻을 수 있다.

- 데이터 1000만건 입력
  - PK 제약 설정, Unique 인덱스(자동), 일반 인덱스 생성 : 1분 19초
  - PK 제약 해제, Unique 인덱스 유지, 일반 인덱스 제거 : 5.8초
    - PK 제약 설정(novalidate) : 6.7초
    - 일반 인덱스 재생성 : 8.2초
    → 총합 20.7초


### 6.1.5 수정가능 조인 뷰

#### 전통적인 방식의 UPDATE

- 전통적인 방식의 UPDATE문으로는 조인이 필요한 쿼리의 비효율을 완전히 없앨 수 없다.

#### 수정가능 조인 뷰

- 수정가능 조인 뷰 : 여러 테이블이 조인된 뷰에 수정을 할 수 있는 경우(12c이상)

- 수정가능 조인 뷰를 수정할 때, 1쪽 집합을 수정하면 오류 발생 (non key-preserved table)
  - ex) `d.deptno = e.deptno`로 조인하고(d는 1쪽, e는 m쪽)
  `set d.loc = 'CHICAGO' where e.job='MANAGER'`로 d테이블의 컬럼을 수정하면
  실제로는 다른 job을 가진 사원의 소재지도 바뀐다. (d.loc이 바뀌므로)
  
- 1쪽 집합에 PK제약/Unique 인덱스를 사용해야 정상적으로 수정이 가능하다.

#### 키 보존 테이블이란?

- 뷰에 자신의 rowid를 제공하는 테이블

#### ora-01779 제약 회피

- 키가 보존되는데도 에러가 발생하는 경우에는 `Merge`문으로 바꿔줘야한다.(일부 구버전)
- Unique 인덱스가 무조건 존재해야 수정가능조인뷰를 활용할 수 있다.

> 250222(토) 393p ~ 429p





### 6.1.6 MERGE 문 활용

- DW의 데이터 동기화 작업 : 기간계 시스템의 신규 데이터 → DW에 반영
  1. 신규데이터를 별도 테이블로 구축
  `create table tmp_c as select ~ from c where 변경일자 < sysdate and 변경일자 >= sysdate - 1`
  
  2. 별도 구축한 테이블을 시스템 간 전송
  
  3. 적재
   ```sql
   merge into c using tmp_c t on (c.cust_id = t.cust_id)
   when matched then update
     set c.cust_nm = t.cust_nm, c.email = t.email, ...
   when not matched then insert
     (cust_id, cust_nm, email, ... ) values
     (c.cust_id, c.cust_nm, c.email, ...)
   ;
   ```
   → upsert라고도 부름
   
#### Optional Clauses

merge문을 활용해서 수정가능 조인 뷰 기능을 대체할 수 있다.
→ 431p 쿼리 참조; merge문에서 매칭하는 절을 서브쿼리로 사용

#### Conditional Operations

merge 문 사용 시 on 절 외에도 where절로 조건을 걸 수 있다.

#### DELETE Clause

update, insert 외에도 delete도 가능하다.

- 기억할 점
  - 432p의 쿼리처럼 여러 작업이 수행될 때, update후의 결과가 delete조건에 일치한다면 삭제된다.
  - 조인에 성공한 데이터만 적용됨
  
#### Merge Into 활용 예

merge문은 한번만 수행되는 효율적인 쿼리작성이 가능하다.


## 6.2 Direct Path IO 활용

- OLTP : 버퍼캐시가 성능 향상에 도움
- OLAP, DW, batch프로그램 : 버퍼캐시를 경유하는 IO가 오히려 비효율적일 수 있음. 
→ Direct Path IO를 활용

### 6.2.1 Direct Path IO

- Direct Path IO가 작동하는 경우
  1. 병렬 쿼리 Full Scan
     - `/*+ full(t) parallel(t 4) */`
     - `/*+ index_ffs(t t_idx01) parallel_index(t t_idx01 4) */`
     - order by, group by, 해시 조인, 소트 머지 조인 등을 처리할 때는 지정한 병렬도보다 두배로 사용됨
  2. 병렬 DML
  3. Direct Path Insert 수행
  4. Temp 세그먼트 블록을 R/W
  5. export를 direct 옵션으로 할 때
  6. nocache 옵션이 지정된 LOB 컬럼을 읽을 때

### 6.2.2 Direct Path Insert

- Insert 과정이 느린 이유
  1. Freelist 탐색
     - `Freelist` : HWM아래쪽에 여유공간이 있는 블록 목록
  2. Freelist에서 찾은 블록을 버퍼캐시에서 탐색
  3. 찾은 블록이 버퍼캐시에 없으면 버퍼캐시에 적재
  4. Undo 세그먼트 기록
  5. Redo 세그먼트 기록


- Direct Path Insert 사용 방법
  - Insert select 문에 append 힌트 사용
  - Insert문에 parallel 힌트 사용
  - SQL Loader를 direct 옵션 체크하여 사용
  - Create table as select문 사용


- Direct Path Insert가 빠른 이유
  1. Freelist를 참조하지 않고 HWM 밑에 순차 데이터 입력
  2. 버퍼캐시 탐색/적재 과정 없이 데이터 파일에 직접 기록
  3. Undo 로깅 없음
  4. Redo 로깅 최소화 가능
     - 전체 비활성화는 불가능. 데이터 딕셔너리 변경사항만 로깅하도록 설정 가능


- PL/SQL의 Array Processing을 Direct PATH IO방식으로 활용
  - `/*+ append_values */` 힌트 사용


- Direct Path Insert 사용 시 주의점
  1. TM Lock 설정됨 (테이블 DML 락)
  2. HWM 아래부터 입력하기 때문에 Freelist를 이용한 블록들의 여유공간 활용 불가
  

### 6.2.3 병렬 DML

- 허용 구문
  - `alter session enable parallel dml;`


- 병렬 DML을 허용하지 않고 힌트를 기술하면, 찾는 것만 병렬로 수행하기 때문에 병목이 생김
- 병렬 DML이 작동하지 않을 때를 대비해 Direct Path IO라도 사용하도록 `/*+ append */`힌트를 같이 사용하는 것이 좋음


- 병렬 DML도 Exclusive TM Lock이 걸리기 때문에 주간에는 사용이 바람직하지 않음


#### 병렬DML이 잘 작동하는지 확인하는 방법

- 작동 시 실행계획에 PX Coordinator 하위목록으로 DML이 표시됨
- PX Coordinator 상위에 DML이 표시되면 QC가 처리함
  - 병렬방식이 아닌 Direct Path IO로 수행됨
  - Query Coordinator = SQL중 처음 실행된 프로세스


## 6.3 파티션을 활용한 DML튜닝

### 6.3.1 테이블 파티션

#### Range 파티션

#### Hash 파티션

#### List 파티션


### 6.3.2 인덱스 파티션

- 테이블
  - 파티션 테이블
  - 비파티션 테이블


- 인덱스
  - 파티션 인덱스
    - 로컬 파티션 인덱스
    : 테이블 파티션과 인덱스 파티션이 1:1 대응 관계(오라클이 자동 관리)
    `create index order_idx01 on order ( order_date, order_amount) LOCAL`

    - 글로벌 파티션 인덱스
    : 그 외 관리방법 (수동지정)
    `create index order_idx01 on order ( order_date, order_amount) GLOBAL`
    
  - 비파티션 인덱스

#### Prefixed vs. Nonprefixed
- 인덱스 파티션 키 컬럼이 인덱스 선두 컬럼인지에 따른 구분
  - Prefixed : 선두에 위치
  - Nonprefixed : 인덱스 파티션 키 컬럼이 선두 X거나 아예 인덱스에 없음


#### 중요한 인덱스 파티션 제약

- Unique 인덱스를 파티셔닝하려면 파티션 키는 인덱스 구성에 포함되어야한다.
→ ex) PK의 인덱스를 파티셔닝 할 때 파티션 키는 PK 컬럼에 속해야함
  - 인덱스가 여러개인 경우 모든 인덱스가 로컬 파티션 인덱스여야 한다.


- 이 제약으로 인해 PK를 로컬 파티셔닝 하지 못하면
  - ex) 테이블 파티션 키가 인덱스 구성 컬럼이 아닌 경우
  → pk (주문번호), 인덱스 파티션키(주문번호), 테이블 파티션키(주문일자) 인 경우 
- 파티션 구조 변경 작업 시 PK가 Unusable 상태로 바뀌고, Rebuild시 서비스가 중단되어야함.
- 따라서 서비스 중단 없이 파티션 구조를 변경할 수 있으려면 
**'모든 인덱스가 로컬 파티션 인덱스'**여야함


- 위 내용에 따른 tip 
: 인덱스를 설계할 때, PK를 로컬 파티션 인덱스로 구성할 수 있도록 파티션 대상 컬럼(대량 데이터 수정 기준컬럼)을 예상할 수 있어야 한다. 


> 250223(일) 430p ~ 456p





### 6.3.3 파티션을 활용한 대량 UPDATE튜닝

대용량 UPDATE를 수행할 때, 일반적인 손익분기점으로 여기는 5%이상의 데이터가 수정대상이라면 Index를 Drop해놓고 DML을 수행한 후 인덱스를 Rebuild하는 방식이 많이 사용된다.

단 10억건에 이르는 초대용량 테이블이라면 인덱스를 Drop, Rebuild하는 과정에 큰 부담이 따르기 때문에 인덱스를 놔둔 체로 작업하는 것이 일반적


#### 파티션 Exchange를 이용한 대량 데이터 변경

1. 임시테이블 생성(가능한 nologging)
```sql
create table tmp
nologging
as
select * from c where false
;
```

2. c테이블을 통해 insert 하면서 필요한 DML작업 수행
```sql
insert /*+ append */ into tmp
select c_col1, c_col2, c_col3, ...
	, (case when c_col4 <> 'abc' then 'abc' else c_col4 end) c_col4 -- col4 수정
from c
where c_time < '20150101'
```

3. tmp 테이블에 원본과 동일하게 인덱스 생성 (가능한 nologging)
`create index tmp_pk on tmp ( ~ ) nologging;`
`create index tmp_idx01 on (col1, col2) nologging;`

4. 파티션 exchange
```sql
alter table c
exchange partition p201412 with table tmp
icluding indexes without validation
;
```

5. tmp 드랍
`drop table tmp;`

6. logging 다시 on
`alter table c modify partition p201412 logging;`
`alter index c_pk modify partition p201412 logging;`
`alter index c_idx01 modify partition p201412 logging;`


### 6.3.4 파티션을 활용한 대량 DELETE 튜닝

- DELETE가 느린 이유; DELETE의 절차
  1. 테이블 레코드 삭제
  2. 삭제에 대한 undo logging
  3. 삭제에 대한 redo logging
  4. 인덱스 레코드 삭제
  5. undo logging
  6. redo logging
  7. 2, 5q번에 대한 redo logging


#### 파티션 Drop을 이용한 대량 데이터 삭제

삭제 대상과 파티션이 맞아떨어진다면 파티션 제거로 데이터를 삭제할 수 있다.

`alter table c drop partition p201412`
`alter table c drop aprtition for ('20140201'); → 값을 이용한 파티션 지정, 제거`


#### 파티션 Truncate를 이용한 대량 데이터 삭제

조건절에 속하는 삭제 대상의 비중이 높다면, 
1. 남길 데이터를 임시테이블에 백업하고 
2. 제거 후 
3. 재입력 하는 방식이 빠르다.


- 서비스 중단 없이 파티션을 Drop/Truncate할 수 있는 조건
  1. 파티션 키와 커팅 기준 컬럼이 정확히 일치
  ex) 파티션 키 = 커팅 기준 컬럼 = '신청 일자'
  2. 파티션 단위와 커팅 주기가 일치해야함
  ex) 월 단위 파티션을 월 단위로 커팅
  3. 모든 인덱스가 로컬 파티션 인덱스여야함
  ex) 파티션 키 = '신청일자', PK = '신청일자 + 신청순번'


### 6.3.5 파티션을 활용한 대량 INSERT 튜닝

#### 비파티션 테이블일 때
- 인덱스 Unusable, DML 수행 후 인덱스를 재생성 하는 것이 더 빠를 수 있다.
  1. `alter table target_t nologging;`
  2. `alter index target_t_idx01 unusable;`
  
  3. `insert /*+ append */ into target_t select * from source_t`
  
  4. `alter index target_t_idx01 rebuild nologging;`
  
  5. `alter table target_t logging;`
  `alter index target_t_idx01 logging;`


#### 파티션 테이블일 때
` alter table target_t modify partition ~ nologging;`
`alter index target_x01 modify partition ~ unusable;`

`insert /*+ append */ into target_t select * from source_t where dt between partitonKeyStart and End`

` alter index target_t_idx01 rebuild partition ~ nologging;`

` alter table target_t modify partition ~ logging;`
`alter index target_x01 modify partition ~ logging;`

> 250224(월) 456p ~ 465p




## 6.4 Lock과 트랜잭션 동시성 제어

- Lock, 동시성 제어, 식별자와 채번에 관한 챕터


### 6.4.1 오라클 Lock

- 래치 : SGA에 공유된 각종 자료구조를 보호하기 위해 사용
- 라이브러리 캐시 Lock/Pin : 라이브러리 캐시에 공유된 SQL 커서, PL/SQL 프로그램을 보호하기 위해 사용
- 버퍼 Lock : 버퍼 블록에 대한 액세스 직렬화를 위해 사용


- DML Lock : 테이블 Lock, 로우 Lock


#### DML 로우row Lock

- 여러 트랜잭션이 한 로우를 변경하는 것을 방지
- UPDATE, DELETE에는 일반적으로 배타적 락 적용
- INSERT에 대한 로우 Lock 경합은 Unique 인덱스가 있을 때만 발생
  - 같은 값을 입력하려는 경우, 선행 트랜잭션의 커밋/롤백 여부에 따라 후행 트랜잭션의 성공여부 결정
- 오라클은 SELECT에 락이 없음 (MVCC사용)
  - MVCC가 아닌 DBMS에선 공유 락 사용 (SELECT끼린 공유, DML과는 경합)


- Lock이 길게 지속되지 않게 튜닝 하는 것도 SQL튜닝의 일부


#### DML 테이블 Lock

- 테이블 Lock을 DM Lock 이라고도 함
- Row Lock의 종류 469p
  - Null
  - RS
  - RX
  - S
  - SRX
  - X


- 리소스가 사용 중일 때, select for update문에선 세가지 경우의수를 모두 선택할 수 있다.
  1. Lock해제를 기다림 (select * from t for update)
  2. 일정 시간만 기다림 (select * from t for update wait 3)
  3. 바로 작업을 포기 (select * from t for update nowait)


#### Lock을 푸는 열쇠, 커밋

- 블로킹 : 락 때문에 후행 트랜잭션이 멈춰있는 상태
- 교착상태 : Lock이 설정된 리소스에 또 Lock을 설정하려고 하는 상황


- 오라클에서 교착상태가 발생했을 때, 먼저 락을 감지한 트랜잭션은 문장수준의 롤백을 진행한다.
그 후 블로킹 상태를 해소하기 위해 커밋/롤백을 해야한다. 프로그램에선 예외처리를 해주어야함


- 트랜잭션이 길어지면 undo 세그먼트 고갈/경합을 유발할 수 있다.
- 커밋을 너무 자주하면 LGWR가 로그 버퍼를 비우는동안 동기 방식으로 기다리는 시간이 늘어남
→ 비동기식 커밋, 배치 커밋 활용 가능

```sql
-- IMMEDIATE : COMMIT마다 LGWR이 로그 버퍼를 파일에 기록
-- BATCH : LGWR이 커밋을 모아서 처리
-- WAIT/NOWAIT : LGWR의 로그버퍼 처리를 기다리는지 여부
COMMIT WRITE IMMEDIATE WAIT;
COMMIT WRITE IMMEDIATE NOWAIT;
COMMIT WRITE BATCH WAIT;
COMMIT WRITE BATCH NOWAIT;
```

#### 비관적 동시성 제어

```sql
select ~
from ~
where ~
for update wait/nowait/skip locked
	of t.colt_1 -- 로우에 락 걸기
;
```

#### 낙관적 동시성 제어

#### 동시성 제어 없는 낙관적 프로그래밍

#### 데이터 품질과 동시성 향상을 위한 제언

성능보다 중요한 것은 데이터 품질

sql튜닝으로 성능을 올린 다음에 Lock을 고민하는 것이 바람직하다. (성능이 오르면 Lock도 짧아지기 때문)

> 250225(화) 466p ~ 479p




### 6.4.3 채번 방식에 따른 INSERT 성능 비교

- DML(INSERT, UPDATE, DELETE, MERGE) 중 TUNABLE 한 것은 INSERT
  - 수행 빈도가 높고 채번 방식에 따른 성능 차이가 큼

- 채번 방식
  1. 채번 테이블
  2. 시퀀스 오브젝트
  3. MAX + 1 조회


#### 채번 테이블

- 별도의 테이블로 관리. 채번 레코드를 읽어서 +1한 값을 새로운 레코드 입력할 때 사용
  - 범용성 좋음
  - 채번 함수만 잘 정의하면 중복 레코드 발생을 위한 예외처리에 신경 쓸 필요 없음
  - 결번 방지됨
  - PK가 복합 컬럼이라도 사용 가능


- 단점은 성능이 좋지 않음
  - 채번한 번호를 대상 테이블에 INSERT하고 COMMIT/ROLLBACK 할 때 까지 로우락이 지속됨
  - 채번 수가 많으면(INSERT 자체가 많으면) 버퍼락, ITL경합으로 인해 서로 다른 종류의 채번을 함에도 경합을 할 수 있음

→ 채번이 아주 많은 테이블에는 사실상 사용 불가한 방법


- PLSQL에 `pragma autonomous_transaction;` 문구; 자율 트랜잭션을 이용해 plsql 함수 내에서 트랜잭션을 설정/해제 할 수 있다.


#### 시퀀스 오브젝트

- 성능 좋음
- 중복 레코드 발생을 위한 예외처리 X


- 테이블별로 시퀀스 오브젝트를 생성/관리해야함


`SYS.SEQ$`테이블에서 관리된다. 결국 테이블로 관리되기 때문에 Lock경합이 있다.
자율 트랜잭션 기능이 기본적으로 구현돼있음


- 시퀀스 Lock
  1. 로우 캐시 Lock
     - 로우 캐시 = 딕셔너리 캐시 ; SGA의 구성요소
     - 이를 읽을 때 액세스를 직렬화 해야 되고, 이 때 로우 락을 사용한다.
  
  2. 시퀀스 캐시 Lock
     - 공유 캐시에 위치함; 액세스 직렬화 필요 : SQ Lock
  
  3. SV Lock
     - 공유 풀(Shared pool)에서 발생하는 동기화 메커니즘. 시퀀스의 메타데이터가 공유 풀 내에 존재하기 때문에 SV Lock이 필요할 수 있음, 이는 시퀀스의 동시성을 보장하는 과정에서 발생

시퀀스의 가장 큰 장점은 **성능**


#### MAX + 1 조회

- 테이블의 최종 일련번호를 구해서 +1 한 값을 INSERT에 사용하는 방식


- 별도의 채번 테이블을 관리하는 부담이 없음
- 동시 트랜잭션에 의한 충돌이 없으면 성능이 매우 빠름
- PK가 복합컬럼일 때도 사용 가능


- 단점
  - 레코드 중복에 대비한 세밀한 예외처리 필요
  - 다중 트랜잭션에 의한 동시 채번이 심하면 성능이 매우 하락
  - 만약 PK가 복합컬럼이고 구분속성의 값 수가 많으면 채번이 분산되어 경합 및 재실행 가능성은 줄어듦


490p 방식별로 비교한 표 확인하기


- 채번 방식 선택 기준
  - 관리 부담이 적은 것은 MAX+1방식
  - 다중 트랜잭션에 의한 동시 채번이 많고, PK가 단일 컬럼이라면 시퀀스 방식
  - 다중 트랜잭션에 의한 동시 채번이 많고, PK가 복합 컬럼에 구분속성의 값 종류가 많으면 MAX+1
  - 다중 트랜잭션에 의한 동시 채번이 많고, PK가 복합 컬럼에 구분속성의 값 종류가 적으면 시퀀스(순환방식)


#### 시퀀스보다 좋은 솔루션

- PK를 구분속성 + 일자정보를 가지는 컬럼 으로 구성하면 채번과 INSERT과정에 생기는 Lock 이슈를 해소 가능
- 이러면 값이 고유해질 확률이 높지만 아닐 경우를 대비한 예외처리도 필수


- 건강한 DB시스템을 위해선 주기적 삭제방법을 고민해야하는데, 
파티션 단위 커팅을 할 때 PK 인덱스가 로컬 파티션 인덱스(테이블 파티션과 동일)여야 하고,
삭제기준 컬럼(파티션 키)이 PK에 속해야하기 때문에 위처럼 PK에 '일자'정보를 포함 하는 것은 의미가 있다.


#### 인덱스 블록 경합

- 단 위처럼 설계할 시 채번없이 INSERT가 빨라진다면, INDEX경합이 나타난다. (MAX+1방식에서도 자주 등장)


- 보통 키순으로 정렬된 상태로 삽입되기 때문에 Right Growing 인덱스, 우측 블록에만 데이터가 입력된다.
  - 따라서 같은 블록을 갱신하려는 버퍼 Lock 경합이 발생
  - 구분속성이 있다면 좀 분산되겠으나 구분속성의 값이 적거나 동시성이 매우 높으면 경합 심함
    - 이럴 때 인덱스를 해시 파티셔닝하거나 Reverse 키 인덱스로 전환하는 것 고려


> 250226(수) 480p ~ 498p





# 7장 SQL옵티마이저

## 7.1 통계정보와 비용 계산 원리

### 7.1.1 선택도와 카디널리티

- 선택도 : 전체 레코드 중 조건절에 의해 선택되는 레코드의 비율
  - `=`검색할 때의 선택도 : 1 / NDV (distinct value)


- 카디널리티 : 전체 레코드 중 조건절에 의해 선택되는 레코드의 갯수
  - 총 로우 수 X 선택도 = 총 로우 수 / NDV


옵티마이저는 카디널리티를 통해 액세스 비용을 계산해서 
테이블 액세스 방식, 조인 순서, 조인 방식 등을 결정

올바른 비용계산을 하기 위해 통계정보 수집주기, 샘플링 비율 등을 잘 정해야 한다.


### 7.1.2 통계정보

- 오브젝트 통계
  1. 테이블 통계
    ```sql
    -- 수집 방법
    begin
    	dbms_stas.gather_table_stats('user01', 'tab1');
    end;
    /
    
    -- 확인 방법
    select ~
    from all_tables
    where owner='user01'
    and table_name = 'tab1';
    ```
  2. 인덱스 통계
    ```sql
    -- 인덱스 통계만 수집
    begin
    	dbms_stats.gather_index_stats( ownname => 'user01', indname => 'tab1_idx01');
    end;
    /
    
    -- 테이블 통계와 같이 수집(cascade)
    begin
    	dbms_stats.gather_table_stats('user01', 'tab01', cascade=>true);
    end;
    /
    
    -- 확인
    select ~
    from all_indexes
    where owner = 'user01'
    and	table_name = 'tab1'
    and index_name = 'tab1_idx01';
    ```
  3. 컬럼 통계
    - 테이블 통계를 수집할 때 같이 수집됨
    ```sql
    select ~
    from all_tab_columns
    where owner = 'user01'
    and table_name = 'tab1'
    and column_name = 'col1'
    ```

#### 컬럼 히스토그램

데이터 분포가 고르지 않은 커럼에는 선택도 계산(1/NDV)이 적절하지 못하고,
데이터 액세스 비용이 잘못 계산될 수 있다.

이를 보완하기 위해 컬럼 히스토그램이 사용됨

1. 도수분포 : 값 별 빈도수
2. 높이균형 : 
3. 상위도수분포 : 상위 n개 값에 대한 빈도수
4. 하이브리드 : 도수분포와 높이균형 히스토그램의 특성 결합

테이블 통계를 수집할 때 `method_opt=>` 파라미터 지정하면 히스토그램을 수집할 수 있음

- 시스템 통계 : HW성능 특성
  - CPU속도
  - 평균 Single Block IO 속도
  - 평균 Multi Block IO 속도
  - 평균 Multi Block IO 개수
  - IO서브시스템의 최대 처리량
  - 병렬 Slave의 평균 처리량


- 시스템 통계는 `sys.aux_stats$` 뷰에서 조회할 수 있음


### 7.1.3 비용 계산 원리

- 인덱스 키 값을 모두 `=`조건으로 검색할 때 필요한 통계 정보
  - `BLEVEL` --인덱스 수직 탐색 비용 
  \+ `AVG_LEAF_BLOCKS_PER_KEY` --인덱스 수평 탐색 비용
  \+ `AVG_DATA_BLOCKS_PER_KEY` --테이블 랜덤 액세스 비용


- 모두 `=`조건이 아닐 때
  - `BLEVEL` --인덱스 수직 탐색 비용 
  \+ `LEAF_BLOCKS` X 유효 인덱스 선택도  --인덱스 수평 탐색 비용
  \+ `CLUSTERING_FACTOR` X 유효 테이블 선택도 --테이블 랜덤 액세스 비용



> 250227(토) 501p ~ 510p




## 7.2 옵티마이저에 대한 이해

### 7.2.1 옵티마이저 종류



> 250228(일) p ~ p