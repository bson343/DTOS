@REM qemu 버전이 높은지 실습에 문제가 생김, 책이 안내한 버전인 qemu_0.10.04.bat을 실행할 것
@echo Due to an unidentified issue caused by a version discrepancy from the book, which has critically affected the practice, please run qemu_0.10.04.bat!
exit


set myPath=C:\msys64\mingw64\bin

%myPath%\qemu-system-x86_64w.exe -L %myPath% -m 1024 -fda c:/Users/SonByeongguk/WT/DTOS/MINT64/Disk.img -display sdl -rtc base=localtime -M pc


exit

qemu-system-x86_64w.exe -m 1024 -fda c:/Users/SonByeongguk/WT/DTOS/MINT64/Disk.img -display sdl -rtc base=localtime -M pc -device virtio-mem,passthrough=on -monitor stdio