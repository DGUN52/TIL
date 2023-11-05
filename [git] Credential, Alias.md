### Git Credential

```bash
# 타이핑 후 아이디/비밀번호 입력 시 다음 번부터 입력하지 않아도 됨
# `시작 > 자격 증명 관리자`에서 수정/삭제 가능
git config --global credential.helper wincred 
# wincred 안될 시 store로 수정. store는 보안상 위험 있으므로 사용 비권장
```

### Git Alias

```bash
# alias를 추가하여 자주 사용하는 명령어를 짧은 명령으로 수행 가능
# 루트폴더의 .gitconfig을 직접 수정하는 방식도 가능

# checkout 변경 예시
git config --global alias.co checkout

# log 보기좋게 변경
git config --global alias.l "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset\' --abbrev-commit"

# 게릿 푸쉬 간소화
git config --global alias.gerritpush "git push gerrit HEAD:refs/for/deploy/Animate-Service"

#사용법
git co {branch명}
git l
git gerritpush
```
ref: [👉깃 로그 튜닝 출처](https://johngrib.github.io/wiki/git-alias/)
