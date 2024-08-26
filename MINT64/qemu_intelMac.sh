debug_mode=0

PATH_PROJ=/Users/bson/WT/DTOS/MINT64


if [ "$#" -eq 0 ]; then
    # 인수가 없는 경우
    debug_mode=0
else
    # 인수가 있는 경우
    for arg in "$@"; do
      if [ "$arg" = "debug" ]; then
          debug_mode=1
          break
      fi
    done
fi

if [ "$debug_mode" -eq 1 ]; then
    echo "디버그 모드 활성화됨."
    # 디버그 모드 관련 작업 수행
    qemu-system-x86_64 -m 1024 -fda $PATH_PROJ/Disk.img -rtc base=localtime -M pc -cpu SandyBridge -D $PATH_PROJ/qemu.log -d cpu
else
    echo "디버그 모드 비활성화됨."
    # 일반 모드 작업 수행
    qemu-system-x86_64 -m 1024 -fda $PATH_PROJ/Disk.img -rtc base=localtime -M pc -cpu SandyBridge
fi


