# ArmPose.msg
# OpenArm 단일 팔의 포즈 표현 (tucked_pose, handover_pose 등)

string arm_side         # "left" | "right"
string pose_name        # "tucked" | "handover" | "pick_ready" | "stow_ready"
geometry_msgs/Pose end_effector_pose  # EEF 카르테시안 포즈
float64[] joint_positions             # 관절 각도 배열 (7+1 DoF)
bool gripper_open       # 그리퍼 개방 여부
