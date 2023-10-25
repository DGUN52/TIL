## # 서론
- 하나의 깃에 토이프로젝트를 완료한 뒤 사후에 커밋히스토리 즉 잔디🌿까지 다 옮겨오고자 한다.
- `folk`로 진행하면 커밋 히스토리까지 가져오진 않기때문에 내 기록을 보존하고싶다면 `clone`으로 진행한다.
- `clone --mirror`과 `clone --bare`방법이 있는데, 구문상 차이가 있지만 동일한 기능을 한다.


### # clone 수행
```bash
git clone --mirror [old repository].git
cd [old repository].git
```
- 복사할 저장소를 `clone`하면 현재경로에 해당 레포 이름으로 `.git`폴더가 생긴다.
![](https://velog.velcdn.com/images/deaf52/post/d9fe6734-9063-46cb-93d3-32f364076edc/image.png)


```bash
git remote set-url --push origin [new repository].git
git push --mirror
```
- cd명령어로 해당 폴더로 이동한 다음 저장할 레포지토리로 remote를 설정해주고 `push --mirror`한다.

- 당연히 저장할 레포지토리는 직접 파주고 깃주소를 복사해서 넣어준다.

### # `bare`명령어로 진행하는 경우도 흐름이 똑같다.
```bash
git clone [old repository].git
cd [old repository].git
git push --mirror [new repository].git
```


### # 뒷처리

```bash
cd ..
rm -rf [old repository].git
```
- 먼저 클로닝하면서 로컬에 생긴 git폴더를 제거한다.
- 모든 히스토리를 가져오기 때문에 기본 브랜치default branch가 바뀔 수도 있고, 정리되지 않은 작업 브랜치들도 그대로 남아있다. 필요하지 않은 경우 삭제한다.

  [👉 기본 브랜치 변경하기]()
  [👉 브랜치 삭제하기]()
