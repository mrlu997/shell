#!/bin/bash
set -euo pipefail

### 配置 ###
BACKUP_DIR="/root/data/docker_data/typecho"
WORK_DIR="/root/backup"
LOG_FILE="/root/backup/backup.log"

TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:?未设置 Telegram Token}"
TELEGRAM_CHAT_ID="5669"

MAX_SIZE=$((50 * 1024 * 1024))   # 50MB
SPLIT_SIZE="40M"

### 函数 ###
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

send_msg() {
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    -d text="$1" >/dev/null
}

send_file() {
  local file="$1"

  result=$(curl -s -F chat_id="$TELEGRAM_CHAT_ID" \
    -F document=@"$file" \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument")

  [[ $(echo "$result" | jq -r '.ok') == "true" ]]
}

### 前置检查 ###
command -v jq >/dev/null || { echo "jq 未安装"; exit 1; }
[ -d "$BACKUP_DIR" ] || { log "备份目录不存在"; exit 1; }
mkdir -p "$WORK_DIR"

### 开始备份 ###
DATE=$(date +%Y%m%d)
BACKUP_NAME="Osaka_${DATE}.tar.gz"
BACKUP_PATH="${WORK_DIR}/${BACKUP_NAME}"

log "开始备份 $BACKUP_DIR"

tar -czf "$BACKUP_PATH" "$BACKUP_DIR"
log "压缩完成：$BACKUP_NAME"

### 判断文件大小 ###
FILE_SIZE=$(stat -c %s "$BACKUP_PATH")
log "备份文件大小：${FILE_SIZE} bytes"

if (( FILE_SIZE <= MAX_SIZE )); then
  ### 小于 50MB，直接上传 ###
  log "文件小于 50MB，直接上传"

  if send_file "$BACKUP_PATH"; then
    send_msg "✅ Osaka 备份完成（未分割）：$BACKUP_NAME"
    log "上传成功：$BACKUP_NAME"
  else
    send_msg "❌ 备份上传失败：$BACKUP_NAME"
    log "上传失败：$BACKUP_NAME"
    exit 1
  fi

else
  ### 大于 50MB，分割上传 ###
  log "文件大于 50MB，开始分割"

  split -b "$SPLIT_SIZE" "$BACKUP_PATH" "$BACKUP_PATH.part"

  for part in "$BACKUP_PATH".part*; do
    log "上传分片：$(basename "$part")"

    if ! send_file "$part"; then
      send_msg "❌ 备份分片上传失败：$(basename "$part")"
      log "分片上传失败：$(basename "$part")"
      exit 1
    fi
  done

  send_msg "✅ Osaka 备份完成（已分割）：$BACKUP_NAME"
  log "分割备份上传完成"
fi

### 清理 ###
rm -f "$BACKUP_PATH" "$BACKUP_PATH".part* 2>/dev/null
log "临时文件已清理"
