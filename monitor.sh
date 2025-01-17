# Function to send message to Discord
send_discord_message() {
	local message="$1"
	local webhook_url=<discord_webhook_url>
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
ip="" # Fill IP to ping
consecutive_failures=0

# Main loop
while true; do
	result=$(ping_ip $ip)

	read response stats <<< "$result"
	IFS='/' read -r min_ping avg_ping max_ping stddev_ping <<< "$(echo "$stats" | awk '{ print $4 }')"
	
	# Check if the response is 0 (unresponsive)
	if [ "$response" -eq 0 ]; then
		consecutive_failures=$((consecutive_failures + 1))
		if [ $consecutive_failures -eq 3 ]; then
				send_discord_message "Internet is down! <@&1230087956266483782>"
		fi
	elif [ "$response" -gt 0 ] && [ "$response" -lt 5 ]; then
		send_discord_message "Internet is slow!\nPing: $avg_ping ms\n<@&1230087956266483782>"
	else
		if [ $consecutive_failures -ge 1 ]; then
				send_discord_message "Office Internet is up again!\nPing: $avg_ping ms\n<@&1230087956266483782>"
		fi
		consecutive_failures=0
	fi

	sleep 60
done
