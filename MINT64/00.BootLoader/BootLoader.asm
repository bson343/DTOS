[ORG 0x00]      ; 코드의 시작 어드레스를 0x00으로 설정
[BITS 16]       ; 이하의 코드는 16비트 코드로 설정

SECTION .text   ; text 섹션(세그먼트)을 정의

jmp 0x07C0:START                                        ; CS 세그먼트 레지스터에 0x07C0을 복사하면서, START 레이블로 이동

START:                          
    mov ax, 0x07C0                                      ; 부트로더의 시작 어드레스(0x07C)를 세그먼트 레지스터에 설정 하기위한 준비
    mov ds, ax                                          ; DS 세그먼트 레지스터에 부트로더 시작 주소 설정
    mov ax, 0xB800                                      ; 비디오 메모리의 시작 주소(0xB800)을 세그먼트 레지스터에 설정 하기위한 준비
    mov es, ax                                          ; ES 세그먼트에 비디오 버퍼 주소 설정

    mov si, 0                                           ; SI 레지스터(문자열 원본 인덱스 레지스터)를 초기화

.SCREENCLEARLOOP:                                       ; 화면을 지우는 루프
    mov byte [ es: si ], 0                              ; 비디오 버퍼의 문자가 위치하는 주소에 0을 복사하여 문자를 삭제
    mov byte [ es: si + 1 ], 0x0A                       ; 비디오 버퍼에 0x0A(검은 바탕에 밝은 녹색)을 복사

    add si, 2                                           ; 비디오 버퍼상의 다음 인덱스 위치로 이동

    cmp si, 80 * 25 * 2                                 ; 화면의 전체 크기는 80문자, 25라인이며
                                                        ; 문자당 아스키 문자 + 문자 속성 정보 포함해서 2바이트로 설정되어 있음

    jl .SCREENCLEARLOOP                                 ; 점프 명령어는 플래그 레지스터의 정보를 바탕으로 작동하며,
                                                        ; 직전에 수행한 비교 명령에 따라 플래그 정보가 기입된다.
                                                        ; 위 두 명령어(cmp, jl)를 활용해 반복문 구현

    mov si, 0                                           ; 재사용을 위한 SI(문자열 원본 인덱스)레지스터를 초기화
    mov di, 0                                           ; DI(문자열 대상 인덱스)레지스터를 초기화

.MESSAGELOOP:                                           ; 메시지를 출력하는 루프
    mov cl, byte [ si + MESSAGE1 ]                      ; 문자열 배열에 MESSAGE1[si]로 접근하는 것과 같음
                                                        ; 해당하는 문자를 CL 레지스터로 복사\

    cmp cl, 0                                           ; Null 문자 체크
    je .MESSAGEEND                                      ; 널문자를 만나면 반복문 종료

    mov byte [ es: di ], cl                             ; di는 비디오 버퍼의 인덱스를 si는 기입할 문자열의 인덱스를 가리키고 있음.
                                                        ; MESSAGELOOP 반복 로직을 돌면서 비디오 버퍼에 지정한 문자열을 복사함.

    add si, 1
    add di, 2                                           ; 리얼모드 비디오 버퍼의 문자열 구조가 문자 + 문자 속성 2바이트로 설정되어있음.

    jmp .MESSAGELOOP



.MESSAGEEND:

    jmp $                                               ; 현재 위치에서 무한 루프 수행

MESSAGE1: db 'MINT64 OS Boot Loader Start~!!', 0        ; 출력할 메시지, 어셈블러가 알아서 1바이트 단위의 문자열 배열을 생성함.
    

jmp $           ; 현재 위치에서 무한 루프 수행

times 510 - ($ - $$) db 0x00
db 0x55
db 0xAA