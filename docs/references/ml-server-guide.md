# ML 서버 가이드

## 서버 정보

| 항목 | 내용 |
|---|---|
| 서버 IP | `14.36.11.47` |
| 내 계정 | `ml4` (이건희) |
| 관리자 | `nls` |
| GPU | 1개 (Slurm으로 공유) |
| 디스크 | 915 GB (`/srv/ml/`) |

---

## 접속

```bash
ssh ml4@14.36.11.47
```

---

## GPU 사용 규칙

> **로그인 셸에서 직접 GPU 작업 절대 금지**

모든 GPU 작업은 반드시 Slurm을 통해 실행한다.

```bash
# 인터랙티브 작업
srun --gpus=1 python train.py

# 배치 작업
sbatch job.sh
```

---

## 주요 Slurm 명령어

| 명령어 | 용도 |
|---|---|
| `srun` | 인터랙티브 작업 실행 |
| `sbatch` | 배치 작업 제출 |
| `squeue` | 작업 큐 확인 |
| `scancel <job_id>` | 작업 취소 |
| `sinfo` | 노드/파티션 상태 확인 |

---

## Python 환경

- `venv` 또는 `uv` 사용
- **시스템 pip 직접 설치 금지**

```bash
# venv
python3 -m venv .venv
source .venv/bin/activate

# uv
uv venv
source .venv/bin/activate
uv pip install <package>
```

---

## Docker GPU

NVIDIA Container Toolkit이 설치되어 있어 Docker에서 GPU 사용 가능하다.

```bash
docker run --gpus all ...
```
