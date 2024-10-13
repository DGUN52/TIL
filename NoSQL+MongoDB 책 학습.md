# NoSQL이란
NoSQL은 RDBMS가 아닌 데이터베이스 시스템을 총칭한다.
NoSQL은 클라이언트/서버환경을 지나 클라우드 컴퓨팅 개발환경이 이끌어낸 빅데이터 시대가 필요로 하는 데이터를 저장하기 위해 필요하다.
현재의 2세대 NoSQL제품들은 Document + KeyValue + ColumnFamily + Graph의 통합기술로 제공되며 기존의 CPU기반보다는 GPU기반이다.


# NoSQL의 장점
1. 클라우드 컴퓨팅 환경에 적합
- 오픈소스, RDBMS에선 처리학 힘든 비정형 데이터의 저장과 관리 용이, 분산/병렬 처리 용이, 운영 # 관리 쉬움
2. 유연한 데이터 #델
- 비정형 데이터 구조 설계. 설계비용 감소. RDBMS의 릴레이션과 조인을 Linking, Embedded로 구현하여 성능 빠름
3. Big Data처리에 효과적
- Memory MApping기능으로 Read/Write가 빠름. 전형적인 os, hw에 구축가능? RDBMS와 같이 트랜잭션 제어 가능
4. RDBMS에 비해 적은 비용
- open source 사용 시 구입 비용 없음. RDB에 비해 유지보수 비용 적음. 유연한 데이터#델 사용으로 개발,구축비용 적음


# RDBMS와 NoSQL의 도입비용 계산 방법
- 선행비용(UpFront Cost)
  - 초기 개발자 비용
  - 초기 관리자 비용(설치, 세팅, Shard/Replication)
  - sw라이센스
  - 서버hw
  - 서버Storage
- 진행비용, 후행비용(Ongoing Cost)
  - 진행 개발자 비용
  - 진행 관리자 비용(Data 유지보수, 헬스체크, 백업복원 등)
  - sw·서버·스토리지 유지보수&지원
- 총소유비용 Total Cost Ownership TCO
  - = 선행비용 + 후행비용
  
  NoSQL의 구축비용은 RDBMS의 1/3정도


# NoSQL의 종류
- MongoDB, Casandra, HBASE, Redis, CoughDB, Neo4j, ArangoDB, DynamoDB
# NoSQL제품 유형
- KeyValue Database, Document Database, ColumnFamily Database, Graph Database
- 2세대의 제품군은 KV+Document+Graph형식이며 ArangoDB, OrientDB가 있다.


# 19년도 DB엔진 순위
- Oracle, MySQL, SQL Server, PostgreSQL
★MongoDB
DB2, Access, SQLite
★Cassandra
Sybase ASE, Solr
★Redis
TEradata, Filemaker
★Hbase
...
- 24년도엔 Oracle, MySQL, SQL Server, PostgreSQL, MongoDB순이며 그 뒷 시스템들과의 차이는 현격하다.(db-engines 기준) 특이한점으로 Databricks의 lakehouse기반 제품이 성장세가 두드러진다.


# MongoDB의 초기엔
Document타입의 데이터를 JSON형식으로 저장하는 것이 주였으나 다음과 같은 기능들이 추가되어 EcoSystem을 갖춤.
- 분산 저장을 위한 샤딩 시스템
- 복제 저장을 위한 ReplicaSets
- 데이터 추출을 위한 text search engine, Full indexing 기법
- 데이터 분석·가공을 위한 Map-reduce, Aggregation Framework
- 데이터 저장·관리를 위한 GridFs
- 서브시스템 #니터링을 위한 OPS #니저·Compass


# Hadoop Ecosystem과 비교
- 개발사 : MongoDB inc / Apache재단
- 기능 : 하둡은 HDFS(분산파일시스템), HBASE(NoSQL), Hive/Pig(데이터추출/분석도구), Zookeeper(분산 코디네이터)
- 확장성 : 동일. ScaleOut, 추가 라이선스 없이 다수 노드 확장 용이
- 안정성 : 동일. Fail발생시 복제기능. 다수 노드로 복제 용이
- 주요 특징 : Document(Data Set 타입유리) vs ColumnFamily(KV타입 유리). MongoDB가 UI·트랜잭션 처리·기술지원 좋고 Subsystem들의 버전관리·연동성·안전성 높음. 


# MongoDB란
- Humongos → MongoDB inc.(2015년)
- JSON Type의 데이터 저장구조 제공
- 샤딩, Replica 기능 제공
- MapReduce 기능 제공
- CRUD위주의 다중 트랜잭션 처리 가능
- Memory Mapping 기술 기반으로 Big Data 처리 성능 좋음(RDBMS의 3~10배)


# RDBMS와 용어 차이
- Table → Collection
- Row → Document
- Column → Field
- Primary Key → Object_id Field
- Relationship → Embedded&Link

2009년 첫 상용화 버전0.8 출시. 현 8.0
실행 가능한 OS → window, linux, unix solaris, mac os


# 버전별 큰 차이점
- 2.0 : MMAPv1, javascript engine v1, MQL, Index, text-search, collection=level lock, replica&shard, 
- 3.0 : **wiredTiger 엔진**, js engine v2, compress&encrypt, validate&audit, authentication, document-level lock
- 3.2~3.6 : in-memory storage engine, ops manager, cloud manager, Graphical tool, aggregation pipeline, partial index, better text search, faceted serach
- 4.x : **ACID트랜잭션(multi-document transaction)**, mmapv1 공식지원x? security, better replicasets&shard cluster, client-side field encryption, union aggregation, cold storage
- 5.x : time-series collection for IOT&Log data, live resharding, better aggregation framework
- 6.x : queryable encryption, multi-cloud cluster
- 7.x : 동적 조인, 자동 샤딩 개선, better transaction management, better statistics
- 8.x : 확장된 queryable encryption, better time-series data 처리, better perf&scale, better aggregate&query


# MongoDB 인스턴스 실행하기(옵션절)
1. powershell 실행
2. mkdir c:/mongodb/test
3. cd c:/mongodb/test
4. mongod --dbpath c:/mongodb/test
> 워닝 msg: Use of deprecated server parameter name, concurrent wiredTiger ~ 등
5. 워닝메세지의 권고사항에 따라 --bind_ip 127.0.0.1 옵션 추가. 해당 워닝은 사라졌으나 다른 워닝 계속 존재

# 인스턴스 실행하기(Config file)
1. cd .. (C:/MONGODB)
2. notepad mongodb.conf
3. 교재의 설정파일 입력
4. mkdir log
5. mkdir data
6. ls
7. mongod --config c:/mongodb/mongodb.conf
> 에러 Unrecognized option: journal.enabled
검색결과 4.0 이후로는 필요없는 옵션. processManagement.fork 옵션도 같이 제거하여 다시 실행

# 인스턴스 실행확인
> netstat -ano 를 입력하여 확인한 결과 --port 옵션으로 지정된 포트로 listening 상태인것을 확인.
- 27000포트를 열고 mongosh로 해당 포트로 접속시도
```bash
> mongosh localhost:27000
> Current Mongosh Log ID: 67025ee222bdc4695cc73bf7
Connecting to:          mongodb://localhost:27000/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.1
Using MongoDB:          8.0.0
Using Mongosh:          2.3.1
```
27000 포트를 열어놓은 cmd창에도 핸드쉐이크 메세지 확인되고 mql 정상 입력 가능
27111이라는 생성하지 않은 포트로 접속 시도하면 아래의 에러메세지와 함께 접속 불가판정
```bash
MongoNetworkError: connect ECONNREFUSED 127.0.0.1:27111, connect ECONNREFUSED ::1:27111
```


# MongoDB 서버 종료
```bash
test> use admin
switched to db admin
admin> db.shutdownServer()
Error: read ECONNRESET
admin> exit
c:\Program Files\MongoDB\Server\8.0\bin>netstat -ano | findstr 27000
  TCP    127.0.0.1:58360        127.0.0.1:27000        TIME_WAIT       0
```
> listening 상태에서 TIME_WAIT으로 정상 변경됨


# 기능호환버전 (FCV)
- 이전 버전의 데이터를 최신 버전의 MongoDB서버에서 사용할 수 있도록 일정 시점까지 유지하는 기능
- 업그레이드 후 비활성화 상태로 운영하다가 다운그레이드 가능성이 없을 경우 활성화

```bash
test> db.adminCommand( { getParameter:1, featureCompatibilityVersion: 1 } )
{ featureCompatibilityVersion: { version: '8.0' }, ok: 1 }
test> db.adminCommand({setFeatureCompatibilityVersion:"7.0"})
MongoServerError[Location7369100]: Once you have downgraded the FCV, if you choose to downgrade the binary version, it will require support assistance. Please re-run this command with 'confirm: true' to acknowledge this and continue with the FCV downgrade.
test> db.adminCommand({setFeatureCompatibilityVersion:"7.0",confirm:true})
{ ok: 1 }
test> db.adminCommand( { getParameter:1, featureCompatibilityVersion: 1 } )
{ featureCompatibilityVersion: { version: '7.0' }, ok: 1 }
```
> 지정한 버전(8.0에서 7.0)으로 다운그레이드됨


# 데이터 처리
- RDBMS에선 정형화된 테이블구조가 먼저 정의되어야하고 이에 따라 생성할 수 있지만, NoSQL에서 Collection을 만들 땐 구성요소가 결정되어있지 않아도 생성할 수 있음
- Collection의 종류
  - Non Capped Collection
  - Capped Collection
    - Capped 콜렉션은 제한된 익스텐트 내에서만 데이터를 저장할 수 있고, 이 크기를 초과할 시 기존 공간을 처음부터 재사용(ex 로그데이터)

```bash
test> db.createCollection("emp",{capped:true, size:2100000000, max:500000});
{ ok: 1 }
test> show collections
emp
test> db.emp.stats()
{
  ok: 1,
  capped: true,
  max: 500000,
  wiredTiger: {
    metadata: { formatVersion: 1 },
    creationString: 'acc'
...중략....
  sharded: false,
  size: 0,
  count: 0,
  numOrphanDocs: 0,
  storageSize: 4096,
  totalIndexSize: 4096,
  totalSize: 8192,
  indexSizes: { _id_: 4096 },
  avgObjSize: 0,
  maxSize: 2100000000,
  ns: 'test.emp',
  nindexes: 1,
  scaleFactor: 1
}
```
> 콜렉션 생성, 분석 정상 수행 완료

```bash
test> db.emp.renameCollection("employees")
{ ok: 1 }
test> show collections
employees
test> db.employees.drop()
true
test> show collections
```
> 콜렉션 리네이밍, 드롭 정상 수행 완료


# Insert Update Remove
NoSQL중에서도 MongoDB의 장점은 데이터조작을 위한 전용 언어를 사용할 수 있다는 점

# insertOne
```bash
test> db.test.insertOne(m)
{
  acknowledged: true,
  insertedId: ObjectId('670268fe827389c63ac73bf8')
}
> save메소드는 deprecated됨. insertOne 정상 수행됨
```

# insertMany
```bash
test> db.test.insertMany([m,n])
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('67026938827389c63ac73bfa'),
    '1': ObjectId('67026938827389c63ac73bfb')
  }
}
test> db.test.find()
[
  { _id: ObjectId('670268fe827389c63ac73bf8'), ename: 'smith' },
  { _id: ObjectId('67026938827389c63ac73bfa'), ename: 'smith' },
  { _id: ObjectId('67026938827389c63ac73bfb'), empno: 1101 }
]
```
> insertMany 정상 수행됨

# for문이용 insertOne
```bash
test> for (var n=1103; n<= 1120; n++) db.test.insertOne({n:n, m:"test"})
{
  acknowledged: true,
  insertedId: ObjectId('670269d1827389c63ac73c0d')
}
test> db.test.find()
[
  { _id: ObjectId('670268fe827389c63ac73bf8'), ename: 'smith' },
  { _id: ObjectId('67026925827389c63ac73bf9'), ename: 'smith' },
  { _id: ObjectId('67026938827389c63ac73bfa'), ename: 'smith' },
  { _id: ObjectId('67026938827389c63ac73bfb'), empno: 1101 },
  { _id: ObjectId('670269d1827389c63ac73bfc'), n: 1103, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73bfd'), n: 1104, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73bfe'), n: 1105, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73bff'), n: 1106, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c00'), n: 1107, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c01'), n: 1108, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c02'), n: 1109, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c03'), n: 1110, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c04'), n: 1111, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c05'), n: 1112, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c06'), n: 1113, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c07'), n: 1114, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c08'), n: 1115, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c09'), n: 1116, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c0a'), n: 1117, m: 'test' },
  { _id: ObjectId('670269d1827389c63ac73c0b'), n: 1118, m: 'test' }
]
Type "it" for more
```
> for문 이용 insertOne 정상수행됨

# update문
```bash
test> db.test.update({n:1103},{$set:{ename:"standford", dept:"research"}})
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
test> db.test.find()
[
...생략...
  {
    _id: ObjectId('670269d1827389c63ac73bfc'),
    n: 1103,
    m: 'test',
    dept: 'research',
    ename: 'standford'
  },
...생략...
]
```
> update문 정상수행됨

# remove문
```bash
test> db.test.remove({ename:'smith'})
DeprecationWarning: Collection.remove() is deprecated. Use deleteOne, deleteMany, findOneAndDelete, or bulkWrite.
{ acknowledged: true, deletedCount: 2 }
```
> remove문에 대해 deprecated 워닝을 받았으나 수행은 정상적으로 됨
대체구문으로 deleteOne, deleteMany, findOneAndDelete, bulkWrite 있음


# Unique ID
각 Collection에 할당된 고유값
FCV버전이 3.6 이상이어야함
DB가 다르면 같은 이름의 컬렉션을 여러개 만들 수 있지만 UUID를 통해 구분할 수 있음

```bash
test> db.adminCommand({getParameter:1, featureCompatibilityVersion:1})
{ featureCompatibilityVersion: { version: '7.0' }, ok: 1 }

test> db.getCollectionInfos({name:"test"})
[
  {
    name: 'test',
    type: 'collection',
    options: {},
    info: {
      readOnly: false,
      uuid: UUID('d1470937-6428-49b9-80f1-8a04fc5902d1')
    },
    idIndex: { v: 2, key: { _id: 1 }, name: '_id_' }
  }
]
```

# JSON과 BSON
Document는 RDBMS의 ROW, 행에 해당
- JSON
  ```json
  { data: record }
  ```
  이 형태를 가지는 자료를 java script 형식의 오브젝트 표기법, JSON이라고 함
- BSON
	MongoDB에서 데이터베이스에 내부적으로 저장될때는 Binary타입으로 변환됨
    - BSON타입은 Name과 Value 2개의 필드로 구성되어 저장됨
    - JavaScript Programming Language, Standard ECMA-262 3rd Edition-1999를 근거로 함
    
# Data Type의 종류
- **OBJECT_ID 타입**
  - RDBMS의 ROWID와 유사한 데이터 속성. PK처럼 유일한 값으로 구성됨
  - BSON Object ID는 12바이트의 Binary 값으로 구성됨
  - Document에게 유일한 값으로 부여됨
  - Default Object ID와 별도로 사용자가 부여 가능
```bash
> db.employee.insertOne({
  "eno" : 1101,
  "fanme" : "admin",
  "lname" : "kroll",
  "job" : "manager",
  "salary" : 100000,
  "dept_name" : "sales"
})
< {
  acknowledged: true,
  insertedId: ObjectId('6704d7a9327456e2ce0e341e')
}
> db.employee.findOne({_id:ObjectId('6704d7a9327456e2ce0e341e')})
< {
  _id: ObjectId('6704d7a9327456e2ce0e341e'),
  eno: 1101,
  fanme: 'admin',
  lname: 'kroll',
  job: 'manager',
  salary: 100000,
  dept_name: 'sales'
}
db.employee.findOne({_id:new ObjectId('6704d7a9327456e2ce0e341e')})
{
  _id: ObjectId('6704d7a9327456e2ce0e341e'),
  eno: 1101,
  fanme: 'admin',
  lname: 'kroll',
  job: 'manager',
  salary: 100000,
  dept_name: 'sales'
}
```
> 데이터 입력 후 ObjectId로 findOne 수행 완료

- **JSON타입의 18가지 속성과 타입 넘버**
  - 일반적인 RDBMS처럼 문자, 숫자, 바이너리 데이터를 저장할 수 있는 타입
  - Double - 1
  - String - 2
  - Object - 3
  - Array - 4
  - Binary data - 5
  - Object id - 7
  - Boolean - 8
  - Date - 9
  - Null - 10
  - Regular expression - 11
  - JavaScript code - 13
  - Symbol - 14
  - JavaScript code with scope - 15
  - 32-bit integer - 16
  - Timestamp - 17
  - 64-bit integer 18
  - Min key - 255
  - Max key - 127
  
```bash
> db.data_att.insertOne({
"_id" : ObjectId("201310100000000000000001"),
"v_date" : ISODate("2018-01-21T14:22:46.777Z"),
"v_bin" : BinData(0,"2faeces232csdceq2424"),
"v_char" : "Joo JongMyun",
"v_num" : 1038641858,
"v_arr" : ["jina6678@daum.net","jina6678@para.com"],
"v_bignum" : NumberLong(1257000)
})
< Warning: NumberLong: specifying a number as argument is deprecated and may lead to loss of precision, pass a string instead
{
  acknowledged: true,
  insertedId: ObjectId('201310100000000000000001')
}
```
> 데이터 타입 지정하여 인서트 완료.
NumberLong 내부 인자를 String(""로 감싸서) 하라는 워닝이 발생하여 따옴표로 감싸넣으니 워닝 없어짐

- **배열, Date, Timestamp 데이터 타입 실습**
```bash
> var cursor = db.things.find()
> while (cursor.hasNext()) printjson(cursor.next())
< {
  _id: ObjectId('6704e08e327456e2ce0e341f'),
  empno: 0,
  ename: 'test',
  sal: 1000
}
{
  _id: ObjectId('6704e08e327456e2ce0e3420'),
  empno: 1,
  ename: 'test',
  sal: 1000
}
...생략...
```
> 배열 타입 실습 완료

```bash
Date()
Tue Oct 08 2024 16:48:25 GMT+0900 (한국 표준시)
new Date()
2024-10-08T07:48:29.647Z
new Date()
2024-10-08T07:48:33.232Z
x = new Date()
2024-10-08T07:49:40.048Z
x.toString()
Tue Oct 08 2024 16:49:40 GMT+0900 (한국 표준시)
d = ISODate()
2024-10-08T07:50:03.673Z
d.getMonth()
9
x.getMonth()
9
d.getYear()
124
x.getYear()
124
y = 2024-01-08T07:50:03.673Z
y = "2024-01-08T07:50:03.673Z"
2024-01-08T07:50:03.673Z
y = ISODate("2024-01-08T07:50:03.673Z")
2024-01-08T07:50:03.673Z
y
2024-01-08T07:50:03.673Z
y.getMonth()
0
db.employee.find()
{
  _id: ObjectId('66f145e383e9b357069d366a'),
  ename: '김몽고',
  depart: '개발팀'
}
{
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  depart: '영업팀',
  status: 'B',
  height: 160
}
> var arr = db.employee.find().toArray()
> arr[1]
< {
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  depart: '영업팀',
  status: 'B',
  height: 160
}
```
> Date타입 실습 완료

```bash
for(var i = 0;i<10;i++) db.foo.insertOne({y:new Timestamp(), x:i})
{
  acknowledged: true,
  insertedId: ObjectId('6704f168327456e2ce0e343f')
}
db.foo.find({},{_id:0})
{
  x: 1,
  y: Timestamp({ t: 1728375902, i: 1 })
}
...생략...
```
> timestamp타입 실습 완료

```bash
function seq_no(name) {
var ret = db.seq_no.findAndModify(
	{query:{id:name},
	update:{$inc:{next:1}},
	"new":true,
	upsert:true});
return ret.next;
}
[Function: seq_no]
db.order_no.insert({_id:seq_no("order_no"), name : "Jimmy"})
{
  acknowledged: true,
  insertedIds: {
    '0': 1
  }
}
db.order_no.insert({_id:seq_no("order_no"), name : "Chad"})
{
  acknowledged: true,
  insertedIds: {
    '0': 2
  }
}
db.order_no.find()
{
  _id: 1,
  name: 'Jimmy'
}
{
  _id: 2,
  name: 'Chad'
}
```
> sequence number 타입 실습 완료

- **연산자 종류**
  - 비교연산자
    - $cmp
    - $eq
    - $gt
    - $gte
    - $lt
    - $lte
    - $ne
  - Boolean 연산자
    - $and
    - $not
    - $or
    
```bash
> db.employee.createIndex({height:1})
< height_1
> db.employee.find({},{_id:0, ename:1}).min({height:150}).max({height:170}).hint({height:1})
> db.employee.find({},{_id:0, ename:1}).min({height:150}).max({height:170}).hint({height:1})
<
{
  ename: '김포문0'
}
{
  ename: '김포문1'
}

> db.employee.find({height:{$gt:150, $lte:170}},{_id:0, ename:1, height:1})
< {
  ename: '김포문0',
  height: 160
}
{
  ename: '김포문1',
  height: 163
}

> db.employee.find({$or: [{ename:'김포문0'},{ename:'김포문1'},{ename:'김몽고'}]})
< 
{
  _id: ObjectId('66f145e383e9b357069d366a'),
  ename: '김몽고',
  depart: '개발팀'
}
{
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  depart: '영업팀',
  status: 'B',
  height: 160
}
{
  _id: ObjectId('66f1470183e9b357069d366c'),
  ename: '김포문1',
  depart: '영업팀',
  status: 'B',
  height: 163
}

> db.employee.find({$or: [{ename:'김포문0'},{ename:'김포문1'},{ename:'김몽고'}]}).count()
< 3

> db.employee.distinct("ename")
< [ '김몽고', '김포문0', '김포문1' ]

> db.employee.find({depart:'영업팀'},{_id:0, ename:1, depart:1}).sort({ename:-1})
< {
  ename: '김포문1',
  depart: '영업팀'
}
{
  ename: '김포문0',
  depart: '영업팀'
}
/* sort -1은 내림차순 1은 오름차순*/

> db.employee.find({depart:{$all:['영업팀']}},{_id:0, ename:1, depart:1})
< {
  ename: '김포문0',
  depart: '영업팀'
}
{
  ename: '김포문1',
  depart: '영업팀'
}
/* $all연산자는 depart필드가 배열일 때 조건으로 주어진 배열(여기에선 영업팀)이 모두 포함되는 다큐먼트만 조회됨
 이와 같이 배열에 대한 조건연산자로 $in $nin이 있음*/
 
 > db.employee.find({ename:{$exists:false}})
 < {
  _id: ObjectId('6704d7a9327456e2ce0e341e'),
  eno: 1101,
  fanme: 'admin',
  lname: 'kroll',
  job: 'manager',
  salary: 100000,
  dept_name: 'sales'
}

> db.employee.find({$and:[{height:{$gte:150}},{ename:{$exists:true}}]},{_id:0,ename:1,height:1})
< {
  ename: '김포문0',
  height: 160
}
{
  ename: '김포문1',
  height: 163
}

> db.school.insertMany([
  {_id:1101, name:"Jimmy", scores: [77,85,90], pratice:[10]},
  {_id:1102, name:"Adam", scores:[95,73,55], pratice: [18,8]}
])
< {
  acknowledged: true,
  insertedIds: {
    '0': 1101,
    '1': 1102
  }
}
> db.school.aggregate([
  {$set:{total_scores : {$sum:"$scores"},
		total_pratice:{$sum: "$pratice"}}},
  {$set:{total_amount : {$add:["$total_scores", "$total_pratice"]}}}
]).pretty()
< {
  _id: 1101,
  name: 'Jimmy',
  scores: [
    77,
    85,
    90
  ],
  pratice: [
    10
  ],
  total_scores: 252,
  total_pratice: 10,
  total_amount: 262
}
{
  _id: 1102,
  name: 'Adam',
  scores: [
    95,
    73,
    55
  ],
  pratice: [
    18,
    8
  ],
  total_scores: 223,
  total_pratice: 26,
  total_amount: 249
}
```

# 변경연산자
- 산술연산자
  - $add
  - $devide
  - $mod
  - $multiply
  - $subtract
- 문자연산자
  - $strcasecmp
  - $substr
  - $toUpper
  - $toLower
  
  
```bash
> db.employee.find({salary:{$type:["int","double"]}},{eno:1,salary:1})
< {
  _id: ObjectId('6704d7a9327456e2ce0e341e'),
  eno: 1101,
  salary: 100000
}
> db.employee.find({ename:{$type:2}},{ename:1,height:1})
< {
  _id: ObjectId('66f145e383e9b357069d366a'),
  ename: '김몽고'
}
{
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  height: 160
}
{
  _id: ObjectId('66f1470183e9b357069d366c'),
  ename: '김포문1',
  height: 163
}

> db.employee.find({ename : {$regex : '김포문',$options:'i'}},{ename:1,height:1})
< {
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  height: 160
}
{
  _id: ObjectId('66f1470183e9b357069d366c'),
  ename: '김포문1',
  height: 163
}

> db.employee.find({$and:[
  {ename:{$ne:'김포문0'}},
  {ename:{$exists:true}}
]})
< {
  _id: ObjectId('66f145e383e9b357069d366a'),
  ename: '김몽고',
  depart: '개발팀'
}
{
  _id: ObjectId('66f1470183e9b357069d366c'),
  ename: '김포문1',
  depart: '영업팀',
  status: 'B',
  height: 163
}

//조건연산자의 복합 사용
> db.employee.find(
{$or:[
  {$and:[
  	{ename:{$ne:'김포문0'}},
  	{ename:{$exists:true}}
	]},
  {height:{$gt:160}}
]})
< {
  _id: ObjectId('66f145e383e9b357069d366a'),
  ename: '김몽고',
  depart: '개발팀'
}
{
  _id: ObjectId('66f1470183e9b357069d366c'),
  ename: '김포문1',
  depart: '영업팀',
  status: 'B',
  height: 163
}
# 김몽고는 or조건의 첫번째에서 도출되었고 김포문1은 or문의 두번째 조건에서 도출되었다.

> db.employee.find({ename:/^김포문0/})
< {
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  depart: '영업팀',
  status: 'B',
  height: 160
}

> db.employees.aggregate([
{
	$set: {
		name2:{$toUpper:"$0.name"}
  		, name3:{$toUpper:"$1.name"}
		, name5:{toLower:"$name3"}
	}
}
,{
	$set: {
		name4:{$toLower:"$name2"}
	}
}
])
< {
  '0': {
    name: 'ocean',
    age: 45,
    dept: 'Network',
    joinDate: 1999-11-15T00:00:00.000Z,
    salary: 100000,
    regignationDate: 2002-12-23T00:00:00.000Z,
    bonus: null
  },
  '1': {
    name: 'river',
    age: 34,
    dept: 'Devops',
    isNegotiating: true
  },
  _id: ObjectId('66f17ab583e9b357069d367b'),
  name2: 'OCEAN',
  name3: 'RIVER',
  name5: {},
  name4: 'ocean'
}

> db.employee.find({ename:/^김포문0/}).count()
< 1
> db.employee.find().count()
< 4
> db.employee.distinct("depart")
< [ '개발팀', '영업팀' ]
< db.employee.find({ename:/^김포문/}).limit(1)
> {
  _id: ObjectId('66f1470183e9b357069d366b'),
  ename: '김포문0',
  depart: '영업팀',
  status: 'B',
  height: 160
}
> db.employee.update(
  	{salary:{$exists:true}}
	,{$inc:{salary:100}}
	,{multi:true}
)
< {
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
> db.employee.updateMany(
  {salary:{$exists:false}}
	,{$inc:{salary:100}}
)
< {
  acknowledged: true,
  insertedId: null,
  matchedCount: 3,
  modifiedCount: 3,
  upsertedCount: 0
}
> db.employee.updateMany(
  {salary:{$lt:1000}}
	,{$unset:{salary:""}}
)
< {
  acknowledged: true,
  insertedId: null,
  matchedCount: 3,
  modifiedCount: 3,
  upsertedCount: 0
}
```

# 빅데이터의 추출과 분석
- MongoDB의 Aggregation Framework 함수를 이용하여 추출
  - MongoDB와 Hadoop의 MapReduce의 과다한 프로그래밍으로 인한 낭비를 최소화하여 빅데이터를 추출
- MongoDB의 Map/Reduce 기능을 이용하여 추출
  - Map함수와 Reduce함수를 JavaScript문법을 통해 데이터를 안정적으로 처리
- MongoDB와 Hadoop의 Map-Reduce를 연동하여 추출
  - MongoDB로 데이터를 읽고 Hadoop MapReduce를 이용하여 데이터를 분석 가공 처리
  
### Aggregation FrameWork
- 빅데이터의 추출에 최적화된 기능(v2.2부터 지원)
- 내부적으로 MongoDB의 MapReduce를 사용하며 빠른 성능이 보장됨
- MapReduce를 이용한 Javascript로 생성되어있음
- 외부 데이터 처리에는 제한적이고, MongoDB 내의 데이터만 처리
- $project, $match, $group, $sort, $limit, $skip 6개 연산자로 구성되며 RDBMS의 select, where, group by, order by등과 같아 사용이 편리
  - $project > select / $match > where / $group > group by

- **AGGREGATE 실습 1**
```bash
> db.employee.aggregate([
  {
		$group : {_id:null, count : {$sum:1}}
	}
])
< {
  _id: null,
  count: 4
}
> db.employee.aggregate([
  {
		$group : {_id:null, total_height : {$sum:"$height"}}
	}
])
< {
  _id: null,
  total_height: 323
}
> db.employee.aggregate([
  {
		$group : {_id:"$depart", total_height : {$sum:"$salary"}}
	}
])
< {
  _id: null,
  total_height: 100200
}
{
  _id: '개발팀',
  total_height: 5000
}
{
  _id: '영업팀',
  total_height: 10000
}
> db.employee.aggregate([
  {
		$group : {_id:"$depart", total_height : {$sum:"$salary"}}
	}
  , {
		$sort : {total_price:1}
	}
])
< {
  _id: '개발팀',
  total_height: 5000
}
{
  _id: '영업팀',
  total_height: 10000
}
{
  _id: null,
  total_height: 100200
}
> db.employee.aggregate([
	{
		$match: {height:{$gt:162}}
	}
  ,{
		$group : {_id:"$depart", total_price : {$sum:"$salary"}}
  }
  , {
		$sort : {total_price:-1}
	}
])
< {
  _id: '영업팀',
  total_price: 5000
}

```

- **AGGREGATE 실습 2**
```bash
// data 삽입
> db.employees.insertMany([
  {deptno:10, sal:1000, job:"clerk", ename:"john", empno:10001}
,  {deptno:20, sal:1500, job:"salesman", ename:"mark", empno:10002}
,  {deptno:30, sal:2000, job:"clerk", ename:"david", empno:10003}
,  {deptno:20, sal:2500, job:"salesman", ename:"roler", empno:10004}
,  {deptno:50, sal:3000, job:"teacher", ename:"mickey", empno:10005}
])
< {
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('670a4682b32ebbd8abaf8079'),
    '1': ObjectId('670a4682b32ebbd8abaf807a'),
    '2': ObjectId('670a4682b32ebbd8abaf807b'),
    '3': ObjectId('670a4682b32ebbd8abaf807c'),
    '4': ObjectId('670a4682b32ebbd8abaf807d')
  }
}
> db.employees.aggregate(
  {$match : {$and: [{deptno:10}, {sal: {$gte:500, $lte : 3000}}]}}
, {$match : {$or : [{job:"clerk"}, {job:"salesman"}]}}
, {$project : {
	_id : 0,
	empno : 1,
  ename : {$toUpper : "$ename"},
	job : {$toUpper : "$job"},
  substr_name : {$substr : ["$ename", 1, 2]},
  str_compare : {$strcasecmp : ["$ename", "jmjoo"]},
	sal : 1
}}
)
< {
  sal: 1000,
  empno: 10001,
  ename: 'JOHN',
  job: 'CLERK',
  substr_name: 'oh',
  str_compare: 1
}

> db.employees.aggregate(
  {$match : {deptno:30}}
, {$project : {_id : 0, empno : 1, stats : {sal:"$sal", comm : "$comm"}}}
)
< {
  empno: 10003,
  stats: {
    sal: 2000
  }
}
// comm 필드가 없으므로 추가
> db.employees.updateMany(
{}
, [
  {
		$set: { comm : {$toInt : {$multiply : [{$rand:{}},1000]}}}
	}
]
)
// comm은 세자리수 랜덤값으로 추가됨. 다시 aggregate문 실행
> db.employees.aggregate(
  {$match : {deptno:30}}
, {$project : {_id : 0, ENAME : {$toUpper: "$ename"}, empno : 1, stats : {sal:"$sal", comm : "$comm"}}}
)
> {
  empno: 10003,
  ENAME: 'DAVID',
  stats: {
    sal: 2000,
    comm: 763
  }
}

// 다음 실습 진행을 위해 sal<2000 인 경우 comm 제거
> db.employees.updateMany(
  {sal : {$lt : 2000}}
, {$unset : {comm:""}}
)
//정상 제거 완료

> db.employees.aggregate(
  {$project : {
		_id : 0
		, empno : 1
		, ename : 1
		, sal : 1
		, comm : {$ifNull:["$comm",0]}
		, sum_avg_add : {$add : ["$sal",{$ifNull : ["$comm",0]}]}
		, sum_avg_subtract : {$subtract : ["$sal", {$ifNull : ["$comm",0]}]}
		, sum_avg_multiply : {$multiply : ["$sal",2]}
		,	sum_avg_divide : {$divide : ["$sal", 2]}
}}
)
< {
  sal: 1000,
  ename: 'john',
  empno: 10001,
  comm: 0,
  sum_avg_add: 1000,
  sum_avg_subtract: 1000,
  sum_avg_multiply: 2000,
  sum_avg_divide: 500
}
// 출력결과 이하생략
```

- 99p까지 실습 완료
