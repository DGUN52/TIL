# Azure?
클라우드 플랫폼은 대부분 AWS, 아마존의 플랫폼을 처음으로 접하는 사람이 많을 것이고, 나 또한 그렇다.

무료요금제인 프리티어를 제공해주고, 참고할 레퍼런스도 많은 큰 장점을 가진 AWS을 학습용으로 채택하는 건 고민할 여지가 없다.

>
[글로벌 클라우드 점유율; tridenstechnology](https://tridenstechnology.com/ko/%ED%81%B4%EB%9D%BC%EC%9A%B0%EB%93%9C-%EC%84%9C%EB%B9%84%EC%8A%A4-%EC%A0%9C%EA%B3%B5%EC%97%85%EC%B2%B4/#h-top-10-cloud-providers-comparison)
**AWS 32%** > MS Azure 22% > Google 11% > Oracle 2%
[국내 클라우드 점유율; news space](https://www.newsspace.kr/news/article.html?no=3043)
**AWS 60%** > MS Azure 24% > 네이버 20.5% > KT 8% = 오라클 8%

2019년 AWS가 44%나 차지했던 글로벌 클라우드 시장은
플랫폼들이 발전해가면서 계속 나눠갖고 있으므로
**다양한 플랫폼 경험은 큰 장점이 될 것이다.**

</br>

# Azure을 사용해보자

## # 회원가입
[👉 MS AZURE - 등록하기](https://go.microsoft.com/fwlink/?linkid=2227353&clcid=0x412&l=ko-kr)
위 사이트로 들어가서 microsoft 계정으로 로그인하면 Sign up 화면이 뜬다.

정보를 하나씩 입력해주면 된다. 
네이버 영문주소를 이용하면 편하다.
 
![영문주소대로 입력](https://velog.velcdn.com/images/deaf52/post/22733aea-e050-4241-af72-f7419f4111f3/image.png)
- 중간이름은 생략하고,
- 전화번호에 국가번호를 입력하지 말라고 하는데 해주어야한다.
ex) 전화번호가 '010 1234 5678'일 경우 → 8210 1234 5678
- 인증번호를 문자로 받으면 스팸차단에서 걸러질 수 있다. 일단은 전화로 받자.




이후 `VISA`/`Master Card`가 지원되는 체크/신용카드를 등록하자.
등록이 완료되면 원화 1,000원이 결제된 후 취소된다.

혹시 지원되는 카드가 없다면 진행이 불가능하니
원활한 클라우드 생활을 위해선 카카오페이 체크카드라던지 하나 발급받는 것이 좋다.


![](https://velog.velcdn.com/images/deaf52/post/f09376ac-ff8a-4b6d-b7d5-460efeceba2e/image.png)

2차인증을 할 것인지 물어보는데 클라우드 계정 해킹 사례는 심심찮게 들을 수 있으니 등록해주자.

authenticator를 사용중이라면 바로 등록, 진행해주면 된다.
google authenticator와 헷갈리지 말기

![](https://velog.velcdn.com/images/deaf52/post/46e897fb-ab39-49dd-a583-575d90ef5887/image.png)

이제 signup이 완료되었고, 바로 다음 단계로 진행하면 된다.

</br>

## # 리소스 만들기 - 가상머신

![](https://velog.velcdn.com/images/deaf52/post/2bca1341-7872-40d3-aaa4-7690097222c0/image.png)

리소스 종류를 'SQL 데이터베이스' 로 만드는 것이 사용에는 더 간편할 것이다.
하지만 더 범용성이 높은 가상 머신을 리눅스로 만들고, 그 안에 MariaDB를 설치해 보겠다.

![](https://velog.velcdn.com/images/deaf52/post/8f016008-1073-461c-a7bf-6b61e3a82a09/image.png)

위 사진의 버튼(Azure 가상머신)을 누르면 본격적인 세팅이 시작된다.

![](https://velog.velcdn.com/images/deaf52/post/6b32e78f-53d8-419a-b2ad-ba07988a4f15/image.png)

> 기본적인 시스템을 익힐 수 있돼 저렴한 이용료를 1순위로 잡고 세팅했다.
언급하지 않은 부분은 기본값으로 사용했다.

### 기본 사항

![](https://velog.velcdn.com/images/deaf52/post/b4895cc9-66c7-41db-ad97-1eb4c5d272ce/image.png)


위의 스크린샷을 보고 세팅하자.
아래는 부가설명
- **지역 : Japan East**
  - 한국 리전에선 가격이 싼 크기 유형이 마땅히 없어서 그나마 가까운 일본 지역으로 선택
- **Auzre Spot 할인으로 실행 : O**
  - 다른 사용자들의 사용량이 적으면 그만큼 저렴하게 이용할 수 있는 변동형 요금제.
  다른 이용자들의 사용량이 많아지면 가격이 올라가거나 가상머신이 중지될 수 있다. (아래 옵션에서 조절 가능)
- **제거 유형 : 용량만**
- **제거 정책 : 중지/할당 취소**
  - 제거 유형을 '가격 또는 용량' 으로 바꾸면 최대비용을 더 낮게 설정할 수 있다.
- **크기 : D2plds_v5**
  - 작성일 기준 0.01372$/h로 이보다 더 저렴한 크기유형은 B유형인데 학습용으로 사용하기엔 충분해 보이나, 로컬스토리지를 지원하는 가장 저렴한 크기유형으로 선택했다.
- **사용자 이름 : RDB_DBA**
  - 혹시 임의로 생성한 후 까먹었다면 `VMWare 정보 > 도움말 > 암호 다시 설정` 탭에서 확인할 수 있다.
- **SSH 공개 키 원본 : 새 키 쌍 생성**
- **키 쌍 이름 : KEY_RDB**

### 디스크
- **OS 디스크 유형 : 표준 HDD**
- **VM으로 삭제 : O**
  - 기본값. 가상머신을 제거할 때 같이 제거되게 하여 관리할 요소를 줄였음

### 네트워킹
- **VM 삭제 시 공용 IP 및 NIC 삭제 : O**

그 외 기본값

### 관리
- **시스템이  할당한 관리 ID 사용**
  - Azure의 다양한 서비스를 사용할 때 VM을 인증하는 자격증명 같은 기능들을 자동으로 관리할 수 있게 해주는 옵션이다.
  무료로 사용할 수 있는 기능이고 편의성을 올려주니 당연히 채택
  
그 외 기본값

### 모니터링
서비스용 가상머신이라면 당연히 사용해야겠지만,
이 글은 학습용일 뿐이고 OS에 크리티컬한 작업을 하지도 않을 것이니 모두 해제한다.

전부 사용하지 않음.


### 고급
- 확장 : 다양한 기능들을 제공하는 확장을 제공한다. 후에 기회가 있다면 사용해보자

일단은 전부 사용하지 않음.


### 만들기
![](https://velog.velcdn.com/images/deaf52/post/52904a16-66c0-47d4-a291-780c7b14f412/image.png)

만들기를 누르면 SSH키를 보관하라고 팝업이 발생한다. 
반드시 기억할 수 있는 곳에 잘 보관하자.


![](https://velog.velcdn.com/images/deaf52/post/a3eb65a4-c373-4945-8dec-0cdef3e7a323/image.png)

![](https://velog.velcdn.com/images/deaf52/post/33d15c20-0968-4dfa-9032-26f206780461/image.png)

그리고 리소스가 시작상태인 것을 확인한다.

이로써 Azure에 Ubuntu 24.04.1 설치를 완료했다.
다음장부턴 본격적으로 MariaDB 설치에 돌입해보자!