원본 게시글 https://velog.io/@deaf52/AWS-EC2%EC%84%9C%EB%B2%84%EC%99%80-MobaXterm%EC%97%B0%EA%B2%B0%ED%95%98%EA%B8%B0
DB이중화를 위해 EC2서버를 열어 MySQL 설치까지 버벅거리며 수행했으나
EC2서버 콘솔이 답답하다 느껴져서 기존에 사용해봤던 `MobaXterm`과 연결하여 사용해보려 한다.

**뭐든 새로운 것은 어렵지만 MobaXterm 연결의 경우 pem키만 잘 갖고있다면 전혀 문제 될 것이 없다!**


## 1. EC2서버 생성
- 모든 설정은 프리티어 기본값으로 설정 (또는 최저성능)
- 사용자 인증에 사용할 인증키는 pem으로 생성하였다.

## 2. MobaXterm 설치
> 공식 설치페이지
https://mobaxterm.mobatek.net/download-home-edition.html

위 링크에서 `portable`혹은`installer` 맘에 드는 것으로 설치
필자는 installer로 설치하였는데 portable이 더 가볍지 않을까 생각된다.

## 3. MobaXterm 설정
![](https://velog.velcdn.com/images/deaf52/post/40cf3c14-c3d6-416c-9edd-fce111959770/image.png)
1) `Session` 클릭
2) `SSH` 클릭
3) Remote host에 EC2의 `인스턴스 요약`의 `퍼블릭IP주소` 입력
![](https://velog.velcdn.com/images/deaf52/post/6052cbb3-c509-478e-a040-a9096ff88945/image.png)
 
4) `private key` 체크
5) 문서표시 누르고 EC2서버 생성할 때 발급받았던 `pem파일` 첨부

마지막으로 `log in`을 하라는 메세지가 뜨는데, 서버 종류 별 기본 사용자 이름은 다음과 같다.
> 아마존 docs - 유저가이드
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/managing-users.html
- Amazon Linux 2023, Amazon Linux 2, Amazon Linux AMI : `ec2-user`
- CentOS AMI : `centos` 또는 `ec2-user`
- Debian AMI : `admin`
- Fedora AMI : `fedora` 또는 `ec2-user`
- RHEL AMI : `ec2-user` 또는 `root`
- SUSE AMI : `ec2-user` 또는 `root`
- Ubuntu AMI : `ubuntu`
- Oracle AMI : `ec2-user`
- Bitnami AMI : `bitnami`
