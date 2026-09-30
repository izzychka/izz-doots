#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if ! command -v python3 >/dev/null; then
    echo 'Python is needed to unpack the rice. Run: sudo pacman -S python'
    exit 1
fi
exec python3 installer/install.py "$@"
