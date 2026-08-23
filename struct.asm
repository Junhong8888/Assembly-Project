.386
.model flat,stdcall
.stack 4096

include Irvine32.inc
ExitProcess PROTO, dwExitCode:DWORD

USER STRUCT
	username BYTE 32 DUP(?)
	password DWORD ?
	userType DWORD ?
	status	 DWORD ?
USER ENDS

.data
	customer USER <>

	; Input Messages
	getUsername BYTE "Enter your username: ",0
	getPassword BYTE "Enter your password (numbers only): ",0
	
	; Display Headers
	dispUser BYTE "Username: ",0
	dispPass BYTE "Password: ",0

.code
main PROC
	; 1. Read Username
	mov edx, OFFSET getUsername
	call WriteString
	
	mov edx, OFFSET customer.username  ; EDX = buffer destination
	mov ecx, SIZEOF customer.username  ; ECX = max character count
	call ReadString
	call Crlf
	
	; 2. Read Password (Numeric)
	mov edx, OFFSET getPassword
	call WriteString
	call ReadDec                       ; Reads number into EAX
	mov customer.password, eax         ; Store numeric value in struct
	call Crlf

	; 3. Display Username
	mov edx, OFFSET dispUser
	call WriteString
	mov edx, OFFSET customer.username  ; EDX = string address
	call WriteString
	call Crlf
	
	; 4. Display Password
	mov edx, OFFSET dispPass
	call WriteString
	mov eax, customer.password         ; EAX = numeric value
	call WriteDec                      ; Call WriteDec for DWORDs
	call Crlf

	INVOKE ExitProcess, 0
main ENDP
END main