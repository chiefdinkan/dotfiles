#!/bin/bash

if ! command -v adb &> /dev/null; then
	echo "ADB is not installed. Please install ADB and try again."
	exit 1
fi

devices=$(adb devices | awk 'NR>1 {print $1}' | grep -v '^$')

if [ -z "$devices" ]; then
	echo "No device found. Connect a device and try again."
	exit 1
fi

for device in $devices; do
	ip_address=$(adb -s $device shell ip route | awk 'NR==1 {print $9}')

	if [ -z "$ip_address" ]; then
		echo "Failed to retrieve IP address for device $device. Make sure the device is connected and try again."
		continue
	fi

	adb -s $device tcpip 5555

	adb -s $device connect $ip_address:5555

	if adb devices | grep -q "$device"; then
		echo "Device $device connected via Wi-Fi."
	else
		echo "Failed to establish a Wi-Fi connection with the device $device."
	fi
done
