# Set new lock screen on remote servers\computers
#list of server names or IP addresses and paths of reg and png
$serverList = @("DC02","DC01","FS01","W")
$regKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
$Path_for_PNG = "C:\Users\sccm\Pictures\test.png"

$credentials = Get-Credential

foreach ($server in $serverList) {
    try {
        $session = New-PSSession -ComputerName $server -Credential $credentials -ErrorAction Stop
        
        # create the key if it doesn't already exist on the remote server
        Invoke-Command -Session $session -ScriptBlock {
            param($regKey)
            if (!(Test-Path -Path $regKey)) {
                $null = New-Item -Path $regKey
            }
        } -ArgumentList $regKey

        # Set the new lock screen on the remote server
        Invoke-Command -Session $session -ScriptBlock {
            param($regKey, $Path_for_PNG)
            Set-ItemProperty -Path $regKey -Name LockScreenImage -Value $Path_for_PNG
        } -ArgumentList $regKey, $Path_for_PNG

        Write-Host "Successfully changed the lock screen on $server"
    }
    catch {
        Write-Host "Failed to change the lock screen on $server. Error: $_"
    }
    finally {
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}
