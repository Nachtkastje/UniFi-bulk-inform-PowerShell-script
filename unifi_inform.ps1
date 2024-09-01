# Define general parameters
$credentialsFile = "credentials.txt" 
$ipAddressesFile = "ip_addresses.txt"
$today = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = "unifi_log.txt"

#Define command to run on the connected device
$commandToRun = "mca-cli-op set-inform https://yourunifi-url.tld:8080/inform"  

# Check for required files
if (-not (Test-Path $credentialsFile)) {
    Write-Error "Credentials file not found at $credentialsFile"
    exit 1
}

if (-not (Test-Path $ipAddressesFile)) {
    Write-Error "IP addresses file not found at $ipAddressesFile"
    exit 1
}

# Read credentials
$credentials = Get-Content $credentialsFile
if ($credentials.Length -lt 2) {
    Write-Error "Credentials file must contain a username and password."
    exit 1
}
$username = $credentials[0].Trim()
$password = $credentials[1].Trim()

# Read IP addresses from the file
$ipAddresses = Get-Content $ipAddressesFile

# Install and import the SSH module if necessary
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module -Name Posh-SSH -Force
}
Import-Module Posh-SSH

# Create a secure password object
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create or clear the log file
New-Item -Path $logFile -ItemType File -Force | Out-Null


# Initialize error summary
$errorSummary = @()

# Process each IP address from the file
foreach ($ipAddress in $ipAddresses) {
    $ipAddress = $ipAddress.Trim()  # Remove any leading/trailing whitespace

    if ($ipAddress -eq '') {
        continue
    }

    Write-Host "Valideren van: $ipAddress" -ForegroundColor Cyan

    # Validate IP address format (basic validation)
    if ($ipAddress -match "^[\d\.]+$") {
        try {
            # Create the SSH session
            $session = New-SSHSession -ComputerName $ipAddress -Credential (New-Object PSCredential ($username, $securePassword)) -AcceptKey
            if ($session -eq $null -or $session.Count -eq 0) {
                $errorSummary += "Failed to create SSH session to $ipAddress."
                continue
            }
            
            # Log connection time and IP address
            Add-Content -Path $logFile -Value "Time: $today"
            Add-Content -Path $logFile -Value "IP adrress: $ipAddress"
            Write-Host "SSH sessie geopend: $ipAddress." -ForegroundColor Green

            # Execute the command 
            try {
                $result = Invoke-SSHCommand -SessionId $session.SessionId -Command $commandToRun

                # Log command output
                Add-Content -Path $logFile -Value "Uitvoer:"
                if ($result -ne $null) {
                    $result.Output | ForEach-Object { Add-Content -Path $logFile -Value $_ }
                } else {
                    Add-Content -Path $logFile -Value "No output or command may not have been executed correctly."
                }
                Write-Host "-----------------------------------------------------" -ForegroundColor Cyan
                # Collect command errors
                if ($result.Error -ne $null -and $result.Error.Count -gt 0) {
                    $errorSummary += "Errors on $ipAddress`n" + ($result.Error -join "")
                }
            } catch {
                $errorSummary += "Failed to execute command on $ipAddress $_"
            }

            # Log separator
            Add-Content -Path $logFile -Value "------------------------------------------`n"

        } catch {
            $errorSummary += "Error creating SSH session to $ipAddress $_"
        }
    } else {
        $errorSummary += "Invalid IP address format: $ipAddress"
    }
}

# Display summary of errors
if ($errorSummary.Count -gt 0) {
    $errorSummary | ForEach-Object { Write-Host $_ }

    Add-Content -Path $logFile -Value "`nSamenvatting van errors:"
    $errorSummary | ForEach-Object { Add-Content -Path $logFile -Value $_ }
} else {
    Write-Host "All commands executed successfully without errors."
}
