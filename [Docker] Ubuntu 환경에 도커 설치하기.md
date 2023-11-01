원본 게시글 : https://velog.io/@deaf52/Docker-Ubuntu-%ED%99%98%EA%B2%BD%EC%97%90-%EB%8F%84%EC%BB%A4-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0

>[👉 도커 홈페이지](https://docs.docker.com/desktop/install/linux-install/)
공식 홈페이지 가이드를 따라 도커를 linux - ubuntu 환경에 설치해보자!

- 많은 공식홈페이지 가이드 중에서도 도커 홈페이지는 깔끔하고 간결했다.
`docker-desktop`을 설치하는데 중간에 `docker engine`을 설치하러 보내서 사알짝 헤매긴 했지만 하나씩 따라하니 잘 설치되고 잘 실행되었다.

- 본 도커 설치 아티클은 `linux`환경에, 그 중에서도 `ubuntu`환경에 설치하는 가이드를 따라하는 아티클이다.

### # 1. 도커 엔진 설치
- remove unofficial packages
```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

- apt repository 추가
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

  -  **❗도커 패키지 설치** 
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- 테스트 런
```
sudo docker run hello-world
```

### # 2. docker-desktop 설치 
>[👉 도커 홈페이지 install/ubuntu](https://docs.docker.com/desktop/install/ubuntu/)

- non-Gnome environment 설치
```
sudo apt install gnome-terminal
```

  - beta버전 제거 및 완전제거
```
sudo apt remove docker-desktop
# complete remove
rm -r $HOME/.docker/desktop
sudo rm /usr/local/bin/com.docker.cli
sudo apt purge docker-desktop
```

  - ❗**DEB 다운로드 및 설치**
```bash
wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.25.0-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64&_gl=1*1yotftr*_ga*NTA0NTMwMjA2LjE2OTgwMjY5MTI.*_ga_XJWPQMJYHQ*MTY5ODc5Nzc4My44LjEuMTY5ODc5ODkyOS4yNS4wLjA.
sudo apt-get update
sudo apt-get install {다운받은 deb파일}
```
  - 실행 확인
```bash
docker compose version
docker --version
docker version
systemctl status docker
```

  - 터미널 실행시 자동 실행
```bash
systemctl --user enable docker-desktop
```

  - docker-desktop 종료
```bash
systemctl --user stop docker-desktop
```

### # 3. Docker 권한 설정
> [👉 도커 홈페이지 _postinstall_](https://docs.docker.com/engine/install/linux-postinstall/)

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```
  - 터미널 재접속 후 권한 부여 됐는지 테스트
```bash
docker run hello-world
```
