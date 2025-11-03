# CI - GitHub Container Registry

## 설명
본 `repo`는 `GitHub Container Registry`에 컨테이너 이미지를 등록해야 하는 서비스 (예: 애플리케이션) 의 `CI`를 위해 작성된 코드 저장소입니다.\
컨테이너 이미지 저장이 아닌, `maven`저장소에 배포 및 의존성 추가로 사용되는 서비스 (예: 유틸리티) 라면, 
<a href="https://github.com/cho-hm/ci-mvn">해당 저장소</a>의 코드를 사용해주세요.

## 프로젝트 포함하기
본 `ci` 프로젝트는 `submodule`<sup>(1)</sup>로 사용하거나, `source code`<sup>(2)</sup>를 직접 다운로드(혹은 복사)하여 사용할 수 있습니다. (`fork` 여부는 자유입니다.)\
> 해당 `repo`는 `ci`소스코드 및 설정 파일의 _저장소_ 역할만 수행합니다.
> 실제 `ci`의 수행은 본 코드를 자신의 애플리케이션에 포함해야만 동작합니다.

### `submodule` 사용시
해당 프로젝트를 포함할 애플리케이션의 루트로 이동한 후 터미널에서 다음 명령을 수행합니다.
> [WARN] 아직 커밋할 수 없는 기존 변경사항이 있다면 해결한 후 수행해야 합니다.  

> 본 소스코드가 포함된 첫 커밋은 `ci`에 포함되지 않습니다.
```bash
git switch ${YOUR_MAIN_BRANCH} # 필요하다면
git submodule add ${https://github.com/cho-hm/ci-ghcr 또는 자신의 fork repo url}
bash ./ci-ghcr/init.sh
git add .github
git commit -m '${COMMIT_MESSAGE}'
git push ${YOUR_REMOTE} ${YOUR_REMOTE_MAIN_BRANCH}
```
#### 리모트 `ci`프로젝트에 변경사항이 생긴 경우
리모트에 `ci`프로젝트에 변경사항이 생긴 경우, 다음 명령을 통해 `submodule`을 `update`이후, `/ci-ghcr/init.sh`를 실행시킵니다.
```bash
git submodule update --remote ci-to-ghcr && bash ./ci-to-ghcr/init.sh
```

### `source code` 다운로드시
해당 프로젝트의 소스코드를 다운받아 내용 전체를 프로젝트 루트의 `ci-ghcr`라는 디렉토리를 생성하여 옮깁니다.
이후 프로젝트 루트에서 다음 명령을 실행합니다.
```bash
bash ./ci-ghcr/init.sh
```
원하는 시점에 새로 추가된 `ci-ghcr/` 와 `.github/`를 포함한 `commit` 및 `push`할 수 있습니다.
> 본 소스코드가 포함된 첫 커밋은 `ci`에 포함되지 않습니다.

#### 리모트 `ci`프로젝트에 변경사항이 생긴 경우
앞선 과정을 새로하는것 처럼 다시 처음부터 반복합니다.

> [info] `submodule`과 소스코드 직접 설치 방식 모두 디렉토리 명을 원하는 대로 설정할 수 있습니다. > 다만, 이 경우 `init.sh`실행 명령의 디렉토리 경로는 자신이 설정한 디렉토리로 작성해야 합니다.

## 구조 및 설정
### 구조
```
./
├── .github/
│   ├── Dockerfile
│   └── workflows/
│       ├── ci-ghcr-builder.yml
│       ├── ci-ghcr-checker.yml
│       ├── ci-ghcr-orchestrator.yml
│       ├── run-ghrc.yml
│       └── scripts/
│           ├── env/
│           │   ├── combine.sh
│           │   └── literal.sh
│           ├── main/
│           │   └── index.sh
│           ├── parser/
│           │   ├── property-parser.sh
│           │   └── set-default.sh
│           ├── runner/
│           │   ├── branch.sh
│           │   ├── signed-tag.sh
│           │   └── tag.sh
│           ├── util/
│           │   └── gpg-key-provider.sh
│           └── valid/
│               ├── valid-first-commit.sh
│               └── validate.sh
├── .gitignore
├── LICENSE
├── README.md
├── ci-ghcr.properties
└── init.sh
```

해당 프로젝트의 기본 구조는 위와 같습니다.
#### 파일 설명
##### `run-ghrc.yml`
`run-ghrc.yml`파일은 전체 프로세스의 `entry point`역할을 하는 `github action workflow`파일입니다.
해당 파일은 `ci-ghcr-orchestrator.yml`을 호출합니다.

해당 파일은 유일한 비 재사용 워크플로입니다.

##### `ci-ghcr-orchestrator.yml`
`ci-ghcr-orchestrator.yml`파일은 `/.github/workflows/scripts/parser/property-parser.sh`를 호출하여 `ci-ghcr.properties`에 명시한 속성 및 필요한 기타 환경변수를 설정합니다.\
이후 `ci-ghcr-checker`와 `ci-ghcr-builder`를 상태에 따라 필요한 환경변수와 함께 호출합니다.

##### `ci-ghcr-checker.yml`
`ci-ghcr-checker.yml`파일은 `ci`를 트리거 시킨 `commit`이 사용자가 설정한 상태와 일치하는지 확인합니다. `signed-tag`인 경우 `gpg token`을 통해 서명의 유효성도 검사합니다.\
모든 상태가 일치하여 유효한 `commit`이라고 판단되면 `CONTINUE`를 `true`로 설정하고 종료합니다.

##### `ci-ghcr-builder.yml`
`ci-ghcr-builder.yml`파일은 `ci-ghcr-checker`가 설정한 `CONTINUE`상태가 `true`인 경우 `ci-ghcr-orchestrator.yml`에 의해 호출됩니다.\
`ci-ghcr.properties`에 명시된 빌드 설정에 따라 프로젝트를 빌드하고 이미지를 배포합니다.

### 설정
애플리케이션 프로젝트 루트에 `ci-ghcr.properties` 파일을 만들어 `ci` 트리거 동작을 선택할 수 있습니다.

#### `ci-ghcr-properties`의 모든 기본값
```properties
# commit type
trigger.type=signed-tag
trigger.branch=

# build options
docker.file.path=./.github/Dockerfile
build.command=./gradlew clean test bootJar --no-daemon --refresh-dependencies -i
image.platform=linux/amd64,linux/arm64
image.name.suffix=trigger-type:tag:branch:sha:short-sha:latest

# gpg
gpg.repo.url=
gpg.repo.gpg.path=keys/gpg
gpg.repo.asc.path=keys/asc
gpg.repo.branch=master
```

#### `ci-ghcr-properties` 속성 설명
##### `commit type`
- `trigger.type`: `ci`를 트리거 시킬 커밋 유형을 설정합니다.
  - 옵션:
    - `signed-tag` (default)
      - ___서명된 태그___ 인 경우 트리거 됩니다.
    - `tag`
      - ___`lightweight tag`___ 인 경우 트리거 됩니다.
    - `branch`
      - `trigger.branch`에 설정된 브랜치 중 하나인 경우 트리거 됩니다.
- `trigger.branch`: `trigger.type=branch`인 경우 트리거 시킬 브랜치를 설정합니다.
  - 옵션:
    - 원하는 브랜치 명을 `:`구분자로 구분해 작성합니다.
    - 예시:
      - `master`
        - `master`브랜치 인 경우만 트리거 합니다.
      - `deploy:stage:master`
        - `deploy`, `stage`, `master`중 하나의 브랜치라면 트리거 됩니다.
    - 주의
      - 해당 브랜치는 원격지에 `push`될 브랜치 기준입니다. 로컬에서 `push`를 수행한 브랜치는 알 수 없습니다.
      
##### `build options`
- `build.command`: 실제 이미지 배포 수행을 위한 빌더 커맨드를 설정합니다.
    - 옵션:
        - 이미지 빌드에 필요한 커맨드를 작성합니다.
- `docker.file.path`: `build`에 사용할 `Dockerfile`의 위치를 설정합니다. 기본으로 제공된 `Dockerfile`과 다른 옵션이 필요한 경우 직접 생성한 `Dockerfile`의 경로를 작성합니다.
  - 옵션:
    - `Dockerfile`의 경로를 절대경로 혹은 프로젝트 루트 기준 상대경로로 작성합니다.
- `build.command`: 프로젝트 빌드시 실행할 빌드 옵션을 작성합니다.
  - 옵션:
    - 프로젝트 빌드에 필요한 명령을 작성합니다.
  - 주의
    - 해당 옵션의 기본값은 `gradle`, `Spring Boot`기준으로 작성되어 있습니다. 환경이 다르다면 꼭 해당 옵션을 명시해야 합니다. (기본값 참고)
- `image.platform`: 이미지의 빌드 플랫폼을 작성합니다.
  - 옵션:
    - 이미지의 빌드 플랫폼을 `:`구분자로 구분해 작성합니다.
  - 예시:
    - `linux/amd64`
    - `linux/amd64:linux/arm64`
- `image.name.suffix`: 빌드 이미지에 사용할 태그 종류를 선택합니다.
  - 옵션: 다음중 원하는 옵션을 `:`구분자로 구분해 작성합니다.
    - `trigger-type`
      - 해당 커밋의 트리거 타입을 태그에 추가합니다.
    - `tag`
      - 해당 커밋의 `tag`를 태그에 추가합니다.
        - `trigger-type`이 `signed-tag`또는 `tag`인 경우에만 유효합니다.
    - `branch`
      - 해당 커밋의 `branch`를 태그에 추가합니다.
        - `trigger-type`이 `branch`인 경우에만 유효합니다.
    - `sha`
      - 해당 커밋의 전체 `sha`를 태그에 추가합니다.
    - `short-sha`
      - 해당 커밋의 짧은 `sha`를 태그에 추가합니다. (`sha-${sha의 앞 7자리}`)
    - `latest`
      - `latest`를 태그에 추가합니다.

##### `gpg`
> `signed-tag`에 사용할 서명 유효성 검증을 위한 `gpg` 공개키에 대한 설정입니다.
> 서명 유효성 검증이 필요하다면 `gpg`공개키를 포함한 `repository`가 필요합니다.
- `gpg.repo.url`: `gpg` 공개키가 포함된 `repository`의 `url`
  - 옵션
    - `gpg` 공개키가 포함된 `repository`의 `url`을 설정합니다.
  - 주의
    - 해당 `repository`가 `public repository` 라면 별도의 설정이 필요하지 않습니다.
    - 해당 `repository`가 `private repository` 라면 자신의 `repository`에 `GPG_TOKEN`이라는 이름의 읽기 권한이 있는 토큰을 등록해야 합니다. 자세한 설명은 <a href="https://docs.github.com/ko/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets">공식 문서</a>를 참고하세요.
- `gpg.repo.gpg.path`: `gpg` 공개키 `repository`의 `.gpg`파일이 저장된 디렉토리의 경로를 작성합니다.
  - 옵션:
    - `gpg` 공개키 `repository`의 `.gpg`파일이 저장된 `repository root`기준 최종 디렉토리 경로를 작성합니다.
- `gpg.repo.asc.path`: `gpg` 공개키 `repository`의 `.asc`파일이 저장된 디렉토리의 경로를 작성합니다.
  - 옵션:
    - `gpg` 공개키 `repository`의 `.asc`파일이 저장된 `repository root`기준 최종 디렉토리 경로를 작성합니다.
- `gpg.repo.branch`: `gpg` 공개키 `repository`의 기준 브랜치를 작성합니다.
  - 옵션:
    - `gpg` 공개키 `repository`의 기준 브랜치를 작성합니다.


### 그 외
#### `Dockerfile`
`Dockerfile`은 `GHCR`로 배포하기 위한 이미지를 생성할 때 사용되는 컨테이너에 대한 정의를 기재합니다.
기본적으로는 8080포트를 `expose`하며, `${PROJECT_ROOT}/build/libs/*.jar` 를 기준으로 빌드합니다.
자신의 프로젝트 환경과 맞지 않다면 원하는 경로에 `Dockerfile`을 작성하고, 
`ci-ghcr.properties`파일에 `docker.file.path=${value}`형식으로 작성할 수 있습니다.

#### `ci-ghcr.properties`
`ci-ghcr.properties` 파일은 해당 `repository`에 포함되지 않습니다. 기본값 외 직접 설정해야 할 값이 존재한다면, ___프로젝트 루트___ 에 `ci-ghcr.properties` 파일을 생성하여 작성합니다.

### 주의사항
#### `.github` 디렉토리
`.github`디렉토리는 각 프로젝트마다 별도로 관리되는 디렉토리입니다. 따라서 얼마든지 변경하더라도, `ci project`의 `repo`로 커밋되지 않습니다.
하지만, `ci-ghcr`프로젝트의 `init.sh` 즉, `bash ./ci-ghcr/init.sh` 명령을 수행하는 경우 `.github`파일의 내용을 덮어씁니다.
파일 내용이 서로 다른경우 기존 파일을 제거하지는 않지만, ___파일 이름이 동일하면서 `ci-ghcr`파일의 내용과 내부가 다른 경우___, 해당 파일은 _`ci-ghcr`에 존재하는 파일로 덮어씁니다._
#### `ci-ghcr` 디렉토리
`ci-ghcr`디렉토리 내부의 내용을 변경할 경우, `ci project`의 `repo`와 연관된 정보를 수정하게 됩니다.
`ci-ghcr`프로젝트에 대한 수정사항이 필요하지 않다면 `ci-ghcr`디렉토리 내의 파일을 수정하지 않아야 합니다.


또한, `ci-ghcr` 디렉토리는 자신의 프로젝트의 `commit`에 포함하지 않아도 됩니다. 하지만 생성 또는 수정된 `.github`디렉토리는 `commit`에 포함되어야 합니다.
> 모든 `ci`의 기준은 `.github` 디렉토리를 기준으로 수행되며, `ci-ghcr`디렉토리는 `.github` 디렉토리를 위한 _로컬 원본 저장소_ 역할입니다.

## License
This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.