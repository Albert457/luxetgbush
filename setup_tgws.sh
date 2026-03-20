#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[1/6] Обновляю пакеты..."
pkg update -y && pkg upgrade -y

echo "[2/6] Ставлю зависимости..."
pkg install -y git python rust clang pkg-config openssl libffi psmisc

echo "[3/6] Обновляю pip..."
python -m pip install --upgrade pip setuptools wheel

echo "[4/6] Клонирую проект..."
rm -rf "$HOME/tg-ws-proxy-android"
git clone https://github.com/Superdetectiv4ik/tg-ws-proxy-android.git "$HOME/tg-ws-proxy-android"

echo "[5/6] Ставлю Python-зависимости..."
cd "$HOME/tg-ws-proxy-android"
python -m pip install websockets==16.0 cryptography psutil pillow

echo "[6/6] Настраиваю конфиг и команду tgws..."
mkdir -p "$HOME/TgWsProxy"
cat > "$HOME/TgWsProxy/config.json" <<'EOF'
{
  "port": 1080,
  "host": "127.0.0.1",
  "dc_ip": ["2:149.154.167.51"],
  "verbose": true
}
EOF

mkdir -p "$HOME/bin"
cat > "$HOME/bin/tgws" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

CONFIG="$HOME/TgWsProxy/config.json"

mkdir -p "$HOME/TgWsProxy"

cat > "$CONFIG" <<'EOC'
{
  "port": 1080,
  "host": "127.0.0.1",
  "dc_ip": ["2:149.154.167.51"],
  "verbose": true
}
EOC

pkill -f "python android.py" 2>/dev/null || true

command -v fuser >/dev/null && {
  fuser -k 1080/tcp 2>/dev/null || true
  fuser -k 1081/tcp 2>/dev/null || true
}

clear
printf 'termux-wake-lock\ncd tg-ws-proxy-android\npython android.py\n\n'

termux-wake-lock
cd "$HOME/tg-ws-proxy-android" && python android.py
EOF

chmod +x "$HOME/bin/tgws"

grep -qxF 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" || echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"

echo
echo "Готово."
echo "Следующие запуски: tgws"
echo

"$HOME/bin/tgws"