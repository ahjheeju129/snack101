#!/bin/bash

echo "🚀 Kubernetes Worker Node 설정 스크립트"
echo "====================================="

# 1. 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo yum update -y

# 2. 필수 패키지 설치
echo "📦 필수 패키지 설치 중..."
sudo yum install -y curl wget git vim --skip-broken

# 3. 방화벽 설정
echo "🔥 방화벽 설정 중..."
# Amazon Linux는 기본적으로 방화벽이 비활성화되어 있음
# 필요한 포트는 AWS 보안 그룹에서 관리

# 4. 스왑 비활성화
echo "💾 스왑 비활성화 중..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 5. 컨테이너 런타임 설치 (containerd)
echo "🐳 containerd 설치 중..."
sudo yum install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl start containerd
sudo systemctl enable containerd

# 6. 커널 모듈 로드
echo "🔧 커널 모듈 로드 중..."
sudo modprobe overlay
sudo modprobe br_netfilter

# 7. 시스템 파라미터 설정
echo "⚙️ 시스템 파라미터 설정 중..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# 8. Kubernetes 저장소 추가
echo "📦 Kubernetes 저장소 추가 중..."
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

# 9. kubeadm 설치
echo "📦 kubeadm 설치 중..."
sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet

echo ""
echo "🎉 Kubernetes Worker Node 설정 완료!"
echo ""
echo "다음 단계:"
echo "1. 마스터 노드에서 조인 토큰 확인:"
echo "   kubeadm token create --print-join-command"
echo "2. 위 명령어 결과를 이 워커 노드에서 실행"
echo "3. 마스터 노드에서 클러스터 상태 확인: kubectl get nodes"
