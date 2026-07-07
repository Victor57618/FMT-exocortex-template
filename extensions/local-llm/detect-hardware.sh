#!/usr/bin/env bash
# see ADR-001-local-llm-stack.md (РП404)
# Детект железа Mac → потолок размера локальной LLM. Read-only, без side effects.
# Используется в Ф0 и переиспользуется FMT-установщиком (Ф3) для hardware-aware выбора.
set -euo pipefail

ram_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "unknown")
macos=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
disk_free_gb=$(df -g / | awk 'END {print $4}')   # END устойчивее к переносу строки df

# Ветка модели по RAM (ADR §2)
if [ "$ram_gb" -le 16 ]; then
  tier="one general ~7-8B (on-demand), без второй модели"
elif [ "$ram_gb" -le 32 ]; then
  tier="one general ~7-8B MVP; опц. вторая лёгкая 3-4B для PII"
else
  tier="general 7-8B + лёгкая PII-модель одновременно; запас на 14B+"
fi

echo "chip=$chip"
echo "ram_gb=$ram_gb"
echo "macos=$macos"
echo "disk_free_gb=$disk_free_gb"
echo "model_tier=$tier"
