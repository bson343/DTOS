[ORG 0x00]      ; 코드의 시작 어드레스를 0ㅌ00으로 설정
[BITS 16]       ; 이하의 코드는 16비트 코드로 설정

SECTION .text   ; text 섹션(세그먼트)을 정의

mov ax, 0xB800
mov ds, ax

mov byte [0x00], '4'
mov byte [0x01], 0x4A

jmp $           ; 현재 위치에서 무한 루프 수행

times 510 - ($ - $$) db 0x00
db 0x55
db 0xAA