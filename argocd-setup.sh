#!/bin/bash

echo "🚀 ArgoCD 설정 스크립트"
echo "========================"

# ArgoCD가 설치되어 있는지 확인
if ! kubectl get namespace argocd > /dev/null 2>&1; then
    echo "❌ ArgoCD가 설치되지 않았습니다."
    echo "다음 명령어로 ArgoCD를 설치하세요:"
    echo "kubectl create namespace argocd"
    echo "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

echo "✅ ArgoCD 네임스페이스 확인 완료"

# ArgoCD 서버가 실행 중인지 확인
echo "ArgoCD 서버 상태 확인 중..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

if [ $? -ne 0 ]; then
    echo "❌ ArgoCD 서버가 준비되지 않았습니다."
    exit 1
fi

echo "✅ ArgoCD 서버 준비 완료"

# ArgoCD Application 배포
echo "ArgoCD Application 배포 중..."
kubectl apply -f argocd/applications/

if [ $? -ne 0 ]; then
    echo "❌ ArgoCD Application 배포 실패"
    exit 1
fi

echo "✅ ArgoCD Application 배포 완료"

# ArgoCD UI 접속 정보
echo ""
echo "🎉 ArgoCD 설정 완료!"
echo ""
echo "ArgoCD UI 접속 방법:"
echo "1. Port-forward로 접속:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   그 후 https://localhost:8080 으로 접속"
echo ""
echo "2. 초기 관리자 비밀번호 확인:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "3. Application 상태 확인:"
echo "   kubectl get applications -n argocd"
echo "   kubectl describe application snack101-staging -n argocd"
echo "   kubectl describe application snack101-production -n argocd"
