#!/usr/bin/env bash
set -euo pipefail

action="${1:-menu}"

screenshots_dir="${HOME}/Pictures/Screenshots"
recordings_dir="${HOME}/Videos/ScreenRecordings"
state_dir="${HOME}/.cache/mac-capture"
pid_file="${state_dir}/wf-recorder.pid"

mkdir -p "${screenshots_dir}" "${recordings_dir}" "${state_dir}"

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

notify() {
  local title="$1"
  local body="${2:-}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "${title}" "${body}"
  fi
}

recording_running() {
  if [[ ! -f "${pid_file}" ]]; then
    return 1
  fi

  local pid
  pid="$(cat "${pid_file}")"
  if [[ -z "${pid}" ]] || ! kill -0 "${pid}" 2>/dev/null; then
    rm -f "${pid_file}"
    return 1
  fi

  return 0
}

copy_file() {
  local file="$1"
  wl-copy < "${file}"
}

take_full_screenshot() {
  local file="${screenshots_dir}/Screenshot_$(timestamp).png"
  grim "${file}"
  copy_file "${file}"
  notify "Screenshot saved" "${file}"
}

take_area_screenshot() {
  local geometry
  geometry="$(slurp)" || exit 0

  local file="${screenshots_dir}/Screenshot_$(timestamp).png"
  grim -g "${geometry}" "${file}"
  copy_file "${file}"
  notify "Selection screenshot saved" "${file}"
}

start_recording_full() {
  if recording_running; then
    notify "Recording already running"
    return 0
  fi

  local file="${recordings_dir}/Recording_$(timestamp).mp4"
  nohup wf-recorder -f "${file}" >/dev/null 2>&1 &
  echo $! > "${pid_file}"
  notify "Screen recording started" "${file}"
}

start_recording_area() {
  if recording_running; then
    notify "Recording already running"
    return 0
  fi

  local geometry
  geometry="$(slurp)" || exit 0

  local file="${recordings_dir}/Recording_$(timestamp).mp4"
  nohup wf-recorder -g "${geometry}" -f "${file}" >/dev/null 2>&1 &
  echo $! > "${pid_file}"
  notify "Area recording started" "${file}"
}

stop_recording() {
  if ! recording_running; then
    notify "No active recording"
    return 0
  fi

  local pid
  pid="$(cat "${pid_file}")"
  kill -INT "${pid}"
  rm -f "${pid_file}"
  notify "Screen recording stopped"
}

show_menu() {
  local prompt="Capture"
  local options

  if recording_running; then
    options=$'Screenshot: Full screen\nScreenshot: Selection\nRecord: Full screen\nRecord: Selection\nStop recording\nOpen screenshots folder\nOpen recordings folder'
  else
    options=$'Screenshot: Full screen\nScreenshot: Selection\nRecord: Full screen\nRecord: Selection\nOpen screenshots folder\nOpen recordings folder'
  fi

  local choice
  choice="$(printf '%s\n' "${options}" | wofi --dmenu --prompt "${prompt}")" || exit 0

  case "${choice}" in
    "Screenshot: Full screen")
      take_full_screenshot
      ;;
    "Screenshot: Selection")
      take_area_screenshot
      ;;
    "Record: Full screen")
      start_recording_full
      ;;
    "Record: Selection")
      start_recording_area
      ;;
    "Stop recording")
      stop_recording
      ;;
    "Open screenshots folder")
      thunar "${screenshots_dir}" >/dev/null 2>&1 &
      ;;
    "Open recordings folder")
      thunar "${recordings_dir}" >/dev/null 2>&1 &
      ;;
  esac
}

case "${action}" in
  screenshot-full)
    take_full_screenshot
    ;;
  screenshot-area)
    take_area_screenshot
    ;;
  record-full)
    start_recording_full
    ;;
  record-area)
    start_recording_area
    ;;
  stop-recording)
    stop_recording
    ;;
  menu)
    show_menu
    ;;
  *)
    echo "Unknown action: ${action}" >&2
    exit 1
    ;;
esac
