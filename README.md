# 🚀 UniFI Bulk inform script
If you love the fact to SSH into 25 devices and manually inform your decices, skip this script.
But if you are tired of UniFi devices showing randomly showwing 'Offline' then use this script to bulk inform your devices.

## ⚙️ How to install
1. Download the script
2. Create a file with the name: credentials.txt - fill in your SSH username on the first line and the password on the second line.
3. Create a file with the name: ip_addresses.txt - you can use this file to paste in all the IP addresses (on each line you need to enter 1 IP address)
4. Run the powershell script as Administrator and let the magic do the work.
It will create a output file named unifi_log.txt to tell you the output of the SSH command 

## ⚙️ Parameters
The script contains a few parameters you can change if you want.

The file where you can fill in the credentials: $credentialsFile = "credentials.txt" 
The file where you can input your IP Addresses: $ipAddressesFile = "ip_addresses.txt"
The file where all logging will be written to: $logFile = "unifi_log.txt"
The url of your inform portal: $commandToRun = "mca-cli-op set-inform https:/yourportal.tld:8080/inform"  

## 💬 Support
This script comes with no support what so ever, but i'm happy to help if you have questions or need custom functions.
