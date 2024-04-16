# Function to send message to Discord
send_discord_message() {
    local message="$1"
    local webhook_url=https://discord.com/api/webhooks/1229713091294396468/429shpsHD5KCkSrIVFKFtkJWv-v61k6t5bswjv6yNOabNg16c_wuBnhqVkRlXKc_M8xI
    curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$message\"}" $webhook_url
    
}

# Function to ping the IP and check response
ping_ip() {
    local ip="$1"
    local ping_output=$(ping -c 10 $ip)
    local response=$(echo "$ping_output" | grep 'received' | awk '{ print $1 }')
    local stats=$(echo "$ping_output" | tail -1)
    echo "$response $stats"
}

# Initialize variables
ip="124.29.217.11"
consecutive_failures=0

# Main loop
while true; do
    result=$(ping_ip $ip)

    read response stats <<< "$result"
    IFS='/' read -r min_ping avg_ping max_ping stddev_ping <<< "$(echo "$stats" | awk '{ print $4 }')"
    
    # Check if the response is 0 (unresponsive)
    if [ "$response" -eq 0 ]; then
        consecutive_failures=$((consecutive_failures + 1))
        if [ $consecutive_failures -eq 5 ]; then
            send_discord_message "Office Internet is down!"
        fi
    elif [ "$response" -gt 0 ] && [ "$response" -lt 5 ]; then
        send_discord_message "Office Internet is slow!\nPing: $avg_ping ms"
    else
        if [ $consecutive_failures -ge 1 ]; then
            send_discord_message "Office Internet is up again!\nPing: $avg_ping ms"
        fi
        consecutive_failures=0
    fi

    sleep 60
done
