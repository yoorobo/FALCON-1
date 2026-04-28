# Vic Pinky 레퍼런스

> 출처: https://github.com/pinklab-art/vic_pinky  
> 제작: PinkLab Art (maintainer: mkh@pinklab.art)

---

## 1. 주요 하드웨어 스펙

| 항목 | 값 |
|---|---|
| 로봇 타입 | 차동 구동 (Differential Drive) |
| 섀시 크기 | 600 × 500 × 128 mm (L × W × H) |
| 섀시 질량 | 50.0 kg |
| 휠 반지름 | 82.5 mm |
| 휠 두께 | 50 mm |
| 휠 간격 (wheel_separation) | 428.8 mm |
| 캐스터 수 | 4개 (전방 2, 후방 2) |
| 캐스터 반지름 | chassis_z_offset / 2 = 43.5 mm |
| 라이다 마운트 위치 | base_link 기준 x=0.185m, z=0.12m |
| 라이다 센서 | RPLIDAR C1 |

### 구동계 구성
- **2-휠 차동 구동** + **4-캐스터** (코너 고정식)
- 왼쪽 휠: base_link → `y = +0.2144m`
- 오른쪽 휠: base_link → `y = -0.2144m`

---

## 2. 센서 구성

| 센서 | 모델 | 비고 |
|---|---|---|
| 2D LiDAR | RPLIDAR C1 | `/dev/rplidar` (udev alias), frame: `laser_link` |
| 카메라 | (URDF 정의됨, 별도 xacro) | `camera.xacro` |

### LiDAR 설정 포인트
- udev rules 파일: `doc/99-vic-pinky.rules` → `/etc/udev/rules.d/` 복사 필요
- sllidar_ros2 패키지 별도 클론 필요: `https://github.com/Slamtec/sllidar_ros2`
- launch 파일에서 `serial_port` → `/dev/rplidar`, `frame_id` → `laser_link` 로 수정 필수

---

## 3. 소프트웨어 스택

| 항목 | 버전/내용 |
|---|---|
| OS | Ubuntu 24.04 |
| ROS2 | **Jazzy** |
| 빌드 시스템 | colcon |
| 시뮬레이터 | Gazebo |
| SLAM | slam_toolbox |
| 네비게이션 | Navigation2 (nav2_bringup) |
| 직렬 통신 | pyserial |
| 기타 의존성 | tf_transformations, laser_filters |

### 워크스페이스 구조
```
vicpinky_ws/
└── src/
    └── vic_pinky/
        ├── vicpinky_bringup/       # 실제 로봇 / Gazebo 기동 launch
        ├── vicpinky_description/   # URDF/xacro, mesh
        ├── vicpinky_navigation/    # SLAM, Nav2 launch
        └── vicpinky_gazebo/        # 시뮬레이션 전용 (로봇 탑재 시 삭제)
```

---

## 4. ROS2 관련 정보

### 주요 Launch 명령

| 목적 | 명령 |
|---|---|
| 로봇 기동 | `ros2 launch vicpinky_bringup bringup.launch.xml` |
| Gazebo 기동 | `ros2 launch vicpinky_bringup gazebo_bringup.launch.xml` |
| 멀티 로봇 스폰 | `ros2 launch vicpinky_bringup gazebo_multi_spwan.launch.xml namespace:=robot2 x:=12.0 y:=-16.0` |
| SLAM (맵 생성) | `ros2 launch vicpinky_navigation map_building.launch.xml` |
| SLAM (시뮬) | `ros2 launch vicpinky_navigation map_building.launch.xml use_sim_time:=true` |
| 맵 저장 | `ros2 run nav2_map_server map_saver_cli -f <map_name>` |
| Nav2 기동 | `ros2 launch vicpinky_navigation bringup_launch.xml map:=<map_name>` |
| 키보드 제어 | `ros2 run teleop_twist_keyboard teleop_twist_keyboard` |

### 주요 토픽
- `/scan` — LiDAR 스캔 데이터 (RPLIDAR C1)
- `cmd_vel` — 구동 명령 (차동 구동)

### TF 프레임 구조
```
base_footprint
  └── base_link
        ├── left_wheel
        ├── right_wheel
        ├── front_left_caster / front_right_caster
        ├── rear_left_caster  / rear_right_caster
        └── lidar_mount
              └── laser_link
```

### 멀티 로봇 지원
- `namespace` 파라미터로 다중 로봇 운용 가능
- Gazebo에서 `gazebo_multi_spwan.launch.xml`로 위치 지정 스폰

---

## 5. FALCON-1 프로젝트 연관 포인트

### 참고 가능한 아키텍처
1. **차동 구동 + 캐스터 구조** — FALCON-1 모바일 베이스 설계 참고 가능
   - wheel_separation, wheel_radius, caster 배치 수치 직접 활용 검토
2. **ROS2 Jazzy 기반** — FALCON-1 동일 환경 타겟 시 호환성 확인됨
3. **SLAM + Nav2 파이프라인** — `slam_toolbox` → 맵 저장 → `Navigation2` 흐름 그대로 채용 가능
4. **멀티 로봇 네임스페이스 패턴** — FALCON-1 다중 에이전트 운용 시 namespace 분리 방식 참고
5. **udev rules 관리** — 시리얼 디바이스 안정적 식별 패턴 (`/dev/rplidar` alias) 동일하게 적용 권장
6. **URDF xacro 모듈화** — `robot_core`, `camera`, `lidar`, `gazebo_control` 분리 구조 → FALCON-1 URDF 설계 시 동일 패턴 채용 권장
7. **Gazebo 시뮬 분리** — 로봇 탑재 시 `vicpinky_gazebo/` 패키지 제거하는 방식 → FALCON-1 배포 환경 구성 시 참고
