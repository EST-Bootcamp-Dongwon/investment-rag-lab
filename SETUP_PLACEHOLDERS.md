# 직접 입력 칸 목록 (SETUP_PLACEHOLDERS)

> 2026-09-15 작성 · 작업본 `EST-Bootcamp-Dongwon/domain-rag-lab` 전용 문서 (강사님 원본에는 없는 파일)

강사님 원본(`edumgt/domain-rag-lab`)에는 강사님 AWS 계정 ID·도메인·키페어 이름·API 서버 주소가
박혀 있었다. 작업본은 **파일 구조와 코드는 실습 그대로 두고**, 그 값만 내가 채울 **칸**으로 바꿨다.

- 칸 표기: `<AWS_ACCOUNT_ID>` 처럼 꺾쇠 대문자 토큰 (짝 저장소 `aws-ec2-alb-lab` 문서와 같은 방식)
- 칸 가까이에 `[직접 입력]` 주석을 붙였다. 예외가 셋 있다
  - `docker-compose.ecr.yml` — 파일 첫 줄 주석 하나가 `image:` 5곳을 함께 설명한다
  - `frontend/index.html` · `frontend/days/02.html` — 주석이 같은 줄의 `<script>` 안에 있다
  - `README.md` 코드블록 속 칸 2곳 — 원본과 merge 할 때 충돌을 줄이려고 **주석 없이 토큰만** 바꿨다
- **로컬 실행에는 칸을 하나도 채우지 않아도 된다.** 전부 AWS 배포용이다. 로컬 절차는 README 그대로다

```bash
cp .env.local.example .env.local
docker compose --env-file .env.local -f docker-compose.yml up --build -d
```

### 칸 찾기

```bash
# 안내 주석 위치 (README 칸 2곳은 주석이 없어 여기 안 나온다)
git grep -n '\[직접 입력\]'

# 아직 안 채운 칸 — 결과가 0줄이면 배포용 칸을 다 채운 것
# (이 문서와 README 예시는 빼고, 토큰을 예로 든 안내 주석 줄도 뺀다)
git grep -n -E '<(AWS_ACCOUNT_ID|S3_BUCKET_NAME|MY_DOMAIN|MY_WEB_DOMAIN|MY_FRONTEND_DOMAIN|SSH_KEY_FILE)>' \
  -- ':!SETUP_PLACEHOLDERS.md' ':!README.md' | grep -v '직접 입력'
```

> ⚠️ 채운 값 중 **계정 ID·도메인은 커밋해도 되지만, 비밀값(키 본문·비밀번호·액세스 키)은 절대 커밋하지 않는다.**
> 이 저장소는 GitHub·GitLab 모두 Public 이다. 비밀값은 `.env.prod`(gitignore) 나 GitHub Secrets 에 넣는다.

---

## 1. 파일에 직접 채우는 칸

| 토큰 | 파일 | 무엇을 넣나 | 언제 필요한가 |
|------|------|-------------|---------------|
| `<AWS_ACCOUNT_ID>` | `.github/workflows/cd-ecr.yml` (`ECR_REGISTRY`) | 내 AWS 계정 ID 12자리 | ECR 빌드·배포 워크플로를 돌릴 때 |
| `<AWS_ACCOUNT_ID>` | `docker-compose.ecr.yml` (`image:` 5곳) | 위와 같은 값 | EC2 에서 ECR 이미지로 띄울 때 |
| `<MY_DOMAIN>` | `Caddyfile` 1행 · `README.md` Caddy 예시 | Caddy 가 HTTPS 로 공개하는 내 도메인 (예: `rag.example.com`) — FastAPI 가 프론트와 API 를 함께 서빙 | EC2 + Caddy 로 공개할 때 |
| `<S3_BUCKET_NAME>` | `app/main.py` (CORS `allow_origins`) | 프론트를 올린 S3 정적 웹사이트 버킷 이름 | 프론트를 S3 로 분리 배포할 때 |
| `<MY_FRONTEND_DOMAIN>` | `app/main.py` (CORS `allow_origins`) | 프론트를 따로 올린 도메인 (예: `app.example.com`) | 프론트를 다른 도메인으로 분리 배포할 때 |
| `<MY_WEB_DOMAIN>` | `app/main.py` (CORS `allow_origins` http·https 2곳) | API 를 부르는 내 웹사이트 도메인 (예: `www.example.com`) | 다른 웹사이트에서 이 API 를 부를 때 |
| `<SSH_KEY_FILE>` | `.env.prod.example` (`LEAN_SSH_KEY_HOST_PATH`) · `README.md` 운영 배포 bash 블록(`chmod` 줄) | EC2 에 올려 둔 키페어 PEM 파일 이름 (예: `my-key.pem`) | EC2 에서 LEAN 원격 실행기를 쓸 때 |
| `''` (빈 값) | `frontend/index.html` · `frontend/days/02.html` (`window.API_BASE`) | 백엔드를 **프론트와 다른 도메인**에 띄웠을 때만 그 주소 (예: `'https://<MY_DOMAIN>'`) | 비워 두면 같은 출처(로컬 FastAPI)로 호출 — 로컬은 그대로 둔다 |

- 리전은 강사님과 같은 서울(`ap-northeast-2`)로 두었다. 다른 리전을 쓰면 위 주소의 리전 부분도 바꾼다.
- `app/main.py` CORS 는 채우지 않은 칸이 어떤 출처와도 맞지 않을 뿐이라 서버는 정상 기동한다.
  프론트를 FastAPI 가 같은 출처로 서빙하는 구성(로컬 · Caddy)에서는 CORS 칸이 필요 없다.

## 2. 파일 밖(GitHub Secrets)에 넣는 값

워크플로가 이미 `${{ secrets.X }}` 로 참조하고 있어 **파일은 고칠 필요가 없다.**
작업본 저장소 **Settings → Secrets and variables → Actions** 에서 사용자가 직접 등록한다.

| 워크플로 | Secrets |
|----------|---------|
| `cd.yml` (EC2 소스 배포) | `EC2_SSH_PRIVATE_KEY` · `EC2_HOST` · `EC2_USER` · `EC2_APP_DIR` |
| `cd-ecr.yml` (ECR 빌드 → EC2) | `AWS_ACCESS_KEY_ID` · `AWS_SECRET_ACCESS_KEY` · `AWS_REGION` · `EC2_ECR_SSH_PRIVATE_KEY` · `EC2_ECR_HOST` · `EC2_ECR_USER` · `EC2_ECR_APP_DIR` |

두 워크플로는 작업본에서 **push 트리거를 꺼 두었다**(2026-09-14, `workflow_dispatch` 수동 실행만).
자동 배포를 다시 켜려면 Secrets 를 먼저 등록한 뒤 각 파일의 주석 처리된 `push:` 블록을 복원한다.

## 3. 서버의 `.env.prod` 에 넣는 값

`cp .env.prod.example .env.prod` 후 채운다 (`.env.prod` 는 gitignore 대상).

- `POSTGRES_PASSWORD` — `replace-with-a-long-unique-password` 를 긴 고유 비밀번호로
- `LEAN_SSH_KEY_HOST_PATH` — 위 `<SSH_KEY_FILE>` 칸
- `VLLM_BASE_URL` — 별도 LLM 서버를 쓸 때 그 서버 주소
- `VLLM_MODEL` — 그 서버가 서빙하는 모델 이름

## 4. 일부러 그대로 둔 것

실행 설정이 아니라 수업 내용이거나 일반 기본값이라 칸으로 바꾸지 않았다.

| 위치 | 내용 | 둔 이유 |
|------|------|---------|
| `frontend/days/01.html` · `test.md` | `github.com/edumgt/...` 링크 | 원본 저장소 출처 안내 (수업 본문) |
| `frontend/days/03.html` | `st.edumgt.co.kr` 링크 | 강사님 실습 사이트 방문 안내 (수업 본문) |
| `README.md` | `/home/ubuntu/...` 문서 링크 | EC2 기본 경로 — 비밀·계정 정보 아님 |
| `data/samples/*.txt` | 실행 로그 속 PC 호스트명 | RAG 샘플 문서 본문 |
| `.env` · `.env.example` | `POSTGRES_PASSWORD=ragpass` · `host.docker.internal` · `EMPTY` | 로컬 개발 기본값 |
| `.env.local.example` | `POSTGRES_PASSWORD=change-this-local-password` · `host.docker.internal` · `EMPTY` | 로컬 템플릿 기본값 |
| `cloudfront-acm-policy.json` | IAM 정책 (`Resource: "*"`) | 계정 고유값 없음 |

## 5. 이력에 대하여

칸으로 바꾼 값(강사님 계정 ID·도메인·키페어 이름)은 **이 커밋 이전의 이력과 강사님 원본 이력에는 남아 있다.**
원본 자체가 Public 이고 개인키·액세스 키는 없어 이력은 재작성하지 않았다 (2026-09-15 사용자 결정).
