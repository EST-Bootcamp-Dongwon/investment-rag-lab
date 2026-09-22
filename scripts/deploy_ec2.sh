#!/bin/bash
set -e

echo "======================================"
echo " AWS EC2 배포 스크립트 (t3.medium용)"
echo "======================================"

# 1. Swap 메모리 설정 (OOM 방지, 2GB)
if [ ! -f /swapfile ]; then
    echo "=> Swap 메모리 설정 중..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "=> Swap 메모리 설정 완료"
fi

# 2. Docker & Docker Compose 설치
if ! command -v docker &> /dev/null; then
    echo "=> Docker 설치 중..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker ubuntu
    echo "=> Docker 설치 완료 (적용하려면 로그아웃 후 다시 로그인해야 할 수 있습니다)"
fi

# 3. 환경 변수 파일 복사 (없을 경우)
if [ ! -f .env.prod ]; then
    echo "=> .env.prod 파일이 없습니다. .env.prod.example에서 복사하여 생성합니다."
    cp .env.prod.example .env.prod
    echo "======================================================================="
    echo " ⚠️ 주의: 배포를 계속하기 전에 .env.prod 파일을 열어 API 키를 입력하세요! ⚠️"
    echo "======================================================================="
    exit 1
fi

# 4. 서비스 시작
echo "=> 프로덕션 컨테이너 시작 중..."
sudo docker compose -f docker-compose.prod.yml up -d --build

echo "=> 데이터 초기 적재 (필요시 백그라운드 진행)"
sudo docker compose -f docker-compose.prod.yml run --rm curriculum-index || echo "Index job skipped or failed."

echo "======================================"
echo " 배포가 완료되었습니다!"
echo " 웹 브라우저에서 EC2의 Public IP로 접속하세요."
echo "======================================"
