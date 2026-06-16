#!/bin/bash

DURATION=30s
THREADS=4
CONNECTIONS=100
LARAVEL=http://localhost:8002
WEBRIUM=http://localhost:8001
ENDPOINTS=("bench/render" "bench/json")

check_endpoint() {
    local url=$1
    local code=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time 5 \
        --http1.1 \
        -4 \
        "$url")
    if [ "$code" != "200" ]; then
        echo "  [ERROR] $url returned HTTP $code"
        return 1
    fi
    echo "  [OK] $url -> HTTP 200"
    return 0
}

for EP in "${ENDPOINTS[@]}"; do
    echo ""
    echo "=============================="
    echo "ENDPOINT: /$EP"
    echo "=============================="

    echo "Checking endpoints..."
    check_endpoint "$LARAVEL/$EP" || { echo "  Skipping Laravel for this endpoint"; }
    check_endpoint "$WEBRIUM/$EP" || { echo "  Skipping Webrium for this endpoint"; }

    echo ""
    echo "--- Laravel ---"
    docker stats --no-stream benchmark-laravel &
    wrk -t$THREADS -c$CONNECTIONS -d$DURATION \
        --latency \
        -s /tmp/check_status.lua \
        $LARAVEL/$EP
    wait
    sleep 5

    echo ""
    echo "--- Webrium ---"
    docker stats --no-stream benchmark-webrium &
    wrk -t$THREADS -c$CONNECTIONS -d$DURATION \
        --latency \
        -s /tmp/check_status.lua \
        $WEBRIUM/$EP
    wait
    sleep 5
done
