Get-Content -Path "00.BootLoader\BootLoader.bin", "01.Kernel32/Kernel32.bin" -Encoding Byte | Set-Content -Path "Disk.img" -Encoding Byte
