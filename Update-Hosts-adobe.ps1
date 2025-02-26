# �ˬd�ثe�}���O�_�H�޲z���v������
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # �p�G���O�A�h���s�Ұʸ}���ín�D�����v��
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# �]�w hosts �ɮת����|
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"

# �]�w�ƥ��ɮת����|
$backupFilePath = "$env:SystemRoot\System32\drivers\etc\hosts.bak"

# ���o�}���Ҧb���ؿ�
$scriptDirectory = $PSScriptRoot

# �غc hosts.txt ��������|
$hostsTxtPath = Join-Path -Path $scriptDirectory -ChildPath "hosts.txt"

# �ˬd hosts �ɮ׬O�_�s�b
if (Test-Path -Path $hostsFilePath) {
    # �ƥ��{���� hosts �ɮ�
    Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
    Write-Host "�w�ƥ� hosts �ɮצ� $backupFilePath" -ForegroundColor Green

    # Ū������M���ɮ� (�ϥε�����|)
    if (Test-Path -Path $hostsTxtPath) {
        $blockList = Get-Content -Path $hostsTxtPath
        # �N����M����[�� hosts �ɮ�
        Add-Content -Path $hostsFilePath -Value $blockList
        Write-Host "�w�N����M���s�� hosts �ɮ�" -ForegroundColor Green
    } else {
        Write-Host "���~�G�䤣�����M���ɮ� ($hostsTxtPath)" -ForegroundColor Red
    }

    # �M�� DNS �֨� (�T�O�ܧ�ߧY�ͮ�)
    ipconfig /flushdns
    Write-Host "�w�M�� DNS �֨�" -ForegroundColor Green
} else {
    Write-Host "���~�G�䤣�� hosts �ɮ� ($hostsFilePath)" -ForegroundColor Red
}

# �Ȱ��}������A���ϥΪ̬d�ݵ��G
Pause
