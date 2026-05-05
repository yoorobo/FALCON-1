# FALCON-1 시스템 아키텍처 및 설계 보고서

## 1. 개요
이 문서는 `Smart Assistant_UR` 명세서 및 기술 연구 자료(Technology-Research A~L)를 기반으로 작성된 **FALCON-1 현장 양팔 로봇 보조 시스템**의 종합 아키텍처 설계서입니다.

## 2. 하드웨어 (HW) 아키텍처
* **모바일 베이스 (Mobile Base)**
  * **모델**: Vic Pinky (PinkLab Light AMR)
  * **센서**: 2D LiDAR, Depth Camera (RealSense)
  * **역할**: 단층 실내 자율주행, 작업자 시각/LiDAR 기반 추종 (Tucked pose 유지)
* **매니퓰레이터 (Manipulator)**
  * **모델**: OpenArm Bimanual (Enactic, 7+1 DoF × 2)
  * **페이로드**: 최대 4.1kg (AGENTS.md 규정 준수)
  * **역할**: 수납장 도킹 후 공구 Pick & Stow, 작업자 Handover
* **엣지/시뮬레이션 서버 (Edge/Sim Server)**
  * **모델**: NVIDIA RTX 5090 (Blackwell) 기반 서버
  * **역할**: Isaac Sim 기반 디지털 트윈 구축, VLA (Vision-Language-Action) 모델 학습/추론, LLM 기반 임무 계획(Reasoning)
* **인터페이스 & 안전망**
  * PTT(Push-To-Talk) 마이크 (음성 화이트리스트 명령)
  * 하드웨어/무선 E-Stop (PLd 등급)

## 3. 소프트웨어 (SW) 아키텍처
* **OS & 미들웨어 (A. 미들웨어/통신, B. 시간 동기화)**
  * Ubuntu 24.04 LTS / ROS 2 Jazzy / FastDDS
  * 시스템 간 정밀 시간 동기화 적용
* **Perception & HRI (E. Vision, F. Depth 3D, G. HRI-음성)**
  * **Voice Node**: PTT 입력 → STT → 화이트리스트 명령 필터링 → NLP 의도 파악
  * **Vision Node**: 객체/작업자 탐지, AprilTag 기반 수납장 도킹 정렬(오차 ±20mm 이내)
* **Navigation (C. 모바일 SLAM)**
  * Nav2 Stack: 실내 환경 매핑(SLAM), 동적 장애물 회피, 작업자 추종
* **Manipulation (D. 제어, H. Grasp Planning)**
  * MoveIt 2: Bimanual 비동기 협응 제어, 충돌 회피 궤적 생성
  * Grasp Planning: 등록된 공구(3종)에 대한 파지점 추출 및 Handover 자세 계산
* **AI & Learning (I. LLM, J. RL-Imitation-VLA)**
  * ACT / LeRobot 프레임워크를 활용한 모방 학습 기반 조작 제어 보조
* **Safety & Control (L. Safety-Power, K. Sim-CI)**
  * ISO 10218-2 PFL(Power and Force Limiting) 모니터링: 작업자 근접 시 속도 클램프(≤ 0.5m/s), Handover 속도 제한(≤ 250mm/s)
  * 통신 두절(>2초) 및 배터리 저하(<15%) 시 Safe Pose 자동 진입

---
*첨부된 Draw.io 파일(`System_Architecture.drawio.xml`, `Robot_State_Diagram.drawio.xml`)을 통해 시각적 아키텍처와 상태 전이도를 확인하실 수 있습니다.*
