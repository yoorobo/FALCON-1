# ToolStatus.msg
# 수납장 슬롯 내 공구 상태 (UR_C04, UR_C05 기반)

string tool_id          # 등록 공구 ID (예: "wrench_01")
string slot_id          # 수납 슬롯 ID (예: "slot_A1")
bool is_registered      # 등록 여부
bool slot_occupied      # 슬롯 점유 여부
bool is_damaged         # 파손/오염 여부
builtin_interfaces/Time last_updated  # 마지막 갱신 시각
