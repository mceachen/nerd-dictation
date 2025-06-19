#!/bin/bash
# Stop script for nerd-dictation hotkey activation

PID_FILE="$HOME/.local/share/nerd-dictation-hotkey.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "Stopping nerd-dictation hotkey listener (PID: $PID)..."
        kill "$PID"
        rm -f "$PID_FILE"
        echo "Stopped."
    else
        echo "Process not running (stale PID file)"
        rm -f "$PID_FILE"
    fi
else
    # Try to find and kill by process name
    if pkill -f "python.*hotkey.py"; then
        echo "Stopped nerd-dictation hotkey listener"
    else
        echo "No nerd-dictation hotkey listener found"
    fi
fi