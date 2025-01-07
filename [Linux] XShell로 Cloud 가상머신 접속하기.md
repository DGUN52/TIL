## XShell
> XShell 다운로드 👉 https://www.netsarang.com/ko/xshell-download/

국내 개발된 터미널 접속도구이다.
현재 재직중인 회사의 주요 고객사 세 곳 중 한 곳에서 사용하고 있다.


나머지 두 곳은 putty와 자체 접속도구를 사용하고 있어서 분포상 겹치는게 없으나
일반적으론 putty가 많이 사용 될 것으로 짐작된다.

접속도구가 다 거기서 거기겠으나 아무튼 디테일한 부분에서 익숙하지 않으면 불편할 때가 있어서
Azure 익히는 김에 새로운 접속도구를 사용해보려 한다.


## # Azure에 접속해보자!
![](https://velog.velcdn.com/images/deaf52/post/c6c64fa7-c9ad-4ed3-9f8e-84efa14eed51/image.png)

당연히 가상머신이 실행중이어야 한다.
기동중인것을 확인하고 공용 IP를 확인하자.

Azure을 예시로 들었지만 VMWare든 AWS의 EC2이든 당연히 상관없다.
가상머신 생성 시 만들었던 pem파일을 이용하여 접속해보자.

</br>

## # XShell 실행

![](https://velog.velcdn.com/images/deaf52/post/4cdbec4e-6cf4-4925-b52d-b4c8414a3b8f/image.png)

XShell을 실행하면 빈 세션창이 뜬다.
새로 만들기를 눌러준다.

![](https://velog.velcdn.com/images/deaf52/post/ad2efbc4-40a7-47b3-bac0-1c6b462c6273/image.png)

구분하기 좋은 이름을 등록하고
호스트에 Azure 공용 IP를 입력한다.

![](https://velog.velcdn.com/images/deaf52/post/03945eac-2f72-432a-ac6a-063dbe83dcec/image.png)

1. 사용자 인증 탭에서
2. OS 계정명을 등록하고 (지금 등록 안하고 세션 접속 시 팝업에 입력할 수도 있다.)
3. 가상머신은 public key 방식으로 세팅되어있다. 체크 해주고 
4. 설정 단계로 넘어가자

![](https://velog.velcdn.com/images/deaf52/post/1c8bdb64-f00a-4d9c-ba4c-7be212d6e204/image.png)

![](https://velog.velcdn.com/images/deaf52/post/5a6ce38b-39a5-499c-827e-ab7d0f0510e6/image.png)

등록된 key 파일이 없으니 새로 등록해준다.

가상머신을 생성할 때 '기존 key 파일을 이용' 같은 옵션을 선택하면 
하나의 pem파일로 여러 리소스에 접속할 수 있다.

![](https://velog.velcdn.com/images/deaf52/post/135052f1-c22e-4286-8544-29b2fdd3b244/image.png)

![](https://velog.velcdn.com/images/deaf52/post/727274d2-904c-40f3-a136-311581ef9752/image.png)

접속을 하면 ip나 계정명이 정상적으로 확인된다.
만약 접속이 안된다면 방화벽/인바운드 설정을 확인할 것

![](https://velog.velcdn.com/images/deaf52/post/a36204ca-c6bb-4f18-9b36-3b3ce3f25008/image.png)
