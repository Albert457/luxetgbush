#!/data/data/com.termux/files/usr/bin/bash
set -e

bash <(curl -s https://raw.githubusercontent.com/Superdetectiv4ik/tg-ws-proxy-android/main/install.sh)

touch "$HOME/.bashrc"
sed -i '/^alias tgws=/d' "$HOME/.bashrc"

cat >> "$HOME/.bashrc" <<'EOF'
alias tgws='CONFIG="$HOME/TgWsProxy/config.json"; pkill -f "python android.py" 2>/dev/null || true; command -v fuser >/dev/null && { fuser -k 1080/tcp 2>/dev/null || true; fuser -k 1081/tcp 2>/dev/null || true; }; sed -Ei '\''s/("port":[[:space:]]*)[0-9]+/\11080/'\'' "$CONFIG"; clear; printf '\''termux-wake-lock\ncd tg-ws-proxy-android\npython android.py\n\n'\''; termux-wake-lock; cd ~/tg-ws-proxy-android && python android.py'
EOF

bash -ic 'source ~/.bashrc; tgws'
