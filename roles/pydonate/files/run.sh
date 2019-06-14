#!/bin/bash
cd "$(dirname "$0")/code"
source venv/bin/activate
exec flask run
