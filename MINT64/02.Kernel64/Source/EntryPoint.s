[BITS 64]           ; 이하의 코드는 64비트 코드로 설정

SECTION .text       ; text 섹션(세그먼트)을 정의

; 외부에서 정의된 함수를 쓸 수 있도록 선언함(Import)
extern Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	코드 영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
	mov ax, 0x10        ; IA-32e 모드 커널용 데이터 세그먼트 디스크립터를 AX 레지스터에 저장
	mov ds, ax          ; DS 세그먼트 셀렉터에 설정
	mov es, ax          ; ES 세그먼트 셀렉터에 설정
	mov fs, ax          ; FS 세그먼트 셀렉터에 설정
	mov gs, ax          ; GS 세그먼트 셀렉터에 설정

	; 스택을 0x600000~0x6FFFFF 영역에 1MB 크기로 생성
	mov ss, ax          ; SS 세그먼트 셀렉터에 설정
	mov rsp, 0x6FFFF8   ; RSP 레지스터의 어드레스를 0x6FFFF8로 설정
	mov rbp, 0x6FFFF8   ; RBP 레지스터의 어드레스를 0x6FFFF8로 설정

    call SCANVIDEOBUFFER

    ; 함수 종료 확인용 센티넬 값
    mov r12, 0

	jmp $

	call Main           ; C 언어 엔트리 포인트 함수(Main) 호출

	jmp $


	; 함수 코드 영역

; VideoBuffer 영역(0xB8000)을 순회하여 인덱스는 rbx, 문자는 rcx레지스터에 담는 함수,
; 디버깅이 힘들어서 qemu의 cpu레지스터 로그를 통해 비디오 버퍼 검증을 위함
; PARAM void
SCANVIDEOBUFFER:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    push rax
    push rcx
    push rdx

    ; log에 검색을 쉽게하기위한 센티넬 값
    mov r12, 0x4242424242424242

    ; 버퍼 마지막 위치 인덱스
    mov rdi, 4000 - 2

    ;시작 인덱스
    mov rsi, 0

.MESSAGELOOP:
    ; 마지막 인덱스 - 현재 인덱스
    mov rax, rdi
    sub rax, rsi

    ; 위 결과가 0이면 전부 순회한 것
    cmp rax, 0
    je .MESSAGEEND

    ; 인덱스는 rbx, 문자는 rcx
    mov rbx, rsi
    movzx rcx, byte [ rsi + 0xB8000 ]
    add rsi, 2

    jmp .MESSAGELOOP

.MESSAGEEND:
    pop rdx
    pop rcx
    pop rax
    pop rdi
    pop rsi
    pop rbp
    ret
