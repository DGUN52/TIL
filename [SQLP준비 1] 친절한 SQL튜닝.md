# 친절한 SQL튜닝



## 1.1 SQL파싱과 최적화
### 1.1.1 구조적, 집합적, 선언적 질의 언어
- **구조적, 집합적, 선언적** 질의 언어

### 1.1.2 SQL 최적화
- 1) SQL파싱 (파서가 수행)
  - 파싱 트리 생성
  - 문법 체크
  - SEMANTIC 체크 : 테이블/컬럼 잘못되게 참조했는지, 오브젝트 권한 보유 여부
- 2) SQL 최적화 (옵티마이저가 수행)
  - 메타데이터를 바탕으로 다양한 실행경로를 생성/비교, 최종 선택
- 3) 로우 소스 생성
  - 실제 실행 가능한 코드/프로시저로 생성
  
### 1.1.3 SQL옵티마이저

1) 실행계획들 찾아냄
2) 데이터 딕셔너리의 메타데이터를 통해 예상비용 산정
3) 최저 비용의 실행계획 수행


### 1.1.4 실행계획과 비용
- 실행계획(Explain)

- 인덱스 힌트
  ```sql
  select /*+ index(t t_x02) */ 
  	a
  	, b
  	, c
  from 
  	t
  where 
  	deptno = 10 
  	and no = 1
  ;
  ```
  

### 1.1.5 옵티마이저 힌트

```sql
/*+ index(t t_x01) */ 

! 가능
/*+ index(t, t_x01) index(t2, t2_x01) */  

! 불가능 (힌트 사이에 반점)
/*+ index(t t_x01), index(t2, t2_x01) */

! 불가능 (테이블에 별칭 지정 시 힌트에도 별칭 지정)
select /*+ index(tmp t_x01) */ *
from tmp t
```

#### 인덱스 힌트 목록
- 최적화 목표
  - ALL_ROWS
  - FIRST_ROWS(N)
- 액세스 방식
  - FULL
  - INDEX
  - INDEX_DESC
  - INDEX_FFS
  - INDEX_SS
- 조인 순서
  - ORDERED
  - LEADING
  - SWAP_JOIN_INPUTS
- 조인 방식
  - USE_NL
  - USE_MERGE
  - USE_HASH
  - NL_SJ
  - MERGE_SJ
  - HASH_SJ
- 서브쿼리 팩토링
  - MATERIALIZE
  - INLINE
- 쿼리 변환
  - MERGE
  - NO_MERGE
  - UNNEST
  - NO_UNNEST
  - PUSH_PRED
  - NO_PUSH_PRED
  - USE_CONCAT
  - NO_EXPAND
- 병렬 처리
  - PARALLEL
  - PARALLEL_INDEX
  - PQ_DISTRIBUTE
- 기타
  - APPEND
  - DRIVING_SITE
  - PUSH_SUBQ
  - NO_PUSH_SUBQ
  
## 1.2 SQL 공유 및 재사용
### 1.2.1 소프트 파싱 vs 하드 파싱
- 최적화를 거친 다음 생성된 프로시저는 `라이브러리 캐시` (SGA 내부 요소)에 저장해된다.
- 이미 있는 실행계획을 가져오는 것을 `소프트파싱` (바로 실행 단계로 넘어감)
- 찾지 못하고 최적화, 로우 소스 생성까지 다 하는 것을 `하드 파싱`


- 옵티마이저가 사용하는 메타데이터 종류
  - 테이블, 컬럼, 인덱스 구조
  - 오브젝트 통계
  - 시스템 통계
  - 옵티마이저 관련 파라미터
  
### 1.2.2 바인드 변수의 중요성
- preparedStatements를 사용하면 다양한 입력변수에 일일히 하드파싱 하지 않고 프로시저형식으로 재사용된다.

> 250206(목) 17p ~ 35p


