# Replica Set?
- DB 시스템들은 저마다의 다중화 방법이 있다. 
Replica Set은 MongoDB에서 제공하는 다중화 방법의 **첫발자국**이라 할 수 있겠다.

- 홀로 설치된 DB시스템을 **Standalone**,
여러 Standalone 시스템들에 role을 부여해서 그룹화 한 것을 **Replica Set**,
다시 Replica Set들을 그룹화 한 것을 **Shard Cluster**라 한다.

오늘은 이 MongoDB의 Replica Set에 대해 알아보자.
</br>
</br>
# 레플리카 셋의 이점
- **고가용성**
 
 : 메인 노드가 다운되면 대기중인 서브 노드가 자동으로 메인 역할을 대체
 
- **읽기 분산**
 
 : 서브 노드로 READ 작업 부하를 분산
 
- **데이터 복구**
 
 : 메인 노드에 장애 발생하여 데이터가 유실되어도,
 서브노드에 보관된 데이터로 복구 가능
</br>
</br>
# Primary, Secondary, Arbiter

Replica Set 방법에선 3개의 노드를 최소 구성요건으로 본다.
그 이하로도 억지로 구성을 할 순 있겠지만 작업중에 에러를 맞딱뜨릴 확률이 높고, 본래의 목적인 안정성에도 부합하지 않는다.
- **Primary** : Read/Write, 사용자 응답을 담당하는 본체
- **Secondary** : Primary를 항시 복제하고, Primary가 다운되면 대신해서 Primary를 맡는다.
- **Arbiter** : 데이터를 저장하지 않는 Primary 선출을 위한 노드
</br>
</br>
# 작동방식
![](https://velog.velcdn.com/images/deaf52/post/7f5555be-4657-4181-8dbc-b85fcd735081/image.png)


Primary에서 발생한 변경사항을 저장하는 **oplog**를 통해 Secondary에 데이터가 복제된다. 
Primary 노드가 모종의 이유로 중단되면,
노드들간의 **투표**를 통해 가장 많은 표를 받은 노드가 Primary로 **선출**된다.

### 투표
![](https://velog.velcdn.com/images/deaf52/post/6fbc1420-a845-4c9a-9d21-a03ac8aafdc1/image.png)
투표는 우선순위, 데이터의 최신화정도 등에 영향을 받는다.

이 투표가 동률을 이루지 않기 위해 노드 수를 홀수로 두는 것이 권장되며,

짝수로 이루어질 경우 Arbiter 노드를 생성하여 과반수투표가 성립되도록 한다.

> Replication Set 구성을 확인하는 명령어
rs.conf() 조회 결과 일부
```js
> rs.conf()
    {
      _id: 5,
      host: '192.168.123.456:27017',
      arbiterOnly: false, //Arbiter 아님
      buildIndexes: true,
      hidden: false,
      priority: 1,
      tags: {},
      secondaryDelaySecs: Long('0'),
      votes: 1 //투표권 가짐
    }
```

# 구성

- **PSS**
 : Primary - Secondary - Secondary
 Stand-by DB가 두 멤버나 있기 때문에 안정적인 구조 

- **PSA**
 : Primary - Secondary - Arbiter
   PSS에 비해 상대적으로 안정성이 낮지만 **최소한의 구성으로 높은 가용성**을 유지할 수 있다.
   (Arbiter의 경우에는 data를 저장하지 않고, R/W 불가한 매우 가벼운 노드로써 시스템 자원을 많이 먹지 않는다.)

Secondary node는 자원이 허락한다면 50개까지 추가 구성할 수 있으며 그 중 7개까지만 투표권을 부여할 수 있다.


# Read Preference
- 읽기부하 분산을 위한 방법.
- Secondary 노드로 읽기부하를 분산한다.
- Read Preference를 secondaryPreferred로 수정하면 작동한다. (클라이언트 URI 단에서 수정)

# Write Concern
- 데이터 쓰기 작업의 일관성을 위한 설정
- 설정된 w의 값만큼 Replication에 데이터 복제가 완료된 뒤 사용자의 요청에 응답한다. 쓰기 작업의 안정성을 올릴 수 있지만 성능은 저하. 

# Read Concern
- 데이터 읽기 작업의 일관성을 위한 설정. 
- 어떤 노드를 얼마나 최신인지 확인하여 읽을 것인지 정함. 

# 명령어
- rs.status() 			
: 상태 확인
- rs.conf()
: 구성 확인
-  rs.add("<ip\>:<port\>")
: Replica Set에 멤버 추가 
ex: `rs.add("192.168.123.456:27017")`
- rs.remove("<ip\>:<port\>")
: 멤버 삭제
ex: `rs.remove("192.168.123.456:27017")`
- rs.stepDown()
: 실행한 노드가 Primary면 Secondary로 전환
- rs.reconfig(`config`)
: Replica Set 구성 변경
- rs.addArb("<ip\>:<port\>")
: Replica Set에 Arbiter 추가
- rs.isMaster()
: 현재 노드의 역할 확인

- rs.initiate({_id:<set-name>})
: ReplicaSet 설정 구성

- rs.printSecondaryReplicationInfo()
: Lag상태 확인
- rs.printReplicationInfo()
: oplog size 확인

#### Replica Set 멤버 구성 예문
```js
rs.initiate(
	{
		_id : "rplSet1",
		members: [
			{ _id : 0, host : "192.168.123.456:27017" },
			{ _id : 1, host : "192.168.123.457:27018" },
			{ _id : 2, host : "192.168.123.458:27019", arbiterOnly:true }
		]
	}
)
```

#### config 수정 예문
```js
var config = rs.config()
config.members[2].vote=0
rs.reconfig(config)
```
  
  ![](https://velog.velcdn.com/images/deaf52/post/61aea350-c2fa-4e03-96a5-7b167bc4d88a/image.png)
