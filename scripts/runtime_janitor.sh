#!/usr/bin/env sh
set -eu

INTERVAL_SEC="${CLEANUP_INTERVAL_SEC:-1800}"
IMAGE_MAX_AGE_HOURS="${CLEANUP_IMAGE_MAX_AGE_HOURS:-12}"
LOG_MAX_AGE_DAYS="${CLEANUP_LOG_MAX_AGE_DAYS:-7}"
JSONL_MAX_AGE_DAYS="${CLEANUP_JSONL_MAX_AGE_DAYS:-14}"
CLEAN_JSONL="${CLEANUP_JSONL_ENABLED:-false}"

IMAGES_DIR="${IMAGES_DIR:-/app/images}"
LOGS_DIR="${LOGS_DIR:-/app/logs}"
JSONL_DIR="${JSONL_DIR:-/app/jsonl}"

now() {
  date '+%Y-%m-%d %H:%M:%S'
}

cleanup_once() {
  echo "[$(now)] janitor: start cleanup"

  if [ -d "$IMAGES_DIR" ]; then
    find "$IMAGES_DIR" -mindepth 1 -maxdepth 1 -type d -name 'task_images_*' -mmin "+$((IMAGE_MAX_AGE_HOURS * 60))" -print -exec rm -rf {} + || true
    find "$IMAGES_DIR" -type d -empty -print -delete || true
  fi

  if [ -d "$LOGS_DIR" ]; then
    find "$LOGS_DIR" -type f \( -name '*.log' -o -name '*.txt' \) -mtime "+$LOG_MAX_AGE_DAYS" -print -delete || true
  fi

  if [ "$CLEAN_JSONL" = "true" ] && [ -d "$JSONL_DIR" ]; then
    find "$JSONL_DIR" -type f -name '*.jsonl' -mtime "+$JSONL_MAX_AGE_DAYS" -print -delete || true
  fi

  echo "[$(now)] janitor: cleanup done"
}

while true; do
  cleanup_once
  sleep "$INTERVAL_SEC"
done
