#!/bin/bash

echo "🚀 Kubernetes Master Node 설정 스크립트 (Ubuntu)"
echo "================================================"

# 1. 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo apt update -y
sudo apt upgrade -y

# 2. 필수 패키지 설치
echo "📦 필수 패키지 설치 중..."
sudo apt install -y curl wget git vim apt-transport-https ca-certificates gnupg lsb-release

# 3. 방화벽 설정
echo "🔥 방화벽 설정 중..."
# Ubuntu는 기본적으로 ufw가 비활성화되어 있음
# 필요한 포트는 AWS 보안 그룹에서 관리

# 4. 스왑 비활성화
echo "💾 스왑 비활성화 중..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 5. 컨테이너 런타임 설치 (containerd)
echo "🐳 containerd 설치 중..."
sudo apt install -y containerd
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
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 9. kubeadm 설치
echo "📦 kubeadm 설치 중..."
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet

# 10. 클러스터 초기화
echo "🚀 클러스터 초기화 중..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# 11. kubeconfig 설정
echo "🔧 kubeconfig 설정 중..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 12. Flannel 네트워크 플러그인 설치
echo "🌐 Flannel 네트워크 플러그인 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# 13. MetalLB 설치
echo "⚖️ MetalLB 설치 중..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# 14. MetalLB 설정
echo "⚙️ MetalLB 설정 중..."
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.0.22.51-10.0.22.60
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF

echo ""
echo "🎉 Kubernetes Master Node 설정 완료!"
echo ""
echo "다음 단계:"
echo "1. 워커 노드에 setup-k8s-worker.sh 실행"
echo "2. 클러스터 상태 확인: kubectl get nodes"
echo "3. 애플리케이션 배포"
