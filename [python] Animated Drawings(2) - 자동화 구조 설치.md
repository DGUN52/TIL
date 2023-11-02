
## # 자동화 구조 설치
> 사용 가이드 👉 [README.md#animating-your-own-library](https://github.com/facebookresearch/AnimatedDrawings#animating-your-own-drawing)

[](https://velog.velcdn.com/images/deaf52/post/40158508-2dad-48e4-a70f-4736882ef3da/image.png)

| 형태파악, 관절설정 | 모션파일 적용 |
| - | - |
| <img src=https://velog.velcdn.com/images/deaf52/post/40158508-2dad-48e4-a70f-4736882ef3da/image.png> | <img src=https://velog.velcdn.com/images/deaf52/post/db5f6940-c5f5-49a3-9186-492b59eaba8a/image.gif> |

- 이때까지는 미리 만들어진 프리셋을 실행시키는 것에 지나지 않았다. 

- 하지만 [예제 사이트](https://sketch.metademolab.com/)에서 제공해주는 `이미지 입력` → **`형태파악, 관절설정`** → **`모션파일로 애니메이션 생성`** 의 기능을 사용자의 서비스에도 적용할 수 있도록 자동화 가이드도 그 다음 내용으로 제공된다.

- 설정된 관절과 캐릭터의 범위를 수정할 수 있는 `fix`기능도 있지만 구현하려는 서비스 범위 상 본 시리즈에선 수정기능까지 다루진 않는다.

### # 0. 도커 설치
>[👉 ubuntu 환경에 설치](https://velog.io/@deaf52/Docker-Ubuntu-%ED%99%98%EA%B2%BD%EC%97%90-%EB%8F%84%EC%BB%A4-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0)
- window환경에는 [공식 홈페이지의 exe파일](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe)로 간단하게 설치할 수 있다.
- 이미 설치 돼있다면 생략한다.



### # 1. docker build, docker run
아래 명령어를 입력해서 이미지를 `build`하고 컨테이너를 `run`한다.
이때까지 **네가지 서로 다른 환경에서 실행했는데 모두 같은 에러가 발생하였다.**

```bash
cd AnimatedDrawings/torchserve

# 컴퓨터 자원에 따라 20분 이상 소요될 수 있다.
docker build -t docker_torchserve .
docker run -d --name docker_torchserve -p 8080:8080 -p 8081:8081 docker_torchserve

# after few seconds
curl http://localhost:8080/ping
# 출력으로 'healthy'라는 단어가 떠야한다.
# 이외의 모든 반환값은 에러로 간주.
```
- 아무 에러도 발생하지 않고 'healthy'라는 리턴을 잘 돌려받았다면 **#3**으로 바로 진행하자. 그 외에는 **#2**에서 오류를 잡고 계속 진행

- `no moudle`관련한 에러는 이전까지의 가이드를 잘못 수행했을 확률이 매우 높다. 신중히 놓치거나 작성자/가이드와 다른 점이 없는지 재시도 해보는 것을 추천

- `mmcv-full==1.7.0`설치에 실패하고 `c++17`을 사용하여야 한다는 에러는 공통적으로 발생하였는데 아래 목차에서 수정

### # 2. mmcv-full 설치 오류
- 구글링중 [깃허브 이슈](https://github.com/open-mmlab/mmcv/issues/2860)에서 해당 오류를 확인하였고, 이를 적용하니 문제없이 `build`와 `run`이 동작하였다.

- 아래에서 설명할 절차는 다음과 같다.
  - mmcv설치파일을 다운로드
  - 이슈에서 제시하는 부분 수정(`setup.py`의 268, 362번째 라인)
  - 바뀐 `setup.py`을 이용하여 빌드하도록 도커파일 변경 

1. mmcv-full 설치파일 다운로드
```bash
# 새로운 폴더에서 작업
mkdir my-mmcv
cd my-mmcv
pip download mmcv-full==1.7.0

# 압축 해제
tar -zxvf mmcv-full-1.7.0.tar.gz
rm -rf mmcv-full-1.7.0.tar.gz
```

2. `setup.py` 수정(아래의 주석 참고) 후 다시 압축. 
예시로는 `vi`를 활용했지만 어떤 방식으로든 수정하면 된다.
```bash
vi mmcv-full-1.7.0/setup.py 
# line 268, 362 to c++14 -> c++17
# 혹은 모든 c++14를 c++17로 치환해서 됐다는 github 답글도 있음

#다시 압축 후 디렉터리 제거
tar -zcvf mmcv-full-1.7.0.tar.gz mmcv-full-1.7.0
rm -rf mmcv-full-1.7.0
#아래 사진 참고
```

| `setup.py` - line 268 |
| - |
|<img src=https://velog.velcdn.com/images/deaf52/post/d96b25d4-5be1-4f18-a433-f843e0d65d0f/image.png>|

|`setup.py` - line 362|
| - |
| <img src=https://velog.velcdn.com/images/deaf52/post/76ec984f-6c0f-4e82-b23d-50fceba63b03/image.png>|

3. Dockerfile 수정 (AnimatedDrawings/torchserve/Dockerfile)
   - `docker build -t docker_torchserve .`를 실행할 때 이 설치파일을 사용하도록 `Dockerfile` 수정
```bash
cd .. #cd AnimatedDrawings/torchserve
vi Dockerfile  
#추가) COPY my-mmcv/mmcv-full-1.7.0.tar.gz /tmp/mmcv-full-1.7.0.tar.gz
#수정) RUN mim install /tmp/mmcv-full-1.7.0.tar.gz
#아래 사진 참조
```
![](https://velog.velcdn.com/images/deaf52/post/8dabe5c0-13a1-4488-bd9c-4d53b3fe8b7f/image.png)


- 다시 `build`및 `run`, 확인
```bash
# 컴퓨터 자원에 따라 20분 이상 소요될 수 있다.
docker build -t docker_torchserve .

docker run -d --name docker_torchserve -p 8080:8080 -p 8081:8081 docker_torchserve

# 컨테이너가 정상적으로 동작할 때까지 기다린 후(5~10초) 상태 확인
curl http://localhost:8080/ping
# healthy가 출력되어야 한다.
```

### # 3. 예제파일 실행

```bash
cd ../examples #cd AnimatedDrawings/examples
python image_to_animation.py drawings/garlic.png garlic_out
```
- image_to_animation.py 파일을 이용하여 `AnimatedDrawings/examples/drawings`폴더에 있는 garlic.png를 처리하여 산출물들을 `AnimatedDrawings/examples/garlic_out`에 저장한다.

![](https://velog.velcdn.com/images/deaf52/post/64c26d51-dd72-4342-843d-1ec6323725a1/image.png)
- 위와 같은 산출물들이 나오는데 `video.gif`가 우리가 원하는 애니메이션이고 나머지는 중간과정에서 나오는 산출물들이다. 

- `drawings`폴더에 다양한 형태의 캐릭터들을 집어놓고 폴더도 따로 명시하여 산출물들을 생성해볼 수 있겠다.

- 인풋으로 들어가는 캐릭터 이미지는 주의할 점이 있다.
  1. **기본적으로 사람형태만 인식한다.**
  사족보행 동물들을 많이 테스트해볼텐데 결과가 좋지 않다.
     - 깃허브 readme의 뒷부분에 다른 형태의 골격을 설정하는 가이드가 있고, 후에 작성할 커스터마이징 아티클에도 추가 기술할 예정.
     
  2. **팔다리가 명확히 떨어져 있어야한다.**
  팔다리가 몸통에 붙어있거나 몸통 안쪽에 그려져있어서 구분이 명확치 않은 경우 원하지 않는 결과가 나온다.
     - 단순히 인식자체를 잘 못하는 경우 `fix`기능으로 고칠 수 있다. 이것도 1번의 골격설정기능처럼 후의 게시글에서 다루거나 readme에서 확인하면 된다.
     
 다음 게시글에서는 플라스크를 이용해 `input -> output`이 되는 서버구조를 작성하는 등 자동화를 커스터마이징 해보도록 하자.
 
 [👉다음 게시글 바로가기(작성중)]()
