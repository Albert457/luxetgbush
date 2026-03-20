#!/data/data/com.termux/files/usr/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

step() {
  clear
  printf '\033[1;31m[%s/7] %s\033[0m\n' "$1" "$2"
}

step 1 "Обновляю пакеты..."
apt-get update
yes '' | apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  upgrade

step 2 "Ставлю системные зависимости..."
yes '' | apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  install git python rust clang pkg-config openssl

step 3 "Ставлю Python-пакеты из Termux..."
yes '' | apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  install python-cryptography python-psutil python-pillow

step 4 "Обновляю pip..."
python -m pip install --upgrade pip setuptools wheel

step 5 "Клонирую проект..."
rm -rf "$HOME/tg-ws-proxy-android"
git clone https://github.com/Superdetectiv4ik/tg-ws-proxy-android.git "$HOME/tg-ws-proxy-android"

step 6 "Патчу проект и ставлю websockets..."
cd "$HOME/tg-ws-proxy-android"
sed -i 's/149\.154\.165\.111/149.154.166.111/' "$HOME/tg-ws-proxy-android/proxy/tg_ws_proxy.py"
python -m pip install --upgrade websockets==16.0

step 7 "Настраиваю конфиг и команду tgws..."
mkdir -p "$HOME/TgWsProxy"
cat > "$HOME/TgWsProxy/config.json" <<'EOF'
{
  "port": 1080,
  "host": "127.0.0.1",
  "dc_ip": [
    "1:149.154.175.50",
    "2:149.154.167.220",
    "3:149.154.175.100",
    "4:149.154.167.91",
    "5:91.108.56.130"
  ],
  "verbose": true
}
EOF

mkdir -p "$HOME/bin"
cat > "$HOME/bin/tgws" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e

CONFIG="$HOME/TgWsProxy/config.json"
REPO="$HOME/tg-ws-proxy-android"

mkdir -p "$HOME/TgWsProxy"

cat > "$CONFIG" <<'EOC'
{
  "port": 1080,
  "host": "127.0.0.1",
  "dc_ip": [
    "1:149.154.175.50",
    "2:149.154.167.220",
    "3:149.154.175.100",
    "4:149.154.167.91",
    "5:91.108.56.130"
  ],
  "verbose": true
}
EOC

sed -i 's/149\.154\.165\.111/149.154.166.111/' ~/tg-ws-proxy-android/proxy/tg_ws_proxy.py

pkill -f "python android.py" 2>/dev/null || true

clear
printf 'termux-wake-lock\ncd tg-ws-proxy-android\npython android.py\n\n'

termux-wake-lock || true
cd "$REPO"
python android.py
EOF

chmod +x "$HOME/bin/tgws"

touch "$HOME/.bashrc"
grep -qxF 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" || printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.bashrc"

clear
printf '\033[1;31mГотово.\033[0m\n'
printf 'Следующие запуски: tgws\n\n'

tgws
