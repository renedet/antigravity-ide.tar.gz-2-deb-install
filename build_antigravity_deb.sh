#!/bin/bash

# Configurações
DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.0.4-6381998290370560/linux-x64/Antigravity%20IDE.tar.gz"
TARBALL="Antigravity IDE.tar.gz"
PKG_NAME="antigravity-ide"
VERSION="2.0.3"

echo "📦 Iniciando a criação do pacote .deb nativo para o Antigravity IDE..."

# Solicita informações do mantenedor com valores padrão
read -p "Digite seu nome completo [Rene Dettenborn]: " maintainer_name
read -p "Digite seu email [renedet@gmail.com]: " maintainer_email

# Usa valores padrão se o usuário não digitar nada
maintainer_name=${maintainer_name:-"Rene Dettenborn"}
maintainer_email=${maintainer_email:-"renedet@gmail.com"}
MAINTAINER="$maintainer_name <$maintainer_email>"

# Verifica se o arquivo com espaço realmente existe antes de continuar
if [ ! -f "$TARBALL" ]; then
    echo "ℹ️ O arquivo '$TARBALL' não foi encontrado. Tentando fazer o download..."
    wget -O "$TARBALL" "$DOWNLOAD_URL"
    if [ $? -ne 0 ]; then
        echo "❌ Erro: Falha ao baixar o arquivo de '$DOWNLOAD_URL'."
        exit 1
    fi
fi

# 1. Cria estrutura temporária de compilação seguindo o padrão Debian
BUILD_DIR=$(mktemp -d -t  antigravity-deb-XXXXXX)
DEBIAN_DIR="$BUILD_DIR/DEBIAN"
mkdir -p "$DEBIAN_DIR"
mkdir -p "$BUILD_DIR/opt/antigravity-ide"
mkdir -p "$BUILD_DIR/usr/share/applications"

echo "📂 Extraindo os binários do tarball..."
tar -xzf "$TARBALL" -C "$BUILD_DIR/opt/antigravity-ide" --strip-components=1

# 2. Configura o atalho .desktop do sistema
cat <<EOF > "$BUILD_DIR/usr/share/applications/antigravity-ide.desktop"
[Desktop Entry]
Name=Antigravity IDE
Comment=Google Antigravity AI-First Code Editor
Exec=/opt/antigravity-ide/antigravity-ide %U
Terminal=false
Type=Application
Icon=/opt/antigravity-ide/resources/app/resources/linux/code.png
Categories=Development;IDE;TextEditor;
StartupNotify=true
EOF

# 3. Gera o arquivo de controle estruturado do Debian
cat <<EOF > "$DEBIAN_DIR/control"
Package: $PKG_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: $MAINTAINER
Depends: libnss3, libatk1.0-0, libatk-bridge2.0-0, libcups2, libdrm2, libgtk-3-0, libgbm1, libasound2
Description: Google Antigravity IDE
 Google Antigravity AI-First Code Editor packaged cleanly from tarball.
EOF

# 4. Cria os scripts de pós-instalação nativos
cat <<EOF > "$DEBIAN_DIR/postinst"
#!/bin/bash
set -e
chown root:root /opt/antigravity-ide/chrome-sandbox
chmod 4755 /opt/antigravity-ide/chrome-sandbox
ln -sf /opt/antigravity-ide/antigravity-ide /usr/local/bin/antigravity-ide
EOF
chmod 755 "$DEBIAN_DIR/postinst"

# 5. Cria o script de pós-remoção nativo
cat <<EOF > "$DEBIAN_DIR/postrm"
#!/bin/bash
set -e
rm -f /usr/local/bin/antigravity-ide
EOF
chmod 755 "$DEBIAN_DIR/postrm"

echo "🛠️ Construindo o pacote .deb usando dpkg-deb..."
OUTPUT_NAME="${PKG_NAME}_${VERSION}_amd64.deb"
dpkg-deb --build "$BUILD_DIR" "$OUTPUT_NAME"

# Limpeza da pasta temporária
rm -rf
