/**
 *  file    Main.c
 *  date    2009/01/02
 *  author  kkamagui 
 *          Copyright(c)2008 All rights reserved by kkamagui
 *  brief   C 언어로 작성된 커널의 엔트리 포인트 파일
 */

#include "Types.h"
#include "Keyboard.h"

// 함수 선언
void kPrintString( int iX, int iY, const char* pcString );

/**
 *  아래 함수는 C 언어 커널의 시작 부분임
 */
void Main( void )
{
    char vcTemp[ 2 ] = { 0, };
    BYTE bFlags;
    BYTE bTemp;
    int i = 0;

    kPrintString( 0, 10, "Switch To IA-32e Mode Success~!!" );
    kPrintString( 0, 11, "IA-32e C Language Kernel Start..............[Pass]" );
    kPrintString( 0, 12, "Keyboard Activate...........................[    ]" );

    // 키보드를 활성화
    if (kActivateKeyboard() == TRUE)
    {
        kPrintString(45, 12, "Pass");
        kChangeKeyboardLED( FALSE, FALSE, FALSE );
    }
    else
    {
        kPrintString( 45, 12, "Fail");
        while (1);
    }

    while ( 1 )
    {
        if (kIsOutputBufferFull() == TRUE)
        {
            bTemp = kGetKeyboardScanCode();

            if (kConvertScanCodeToASCIICode(bTemp, &( vcTemp [ 0 ]), &bFlags) == TRUE)
            {
                if (bFlags & KEY_FLAGS_DOWN)
                {
                    kPrintString(i++, 13, vcTemp);
                }
            }
        }
    }
}

/**
 *  문자열을 X, Y 위치에 출력
 */
void kPrintString( int iX, int iY, const char* pcString )
{
    CHARACTER* pstScreen = ( CHARACTER* ) 0xB8000;
    int i;
    
    // X, Y 좌표를 이용해서 문자열을 출력할 어드레스를 계산
    pstScreen += ( iY * 80 ) + iX;

    // NULL이 나올 때까지 문자열 출력
    for( i = 0 ; pcString[ i ] != 0 ; i++ )
    {
        pstScreen[ i ].bCharactor = pcString[ i ];
    }
}
