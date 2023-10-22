### 서론
- docker에 실행시킬 이미지가 요구하는 ram수준을 맞춰주지 못하거나
- 혹은 반대로 docker의 wsl(vmmemWSL)이 메모리를 너무 잡아먹으면 램을 제한할 필요가 있다.
- 구글링을 해보면 다양한 방법이 나오는데 .wslconfig으로 간단히 설정하는 방법을 소개한다.


### 적용방법

1. 윈도우 탐색기 주소창에 `%userprofile%` 입력
![](https://velog.velcdn.com/images/deaf52/post/9fa32a4f-0f6b-487e-aeb6-ec2b63293afa/image.png)

2. `C:\Users\사용자이름`폴더에 접속될텐데 우클릭으로 `새로만들기 - 텍스트파일`, 만들어진 텍스트파일을 `.wslconfig`으로 변경한다.
![](https://velog.velcdn.com/images/deaf52/post/8cb2af95-5e4e-4a5a-b1d2-59af83372729/image.png)

3. 내부는 다음과 같이 설정할 수 있다.
```
[wsl2]
memory=16GB
processors=2
swap=1GB
```
>
`kernel`: 리눅스 커널을 사용자가 지정
`kernelCommandLine` : 사용자가 지정하는 kernel command line 추가
`메모리` : WSL 2.0  사용하는 메모리 지정한다. 기본 값으로 윈도우의 80%를 설정함  (WSL 성능 향상)
`CPU` : WSL  2.0 에서 사용하는 CPU 개수 지정  (WSL 성능 향상)
`localhostForwarding` :  localhost에 연결을 위한 포트 포워딩 
`가상 메모리` : SWAP 공간을 할당 크기 지정 가능 (WSL에서 메모리가 부족한 경우 사용)
`가상 메모리 파일 저정` : Swap 파일을 지정 가능하다.  위치 설정을 하지 않으면 윈도우 프로파일 폴더 하위의 temp 폴더에 생성된다.<br>
ref1 : [kibua20 tistory](https://kibua20.tistory.com/63)
ref2 : [microsoft github](https://github.com/MicrosoftDocs/wsl/blob/main/WSL/wsl-config.md)

4. 설정을 마치면 콘솔에서 `wsl --shutdown`으로 wsl을 강제종료 시켜준다.
5. 도커 등을 재시작한다.
