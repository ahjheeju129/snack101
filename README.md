# 🍿 Snack101 - 과자 리뷰 서비스

간단한 과자 리뷰 서비스로, 별점과 한줄평을 입력할 수 있는 웹 애플리케이션입니다.

## 🚀 기능

- 과자 이름, 별점(1-5점), 한줄평 입력
- 리뷰 목록 조회
- 반응형 웹 디자인
- 쿠버네티스 자동 스케일링 (HPA)

## 🏗️ 아키텍처

- **백엔드**: FastAPI (Python)
- **데이터베이스**: SQLite
- **프론트엔드**: HTML/CSS/JavaScript
- **컨테이너**: Docker
- **오케스트레이션**: Kubernetes
- **스케일링**: HPA (Horizontal Pod Autoscaler)
- **CI/CD**: GitHub Actions + ArgoCD
- **GitOps**: Kustomize + ArgoCD

## 📁 프로젝트 구조

```
snack101/
├── app.py                 # FastAPI 백엔드 서버
├── requirements.txt       # Python 의존성
├── Dockerfile            # Docker 이미지 설정
├── static/               # 프론트엔드 파일
│   ├── index.html
│   ├── style.css
│   └── script.js
├── k8s/                  # 쿠버네티스 매니페스트
│   ├── base/             # 기본 매니페스트
│   ├── overlays/         # 환경별 설정
│   │   ├── staging/      # 스테이징 환경
│   │   └── production/   # 프로덕션 환경
│   └── kustomization.yaml
├── argocd/               # ArgoCD 설정
│   ├── applications/     # ArgoCD Applications
│   └── app-of-apps.yaml
├── .github/workflows/    # GitHub Actions CI/CD
│   └── ci-cd.yaml
├── deploy.sh             # 수동 배포 스크립트
├── argocd-setup.sh      # ArgoCD 설정 스크립트
└── README.md
```

## 🛠️ 로컬 개발

### 1. 의존성 설치
```bash
pip install -r requirements.txt
```

### 2. 서버 실행
```bash
python app.py
```

### 3. 접속
http://localhost:8000

## 🐳 Docker 실행

### 1. 이미지 빌드
```bash
docker build -t snack101:latest .
```

### 2. 컨테이너 실행
```bash
docker run -p 8000:8000 snack101:latest
```

## 🔄 CI/CD 파이프라인

### GitHub Actions CI/CD
- **자동 테스트**: 코드 품질 검사, 린팅
- **Docker 이미지 빌드**: GitHub Container Registry에 푸시
- **환경별 배포**: develop → staging, main → production
- **ArgoCD 연동**: GitOps 방식으로 자동 배포

### ArgoCD GitOps
- **자동 동기화**: Git 저장소 변경사항 자동 감지
- **환경별 관리**: staging/production 환경 분리
- **롤백 지원**: 이전 버전으로 쉽게 롤백
- **헬스 모니터링**: 애플리케이션 상태 실시간 모니터링

### 배포 플로우
1. **개발**: `develop` 브랜치에 코드 푸시
2. **CI**: GitHub Actions가 테스트 실행 및 Docker 이미지 빌드
3. **Staging**: ArgoCD가 자동으로 staging 환경에 배포
4. **Production**: `main` 브랜치 머지 시 production 환경에 배포

## ☸️ 쿠버네티스 배포

### 1. 자동 배포
```bash
./deploy.sh
```

### 2. 수동 배포
```bash
# 네임스페이스 생성
kubectl apply -f k8s/namespace.yaml

# ConfigMap 생성
kubectl apply -f k8s/configmap.yaml

# Deployment 생성
kubectl apply -f k8s/deployment.yaml

# Service 생성
kubectl apply -f k8s/service.yaml

# Ingress 생성
kubectl apply -f k8s/ingress.yaml

# HPA 생성
kubectl apply -f k8s/hpa.yaml
```

### 3. ArgoCD 설정 (GitOps)

#### ArgoCD 설치
```bash
# ArgoCD 설치
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

#### ArgoCD Application 배포
```bash
# ArgoCD Application 배포
./argocd-setup.sh
```

#### ArgoCD UI 접속
```bash
# Port-forward로 ArgoCD UI 접속
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 초기 관리자 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### 4. 서비스 접속

#### Port-forward 사용
```bash
kubectl port-forward -n snack101 service/snack101-service 8080:80
```
그 후 http://localhost:8080 으로 접속

#### Ingress 사용
```bash
# /etc/hosts 파일에 추가
127.0.0.1 snack101.local
```
그 후 http://snack101.local 으로 접속

## 📊 모니터링

### HPA 상태 확인
```bash
kubectl get hpa -n snack101
```

### Pod 상태 확인
```bash
kubectl get pods -n snack101
```

### 서비스 상태 확인
```bash
kubectl get services -n snack101
```

### 로그 확인
```bash
kubectl logs -n snack101 deployment/snack101-app
```

### ArgoCD Application 상태 확인
```bash
# 모든 Application 상태 확인
kubectl get applications -n argocd

# 특정 Application 상세 정보
kubectl describe application snack101-staging -n argocd
kubectl describe application snack101-production -n argocd

# Application 동기화 상태
kubectl get application snack101-staging -n argocd -o jsonpath='{.status.sync.status}'
kubectl get application snack101-production -n argocd -o jsonpath='{.status.sync.status}'
```

## 🔧 HPA 설정

- **최소 레플리카**: 2개
- **최대 레플리카**: 10개
- **CPU 임계값**: 70%
- **메모리 임계값**: 80%

## 🧪 테스트

### API 테스트
```bash
# 헬스체크
curl http://localhost:8000/health

# 리뷰 등록
curl -X POST http://localhost:8000/reviews/ \
  -H "Content-Type: application/json" \
  -d '{"snack_name": "새우깡", "rating": 4.5, "review": "바삭하고 맛있어요!"}'

# 리뷰 조회
curl http://localhost:8000/reviews/
```

## 🚨 문제 해결

### Pod가 시작되지 않는 경우
```bash
kubectl describe pod -n snack101 <pod-name>
kubectl logs -n snack101 <pod-name>
```

### HPA가 작동하지 않는 경우
```bash
kubectl describe hpa -n snack101 snack101-hpa
```

### 서비스 접속이 안 되는 경우
```bash
kubectl get endpoints -n snack101
kubectl describe service -n snack101 snack101-service
```

## 📝 라이선스

MIT License
