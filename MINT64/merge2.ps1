param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$DestinationFileName,

    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$InputArray=@()
)

Write-Host "Check Destination File Name: $DestinationFileName"
Write-Host "Check Input String"

foreach($element in $InputArray)
{
    Write-Host $element
}

$length = $InputArray.Count
Write-Host "InputCount: $length"

$DestinationFile = $DestinationFileName;

# 입력 파일들이 존재하는지 확인
foreach ($file in $InputArray) {
    if (-Not (Test-Path $file)) {
        Write-Host "not exist files: $file"
        exit 1
    }
}

# 출력 파일이 이미 존재하면 삭제
if (Test-Path $DestinationFile) {
    Remove-Item $DestinationFile
}

# 각 파일의 내용을 출력 파일로 합침
foreach ($file in $InputArray) {
    Get-Content $file -Encoding Byte | Add-Content -Path $DestinationFile -Encoding Byte
}

Write-Host "File merging completed. Result FileName: $DestinationFile"