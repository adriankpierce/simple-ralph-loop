#!/bin/bash
pkill -f ralph.sh 2>/dev/null
pkill -f "claude -p" 2>/dev/null
echo "Stopped."
