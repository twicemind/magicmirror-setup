#!/bin/bash

# Start Test Server Script
# Starts the test app in the background with proper logging

cd "$(dirname "$0")/webui" || exit 1

# Kill existing instances
pkill -f "python.*test_app.py" 2>/dev/null

# Create log directory
mkdir -p logs

# Start server in background
echo "Starting MagicMirror Setup Test Server..."
# shellcheck disable=SC1091
source venv/bin/activate
nohup python test_app.py > logs/test_app.log 2>&1 &

PID=$!
sleep 2

# Check if server is running
if ps -p $PID > /dev/null 2>&1; then
    echo "✅ Server started successfully (PID: $PID)"
    echo "📋 Log file: webui/logs/test_app.log"
    echo "🌐 Open: http://localhost:8081"
    echo ""
    echo "To stop: pkill -f 'python.*test_app.py'"
    echo "To view logs: tail -f webui/logs/test_app.log"
else
    echo "❌ Server failed to start. Check logs/test_app.log for errors"
    exit 1
fi
