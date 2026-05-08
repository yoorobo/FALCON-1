# FALCON-1

**Team:** Nerd Labs

FALCON-1 is a robotic system integration project combining an autonomous mobile platform (Vic Pinky) with a dual-arm manipulator (OpenArm) for pick-and-place operations. The project is orchestrated through an AI Agent Harness that governs simulation gating, safety constraints, and task execution across both systems.

---

## Hardware

### Vic Pinky — Autonomous Mobile Platform

| Spec | Value |
|---|---|
| Drive type | Differential drive |
| Chassis | 600 × 500 × 128 mm, 50.0 kg |
| Wheel radius | 82.5 mm |
| Wheel separation | 428.8 mm |
| Casters | 4 (front ×2, rear ×2) |
| LiDAR | RPLIDAR C1 |
| Camera | xacro-defined, modular |

- 2-wheel differential drive + 4 fixed-corner casters
- LiDAR mounted at `x=0.185m, z=0.12m` from `base_link`

### OpenArm — Dual-Arm Manipulator

| Spec | Value |
|---|---|
| Structure | Humanoid arm (MiSUMi aluminium frame) |
| Nominal payload | **4.1 kg** (at max extension, 1 min hold) |
| Peak payload | 6.0 kg (worst-case pose, 3 s move + 1 s hold) |
| Mounting | M6 tapped holes for table fixture |
| Safety | Built-in mechanical limit mechanism |

> **Note:** Payload includes the end-effector weight. A 1.5 kg gripper leaves 2.6 kg of usable payload at nominal rating.

---

## Software Stack

| Layer | Component |
|---|---|
| OS | Ubuntu 24.04 |
| Middleware | ROS 2 Jazzy |
| Build system | colcon |
| Simulation | Gazebo / Isaac Sim |
| SLAM | slam_toolbox |
| Navigation | Navigation2 (nav2_bringup) |
| ML compute | Slurm-managed GPU server |
| AI Orchestration | Claude Code + Codex cross-check harness |

### Workspace Layout (Vic Pinky)

```
vicpinky_ws/
└── src/
    └── vic_pinky/
        ├── vicpinky_bringup/       # Robot & Gazebo launch
        ├── vicpinky_description/   # URDF / xacro / meshes
        ├── vicpinky_navigation/    # SLAM & Nav2 launch
        └── vicpinky_gazebo/        # Sim-only (removed on hardware deploy)
```

---

## My Role — AI Agent Harness Orchestration

I own the **AI Agent Harness** layer of FALCON-1. Responsibilities:

- **Task planning** — decompose high-level goals into robot-executable subtasks
- **Simulation gating** — enforce the rule that no hardware is touched until Gazebo and Isaac Sim both pass
- **Safety enforcement** — guard the 4.1 kg payload constraint and other operational limits
- **Documentation discipline** — maintain `docs/exec-plans/` as the single source of truth for every plan before execution
- **Cross-system coordination** — sequence Vic Pinky navigation and OpenArm pick-and-place so they compose safely
- **Cross-check workflow** — use Claude Code and Codex as separate review paths before merge

---

## Harness Architecture

```
┌─────────────────────────────────────────────────┐
│                  AI Agent Harness               │
│ (Claude Code + Codex, AGENTS/CLAUDE.md rules)  │
└────────────┬──────────────────────┬─────────────┘
             │                      │
   ┌─────────▼──────────┐  ┌───────▼────────────┐
   │   Simulation Gate  │  │   Safety Checker   │
   │  Gazebo / Isaac    │  │  payload ≤ 4.1 kg  │
   │  Sim must PASS     │  │  sim must PASS     │
   └─────────┬──────────┘  └───────┬────────────┘
             │                      │
   ┌─────────▼──────────────────────▼────────────┐
   │               Hardware Layer                 │
   │                                              │
   │  ┌──────────────┐       ┌─────────────────┐ │
   │  │  Vic Pinky   │       │    OpenArm      │ │
   │  │  (Nav2/SLAM) │       │  (pick & place) │ │
   │  └──────────────┘       └─────────────────┘ │
   └──────────────────────────────────────────────┘
```

### Operational Rules

1. **Simulation first** — Gazebo simulation must pass before any hardware run. Same requirement applies to Isaac Sim.
2. **Payload hard limit** — OpenArm must never exceed 4.1 kg nominal payload (including end-effector weight).
3. **Plan before execute** — Every task begins with a written plan in `docs/exec-plans/` before code or hardware is touched.
4. **No mocking / hardcoding** — All implementations must reflect real system behavior.

### GitHub-Centric Workflow

FALCON-1 is managed with **GitHub as the source of truth** and Notion as the human-readable operations log.

- GitHub stores task state, code changes, review history, and durable documentation.
- Notion stores daily summaries, meeting notes, and decision context with links back to GitHub.
- Every meaningful task should connect `Issue -> Branch -> PR -> Notion log`.

See [docs/OPERATIONS.md](docs/OPERATIONS.md) for the standard workflow.

---

## Reference Repositories

| Repo | Purpose |
|---|---|
| [pinklab-art/vic_pinky](https://github.com/pinklab-art/vic_pinky) | Vic Pinky — URDF, Nav2, SLAM, Gazebo launch |
| [yoorobo/ShopPinkki](https://github.com/yoorobo/ShopPinkki) | ROS 2 reference — mobile robot base |
| [yoorobo/Hand-Gesture-Recognition-](https://github.com/yoorobo/Hand-Gesture-Recognition-) | Deep learning reference — gesture input |
| [docs.openarm.dev](https://docs.openarm.dev/hardware/) | OpenArm official hardware documentation |

---

## Documentation

```
docs/
├── OPERATIONS.md     # GitHub/Notion operating model
├── design-docs/      # Architecture and system design documents
├── product-specs/    # Hardware and product specification sheets
├── references/       # External references and collected specs
└── exec-plans/       # Dated execution plans (written before every task)
```
