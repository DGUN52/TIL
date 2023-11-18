## # ERROR발생!
GITLAB에서 GITHUB로 레포지토리를 복사하던 중 다음과 같은 에러가 발생했다.

```bash
remote: error: Trace: 4ce0f2f3f35bba4f9b5d8cf20e84b205e2d596a45a2dcc07fbfe5804ceae09d4
remote: error: See https://gh.io/lfs for more information.
remote: error: File my-path/apt-download/docker-desktop-4.25.0-amd64.deb is 428.13 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
```

깃허브는 100MB이상의 파일업로드 시 `lfs`를 사용하기를 권장하는데 400MB파일을 올리려니 에러와 함께 푸쉬가 거부당했다.

그런데 왠걸? 해당 파일은 오래전에 지운 상태고 '커밋 히스토리'상에서 날 괴롭히고 있어서 순간 멘붕이 왔다.

찾아보니 lfs는 이미 커밋된 파일에 적용할 수 없기 때문에 다음과 같은 방법이 있다.
**
1. 커밋하기 이전으로 히스토리를 돌려서 lfs를 적용하던가 지우던가 분할하는 조치를 취하는 방법
2. 커밋된 모든 기록을 뒤져서💀 히스토리에서 해당 파일을 삭제하는 것
**

이 글은 2번에 대한 글이다.

## # git filter-branch
```bash
# 1안
git filter-branch -f --tree-filter 'rm -rf my-path/apt-download/docker-desktop-4.25.0-amd64.deb' HEAD
# 2안
git filter-branch -f --index-filter 'git rm --cached --ignore unmatch my-path/apt-download/docker-desktop-4.25.0-amd64.deb' HEAD
```
`filter-branch`는 히스토리를 직접 조작하는 명령어이다. 
git의 정체성에 어긋나는, 일반적으로 권장되지 않는 방법이다.
돌이킬 수 없는 변경사항을 적용할 수 있기 때문에 작업 전에 저장소를 복사해두는 것이 권장된다.

### # 명령어 설명
- `-f` : 변경사항을 강제로 적용한다. 필자의 경우 여러번 조작하여서 백업을 덮어써야하는 상황이 생겨서 적용하였는데 제거해도 사용에 무리가 없을 듯 하다.
- `--tree-filter` : tree-filter는 작업 시 작업 디렉토리에 체크아웃하고 작업하기 때문에 속도가 느릴 수 있으나 모든파일에 반영 가능하다.
- `--index-filter` : index-filter는 커밋에 대해 인덱스만 조작하고 직접 체크아웃하지는 않는다. tree-filter보다 빠를 수 있지만 변경사항을 포착하지 않을 수 있다.
- 이후 홑따옴표 안의 명령어 : 원하는 파일을 삭제하는 쉘 명령어이다. 설명 생략.

## # repository 복사 성공!
해당 명령어를 적용 후 (시간을 꽤 소요한다.) 정상적으로 `Github`에 레포를 복사할 수 있었다.
이런 번거로움은 전적으로 설치파일을 깃에 커밋한 나의 잘못..
덕분에 새로운 지식은 하나 늘었다 ^^...!
