1. Web-RTC 구현을 위한 학습
  - Singaling Server
    - Session Control Messages, Error Messages, Codec, Bandwith 등 다양한 정보가 각 Peer들에게 전달되어야 함.
    - SDP (Session Description Protocol)을 통해
    - Signaling Server 는 일반적으로 클라이언트 사이드와 WebSocket 방식으로 작동

  - STUN Server (Session Traversal Utilities for NAT)
    - NAT환경에 놓인 Peer에 대한 Signaling을 위한 Server
    - STUN Server와 TURN Server 필요
  - STUN Server : 자신의 공인 IP(Public Address)를 알려주는 방식.
    - 자신의 공인 IP를 전송하고 이를 이용해서 Signaling하는 방식
    - 직접 구현 필요 XX -> 오픈소스 및 Google의 STUN Server 사용

  - TURN Server (Traversal Using Relays around NAT) Server
    - STUN Server로도 연결하지 못하는 20%를 연결하기 위한 서버
    - 보호정책이 강한 NAT나 라우터, Symmetric NAT환경
    - symmetric NAT제한을 우회할 수 있게 해줌
    - Peer간 통신 채널을 중계해주는 역할. P2P방식을 벗어남 -> 부하와 트래픽 발생
    - Local IP와 Public IP로도 연결할 수 없는 경우 TURN 서버 사용

2. openvidu 샘플 구동
  - 샘플
    - [https://velog.io/@jsb100800/개발-WebRTC-SpringBoot-Vue.js를-활용한-Group-Video-Call](https://velog.io/@jsb100800/%EA%B0%9C%EB%B0%9C-WebRTC-SpringBoot-Vue.js%EB%A5%BC-%ED%99%9C%EC%9A%A9%ED%95%9C-Group-Video-Call)
  - Signaling, SFU, MCU방식에 대한 설명
    - [https://millo-l.github.io/WebRTC-구현-방식-Mesh-SFU-MCU/](https://millo-l.github.io/WebRTC-%EA%B5%AC%ED%98%84-%EB%B0%A9%EC%8B%9D-Mesh-SFU-MCU/)
  - Docker 및 리눅스 배포판 설치
    - [https://velog.io/@hanjuli94/윈도우에서-도커-실습하기](https://velog.io/@hanjuli94/%EC%9C%88%EB%8F%84%EC%9A%B0%EC%97%90%EC%84%9C-%EB%8F%84%EC%BB%A4-%EC%8B%A4%EC%8A%B5%ED%95%98%EA%B8%B0)
  - Maven 설치
    - 설치링크
  - Ubuntu, Docker 설치 및 구동, Vue기반 화상회의 샘플 구동 성공
    - 남은 과제) 구조 분석하여 프로젝트에 적용
