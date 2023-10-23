- 참고 : https://github.com/facebookresearch/AnimatedDrawings

## # 서론
- 페이스북(메타) 레포에 배포된 `Image → Animation` 을 간편하게 해주는 라이브러리이다. 

- 올해 2월에 Initial Commit된 따끈따끈한 레포지토리이다.

- 참고할 레퍼런스가 적은데 기본 readme가 상세히 작성돼있어서 시간을 좀 들이면 문제없이 적용할 수 있을 것으로 생각된다.


## # 기본사용법
- python과 miniconda/anaconda가 설치 됐다고 가정.
  - 파이썬 버전은 ReadMe에서 제시하는 대로 `3.8.13`을 맞추는 것을 추천
  - cmd창에서 실행이 안될 경우 <u>환경변수</u> 설정 및 [별칭 제거](https://velog.io/@deaf52/python-CMD%EC%B0%BD%EC%97%90-python-%EC%9E%85%EB%A0%A5-%EC%8B%9C-microsoft-store-%EC%97%B4%EB%A6%AC%EB%8A%94-%EB%AC%B8%EC%A0%9C) 필요

- 다른 랩탑을 사용하면서 miniconda 설치 없이 사용해봤는데 번거롭다.
초보자라면 그냥 miniconda를 이용하자.
  
### 1. AnimatedDrawings 라이브러리 설치

- 원하는 디렉토리에 `git clone`, 가상환경 설정

```bash
git clone https://github.com/facebookresearch/AnimatedDrawings.git
cd AnimatedDrawings
pip install -e .
```

- 가상환경 설정 및 실행

1) conda 미설치 경우
```bash
python.exe -m pip install --upgrade pip
python -m venv AnimatedDrawings
Scripts\activate.bat
```
2) conda 설치한 경우
```bash
conda create --name animated_drawings python=3.8.13
conda activate animated_drawings
```

### 2. example 렌더링

- 필요 라이브러리 없을 시 설치
```bash
pip install glfw scikit-learn shapely scikit-image pyopengl opencv-python numpy pillow pyyaml 
```
- 파이썬 실행 후 렌더링 시작
```bash
python
from animated_drawings import render
render.start('./examples/config/mvc/interactive_window_example.yaml')
```
- 정상적으로 구동됐다면 새 창이 뜨면서 춤을 추는 애니메이션이 실행

- 라이브러리를 직접 사용하고자 한다면 `config`파일들은 훑고 넘어가는게 도움이 될 것

## # Animated Drawings 실행 구조
- 자세한건 해당 라이브러리 깃의 ReadMe를 참조
> https://github.com/facebookresearch/AnimatedDrawings

---

## # 자동화 구조
>https://github.com/facebookresearch/AnimatedDrawings#animating-your-own-drawing

- 이미지를 input하면 애니메이션을 output해주는 기능을 플라스크 서버 형태로 제공해주는데, 요구성능이 괴랄한지 컴파일시간이 상당하다.
  - 도커나 리눅스구조를 공부하는 사람이 아닌 이상 **메모리가 16GB도 안되는 랩탑은 일찌감치 포기**하는 것이 여러모로 좋을 듯
  
  - (라이브러리들을 찬찬히 보면 opencv, opengl, numpy, mmcv, mmdet같은 머신러닝 라이브러리 천국이다.)

- **Docker가 설치되고 실행중이어야함**

### ## 1. 도커 컨테이너 빌드

```bash
(animated_drawings) AnimatedDrawings % cd torchserve
(animated_drawings) torchserve % docker build -t docker_torchserve .
```

> ⚠️여기서부턴 리눅스 비전문가가 우당탕탕 억지로 돌리는 내용⚠️이라  참고만 하기 바란다.
참고하지 않거나 정상수행된다면 <a href="#2">여기</a>로 스킵

- 이대로 실행하면 다음과 같은 에러가 💐한다발💐 발생할 것이다.

  - mmcv-full 설치단계에서 에러가 발생한다.
  
```bash
20.37           4 | #error C++17 or later compatible compiler is required to use ATen.
20.37          27 | #error You need C++17 to compile PyTorch
 ```

- mmcv 라이브러리를 설치할 때 C++17 버전을 사용하라는데, 구글링을 해보면 다음과 같은 해결책이 나온다.

####  ~~방안1) 다음 두 라인을 `c++14`에서 `c++17`로 수정한다.~~

> [setup.py 라인1](https://github.com/open-mmlab/mmcv/blob/d28aa8a9cced3158e724585d5e6839947ca5c449/setup.py#L204)
[setup.py 라인2](https://github.com/open-mmlab/mmcv/blob/d28aa8a9cced3158e724585d5e6839947ㅁca5c449/setup.py#L421)
[ref: github issue](https://github.com/open-mmlab/mmcv/issues/2860#issuecomment-1622170278)

- `docker build` 명령어로 `setup.py`를 관리하는데 도커 이미지가 생성되기 전에 실패해서 이 setup.py에 어떻게 접근해야하는지 모르겠어서 pass.

- 리눅스와 패키지에 대한 지식이 있어야 할 것 같은데 리눅스 스킬이 부족한 글쓴이는 몇시간을 쏟아부었지만 실패. 

  - repository를 clone후 설치하는 방식은 버전지정이 불가능해보였다.
  - 실제론 여러 방안이 있을 듯 한데 혹 아시는 분이 있다면 .. 📞
  
  
#### ~~방안2) cuda라는 라이브러리를 사용해서 같이 사용한다.~~

- 글쓴이의 랩탑은 intel 내장gpu라 해당사항 없음.
- _gluda_라는 intel gpu용 _cuda_ 대용 라이브러리가 있긴 하다.
  
  
#### 🪶방안3) Dockerfile에서 mvcc-full 설치버전을 수정한다.🪶

**1. `설치경로\AnimatedDrawings\torchserve\Dockerfile` 수정
**
**2. 해당 파일을 text뷰어로 열고 다음 라인 수정 `RUN mim install mmcv-full==1.7.0`
**
**3. 해당 라인에서 버전을 `1.7.0 → 1.3.17`로 변경하면 정상 설치됨.
**    - 초기 빌드 시 갤럭시북3 프로에서 10분 정도 소요됐다.
  
**4. 도커에 이미지를 실행하기 전 권고사항대로 RAM을 16GB로 배정한다.
**
> [.wslconfig으로 도커 스펙 조절하기](https://velog.io/@deaf52/wsl-.wslconfig%EC%9C%BC%EB%A1%9C-%EB%8F%84%EC%BB%A4-%EC%8A%A4%ED%8E%99-%EA%B4%80%EB%A6%AC%ED%95%98%EA%B8%B0)
  
**5. 도커 이미지를 실행한다.
**
```bash
docker run -d --name docker_torchserve -p 8080:8080 -p 8081:8081 docker_torchserve
```
  
  - 그럼 다음과 같이 `docker_torchserve`라는 이름의 도커 컨테이너가 생긴것을 설치한 docker 앱에서 확인할 수 있다.
  
  ![](https://velog.velcdn.com/images/deaf52/post/927b6b24-4d72-4d76-a0c0-890d4528c61b/image.png)
  
  - 컨테이너의 로그를 열어보면 에러는 뜨지 않는다.
  
  - 이제 `1.3.17`로 낮춰서 설치했던 `mmcv-full` 라이브러리를 `1.7.0`버전으로 업그레이드 해보자.
  
**6. 실행된 도커 컨테이너의 Terminal(exec)에서 `python --version`을 실행하면 `3.11.5`라 뜨는데, ReadMe에서 권고하는 `3.8.13`으로 다운그레이드하고 mmcv-full==1.7.0으로 업그레이드 한다.
**  
- (그렇지 않으면 miniconda에서 발생한 c++14대신 c++17을 쓰라는 에러가 똑같이 발생한다.)
    
- 다운그레이드 하기 전에 먼저 현재 pip에 설치된 모듈들을 복사해둔다.

```bash
pip list
```

- 복사 후 파이썬 버전을 다운그레이드하고 좀 무식하지만 이전에 설치돼있던 모듈들을 다시 설치한다. `ts`를 설치하지 않으면 중간에 도커가 정지될 시 재실행 할 수 없다.
```bash
conda install python=3.8.13
pip install ts
```

- 글쓴이의 모듈 목록은 다음과 같다. 한번에 설치하려하면 오류가 나기 때문에 적당히 끊어서 설치하고, 선후관계가 있을 수 있기 때문에 두세번 반복한다.
```bash
pip install aliyun-python-sdk-core aliyun-python-sdk-kms boltons brotlipy certifi cffi charset-normalizer chumpy click colorama conda conda-content-trust conda-libmamba-solver conda-package-handling conda_package_streaming contourpy crcmod cryptography cycler Cython filelock fonttools fsspec idna importlib-metadata Jinja2 jmespath json-tricks jsonpatch jsonpointer kiwisolver libmambapy Markdown markdown-it-py MarkupSafe matplotlib mdurl mmcv-full==1.7.0 mmdet mmpose model-index mpmath munkres networkx numpy nvidia-cublas-cu12 nvidia-cuda-cupti-cu12 nvidia-cuda-nvrtc-cu12 nvidia-cuda-runtime-cu12 nvidia-cudnn-cu12 nvidia-cufft-cu12 nvidia-curand-cu12 nvidia-cusolver-cu12 nvidia-cusparse-cu12 nvidia-nccl-cu12 nvidia-nvjitlink-cu12 nvidia-nvtx-cu12 opencv-python opendatalab openmim openxlab ordered-set oss2 packaging pandas Pillow pip platformdirs pluggy psutil pycocotools pycosat pycparser pycryptodome Pygments pyOpenSSL pyparsing PySocks python-dateutil pytz PyYAML requests rich ruamel.yaml scipy setuptools six sympy tabulate terminaltables tomli toolz torch torchserve torchvision tqdm triton typing_extensions tzdata urllib3 wheel xtcocotools yapf zipp zstandard1
```

- 이렇게 `mmcv`버전을 `1.7.0`으로 업그레이드 하였다.
- 로그나 실행에 에러는 발생하지 않지만 `curl`을 이용한 핑요청에도 잠시 응답하다가 요청을 받지 않기 시작한다. 이미지 렌더링 요청도 당연히 응답하지 않는다.
  - 도커의 exec(구 terminal) 내에서 mmcv버전을 1.7.0으로 업그레이드 해주어도 마찬가지.
    
### ## 2. 설치완료 시 테스트 수행 <link name="#2">⛓️</link>
