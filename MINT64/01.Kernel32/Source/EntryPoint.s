[ORG 0x00]                          ; 코드의 시작 어드레스를 0x00으로 설정
[BITS 16]

SECTION .text

START:
    mov ax, 0x1000                  ; 보호 모드 엔트리 포인트의 시작 주소(0x1000)을 세그먼트 레지스터에 설정
    
    mov ds, ax
    mov es, ax

    cli                             ; 인터럽트 차단
    lgdt [ GDTR ]                   ; GDTR 자료구조를 프로세서에 설정하여 GDT 테이블을 로드

; 보호 모드 진입 절차

    mov eax, 0x4000003B             ; PG=0, CD=1, NW=0, AM=0, WP=0, NE=1, ET=1, TS=1, EM=0, MP=1, PE=1
                                    ; 모드에 따라 메모리 접근 제한과 레지스터 용도 차이는 있지만,
                                    ; 모드 관계 없이 설계 된 레지스터 범위 전부 접근이 가능한 것 같다.
                                    ; 리얼모드에서 eax범위의 레지스터를 사용하는 것을 보니

    mov cr0, eax                    ; CR0 컨트롤 레지스터에 위에서 저장한 플래스를 설정하여 보호 모드로 전환

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   예제와 다르게 작성한 영역 시작
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 예제 코드
    ; 커널 코드 세그먼트를 0x00을 기준으로 하는 것으로 교체하고 EIP의 값을 0x00을 기준으로 재설정
    ; jmp dword(16bit 세트먼트 레지스터) CS 세그먼트 셀렉터 : EIP
    jmp dword 0x08: ( PROTECTEDMODE - $$ + 0x10000 )
                                    ; 왜 오프셋 영역에 실행 주소를 보정해야 하는지 모르겠다
                                    ; 리얼모드처럼 보호모드도 세그먼트:오프셋 모델로 주소를 지정하므로 세그먼트 영역에 0x10000을 지정하면 되는거 아닌가?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 한 번 시도해본 코드
    ;jmp dword 0x08: PROTECTEDMODE
                                    ; GDT에서 코드 세그먼트 기본주소를 0x00(32bit)에서 0x10000(32bit) 수정 함
                                    ; GDT에서 시작 주소를 설정하였으므로 오프셋은 가독성 좋게 레이블만 사용
                                    ; 시도 결과 잘 실행됨!!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   예제와 다르게 작성한 영역 끝
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 보호 모드 진입

[BITS 32]
PROTECTEDMODE:
    mov ax, 0x10                    ; 보호 모드 커널용 데이터 세그먼트 디스크립터 AX 레지스터에 저장
                                    ; 세그먼트 셀렉터에 설정 할 오프셋 정보
                                    ; GDT 기본주소로 부터 16Byte 떨어진 위치에 데이터 세그먼트 디스크립터가 존재함

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 스택을 0x00000000 ~ 0x0000FFFF 영역(16bit 범위) 영역에 64KB 크기로 생성
    mov ss, ax                      ; 스택 세그먼트 설정
    mov esp, 0xFFFE                 
    mov ebp, 0xFFFE                 
                                    ; 이런식이면 하나의 기본주소로 힙과 스택을 한꺼번에 표현 할 수 있나?, 하지만 스택과 데이터 세그먼트는 별개로 설정할 수도 있을 텐데?

    ; 화면에 보호 모드로 전환되었다는 메시지를 찍는다
    push ( SWITCHSUCCESSMESSAGE - $$ + 0x10000)
    push 2
    push 0
    call PRINTMESSAGE
    add esp, 12                     ; 삽입한 파라미터 제거
    
    jmp dword 0x08: 0x10200           ; 현재 위치에서 무한 루프 수행


; 함수 코드 영역

; 메시지를 출력하는 함구
; 스택에 x, y, 문자열 주소가
PRINTMESSAGE:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push edx

    ; X, Y의 좌표로 비디오 메모리의 어드레스를 계산함

    ; Y좌표 계산
    mov eax, dword [ebp + 12]           ; 파라미터는 ebp주소 기준으로 복귀할 ebp 주소, 복귀할 명령어 주소, 파라미터1, 2, 3순임
    mov esi, 160                        ; 한 라인의 바이트 수 width (2 * 80)를 ESI 레지스터에 설정
                                        ; 2차원 배열 1차원 처럼 접근하는 방법 (X + width * Y)
    mul esi
    mov edi, eax

    ; X좌표 계산
    mov eax, dword [ ebp + 8 ]
    mov esi, 2
    mul esi
    add edi, eax

    ; 출력할 문자열의 주소
    mov esi, dword [ ebp + 16 ]

.MESSAGELOOP:
    mov cl, byte [ esi ]

    cmp cl, 0
    je .MESSAGEEND

    mov byte [ edi + 0xB8000 ], cl

    add esi, 1
    add edi, 2

    jmp .MESSAGELOOP

.MESSAGEEND:
    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret

; 데이터 영역

; 아래의 데이터들을 8바이트에 맞춰 정렬하기 위해 추가
align 8, db 0

; GDTR의 끝을 8byte로 정렬하기 위해 추가
dw 0x0000

; GDTR 자료구조 정의
GDTR:
    dw GDTEND - GDT - 1                     ; 아래에 위치하는 GDT 테이블의 전체 크기
    dd ( GDT - $$ + 0x10000)                ; 아래에 위치하는 GDT 테이블의 시작 줄소

; GDT 테이블 정의
GDT:
    ; 널 디스크립터
    NULLDescriptor:
        dw 0x0000
        dw 0x0000
        db 0x00
        db 0x00
        db 0x00
        db 0x00
    
    ; 보호 모드 커널용 코드 세그먼트 디스크립터
    CODEDESCRIPTOR:
        dw 0xFFFF                           ; Limit [15:00]
        dw 0x0000                           ; Base [15:00]
        db 0x00                             ; Base [23:16] @@ 예제와 다르게 작성함 예제는 0x00
        db 0x9A                             ; P=1, DPL=0, Code Segment, Execute/Read
        db 0xCF                             ; G=1, D=1, Limit[19:16]
        db 0x00                             ; Base [31:24]

    ; 보호 모드 커널용 데이터 세그먼트 디스크립터
    DATADESCRIPTOR:
        dw 0xFFFF                           ; Limit [15:00]
        dw 0x0000                           ; Base [15:00]
        db 0x00                             ; Base [23:16]
        db 0x92                             ; P=1, DPL=0, Data Segment, Read/Write
        db 0xCF                             ; G=1, D=1, Limit[19:16]
        db 0x00                             ; Base [31:24]
GDTEND:

; 보호 모드로 전환되었다는 메시지
SWITCHSUCCESSMESSAGE: db 'Switch To Protected Mode Success~!!', 0

times 512 - ( $ - $$ ) db 0x00              ; 512바이트를 맞추기 위해 남은 부분을 0으로 채움



