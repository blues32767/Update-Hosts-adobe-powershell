# �ˬd��e����O�_�H�޲z���v���B�� (Check if script is running with administrator privileges)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # �p�G���O�A�h���s�Ұʵ{���ín�D�޲z���v�� (If not, restart the script with admin rights)
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# �]�m hosts �ɮת����| (Set the path for hosts file)
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"

# �]�m�ƥ��ɮת����| (Set the path for backup file)
$backupFilePath = "$env:SystemRoot\System32\drivers\etc\hosts.bak"

# ����}���Ҧb���ؿ� (Get the directory where script is located)
$scriptDirectory = $PSScriptRoot

# �c�� hosts.txt �ɮת�������| (Build the full path for hosts.txt file)
$hostsTxtPath = Join-Path -Path $scriptDirectory -ChildPath "hosts.txt"

# �ˬd hosts �ɮ׬O�_�s�b (Check if hosts file exists)
if (Test-Path -Path $hostsFilePath) {
    # �ƥ���l�� hosts �ɮ� (Backup the original hosts file)
    Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
    Write-Host "�w�ƥ� hosts �ɮר� $backupFilePath (Hosts file backed up to $backupFilePath)" -ForegroundColor Green

    # Ū���¦W���ɮ� (�ϥε�����|) (Read blocklist file using absolute path)
    if (Test-Path -Path $hostsTxtPath) {
        $blockList = Get-Content -Path $hostsTxtPath
        # �N�¦W�椺�e�[�J hosts �ɮ� (Add blocklist content to hosts file)
        Add-Content -Path $hostsFilePath -Value $blockList
        Write-Host "�w�N�¦W�椺�e�s�W�� hosts �ɮ� (Blocklist content added to hosts file)" -ForegroundColor Green
    } else {
        Write-Host "���~�G�䤣��¦W���ɮ� ($hostsTxtPath) (Error: Blocklist file not found ($hostsTxtPath))" -ForegroundColor Red
    }

    # �M�� DNS �֨� (�T�O�ܧ�ߧY�ͮ�) (Clear DNS cache to ensure changes take effect immediately)
    ipconfig /flushdns
    Write-Host "�w�M�� DNS �֨� (DNS cache cleared)" -ForegroundColor Green
} else {
    Write-Host "���~�G�䤣�� hosts �ɮ� ($hostsFilePath) (Error: Hosts file not found ($hostsFilePath))" -ForegroundColor Red
}

# �\��1�G���� AGSService �A�� (Feature 1: Disable AGSService)
Write-Host "���b���� AGSService �A��... (Disabling AGSService...)" -ForegroundColor Yellow
try {
    $service = Get-Service -Name "AGSService" -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service -Name "AGSService" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "AGSService" -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "�w���\���� AGSService �A�� (AGSService successfully disabled)" -ForegroundColor Green
    } else {
        Write-Host "�䤣�� AGSService �A�� (AGSService not found)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "���� AGSService �A�Ȯɵo�Ϳ��~: $_ (Error disabling AGSService: $_)" -ForegroundColor Red
}

# �\��2�G�R�� AGSService �A�ȩM AdobeGCClient ��Ƨ� (Feature 2: Delete AGSService and AdobeGCClient folder)
Write-Host "���b�R�� AGSService �A��... (Deleting AGSService...)" -ForegroundColor Yellow
try {
    cmd /c "sc delete AGSService"
    Write-Host "�w����R�� AGSService �A�ȩR�O (AGSService deletion command executed)" -ForegroundColor Green
} catch {
    Write-Host "�R�� AGSService �A�Ȯɵo�Ϳ��~: $_ (Error deleting AGSService: $_)" -ForegroundColor Red
}

$adobeGCClientPath = "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient"
Write-Host "���b�R�� AdobeGCClient ��Ƨ�... (Deleting AdobeGCClient folder...)" -ForegroundColor Yellow
if (Test-Path -Path $adobeGCClientPath) {
    try {
        Remove-Item -Path $adobeGCClientPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "�w���\�R�� AdobeGCClient ��Ƨ� (AdobeGCClient folder successfully deleted)" -ForegroundColor Green
    } catch {
        Write-Host "�R�� AdobeGCClient ��Ƨ��ɵo�Ϳ��~: $_ (Error deleting AdobeGCClient folder: $_)" -ForegroundColor Red
    }
} else {
    Write-Host "�䤣�� AdobeGCClient ��Ƨ� (AdobeGCClient folder not found)" -ForegroundColor Yellow
}

# �\��3�G�R�� AAMUpdater �A�ȩM UWA ��Ƨ� (Feature 3: Delete AAMUpdater and UWA folder)
Write-Host "���b�R�� AAMUpdater �A��... (Deleting AAMUpdater service...)" -ForegroundColor Yellow
try {
    cmd /c "sc delete AAMUpdater"
    Write-Host "�w����R�� AAMUpdater �A�ȩR�O (AAMUpdater deletion command executed)" -ForegroundColor Green
} catch {
    Write-Host "�R�� AAMUpdater �A�Ȯɵo�Ϳ��~: $_ (Error deleting AAMUpdater: $_)" -ForegroundColor Red
}

$uwaPath = "C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA"
Write-Host "���b�R�� UWA ��Ƨ�... (Deleting UWA folder...)" -ForegroundColor Yellow
if (Test-Path -Path $uwaPath) {
    try {
        Remove-Item -Path $uwaPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "�w���\�R�� UWA ��Ƨ� (UWA folder successfully deleted)" -ForegroundColor Green
    } catch {
        Write-Host "�R�� UWA ��Ƨ��ɵo�Ϳ��~: $_ (Error deleting UWA folder: $_)" -ForegroundColor Red
    }
} else {
    Write-Host "�䤣�� UWA ��Ƨ� (UWA folder not found)" -ForegroundColor Yellow
}

# �Ȱ��{������A���ϥΪ̬d�ݵ��G (Pause execution to let user see the results)
Write-Host "`n�Ҧ��ާ@�w�����I(All operations completed!)" -ForegroundColor Cyan
Pause
