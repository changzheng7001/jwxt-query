#!/usr/bin/env bash
# 把 jwxt-webapp/ 的网页源同步到两份打包工程。
# 网页源是唯一可信来源；apk-source/assets 与 cicp-jwxt-android/app/src/main/assets
# 下的同名文件都是生成物，不入库，每次打包前跑这个脚本重新生成。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/jwxt-webapp"
TARGETS=(
  "$ROOT/apk-source/assets"
  "$ROOT/cicp-jwxt-android/app/src/main/assets"
)

need() { [ -e "$1" ] || { echo "缺少源文件：$1" >&2; exit 1; }; }
need "$SRC/index.html"
need "$SRC/jwxt-mobile.html"
need "$SRC/js"
need "$SRC/ui"
need "$SRC/schedule-assets"

for T in "${TARGETS[@]}"; do
  mkdir -p "$T/js" "$T/ui" "$T/schedule-assets"

  cp "$SRC/index.html" "$T/index.html"
  cp "$SRC/jwxt-mobile.html" "$T/jwxt-mobile.html"

  rm -f "$T"/js/*.js
  cp "$SRC"/js/*.js "$T/js/"

  rm -f "$T"/ui/*.js "$T"/ui/*.css
  cp "$SRC"/ui/*.js "$SRC"/ui/*.css "$T/ui/"

  # schedule-assets 整目录镜像，避免留下旧素材
  rm -f "$T"/schedule-assets/*
  cp "$SRC"/schedule-assets/* "$T/schedule-assets/"

  echo "已同步 → ${T#$ROOT/}"
done

echo "完成：网页源已复制到两份打包工程（这些副本不入库，改动只需改 jwxt-webapp/）"
