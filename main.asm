INCLUDE Irvine32.inc

; Shoe data type definition
Shoe STRUCT
    shoeID       DWORD ?
    shoeName     BYTE 30 DUP(?)
    shoeQuantity DWORD ?
    shoePrice    DWORD ?
Shoe ENDS

; Purchase Record data type definition
PurchaseRecord STRUCT
    transactionID DWORD ?
    totalAmount   DWORD ?   ; In Cents
    paymentType   DWORD ?   ; 1=Cash, 2=Card, 3=QR
    itemCount     DWORD ?   ; Total shoe pairs purchased
PurchaseRecord ENDS

; Payment Method & Invoice Constants
CASH = 1
CARD = 2
QR   = 3
CENT = 100
MEMBER_RATE = 5
SST_RATE = 6
ONE_HUNDRED = 100

.data
    ; ==========================================
    ; ASCII Logo & Themes 
    ; ==========================================
    logo BYTE ".___  ___.     ___       __     ____    __    ____  __    __  ",13,10
         BYTE "|   \/   |    /   \     |  |    \   \  /  \  /   / |  |  |  | ",13,10
         BYTE "|  \  /  |   /  ^  \    |  |     \   \/    \/   /  |  |__|  | ",13,10
         BYTE "|  |\/|  |  /  /_\  \   |  |      \            /   |   __   | ",13,10
         BYTE "|  |  |  | /  _____  \  |  `----.  \    /\    /    |  |  |  | ",13,10
         BYTE "|__|  |__|/__/     \__\ |_______|   \__/  \__/     |__|  |__| ",13,10,0

    BlueTextOnGray   = blue + (lightGray * 16)
    WhiteTextOnBlack = white + (black * 16)

    colorMsg     BYTE "===== DISPLAY SETTINGS =====",13,10
                 BYTE "Choose a background color you desire:",13,10
                 BYTE "1. Light Theme",13,10
                 BYTE "2. Dark Theme",13,10
                 BYTE "Enter your choice (1-2): ",0
                 
    currentTheme DWORD ?    ; Stores active foreground + background attribute

    ; ==========================================
    ; UI Strings & Menus
    ; ==========================================
    mainTitle    BYTE "==========================================", 0dh, 0ah
                 BYTE "        POS SYSTEM MAIN GATEWAY           ", 0dh, 0ah
                 BYTE "==========================================", 0dh, 0ah, 0
                 
    mainOpt      BYTE "1. Login (Manager / Staff / Member)", 0dh, 0ah
                 BYTE "2. Register New Account", 0dh, 0ah
                 BYTE "3. Guest Access", 0dh, 0ah
                 BYTE "4. Exit System", 0dh, 0ah
                 BYTE "Select Option (1-4): ", 0

    loginTitle   BYTE "==========================================", 0dh, 0ah
                 BYTE "              LOGIN PORTAL                ", 0dh, 0ah
                 BYTE "==========================================", 0dh, 0ah, 0

    loginOpt     BYTE "1. Manager Login", 0dh, 0ah
                 BYTE "2. Staff Login", 0dh, 0ah
                 BYTE "3. Member Login", 0dh, 0ah
                 BYTE "4. Back to Main Gateway", 0dh, 0ah
                 BYTE "Select Login Role (1-4): ", 0

    regMenuTitle BYTE "==========================================", 0dh, 0ah
                 BYTE "          REGISTRATION PORTAL             ", 0dh, 0ah
                 BYTE "==========================================", 0dh, 0ah, 0

    regMenuOpt   BYTE "1. Register Admin / Manager", 0dh, 0ah
                 BYTE "2. Register Staff", 0dh, 0ah
                 BYTE "3. Register Member", 0dh, 0ah
                 BYTE "4. Back to Main Gateway", 0dh, 0ah
                 BYTE "Select Account Type to Register (1-4): ", 0

    mgrMenuTitle BYTE "==============================", 0dh, 0ah
                 BYTE "      MANAGER DASHBOARD        ", 0dh, 0ah
                 BYTE "==============================", 0dh, 0ah, 0
    mgrMenuOpt   BYTE "1. Add Staff", 0dh, 0ah
                 BYTE "2. Remove Staff", 0dh, 0ah
                 BYTE "3. Update Staff", 0dh, 0ah
                 BYTE "4. View Sales Report", 0dh, 0ah
                 BYTE "5. Logout", 0dh, 0ah
                 BYTE "Select Option (1-5): ", 0

    staffTitle   BYTE "==============================", 0dh, 0ah
                 BYTE "        STAFF DASHBOARD        ", 0dh, 0ah
                 BYTE "==============================", 0dh, 0ah, 0
    staffOpt     BYTE "1. Add Stock", 0dh, 0ah
                 BYTE "2. Remove Stock", 0dh, 0ah
                 BYTE "3. Update Stock", 0dh, 0ah
                 BYTE "4. Logout", 0dh, 0ah
                 BYTE "Select Option (1-4): ", 0
    
    msgRegUser   BYTE "Enter New Username: ", 0
    msgRegPass   BYTE "Enter New Password: ", 0
    msgUser      BYTE "Enter Username: ", 0
    msgPass      BYTE "Enter Password: ", 0
    
    msgErrC      BYTE "Error: Invalid choice. Try again.", 0dh, 0ah, 0
    msgErrL      BYTE "Error: Access Denied! Invalid credentials.", 0dh, 0ah, 0
    msgErrEmpty  BYTE "Error: Input cannot be empty! Try again.", 0dh, 0ah, 0
    msgErrDup    BYTE "Error: Username already exists! Try another.", 0dh, 0ah, 0
    msgSuccReg   BYTE "Registration Successful!", 0dh, 0ah, 0
    msgGuest     BYTE "Welcome Guest. Proceeding to Sales...", 0dh, 0ah, 0
    msgMemSucc   BYTE "Welcome Member. Proceeding to Sales...", 0dh, 0ah, 0

    ; Management prompts & status messages
    msgPromptShoeID   BYTE "Enter Shoe ID (1-8): ", 0
    msgPromptAddQty   BYTE "Enter Stock Quantity to Add: ", 0
    msgPromptRemQty   BYTE "Enter Stock Quantity to Remove: ", 0
    msgPromptNewQty   BYTE "Enter New Stock Quantity: ", 0
    msgPromptNewPrice BYTE "Enter New Price (RM): ", 0
    msgStockUpdated   BYTE "Stock updated successfully!", 0dh, 0ah, 0
    msgStaffAdded     BYTE "Staff added successfully!", 0dh, 0ah, 0
    msgStaffRemoved   BYTE "Staff reset/removed successfully!", 0dh, 0ah, 0
    msgStaffUpdated   BYTE "Staff credentials updated successfully!", 0dh, 0ah, 0

    ; ==========================================
    ; User Roles Context Flag
    ; ==========================================
    isMemberUser DWORD 0    ; 1 = Member, 0 = Non-Member/Guest/Staff

    ; ==========================================
    ; Database (RAM-based Credentials)
    ; ==========================================
    mgrUser      BYTE "manager", 23 DUP(0) 
    mgrPass      BYTE "123", 27 DUP(0)     

    staffUser    BYTE "staff", 25 DUP(0) 
    staffPass    BYTE "123", 27 DUP(0)
    
    memUser      BYTE "member", 24 DUP(0) 
    memPass      BYTE "123", 27 DUP(0)

    ; ==========================================
    ; Variables & Buffers
    ; ==========================================
    inChoice     BYTE 10 DUP(0)  
    inUser       BYTE 30 DUP(0)
    inPass       BYTE 30 DUP(0)

    ; ==========================================
    ; Purchase History Storage
    ; ==========================================
    MAX_SALES    = 50
    salesHistory PurchaseRecord MAX_SALES DUP(<0,0,0,0>)
    salesCount   DWORD 0

    ; ==========================================
    ; Report Interface Strings
    ; ==========================================
    reportTitle  BYTE "========================================================", 13, 10
                 BYTE "              ADMIN DASHBOARD - SALES REPORT            ", 13, 10
                 BYTE "========================================================", 13, 10, 0
    repHeader    BYTE "TX Qty    Payment     Amount     ", 13, 10
                 BYTE "--------------------------------------------------------", 13, 10, 0
    repNoSales   BYTE "No transaction records found.", 13, 10, 0
    repTotalTx   BYTE 13, 10, "Total Transactions Processed : ", 0
    repTotalRev  BYTE 13, 10, "Total Revenue Collected      : RM", 0
    repCashCount BYTE 13, 10, "Cash Transactions            : ", 0
    repCardCount BYTE 13, 10, "Card Transactions            : ", 0
    repQRCount   BYTE 13, 10, "QR Code Transactions         : ", 0
    
    ; ==========================================
    ; Product and Catalog Module
    ; ==========================================
    shoeCart Shoe <1, "Nike Air Jordan 1", 0, 0>,
               <2, "Nike Air Jordan 5", 0, 0>,
               <3, "Nike Air Jordan 6", 0, 0>,
               <4, "Adizero EVO SL", 0, 0>,
               <5, "Racer TR23", 0, 0>,
               <6, "Harden Volume 9", 0, 0>,
               <7, "SOFTRIDE Carson Fresh", 0, 0>,
               <8, "Deviate NITRO 3", 0, 0>

    id    DWORD ?
    qty   DWORD ?
    price DWORD ?

    shoes Shoe <1, "Nike Air Jordan 1", 200, 175>,
               <2, "Nike Air Jordan 5", 200, 120>,
               <3, "Nike Air Jordan 6", 200, 280>,
               <4, "Adizero EVO SL", 200, 330>,
               <5, "Racer TR23", 200, 230>,
               <6, "Harden Volume 9", 200, 450>,
               <7, "SOFTRIDE Carson Fresh", 200, 245>,
               <8, "Deviate NITRO 3", 200, 300>

    header BYTE "=====================================================", 13, 10
           BYTE "ID   Shoe Name                       Quantity   Price", 13, 10
           BYTE "=====================================================", 13, 10, 0
           
    footer BYTE "=====================================================", 13, 10, 0

    getShoeID  BYTE "Enter Shoe ID (1-8): ",0
    getShoeQty BYTE "Enter quantity: ",0
    quit       BYTE "Continue to add items ? (Y/n) ",0

    ; ==========================================
    ; Integrated Payment & Invoice Strings
    ; ==========================================
    totalSubtotal  DWORD 0   ; In Cents
    discountAmount DWORD 0   ; In Cents
    taxableAmount  DWORD 0   ; In Cents
    sstAmount      DWORD 0   ; In Cents
    grandTotal     DWORD 0   ; In Cents

    ringgitAmount  DWORD 0
    centAmount     DWORD 0

    paymentMethod  DWORD ?
    amountPaid     DWORD ?
    changeDue      DWORD ?

    inputBuffer BYTE 32 DUP(0)
    cardNumber  BYTE 32 DUP(0)
    expiryDate  BYTE 16 DUP(0)
    cvvNumber   BYTE 16 DUP(0)

    titleMsg BYTE 13,10
             BYTE "==============================================",13,10
             BYTE "          SHOE RETAIL POS SYSTEM",13,10
             BYTE "       PAYMENT & RECEIPT PROCESSING",13,10
             BYTE "==============================================",13,10,0

    paymentMenu BYTE 13,10
                BYTE "Payment Method",13,10
                BYTE "1. Cash",13,10
                BYTE "2. Card",13,10
                BYTE "3. QR Payment",13,10
                BYTE "Select payment method (1-3): ",0

    invalidPayment BYTE 13,10
                   BYTE "Invalid payment method. Please select 1, 2 or 3.",13,10,0

    cashPrompt BYTE 13,10
               BYTE "Enter amount paid (RM): ",0

    insufficientMsg BYTE 13,10
                    BYTE "Insufficient payment. Please enter again.",13,10,0

    invalidAmountMsg BYTE 13,10
                     BYTE "Invalid amount. Please enter a valid RM amount.",13,10,0

    cashSuccessMsg BYTE 13,10
                   BYTE "Cash payment successful!",13,10,0

    cardNumberMsg BYTE 13,10
                  BYTE "Enter Card Number (16 digits): ",0

    expiryMsg BYTE "Enter Expiry Date (MM/YY): ",0
    cvvMsg    BYTE "Enter CVV (3 digits): ",0

    invalidCardMsg BYTE 13,10
                   BYTE "Invalid card number. Please enter exactly 16 digits.",13,10,0

    invalidCVVMsg BYTE 13,10
                  BYTE "Invalid CVV. Please enter exactly 3 digits.",13,10,0

    cardSuccessMsg BYTE 13,10
                   BYTE "Card payment successful!",13,10,0

    qrMsg BYTE 13,10
          BYTE "Please scan the QR code to complete payment.",13,10,0

    qrLine1  BYTE "##############################",13,10,0
    qrLine2  BYTE "##      ##  ####  ##      ##",13,10,0
    qrLine3  BYTE "##  ##  ##  ##    ##  ##  ##",13,10,0
    qrLine4  BYTE "##      ##  ####  ##      ##",13,10,0
    qrLine5  BYTE "##############################",13,10,0
    qrLine6  BYTE "      ####  ##  ####",13,10,0
    qrLine7  BYTE "##  ######      ##  ####  ##",13,10,0
    qrLine8  BYTE "    ##  ##  ####    ##",13,10,0
    qrLine9  BYTE "##############################",13,10,0
    qrLine10 BYTE "##      ##  ####  ##      ##",13,10,0
    qrLine11 BYTE "##  ##  ##    ##  ##  ##  ##",13,10,0
    qrLine12 BYTE "##      ##  ####  ##      ##",13,10,0
    qrLine13 BYTE "##############################",13,10,0

    qrConfirmMsg BYTE 13,10
                 BYTE "Payment completed? (Y/N): ",0

    qrSuccessMsg BYTE 13,10
                 BYTE "QR payment successful!",13,10,0

    qrCancelMsg BYTE 13,10
                BYTE "QR payment cancelled.",13,10,0

    invalidQRMsg BYTE 13,10
                 BYTE "Invalid input. Please enter Y or N.",13,10,0

    invoiceTitle BYTE 13,10
                 BYTE "========== INVOICE ==========",13,10,0

    itemLabel     BYTE 13,10,"Item ",0
    priceLabel    BYTE "   Unit Price: ",0
    quantityLabel BYTE "   Quantity: ",0
    subtotalLabel BYTE "   Subtotal: ",0
    lineLabel     BYTE 13,10,"-----------------------------",13,10,0

    totalLabel    BYTE "Total Subtotal: ",0
    discountLabel BYTE 13,10,"Discount: ",0
    taxableLabel  BYTE 13,10,"Taxable Amount: ",0
    sstLabel      BYTE 13,10,"SST (6%): ",0
    grandLabel    BYTE 13,10,"GRAND TOTAL: ",0

    receiptTitle BYTE 13,10
                 BYTE "========================================================",13,10
                 BYTE "                         MALWH",13,10
                 BYTE "                 25, Jalan Bukit Bintang",13,10
                 BYTE "                    55100 Kuala Lumpur",13,10
                 BYTE "                    Tel: 03-2187 6543",13,10
                 BYTE "--------------------------------------------------------",13,10
                 BYTE "--------------------------------------------------------",13,10,0

    productHeader BYTE "Product                Qty  Unit Price Total Price",13,10,0
    separatorMsg  BYTE "--------------------------------------------------------",13,10,0

    subtotalMsg BYTE 13,10
                BYTE "Subtotal:                                      ",0

    discountMsg BYTE 13,10
                BYTE "Member Discount (5%):                         -",0

    sstMsg BYTE 13,10
           BYTE "SST (6%):                                      ",0

    grandTotalMsg BYTE 13,10
                  BYTE "GRAND TOTAL:                                   ",0

    paymentMethodMsg BYTE 13,10
                     BYTE "Payment Method:                                ",0

    cashMsg      BYTE "Cash",0
    cardMsg      BYTE "Card",0
    qrPaymentMsg BYTE "QR Payment",0

    amountPaidMsg BYTE 13,10
                  BYTE "Amount Paid:                                   ",0

    changeMsg BYTE 13,10
              BYTE "Change:                                        ",0

    paymentCompleteMsg BYTE 13,10
                       BYTE "Payment Status:                                SUCCESS",13,10,0

    thankYouMsg BYTE 13,10
                BYTE "--------------------------------------------------------",13,10
                BYTE "             Thank you for shopping with us!",13,10
                BYTE "            The goods sold are not refundable,",13,10
                BYTE "               returnable and exchangeable.",13,10
                BYTE "========================================================",13,10,0

    rmText BYTE "RM ",0
    decimalText BYTE ".",0
    zeroText BYTE "0",0

    returnMsg BYTE 13,10
              BYTE "Press any key to exit to Main Menu...",0

.code

; ==========================================
; MAIN ENTRY POINT
; ==========================================
main PROC
    call SelectTheme
    call MainGateway
    exit
main ENDP


; ==========================================
; 1. THEME SELECTION PROCEDURE
; ==========================================
SelectTheme PROC
ThemeStart:
    mov eax, white + (black * 16)
    call SetTextColor
    call Clrscr
    
    mov edx, OFFSET colorMsg
    call WriteString
    
    mov edx, OFFSET inChoice
    mov ecx, SIZEOF inChoice
    call ReadString
    cmp eax, 1
    jne ThemeInvalid

    mov al, inChoice[0]
    cmp al, '1'
    je SetLight
    cmp al, '2'
    je SetDark

ThemeInvalid:
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    jmp ThemeStart

SetLight:
    mov eax, BlueTextOnGray
    mov currentTheme, eax       
    call SetTextColor
    call Clrscr
    ret

SetDark:
    mov eax, WhiteTextOnBlack
    mov currentTheme, eax       
    call SetTextColor
    call Clrscr
    ret
SelectTheme ENDP


; ==========================================
; 2. MAIN LOGIN / REGISTER GATEWAY
; ==========================================
MainGateway PROC
GatewayStart:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    
    mov edx, OFFSET logo
    call WriteString
    call Crlf

    mov edx, OFFSET mainTitle
    call WriteString
    mov edx, OFFSET mainOpt
    call WriteString

    mov edx, OFFSET inChoice
    mov ecx, SIZEOF inChoice
    call ReadString
    cmp eax, 1
    jne GatewayInvalid

    mov al, inChoice[0]
    cmp al, '1'
    je ShowLoginPortal
    cmp al, '2'
    je ShowRegisterPortal
    cmp al, '3'
    je DoGuestLogin
    cmp al, '4'
    je ExitGateway

GatewayInvalid:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    jmp GatewayStart

ShowLoginPortal:
    call LoginPortal
    jmp GatewayStart

ShowRegisterPortal:
    call RegisterPortal
    jmp GatewayStart

DoGuestLogin:
    mov isMemberUser, 0
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgGuest
    call WriteString
    call Crlf
    call WaitMsg
    call ClearCart
    call getInput
    call GenerateInvoice
    call PaymentReceiptModule
    jmp GatewayStart

ExitGateway:
    ret
MainGateway ENDP


; ==========================================
; 3. LOGIN PORTAL MENU
; ==========================================
LoginPortal PROC
LoginStart:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    
    mov edx, OFFSET loginTitle
    call WriteString
    mov edx, OFFSET loginOpt
    call WriteString

    mov edx, OFFSET inChoice
    mov ecx, SIZEOF inChoice
    call ReadString
    cmp eax, 1
    jne LoginInvalid

    mov al, inChoice[0]
    cmp al, '1'
    je DoMgrLogin
    cmp al, '2'
    je DoStaffLogin
    cmp al, '3'
    je DoMemLogin
    cmp al, '4'
    je ExitLoginPortal

LoginInvalid:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    jmp LoginStart

DoMgrLogin:
    mov isMemberUser, 0
    mov esi, OFFSET mgrUser
    mov edi, OFFSET mgrPass
    call PerformLogin
    cmp eax, 1
    jne LoginStart
    call ManagerDashboard
    jmp LoginStart

DoStaffLogin:
    mov isMemberUser, 0
    mov esi, OFFSET staffUser
    mov edi, OFFSET staffPass
    call PerformLogin
    cmp eax, 1
    jne LoginStart
    call StaffDashboard
    jmp LoginStart

DoMemLogin:
    mov isMemberUser, 1
    mov esi, OFFSET memUser
    mov edi, OFFSET memPass
    call PerformLogin
    cmp eax, 1
    jne LoginStart
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgMemSucc
    call WriteString
    call Crlf
    call WaitMsg
    call ClearCart
    call getInput
    call GenerateInvoice
    call PaymentReceiptModule
    jmp LoginStart

ExitLoginPortal:
    ret
LoginPortal ENDP


; ==========================================
; 4. REGISTER PORTAL MENU (PUBLIC ACCESSIBLE)
; ==========================================
RegisterPortal PROC
RegStart:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    
    mov edx, OFFSET regMenuTitle
    call WriteString
    mov edx, OFFSET regMenuOpt
    call WriteString

    mov edx, OFFSET inChoice
    mov ecx, SIZEOF inChoice
    call ReadString
    cmp eax, 1
    jne RegInvalid

    mov al, inChoice[0]
    cmp al, '1'
    je RegAdminPublic
    cmp al, '2'
    je RegStaffPublic
    cmp al, '3'
    je RegMemberPublic
    cmp al, '4'
    je ExitRegPortal

RegInvalid:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    jmp RegStart

RegAdminPublic:
    mov esi, OFFSET mgrUser
    mov edi, OFFSET mgrPass
    call RegisterAccount
    jmp RegStart

RegStaffPublic:
    mov esi, OFFSET staffUser
    mov edi, OFFSET staffPass
    call RegisterAccount
    jmp RegStart

RegMemberPublic:
    mov esi, OFFSET memUser
    mov edi, OFFSET memPass
    call RegisterAccount
    jmp RegStart

ExitRegPortal:
    ret
RegisterPortal ENDP


; ==========================================
; 5. UNIFIED LOGIN PROCEDURE
; ==========================================
PerformLogin PROC
    LOCAL pUser:DWORD, pPass:DWORD
    mov pUser, esi
    mov pPass, edi

    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    mov al, 0
    rep stosb
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    mov al, 0
    rep stosb

PromptUser:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgUser
    call WriteString
    mov edx, OFFSET inUser
    mov ecx, SIZEOF inUser
    call ReadString
    cmp inUser[0], 0            
    jne PromptPass

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp PromptUser

PromptPass:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgPass
    call WriteString
    mov edi, OFFSET inPass

PassLoop:
    call ReadChar
    cmp al, 0Dh                 ; Enter key
    je PassDone
    cmp al, 08h                 ; Backspace
    je PassLoop
    mov [edi], al
    inc edi
    mov al, '*'                 ; Mask password
    call WriteChar
    jmp PassLoop

PassDone:
    mov byte ptr [edi], 0
    call Crlf
    cmp inPass[0], 0            
    jne CompareUser

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp PromptPass

CompareUser:
    mov esi, OFFSET inUser
    mov edi, pUser          
CompareUserLoop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne LoginFailed
    cmp al, 0
    je ComparePass
    inc esi
    inc edi
    jmp CompareUserLoop

ComparePass:
    mov esi, OFFSET inPass
    mov edi, pPass          
ComparePassLoop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne LoginFailed
    cmp al, 0
    je LoginSuccess
    inc esi
    inc edi
    jmp ComparePassLoop

LoginSuccess:
    mov eax, 1
    ret

LoginFailed:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrL
    call WriteString
    call WaitMsg
    mov eax, 0
    ret
PerformLogin ENDP


; ==========================================
; 6. MANAGER DASHBOARD PROCEDURE
; ==========================================
ManagerDashboard PROC
MgrStart:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    
    mov edx, OFFSET mgrMenuTitle
    call WriteString
    mov edx, OFFSET mgrMenuOpt
    call WriteString
    
    mov edx, OFFSET inChoice
    mov ecx, SIZEOF inChoice
    call ReadString
    cmp eax, 1
    jne MgrInvalid

    mov al, inChoice[0]
    cmp al, '1'
    je DoAddStaff
    cmp al, '2'
    je DoRemoveStaff
    cmp al, '3'
    je DoUpdateStaff
    cmp al, '4'
    je DoSalesReport
    cmp al, '5'
    je MgrExit

MgrInvalid:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    jmp MgrStart

DoAddStaff:
    call AddStaff
    jmp MgrStart

DoRemoveStaff:
    call RemoveStaff
    jmp MgrStart

DoUpdateStaff:
    call UpdateStaff
    jmp MgrStart

DoSalesReport:
    call GenerateSalesReport
    jmp MgrStart

MgrExit:
    ret
ManagerDashboard ENDP


; ==========================================
; 7. STAFF DASHBOARD PROCEDURE
; ==========================================
StaffDashboard PROC
StaffStart:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    
    mov edx, OFFSET staffTitle
    call WriteString
    mov edx, OFFSET staffOpt
    call WriteString
    
    mov edx, OFFSET inChoice
    mov ecx, SIZEOF inChoice
    call ReadString
    cmp eax, 1
    jne StaffInvalid

    mov al, inChoice[0]
    cmp al, '1'
    je DoAddStock
    cmp al, '2'
    je DoRemoveStock
    cmp al, '3'
    je DoUpdateStock
    cmp al, '4'
    je StaffExit

StaffInvalid:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    jmp StaffStart

DoAddStock:
    call AddStock
    jmp StaffStart

DoRemoveStock:
    call RemoveStock
    jmp StaffStart

DoUpdateStock:
    call UpdateStock
    jmp StaffStart

StaffExit:
    ret
StaffDashboard ENDP


; ==========================================
; ADMIN SUBROUTINES (STAFF MANAGEMENT)
; ==========================================
AddStaff PROC
    mov esi, OFFSET staffUser
    mov edi, OFFSET staffPass
    call RegisterAccount
    ret
AddStaff ENDP

RemoveStaff PROC
    call Clrscr
    mov edi, OFFSET staffUser
    mov ecx, SIZEOF staffUser
    mov al, 0
    rep stosb

    mov edi, OFFSET staffPass
    mov ecx, SIZEOF staffPass
    mov al, 0
    rep stosb

    mov edx, OFFSET msgStaffRemoved
    call WriteString
    call WaitMsg
    ret
RemoveStaff ENDP

UpdateStaff PROC
    call Clrscr
    mov esi, OFFSET staffUser
    mov edi, OFFSET staffPass
    call RegisterAccount
    ret
UpdateStaff ENDP


; ==========================================
; STAFF SUBROUTINES (STOCK MANAGEMENT)
; ==========================================
AddStock PROC
    call Clrscr
    call displayCatalog
    mov edx, OFFSET msgPromptShoeID
    call WriteString
    call ReadInt
    cmp eax, 1
    jl InvalidShoe
    cmp eax, 8
    jg InvalidShoe

    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoes
    add esi, eax

    mov edx, OFFSET msgPromptAddQty
    call WriteString
    call ReadInt

    add (Shoe PTR [esi]).shoeQuantity, eax
    mov edx, OFFSET msgStockUpdated
    call WriteString
    call WaitMsg
    ret

InvalidShoe:
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    ret
AddStock ENDP

RemoveStock PROC
    call Clrscr
    call displayCatalog
    mov edx, OFFSET msgPromptShoeID
    call WriteString
    call ReadInt
    cmp eax, 1
    jl InvalidShoeRem
    cmp eax, 8
    jg InvalidShoeRem

    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoes
    add esi, eax

    mov edx, OFFSET msgPromptRemQty
    call WriteString
    call ReadInt

    cmp eax, (Shoe PTR [esi]).shoeQuantity
    ja StockUnderflow
    sub (Shoe PTR [esi]).shoeQuantity, eax
    jmp StockRemDone

StockUnderflow:
    mov (Shoe PTR [esi]).shoeQuantity, 0

StockRemDone:
    mov edx, OFFSET msgStockUpdated
    call WriteString
    call WaitMsg
    ret

InvalidShoeRem:
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    ret
RemoveStock ENDP

UpdateStock PROC
    call Clrscr
    call displayCatalog
    mov edx, OFFSET msgPromptShoeID
    call WriteString
    call ReadInt
    cmp eax, 1
    jl InvalidShoeUpd
    cmp eax, 8
    jg InvalidShoeUpd

    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoes
    add esi, eax

    mov edx, OFFSET msgPromptNewQty
    call WriteString
    call ReadInt
    mov (Shoe PTR [esi]).shoeQuantity, eax

    mov edx, OFFSET msgPromptNewPrice
    call WriteString
    call ReadInt
    mov (Shoe PTR [esi]).shoePrice, eax

    mov edx, OFFSET msgStockUpdated
    call WriteString
    call WaitMsg
    ret

InvalidShoeUpd:
    mov edx, OFFSET msgErrC
    call WriteString
    call WaitMsg
    ret
UpdateStock ENDP


; ==========================================
; 8. ACCOUNT REGISTRATION PROCEDURE
; ==========================================
RegisterAccount PROC
    LOCAL pTargetUser:DWORD, pTargetPass:DWORD
    mov pTargetUser, esi
    mov pTargetPass, edi

PromptRegUser:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    
    push edi
    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    mov al, 0
    rep stosb
    pop edi

    mov edx, OFFSET msgRegUser
    call WriteString
    mov edx, OFFSET inUser
    mov ecx, SIZEOF inUser
    call ReadString
    cmp inUser[0], 0
    jne DoDupCheck
    
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp PromptRegUser

DoDupCheck:
    call CheckDuplicateUser
    cmp eax, 1
    je PromptRegUser        

    mov esi, OFFSET inUser
    mov edi, pTargetUser
    call StringCopy

PromptRegPass:
    mov edi, pTargetPass
    mov ecx, 30
    mov al, 0
    rep stosb

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgRegPass
    call WriteString
    mov edx, pTargetPass
    mov ecx, 30
    call ReadString
    
    mov esi, pTargetPass
    cmp byte ptr [esi], 0
    jne RegDone

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp PromptRegPass

RegDone:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgSuccReg
    call WriteString
    call Crlf
    call WaitMsg
    ret
RegisterAccount ENDP


; ==========================================
; 9. HELPER: CHECK DUPLICATE USERNAME
; ==========================================
CheckDuplicateUser PROC
    mov esi, OFFSET inUser
    mov edi, OFFSET mgrUser
    call StringCompare
    cmp eax, 1
    je DupFound

    mov esi, OFFSET inUser
    mov edi, OFFSET staffUser
    call StringCompare
    cmp eax, 1
    je DupFound

    mov esi, OFFSET inUser
    mov edi, OFFSET memUser
    call StringCompare
    cmp eax, 1
    je DupFound

    mov eax, 0
    ret

DupFound:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrDup
    call WriteString
    call WaitMsg
    mov eax, 1
    ret
CheckDuplicateUser ENDP


; ==========================================
; 10. HELPER: STRING COMPARE
; ==========================================
StringCompare PROC
CompareLoop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne NoMatch
    cmp al, 0
    je Match
    inc esi
    inc edi
    jmp CompareLoop

Match:
    mov eax, 1
    ret
NoMatch:
    mov eax, 0
    ret
StringCompare ENDP


; ==========================================
; 11. HELPER: STRING COPY
; ==========================================
StringCopy PROC
CopyLoop:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je CopyDone
    inc esi
    inc edi
    jmp CopyLoop
CopyDone:
    ret
StringCopy ENDP


; ==========================================
; 12. HELPER: CLEAR CART BETWEEN TRANSACTIONS
; ==========================================
ClearCart PROC
    mov esi, OFFSET shoeCart
    mov ecx, LENGTHOF shoeCart
ClearLoop:
    mov (Shoe PTR [esi]).shoeQuantity, 0
    mov (Shoe PTR [esi]).shoePrice, 0
    add esi, TYPE Shoe
    loop ClearLoop
    ret
ClearCart ENDP


; ==========================================
; 13. GET USER INPUT (SALES MODULE)
; ==========================================
getInput PROC

.REPEAT
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    call displayCatalog

inputID:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET getShoeID
    call Crlf
    call WriteString
    call ReadInt
    jnc goodInput
    jmp inputID

goodInput:
    cmp eax, 8
    jg inputID
    cmp eax, 1
    jl inputID
    mov id, eax     

inputQty:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET getShoeQty
    call Crlf
    call WriteString
    call ReadInt
    jnc goodQty
    jmp inputQty

goodQty:
    cmp eax, 200
    jg inputQty
    cmp eax, 1
    jl inputQty
    mov qty, eax     
    
    call calcPrice
    call addCart

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET quit
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf

.UNTIL (al == 'N' || al == 'n')
    ret
getInput ENDP


; ==========================================
; 14. DISPLAY PRODUCT CATALOG
; ==========================================
displayCatalog PROC
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET header
    call WriteString

    mov esi, OFFSET shoes        
    mov ecx, LENGTHOF shoes     
    mov bl, 3                    

L1:
    mov dh, bl                   
    mov dl, 0
    call Gotoxy
    mov eax, (Shoe PTR [esi]).shoeID
    call WriteDec

    mov dh, bl
    mov dl, 5
    call Gotoxy
    lea edx, (Shoe PTR [esi]).shoeName   
    call WriteString

    mov dh, bl
    mov dl, 39
    call Gotoxy
    mov eax, (Shoe PTR [esi]).shoeQuantity
    call WriteDec

    mov dh, bl
    mov dl, 50
    call Gotoxy
    mov eax, (Shoe PTR [esi]).shoePrice
    call WriteDec

    inc bl                        
    add esi, TYPE Shoe
    loop L1

    mov dh, bl
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET footer
    call WriteString
    ret 
displayCatalog ENDP


; ==========================================
; 15. CALCULATE PRICE
; ==========================================
calcPrice PROC
    mov ebx, id
    dec ebx
    mov eax, TYPE Shoe
    mul ebx
    mov ebx, eax

    mov esi, OFFSET shoes
    add esi, ebx
    mov eax, (Shoe PTR [esi]).shoePrice
    mov price, eax

    mov ebx, qty
    mul ebx
    mov price, eax
    ret
calcPrice ENDP


; ==========================================
; 16. ADD TO CART
; ==========================================
addCart PROC
    mov ebx, id
    dec ebx                     
    mov eax, TYPE Shoe
    mul ebx                      
    mov ebx, eax

    mov esi, OFFSET shoeCart
    add esi, ebx                

    mov eax, price
    add (Shoe PTR [esi]).shoePrice, eax

    mov eax, qty
    add (Shoe PTR [esi]).shoeQuantity, eax
    ret
addCart ENDP


; ==========================================
; 17. GENERATE INVOICE
; ==========================================
GenerateInvoice PROC
    mov eax, currentTheme
    call SetTextColor
    call Clrscr

    mov esi, OFFSET shoeCart
    mov ecx, LENGTHOF shoeCart
    mov eax, 0                  

CalcCartTotal:
    mov ebx, (Shoe PTR [esi]).shoePrice
    add eax, ebx
    add esi, TYPE Shoe
    loop CalcCartTotal

    mov ebx, CENT
    mul ebx
    mov totalSubtotal, eax

    call CalculateDiscount
    call CalculateTaxableAmount
    call CalculateSST
    call CalculateGrandTotal
    call DisplayInvoice
    ret
GenerateInvoice ENDP


; ==========================================
; CALCULATE DISCOUNT
; ==========================================
CalculateDiscount PROC
    cmp isMemberUser, 1
    je MemberDiscount

    mov discountAmount, 0
    ret

MemberDiscount:
    mov eax, totalSubtotal
    mov ebx, MEMBER_RATE
    mul ebx
    mov ebx, ONE_HUNDRED
    mov edx, 0
    div ebx
    mov discountAmount, eax
    ret
CalculateDiscount ENDP


; ==========================================
; CALCULATE TAXABLE AMOUNT
; ==========================================
CalculateTaxableAmount PROC
    mov eax, totalSubtotal
    sub eax, discountAmount
    mov taxableAmount, eax
    ret
CalculateTaxableAmount ENDP


; ==========================================
; CALCULATE SST
; ==========================================
CalculateSST PROC
    mov eax, taxableAmount
    mov ebx, SST_RATE
    mul ebx
    mov ebx, ONE_HUNDRED
    mov edx, 0
    div ebx
    mov sstAmount, eax
    ret
CalculateSST ENDP


; ==========================================
; CALCULATE GRAND TOTAL
; ==========================================
CalculateGrandTotal PROC
    mov eax, totalSubtotal
    sub eax, discountAmount
    add eax, sstAmount
    mov grandTotal, eax
    ret
CalculateGrandTotal ENDP


; ==========================================
; DISPLAY INVOICE
; ==========================================
DisplayInvoice PROC
    mov edx, OFFSET invoiceTitle
    call WriteString

    mov esi, OFFSET shoeCart
    mov ecx, LENGTHOF shoeCart
    mov ebx, 1                  ; Item counter

DisplayInvoiceLoop:
    push ecx
    mov eax, (Shoe PTR [esi]).shoeQuantity
    cmp eax, 0
    je SkipInvoiceItem

    lea edx, (Shoe PTR [esi]).shoeName
    call WriteString

    mov edx, OFFSET priceLabel
    call WriteString
    
    ; Unit Price in Cents
    mov eax, (Shoe PTR [esi]).shoePrice
    mov ecx, (Shoe PTR [esi]).shoeQuantity
    mov edx, 0
    div ecx
    mov ecx, CENT
    mul ecx
    call DisplayMoney

    mov edx, OFFSET quantityLabel
    call WriteString
    mov eax, (Shoe PTR [esi]).shoeQuantity
    call WriteDec

    mov edx, OFFSET subtotalLabel
    call WriteString
    mov eax, (Shoe PTR [esi]).shoePrice
    mov ecx, CENT
    mul ecx
    call DisplayMoney
    call Crlf
SkipInvoiceItem:
    inc ebx
    add esi, TYPE Shoe
    pop ecx
    loop DisplayInvoiceLoop

    mov edx, OFFSET lineLabel
    call WriteString

    mov edx, OFFSET totalLabel
    call WriteString
    mov eax, totalSubtotal
    call DisplayMoney

    mov edx, OFFSET discountLabel
    call WriteString
    mov eax, discountAmount
    call DisplayMoney

    mov edx, OFFSET taxableLabel
    call WriteString
    mov eax, taxableAmount
    call DisplayMoney

    mov edx, OFFSET sstLabel
    call WriteString
    mov eax, sstAmount
    call DisplayMoney

    mov edx, OFFSET grandLabel
    call WriteString
    mov eax, grandTotal
    call DisplayMoney
    call Crlf
    call Crlf
    call WaitMsg
    ret
DisplayInvoice ENDP


; ==========================================
; 18. PAYMENT & RECEIPT MODULE
; ==========================================
PaymentReceiptModule PROC
    mov eax, currentTheme
    call SetTextColor
    call Clrscr

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET titleMsg
    call WriteString

PaymentMenuLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET paymentMenu
    call WriteString

    call ReadInt
    mov paymentMethod, eax

    cmp eax, CASH
    je ProcessCashPayment

    cmp eax, CARD
    je ProcessCardPayment

    cmp eax, QR
    je ProcessQRPayment

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidPayment
    call WriteString
    jmp PaymentMenuLoop

ProcessCashPayment:
CashPaymentLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET cashPrompt
    call WriteString

    mov edx, OFFSET inputBuffer
    mov ecx, SIZEOF inputBuffer
    call ReadString

    mov edx, OFFSET inputBuffer
    call ParseRMToCents

    cmp ebx, 1
    je ValidCashAmount

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidAmountMsg
    call WriteString
    jmp CashPaymentLoop

ValidCashAmount:
    mov amountPaid, eax

    cmp eax, grandTotal
    jl InsufficientCash

    mov eax, amountPaid
    sub eax, grandTotal
    mov changeDue, eax

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET cashSuccessMsg
    call WriteString

    call GenerateReceipt
    ret

InsufficientCash:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET insufficientMsg
    call WriteString
    jmp CashPaymentLoop

ProcessCardPayment:
CardNumberLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET cardNumberMsg
    call WriteString

    mov esi, OFFSET cardNumber
    mov ecx, 0

ReadCardDigit:
    call ReadChar

    cmp al, 13
    je CheckCardComplete

    cmp al, '0'
    jb InvalidCardInput
    cmp al, '9'
    ja InvalidCardInput

    mov BYTE PTR [esi], al
    inc esi
    inc ecx

    mov al, '*'
    call WriteChar

    cmp ecx, 16
    jl ReadCardDigit

WaitForCardEnter:
    call ReadChar
    cmp al, 13
    jne WaitForCardEnter

CheckCardComplete:
    cmp ecx, 16
    jne InvalidCardInput

    mov BYTE PTR [esi], 0
    call Crlf
    jmp ExpiryInput

InvalidCardInput:
    call Crlf
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidCardMsg
    call WriteString

    mov esi, OFFSET cardNumber
    mov ecx, 32
ClearCardBuffer:
    mov BYTE PTR [esi], 0
    inc esi
    loop ClearCardBuffer

    jmp CardNumberLoop

ExpiryInput:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET expiryMsg
    call WriteString

    mov edx, OFFSET expiryDate
    mov ecx, SIZEOF expiryDate
    call ReadString

CVVLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET cvvMsg
    call WriteString

    mov edx, OFFSET cvvNumber
    mov ecx, SIZEOF cvvNumber
    call ReadString

    mov edx, OFFSET cvvNumber
    mov ecx, 3
    call ValidateDigits

    cmp eax, 1
    je CardPaymentSuccess

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidCVVMsg
    call WriteString
    jmp CVVLoop

CardPaymentSuccess:
    mov eax, grandTotal
    mov amountPaid, eax
    mov changeDue, 0

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET cardSuccessMsg
    call WriteString

    call GenerateReceipt
    ret

ProcessQRPayment:
QRPaymentLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET qrMsg
    call WriteString

    mov edx, OFFSET qrLine1
    call WriteString
    mov edx, OFFSET qrLine2
    call WriteString
    mov edx, OFFSET qrLine3
    call WriteString
    mov edx, OFFSET qrLine4
    call WriteString
    mov edx, OFFSET qrLine5
    call WriteString
    mov edx, OFFSET qrLine6
    call WriteString
    mov edx, OFFSET qrLine7
    call WriteString
    mov edx, OFFSET qrLine8
    call WriteString
    mov edx, OFFSET qrLine9
    call WriteString
    mov edx, OFFSET qrLine10
    call WriteString
    mov edx, OFFSET qrLine11
    call WriteString
    mov edx, OFFSET qrLine12
    call WriteString
    mov edx, OFFSET qrLine13
    call WriteString

    mov edx, OFFSET qrConfirmMsg
    call WriteString

    call ReadChar
    call WriteChar
    call Crlf

    cmp al, 'Y'
    je QRPaymentSuccess
    cmp al, 'y'
    je QRPaymentSuccess
    cmp al, 'N'
    je QRPaymentCancelled
    cmp al, 'n'
    je QRPaymentCancelled

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidQRMsg
    call WriteString
    jmp QRPaymentLoop

QRPaymentSuccess:
    mov eax, grandTotal
    mov amountPaid, eax
    mov changeDue, 0

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET qrSuccessMsg
    call WriteString

    call GenerateReceipt
    ret

QRPaymentCancelled:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET qrCancelMsg
    call WriteString
    jmp PaymentMenuLoop

PaymentReceiptModule ENDP


; ==========================================
; 19. PARSE RM STRING TO CENTS
; ==========================================
ParseRMToCents PROC
    mov esi, edx
    mov eax, 0
    mov ebx, 0
    mov ecx, 0
    mov edi, 0

ParseLoop:
    mov dl, BYTE PTR [esi]

    cmp dl, 0
    je ParseFinished

    cmp dl, '.'
    je DecimalPoint

    cmp dl, '0'
    jb InvalidInput

    cmp dl, '9'
    ja InvalidInput

    sub dl, '0'

    cmp edi, 1
    je DecimalDigit

    imul eax, eax, 10
    movzx edx, dl
    add eax, edx
    inc esi
    jmp ParseLoop

DecimalPoint:
    cmp edi, 1
    je InvalidInput
    mov edi, 1
    inc esi
    jmp ParseLoop

DecimalDigit:
    cmp ecx, 2
    jae InvalidInput
    movzx edx, dl

    cmp ecx, 0
    je FirstDecimalDigit
    add ebx, edx
    jmp NextDecimalDigit

FirstDecimalDigit:
    imul edx, edx, 10
    add ebx, edx

NextDecimalDigit:
    inc ecx
    inc esi
    jmp ParseLoop

ParseFinished:
    cmp edi, 0
    je NoDecimal

    cmp ecx, 0
    je InvalidInput

    cmp ecx, 1
    jne AddCents

    imul ebx, ebx, 10

AddCents:
    imul eax, eax, 100
    add eax, ebx

    cmp eax, 0
    jle InvalidInput
    mov ebx, 1
    ret

NoDecimal:
    imul eax, eax, 100
    cmp eax, 0
    jle InvalidInput
    mov ebx, 1
    ret

InvalidInput:
    mov ebx, 0
    ret
ParseRMToCents ENDP


; ==========================================
; 20. VALIDATE DIGITS HELPER
; ==========================================
ValidateDigits PROC
    mov esi, edx
    mov ebx, 0

ValidateLoop:
    mov dl, BYTE PTR [esi]

    cmp dl, 0
    je CheckLength

    cmp dl, '0'
    jb InvalidDigits

    cmp dl, '9'
    ja InvalidDigits

    inc ebx
    inc esi
    jmp ValidateLoop

CheckLength:
    cmp ebx, ecx
    jne InvalidDigits
    mov eax, 1
    ret

InvalidDigits:
    mov eax, 0
    ret
ValidateDigits ENDP


; ==========================================
; 21. GENERATE & PRINT SALES RECEIPT
; ==========================================
GenerateReceipt PROC
    mov eax, currentTheme
    call SetTextColor
    call Crlf

    mov edx, OFFSET receiptTitle
    call WriteString
    
    ; Header: Product (25) | Qty (5) | Unit Price (12) | Total Price
    mov edx, OFFSET productHeader
    call WriteString
    mov edx, OFFSET separatorMsg
    call WriteString

    mov esi, OFFSET shoeCart
    mov ecx, LENGTHOF shoeCart

ReceiptItemLoop:
    mov eax, (Shoe PTR [esi]).shoeQuantity
    cmp eax, 0
    je SkipReceiptItem

    ; Preserve loop counter across printing operations
    push ecx

    ; 1. Display Shoe Name
    lea edx, (Shoe PTR [esi]).shoeName
    call WriteString

    ; 2. Pad Shoe Name Column (25 chars)
    lea edx, (Shoe PTR [esi]).shoeName
    call StrLength             
    mov ecx, 25
    sub ecx, eax
PadNameLoop:
    mov al, ' '
    call WriteChar
    loop PadNameLoop

    ; 3. Display Quantity & Pad Column (5 chars)
    mov eax, (Shoe PTR [esi]).shoeQuantity
    call WriteDec
    
    mov al, ' '
    call WriteChar
    call WriteChar

    ; 4. Calculate & Display Unit Price (Line Total / Quantity)
    mov eax, (Shoe PTR [esi]).shoePrice
    mov ecx, (Shoe PTR [esi]).shoeQuantity
    mov edx, 0
    div ecx                     ; EAX = Unit Price in RM

    mov ecx, CENT
    mul ecx                     ; EAX = Unit Price in Cents
    call DisplayMoney

    ; 5. Pad Unit Price Column
    mov al, ' '
    call WriteChar
    call WriteChar

    ; 6. Calculate & Display Line Total Price
    mov eax, (Shoe PTR [esi]).shoePrice
    mov ecx, CENT
    mul ecx                     ; EAX = Line Total in Cents
    call DisplayMoney
    call Crlf

    ; Restore main loop counter
    pop ecx

SkipReceiptItem:
    add esi, TYPE Shoe
    loop ReceiptItemLoop

    ; --- Summary Section ---
    mov edx, OFFSET separatorMsg
    call WriteString

    mov edx, OFFSET subtotalMsg
    call WriteString
    mov eax, totalSubtotal
    call DisplayMoney

    mov edx, OFFSET discountMsg
    call WriteString
    mov eax, discountAmount
    call DisplayMoney

    mov edx, OFFSET sstMsg
    call WriteString
    mov eax, sstAmount
    call DisplayMoney

    mov edx, OFFSET grandTotalMsg
    call WriteString
    mov eax, grandTotal
    call DisplayMoney
    call Crlf

    mov edx, OFFSET separatorMsg
    call WriteString

    ; --- Payment Details ---
    mov edx, OFFSET paymentMethodMsg
    call WriteString

    cmp paymentMethod, CASH
    je ReceiptCashMethod
    cmp paymentMethod, CARD
    je ReceiptCardMethod

    mov edx, OFFSET qrPaymentMsg
    call WriteString
    jmp DisplayPaymentAmount

ReceiptCashMethod:
    mov edx, OFFSET cashMsg
    call WriteString
    jmp DisplayPaymentAmount

ReceiptCardMethod:
    mov edx, OFFSET cardMsg
    call WriteString

DisplayPaymentAmount:
    mov edx, OFFSET amountPaidMsg
    call WriteString
    mov eax, amountPaid
    call DisplayMoney

    mov edx, OFFSET changeMsg
    call WriteString
    mov eax, changeDue
    call DisplayMoney

    mov edx, OFFSET paymentCompleteMsg
    call WriteString
    mov edx, OFFSET thankYouMsg
    call WriteString

    ; --- Post-Processing Calls ---
    call RecordTransaction           ; Log transaction into history buffer
    call UpdateStockAfterPurchase    ; Update inventory stock in shoes array

    mov edx, OFFSET returnMsg
    call WriteString
    call ReadChar
    ret
GenerateReceipt ENDP


; ==========================================
; 22. DISPLAY MONEY IN RM FORMAT
; ==========================================
DisplayMoney PROC
    mov ebx, ONE_HUNDRED
    mov edx, 0
    div ebx

    mov ringgitAmount, eax
    mov centAmount, edx

    mov edx, OFFSET rmText
    call WriteString

    mov eax, ringgitAmount
    call WriteDec

    mov edx, OFFSET decimalText
    call WriteString

    cmp centAmount, 10
    jae DisplayCents

    mov edx, OFFSET zeroText
    call WriteString

DisplayCents:
    mov eax, centAmount
    call WriteDec
    ret
DisplayMoney ENDP


; ==========================================
; 23. RECORD PURCHASE TRANSACTION
; ==========================================
RecordTransaction PROC
    cmp salesCount, MAX_SALES
    jae RecordFull              ; Ignore if log buffer is maxed out

    mov eax, salesCount
    mov ebx, TYPE PurchaseRecord
    mul ebx
    mov esi, OFFSET salesHistory
    add esi, eax

    mov eax, salesCount
    inc eax
    mov (PurchaseRecord PTR [esi]).transactionID, eax

    mov eax, grandTotal
    mov (PurchaseRecord PTR [esi]).totalAmount, eax

    mov eax, paymentMethod
    mov (PurchaseRecord PTR [esi]).paymentType, eax

    mov edi, OFFSET shoeCart
    mov ecx, LENGTHOF shoeCart
    mov ebx, 0

CountItemsLoop:
    mov eax, (Shoe PTR [edi]).shoeQuantity
    add ebx, eax
    add edi, TYPE Shoe
    loop CountItemsLoop

    mov (PurchaseRecord PTR [esi]).itemCount, ebx

    inc salesCount

RecordFull:
    ret
RecordTransaction ENDP


; ==========================================
; 24. GENERATE & DISPLAY SALES REPORT
; ==========================================
GenerateSalesReport PROC
    LOCAL totalRev:DWORD, countCash:DWORD, countCard:DWORD, countQR:DWORD
    
    mov totalRev, 0
    mov countCash, 0
    mov countCard, 0
    mov countQR, 0

    mov eax, currentTheme
    call SetTextColor
    call Clrscr

    mov edx, OFFSET reportTitle
    call WriteString

    cmp salesCount, 0
    jne PrintReportData

    mov edx, OFFSET repNoSales
    call WriteString
    call Crlf
    call WaitMsg
    ret

PrintReportData:
    mov edx, OFFSET repHeader
    call WriteString

    mov esi, OFFSET salesHistory
    mov ecx, salesCount

ReportLoop:
    mov eax, (PurchaseRecord PTR [esi]).transactionID
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar

    mov eax, (PurchaseRecord PTR [esi]).itemCount
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov eax, (PurchaseRecord PTR [esi]).paymentType
    cmp eax, CASH
    je RepIsCash
    cmp eax, CARD
    je RepIsCard

    mov edx, OFFSET qrPaymentMsg
    call WriteString
    inc countQR
    jmp PrintAmount

RepIsCash:
    mov edx, OFFSET cashMsg
    call WriteString
    inc countCash
    jmp PrintAmount

RepIsCard:
    mov edx, OFFSET cardMsg
    call WriteString
    inc countCard

PrintAmount:
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar

    mov eax, (PurchaseRecord PTR [esi]).totalAmount
    add totalRev, eax
    call DisplayMoney
    call Crlf

    add esi, TYPE PurchaseRecord
    dec ecx
    jnz NEAR PTR ReportLoop

    mov edx, OFFSET separatorMsg
    call WriteString

    mov edx, OFFSET repTotalTx
    call WriteString
    mov eax, salesCount
    call WriteDec

    mov edx, OFFSET repTotalRev
    call WriteString
    mov eax, totalRev
    call DisplayMoney

    mov edx, OFFSET repCashCount
    call WriteString
    mov eax, countCash
    call WriteDec

    mov edx, OFFSET repCardCount
    call WriteString
    mov eax, countCard
    call WriteDec

    mov edx, OFFSET repQRCount
    call WriteString
    mov eax, countQR
    call WriteDec

    call Crlf
    call Crlf
    call WaitMsg
    ret
GenerateSalesReport ENDP

; ==========================================
; 25. UPDATE INVENTORY AFTER PURCHASE
; ==========================================
UpdateStockAfterPurchase PROC
    mov esi, OFFSET shoeCart
    mov ecx, LENGTHOF shoeCart

UpdateLoop:
    push ecx
    
    ; Check if cart item has quantity purchased
    mov eax, (Shoe PTR [esi]).shoeQuantity
    cmp eax, 0
    je SkipStockUpdate

    ; Find matching shoe ID in shoes array
    mov ebx, (Shoe PTR [esi]).shoeID
    dec ebx                         ; Convert 1-based ID to 0-based index
    mov eax, TYPE Shoe
    mul ebx
    
    mov edi, OFFSET shoes
    add edi, eax                    ; EDI points to matching item in 'shoes'

    ; Subtract cart quantity from inventory stock
    mov eax, (Shoe PTR [esi]).shoeQuantity
    cmp eax, (Shoe PTR [edi]).shoeQuantity
    ja InventoryUnderflow           ; Guard against underflow

    sub (Shoe PTR [edi]).shoeQuantity, eax
    jmp SkipStockUpdate

InventoryUnderflow:
    mov (Shoe PTR [edi]).shoeQuantity, 0

SkipStockUpdate:
    add esi, TYPE Shoe
    pop ecx
    loop UpdateLoop

    ret
UpdateStockAfterPurchase ENDP

END main