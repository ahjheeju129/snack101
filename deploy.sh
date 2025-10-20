#!/bin/bash

echo "🍿 Snack101 배포 스크립트"
echo "=========================="

# Docker 이미지 빌드
echo "1. Docker 이미지 빌드 중..."
docker build -t snack101:latest .

if [ $? -ne 0 ]; then
    echo "❌ Docker 이미지 빌드 실패"
    exit 1
fi
echo "✅ Docker 이미지 빌드 완료"

# 쿠버네티스에 배포
echo "2. 쿠버네티스에 배포 중..."
kubectl apply -f k8s/all.yaml

if [ $? -ne 0 ]; then
    echo "❌ 쿠버네티스 배포 실패"
    exit 1
fi
echo "✅ 쿠버네티스 배포 완료"

# 배포 상태 확인
echo "3. 배포 상태 확인 중..."
kubectl get pods -n snack101
kubectl get services -n snack101
kubectl get hpa -n snack101

echo ""
echo "🎉 배포 완료!"
echo ""
echo "서비스 접속 방법:"
echo "1. Ingress를 통해 접속: http://snack101.local"
echo "2. Port-forward로 접속: kubectl port-forward -n snack101 service/snack101-service 8080:80"
echo "   그 후 http://localhost:8080 으로 접속"
echo ""
echo "HPA 상태 확인: kubectl get hpa -n snack101"
echo "Pod 상태 확인: kubectl get pods -n snack101"
