.386
.model flat,stdcall
.stack 4096

include Irvine32.inc
ExitProcess PROTO, dwExitCode:DWORD

.data
    ; Logo ASCII Art
    logo BYTE ".___  ___.      ___       __      ____    __    ____  __    __  ",13,10
         BYTE "|   \/   |     /   \     |  |     \   \  /  \  /   / |  |  |  | ",13,10
         BYTE "|  \  /  |    /  ^  \    |  |      \   \/    \/   /  |  |__|  | ",13,10
         BYTE "|  |\/|  |   /  /_\  \   |  |       \            /   |   __   | ",13,10
         BYTE "|  |  |  |  /  _____  \  |  `----.   \    /\    /    |  |  |  | ",13,10
         BYTE "|__|  |__| /__/     \__\ |_______|    \__/  \__/     |__|  |__| ",13,10,0

    ; Color Definitions
    BlueTextOnGray = blue + (lightGray * 16)
    WhiteTextOnBlack = white + (black * 16)

    ; Messages
    menu   BYTE "===== Welcome to User Menu =====",13,10,0

    color  BYTE "Choose a background color you desire",13,10
           BYTE "1. Light",13,10
           BYTE "2. Dark",13,10
           BYTE "Enter your choice: ",0

    choice BYTE "Invalid choice. Please enter a valid choice.",13,10,13,10,0

.code
main PROC

call Clrscr
L1:
    mov edx, OFFSET color
    call WriteString
    call ReadInt

    cmp eax, 1
    je  SetLight
    cmp eax, 2
    je  SetDark

    ; Invalid Input Handling
    mov edx, OFFSET choice
    call WriteString
    jmp L1                ; Retry prompt on invalid choice

SetLight:
    mov eax, BlueTextOnGray
    call SetTextColor
    call Clrscr
    jmp DisplayMenu

SetDark:
    mov eax, WhiteTextOnBlack
    call SetTextColor
    call Clrscr
    jmp DisplayMenu

DisplayMenu:
    mov edx, OFFSET logo 
    call WriteString
    call Crlf

    mov edx, OFFSET menu
    call WriteString

    mov eax,10
    INVOKE ExitProcess, 0 

main ENDP
END main