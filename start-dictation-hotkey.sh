#!/bin/bash
# Startup script for nerd-dictation hotkey activation
# Place this script in your startup applications or run it manually

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Audio device - find yours with one of these commands:
# PipeWire: pw-cli list-objects | grep -B1 -A5 "Audio/Source"
# PipeWire: wpctl status (look under Audio > Sources)
# PulseAudio: pactl list sources | grep -A2 "Name:"
USB_DEVICE="alsa_input.usb-046d_HD_Pro_Webcam_C920_F3E6DAF-02.analog-stereo"

ACTIVATION_KEY="caps_lock"  # Change to alt_r, alt_gr, or menu if desired
LOG_FILE="$HOME/.local/share/nerd-dictation-hotkey.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Kill any existing instances
pkill -f "python.*hotkey.py" || true

# Wait a moment for audio subsystem to initialize (useful at startup)
if [ "$1" = "--startup" ]; then
    log_message "Waiting for audio subsystem to initialize..."
    sleep 5
fi

# Change to script directory
cd "$SCRIPT_DIR" || exit 1

# Check if virtual environment exists and has pynput
if [ -d ".venv" ]; then
    log_message "Found virtual environment, checking for pynput..."
    if .venv/bin/python -c "import pynput" 2>/dev/null; then
        log_message "Activating virtual environment..."
        source .venv/bin/activate
    else
        log_message "Virtual environment missing pynput, installing..."
        .venv/bin/pip install pynput >> "$LOG_FILE" 2>&1
        source .venv/bin/activate
    fi
else
    log_message "No virtual environment found, checking system Python"
    if ! python3 -c "import pynput" 2>/dev/null; then
        log_message "ERROR: pynput not installed. Please run: pip install pynput"
        exit 1
    fi
fi

# Start the hotkey script
log_message "Starting nerd-dictation hotkey listener..."
log_message "Device: $USB_DEVICE"
log_message "Activation key: $ACTIVATION_KEY"

# Run in background and redirect output to log
nohup python hotkey.py --device "$USB_DEVICE" --key "$ACTIVATION_KEY" >> "$LOG_FILE" 2>&1 &

# Get the PID
PID=$!
echo $PID > "$HOME/.local/share/nerd-dictation-hotkey.pid"

log_message "Started with PID: $PID"
log_message "Double-tap $ACTIVATION_KEY to start/stop dictation"

# Optional: Show notification if notify-send is available
if command -v notify-send &> /dev/null; then
    notify-send "Nerd Dictation" "Hotkey listener started\nDouble-tap $ACTIVATION_KEY to dictate" -i audio-input-microphone
fi