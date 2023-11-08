- 원본글 : https://velog.io/write?id=8a9209bf-c48a-4440-923f-accd1c86b8fc
## # 파이썬 버전과 모듈은 뗄 수 없는 관계
> 💥파이썬은 버전에 굉장히 민감하여 설치에 주의가 요구된다!

이 말은 파이썬을 만져본 분들에겐 굉장히 익숙한 말일텐데, 관련지식이 전무한 사람에겐 _**"그렇구나, 왠진 모르겠지만 오케 알아둬야겠다."**_😊 라고 넘어갈 수 밖에 없다.
실제로 고이고이 설치했던 모듈들이 다 날아간게 파이썬 환경이 달라져서란걸 겪어보기 전까지는 알 수 없기 때문..

어쨌건 이유는 단순명료하다.
- **모든 모듈은 파이썬환경에 종속되어 설치되기 때문!**

이걸 다르게 말하면
- **모듈은 파이썬 설치폴더의 lib폴더 안에 설치되기 때문이다!!**

`pip install module`라는 같은 명령어로 모듈을 설치해도, 현재 실행되고 있는 파이썬 폴더의 하위폴더에 저장되기 때문에 **아나콘다 설치, python 버전 변경 등** 모종의 이유로 설치환경이 바뀌게 된다면 모듈은 초기화된다.
이러한 이유로 가상환경사용이 필수에 가깝게 권장되고, `pip install`시에도 가상환경을 사용하지 않는다면 ⚠️warning⚠️이 계속 발생할 것이다.

![](https://velog.velcdn.com/images/deaf52/post/d0cfccdc-249e-416c-a546-35cac53b60be/image.png)
위 그림은 명령어의 동작을 이해하지 못하고 모듈만 설치하고자 할 때 겪을 수 있는 상황이다.
MINICONDA 설치 시점이나 환경변수의 세팅시점에 따라서
- 모듈이 일부만 설치될 수도,
- 분명히 설치화면이 떴는데 아무것도 없을 수도
- 잘 되고 잘 썼는데 하루 뒤에 켜보니 싹 사라져있다거나

하는, 초보자로선 황당무계한 상황이 발생할 수도 있다.

본 글은 이러한 지식이 있었음에도 `도커+miniconda` 빌드를 하면서 겪은 상황에 대한 글이라 서론은 여기까지만.

넘어가기 전에 서론에 대한 대책을 한마디로 제시하면,
> 파이썬 가상환경을 무조건 ❗**처음부터**❗사용하라!


## # _"아니 저 콘다 깔았는데요?"_
conda에서 제공하는 라이브러리가 필요한 도커를 실행할 때 다음과 같은 `Dockerfile`을 구성했다.
```bash
# 1.도커이미지 설정
FROM python:3.8-slim

# 2.conda설치 - miniconda 공식 홈페이지 제공 코드
RUN mkdir -p ~/miniconda3
RUN apt-get install -y wget
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm -rf ~/miniconda3/miniconda.sh
RUN ~/miniconda3/bin/conda init bash
RUN ~/miniconda3/bin/conda init zsh

# 3.필요한 라이브러리 설치
pip install ~
pip install ~
pip install ~
```
1. 필요한 python버전인 3.8을 명시하고, 
2. conda를 설치하고, 
3. 라이브러리들을 설치했다.

근데 왠걸, 막상 실행된 도커를 살펴보니 `python`버전은 3.11이고 설치로그도 다 확인한 모듈들은 감쪽같이 사라져있었다.

이유를 간략히 말하자면, conda를 설치하면 `python 3.11`로 변경되지만, 빌드중에는 환경변수등 실행환경이 완전히 바뀌지 않기 때문에 모듈들은 `python3.8`에 설치되고, 실제 docker는 `miniconda(python3.11)`로 실행된다. 빌드 중 `pip`로 설치한 모듈들은 폴더를 뒤집어봐야만 알 수 있다.

### # 올바른 방법
은 다음과 같다.
```bash
FROM continuumio/miniconda3:latest

#conda설치 필요 없음. 파이썬 환경설정
conda install python==3.8.13

#필요한 라이브러리 설치
pip install ~
pip install ~
pip install ~
```
- miniconda가 제공되는 이미지를 사용하고
- 바로 필요한 python버전으로 환경설정하는 것

**미니콘다를 제공하는 도커 이미지가 있다**라는 지식이 없었으니 직접 개고생을 하는 수 밖에..😭

혹은 첫번째 방법에서 conda 명령어, 가상환경 경로를 직접 지정해주는 방법이 있다.
```bash
FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# Install Dependencies of Miniconda
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate my_env" >> ~/.bashrc
    
RUN /bin/bash -c "source activate my_env && pip install torch" 

CMD [ "/bin/bash" ]
#출처 - https://bluecolorsky.tistory.com/94
```
보시다시피 굉장히 번거로운 방법이다.
파이썬 이미지를 꼭 써야하는 이유가 있는 것이 아니라면 anaconda내지 miniconda를 이용해야하는 도커에는 해당 환경이 이미 설치된 이미지를 이용하는 것을 추천한다.

이상 도커와 파이썬 지식이 부족해 고생한 기록을 공유해보았다.
