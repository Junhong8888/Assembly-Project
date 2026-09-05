INCLUDE Irvine32.inc

; ==========================================
; CONSTANTS
; ==========================================
CASH = 1
CARD = 2
QR   = 3
CENT = 100
MEMBER_RATE = 5
SST_RATE = 6
ONE_HUNDRED = 100
MAX_STAFF = 10
MAX_SALES = 50

MIN_SIZE = 40
MAX_SIZE = 45
NUM_SIZES = 6   ; Sizes 40, 41, 42, 43, 44, 45
NUM_SHOES = 8   ; Dynamic catalog boundary

; ==========================================
; ENTERPRISE DATA STRUCTURES
; ==========================================
Shoe STRUCT
    shoeID       DWORD ?
    shoeName     BYTE 32 DUP(?)     ; Padded to 32 for strict memory alignment
    shoePrice    DWORD ?
    ; Size Quantities Array (Offsets: 40->0, 41->4, 42->8, 43->12, 44->16, 45->20)
    qty40        DWORD ?
    qty41        DWORD ?
    qty42        DWORD ?
    qty43        DWORD ?
    qty44        DWORD ?
    qty45        DWORD ?
Shoe ENDS

PurchaseRecord STRUCT
    transactionID DWORD ?
    shoeID        DWORD ?   ; shoeID field
    totalAmount   DWORD ?   ; In Cents
    paymentType   DWORD ?   ; 1=Cash, 2=Card, 3=QR
    itemCount     DWORD ?   ; Total shoe pairs purchased
PurchaseRecord ENDS

Staff STRUCT
    staffUsername BYTE 30 DUP(?)
    staffPassword BYTE 30 DUP(?)
    staffActive   DWORD ?   ; 1 = slot in use, 0 = empty
Staff ENDS

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
                 
    currentTheme DWORD ?

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
                 BYTE "             LOGIN PORTAL                 ", 0dh, 0ah
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
                 BYTE "5. View Staff List", 0dh, 0ah
                 BYTE "6. Logout", 0dh, 0ah
                 BYTE "Select Option (1-6): ", 0

    staffTitle   BYTE "==============================", 0dh, 0ah
                 BYTE "        STAFF DASHBOARD        ", 0dh, 0ah
                 BYTE "==============================", 0dh, 0ah, 0
    staffOpt     BYTE "1. Add Stock", 0dh, 0ah
                 BYTE "2. Remove Stock", 0dh, 0ah
                 BYTE "3. Update Stock", 0dh, 0ah
                 BYTE "4. View Current Stock", 0dh, 0ah
                 BYTE "5. Logout", 0dh, 0ah
                 BYTE "Select Option (1-5): ", 0

    ; Management prompts & status messages
    msgPromptShoeID   BYTE "Enter Shoe ID (1-", 0
    msgPromptShoeID2  BYTE "): ", 0
    msgPromptSize     BYTE "Enter Shoe Size (40-45): ", 0
    msgPromptAddQty   BYTE "Enter Stock Quantity to Add: ", 0
    msgPromptRemQty   BYTE "Enter Stock Quantity to Remove: ", 0
    msgPromptNewQty   BYTE "Enter New Stock Quantity: ", 0
    msgPromptNewPrice BYTE "Enter New Price (RM): ", 0
    
    msgStockUpdated   BYTE "Stock updated successfully!", 0dh, 0ah, 0
    msgStaffAdded     BYTE "Staff added successfully!", 0dh, 0ah, 0
    msgStaffRemoved   BYTE "Staff removed successfully!", 0dh, 0ah, 0
    msgStaffUpdated   BYTE "Staff credentials updated successfully!", 0dh, 0ah, 0
    msgGuest          BYTE "Welcome Guest. Proceeding to Sales...", 0dh, 0ah, 0
    msgMemSucc        BYTE "Welcome Member. Proceeding to Sales...", 0dh, 0ah, 0

    ; General Validations
    msgRegUser        BYTE "Enter New Username: ", 0
    msgRegPass        BYTE "Enter New Password: ", 0
    msgUser           BYTE "Enter Username: ", 0
    msgPass           BYTE "Enter Password: ", 0
    msgErrC           BYTE "Error: Invalid choice. Try again.", 0dh, 0ah, 0
    msgErrL           BYTE "Error: Access Denied! Invalid credentials.", 0dh, 0ah, 0
    msgErrEmpty       BYTE "Error: Input cannot be empty! Try again.", 0dh, 0ah, 0
    msgErrDup         BYTE "Error: Username already exists! Try another.", 0dh, 0ah, 0
    msgSuccReg        BYTE "Registration Successful!", 0dh, 0ah, 0

    msgEnterStaffUserRem BYTE "Enter staff username to remove: ", 0
    msgEnterStaffUserUpd BYTE "Enter staff username to update: ", 0
    msgStaffNotFound     BYTE "Error: Staff username not found!", 0dh, 0ah, 0
    msgNoStaffReg        BYTE "Error: No staff account is currently registered!", 0dh, 0ah, 0

    errStockID1  BYTE "Invalid Shoe ID! Please enter a number between 1 and ",0
    errStockID2  BYTE ".",13,10,0
    errSize      BYTE "Invalid Size! Please enter a value between 40 and 45.",13,10,0
    errStockQty  BYTE "Invalid quantity! Please enter a positive whole number.",13,10,0
    errQty       BYTE "The quantity you entered is not in the range. Please re-enter",13,10,0
    errRemoveQty BYTE "Cannot remove more than the current stock quantity!",13,10,0
    errEmpty     BYTE "Stock is empty or fully added to cart! Please choose another.",13,10,0

    ; View staff list strings
    staffListTitle   BYTE "========================================",13,10
                     BYTE "            REGISTERED STAFF LIST         ",13,10
                     BYTE "========================================",13,10,0
    staffListHeader  BYTE "No.   Username                       Password",13,10,0
    staffListEmpty   BYTE "No staff accounts registered.",13,10,0
    msgStaffListFull BYTE "Error: Staff list is full! Cannot add more staff.",13,10,0

    ; Current order (cart) display strings
    cartTitle    BYTE 13,10,"---------------- YOUR CURRENT ORDER ----------------",13,10,0
    cartEmptyMsg BYTE "  (No items added yet)",13,10,0
    cartFooter   BYTE "------------------------------------------------------",13,10,0
    msgSizeUpdated BYTE "Shoe size successfully updated!", 0Dh, 0Ah, 0

    idSeparator BYTE ". ", 0        
    currentID   DWORD ?

    ; Edit cart strings
    msgEditCartPrompt BYTE 13,10,"Enter Item ID in your cart to edit/remove (0 = Back): ",0
    msgEditSizePrompt BYTE "Enter Size to edit (40-45): ",0
    msgEditSubMenu    BYTE 13,10,"1. Update Size (40-45)",13,10
                      BYTE "2. Update Quantity",13,10
                      BYTE "3. Remove Item",13,10
                      BYTE "4. Back",13,10
                      BYTE "Select option (1-3): ",0
    msgItemNotInCart  BYTE 13,10,"This specific item/size is not currently in your cart.",13,10,0
    msgItemRemoved    BYTE 13,10,"Item removed from cart.",13,10,0
    msgCartUpdated    BYTE 13,10,"Cart quantity updated.",13,10,0
    msgInvalidEntry   BYTE 13,10,"Invalid input! Numbers only, please try again.",13,10,0

    ; Switch method prompt
    msgSwitchMethod BYTE 13,10,"Insufficient funds.",13,10
                    BYTE "Type T to try a different amount, or C to change payment method: ",0

    ; Context Flag
    isMemberUser DWORD 0    ; 1 = Member, 0 = Non-Member/Guest/Staff

    ; Database (RAM-based Credentials)
    mgrUser      BYTE "manager", 23 DUP(0) 
    mgrPass      BYTE "123", 27 DUP(0)     

    staffList    Staff MAX_STAFF DUP(<>)
    staffCount   DWORD 0

    defaultStaffUser BYTE "staff",0
    defaultStaffPass BYTE "123",0

    memUser      BYTE "member", 24 DUP(0) 
    memPass      BYTE "123", 27 DUP(0)

    inChoice     BYTE 10 DUP(0)  
    inUser       BYTE 30 DUP(0)
    inPass       BYTE 30 DUP(0)

    ; Purchase History (Circular Ring Buffer)
    salesHistory         PurchaseRecord MAX_SALES DUP(<>)
    salesCount           DWORD 0  ; Index pointer for array (0-49)
    lifetimeTransactions DWORD 0  ; Infinite counter

    ; Report Interface Strings
    reportTitle  BYTE "========================================================", 13, 10
                 BYTE "               ADMIN DASHBOARD - SALES REPORT             ", 13, 10
                 BYTE "========================================================", 13, 10, 0
    repHeader    BYTE "TX   Qty   Payment            Amount", 0Dh, 0Ah
                 BYTE "--------------------------------------------------------", 0Dh, 0Ah, 0
    repTotalPairs BYTE 13,10, "Total Pairs Sold             : ",0
    repNoSales   BYTE "No transaction records found.", 13, 10, 0
    repTotalTx   BYTE 13, 10, "Total Transactions Processed : ", 0
    repTotalRev  BYTE 13, 10, "Total Revenue Collected      : ", 0
    repCashCount BYTE 13, 10, "Cash Transactions            : ", 0
    repCardCount BYTE 13, 10, "Card Transactions            : ", 0
    repQRCount   BYTE 13, 10, "QR Code Transactions         : ", 0
    
    ; ==========================================
    ; CATALOG & SIZE MODULE
    ; ==========================================
    ; Initialize empty cart (Prices Pre-Loaded)
    shoeCart Shoe <1, "Nike Air Jordan 1", 175, 0,0,0,0,0,0>
             Shoe <2, "Nike Air Jordan 5", 120, 0,0,0,0,0,0>
             Shoe <3, "Nike Air Jordan 6", 280, 0,0,0,0,0,0>
             Shoe <4, "Adizero EVO SL", 330, 0,0,0,0,0,0>
             Shoe <5, "Racer TR23", 230, 0,0,0,0,0,0>
             Shoe <6, "Harden Volume 9", 450, 0,0,0,0,0,0>
             Shoe <7, "SOFTRIDE Carson Fresh", 245, 0,0,0,0,0,0>
             Shoe <8, "Deviate NITRO 3", 300, 0,0,0,0,0,0>

    ; Initialize Master Store Stock (All set to 30 pairs per size)
    shoes Shoe <1, "Nike Air Jordan 1", 175, 30,30,30,30,30,30>
          Shoe <2, "Nike Air Jordan 5", 120, 30,30,30,30,30,30>
          Shoe <3, "Nike Air Jordan 6", 280, 30,30,30,30,30,30>
          Shoe <4, "Adizero EVO SL", 330, 30,30,30,30,30,30>
          Shoe <5, "Racer TR23", 230, 30,30,30,30,30,30>
          Shoe <6, "Harden Volume 9", 450, 30,30,30,30,30,30>
          Shoe <7, "SOFTRIDE Carson Fresh", 245, 30,30,30,30,30,30>
          Shoe <8, "Deviate NITRO 3", 300, 30,30,30,30,30,30>

    id           DWORD ?
    selectedSize DWORD ?
    qty          DWORD ?
    limit        DWORD ?
    printCol     BYTE  ?

    header BYTE "===============================================================================", 13, 10
           BYTE "ID  Shoe Name                      Price   | 40  41  42  43  44  45 | Total", 13, 10
           BYTE "===============================================================================", 13, 10, 0
    footer BYTE "===============================================================================", 13, 10, 0

    getShoeID1 BYTE "Enter Shoe ID (1-",0
    getShoeID2 BYTE "), or ",0
    getShoeID3 BYTE " to Edit Cart: ",0
    getShoeQty BYTE "Enter quantity: ",0
    quit       BYTE "Continue to add items ? (Y/n) ",0
    szText1    BYTE " (Sz ",0
    szText2    BYTE ")",0

    ; Payment Strings
    totalSubtotal  DWORD 0   
    discountAmount DWORD 0   
    taxableAmount  DWORD 0   
    sstAmount      DWORD 0   
    grandTotal     DWORD 0   

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
               BYTE "Enter amount paid (RM), or 0 to change payment method: ",0

    insufficientMsg BYTE 13,10
                    BYTE "Insufficient payment. Please enter again.",13,10,0

    invalidAmountMsg BYTE 13,10
                     BYTE "Invalid amount. Please enter a valid RM amount.",13,10,0

    cashSuccessMsg BYTE 13,10
                   BYTE "Cash payment successful!",13,10,0

    cardNumberMsg BYTE 13,10
                  BYTE "Enter Card Number (16 digits, or press Enter to change payment method): ",0

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

    invalidExpiryMsg BYTE "Invalid Expiry Date! Format must be MM/YY (Month 01-12, Year 26+).",13,10,0

    invoiceTitle BYTE 13,10
                 BYTE "========== INVOICE ==========",13,10,0

    quantityLabel BYTE "   Quantity: ",0
    subtotalLabel BYTE "   Subtotal: ",0
    lineLabel     BYTE 13,10,"-----------------------------",13,10,0

    totalLabel    BYTE "Total Subtotal: ",0
    discountLabel BYTE 13,10,"Discount: ",0
    taxableLabel  BYTE 13,10,"Taxable Amount: ",0
    sstLabel      BYTE 13,10,"SST (6%): ",0
    grandLabel    BYTE 13,10,"GRAND TOTAL: ",0

    msgConfirmOrder BYTE 13,10
                    BYTE "Confirm this order and proceed to payment? (Y/N): ",0
    msgModifyOrder  BYTE 13,10
                    BYTE "Returning to the order screen so you can modify your cart...",13,10,0
    invalidConfirmMsg BYTE 13,10
                       BYTE "Invalid input. Please enter Y or N.",13,10,0

    receiptTitle BYTE 13,10
                 BYTE "==========================================================================",13,10
                 BYTE "                                 MALWH",13,10
                 BYTE "                          25, Jalan Bukit Bintang",13,10
                 BYTE "                             55100 Kuala Lumpur",13,10
                 BYTE "                             Tel: 03-2187 6543",13,10
                 BYTE "--------------------------------------------------------------------------",13,10
                 BYTE "--------------------------------------------------------------------------",13,10,0

    productHeader BYTE "Product                                Qty     Unit Price     Total Price",13,10,0
    separatorMsg  BYTE "--------------------------------------------------------------------------",13,10,0

    subtotalMsg BYTE 13,10
                BYTE "Subtotal:                                                         ",0
    discountMsg BYTE 13,10
                BYTE "Member Discount (5%):                                            -",0
    sstMsg BYTE 13,10
           BYTE "SST (6%):                                                         ",0
    grandTotalMsg BYTE 13,10
                  BYTE "GRAND TOTAL:                                                      ",0

    paymentMethodMsg BYTE 13,10
                     BYTE "Payment Method:                                                   ",0

    cashMsg      BYTE "Cash",0
    cardMsg      BYTE "Card",0
    qrPaymentMsg BYTE "QR Payment",0

    amountPaidMsg BYTE 13,10
                  BYTE "Amount Paid:                                                      ",0
    changeMsg BYTE 13,10
              BYTE "Change:                                                           ",0
    paymentCompleteMsg BYTE 13,10
                       BYTE "Payment Status:                                                   SUCCESS",13,10,0

    thankYouMsg BYTE 13,10
                BYTE "--------------------------------------------------------------------------",13,10
                BYTE "                      Thank you for shopping with us!",13,10
                BYTE "                     The goods sold are not refundable,",13,10
                BYTE "                        returnable and exchangeable.",13,10
                BYTE "==========================================================================",13,10,0

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
    call InitDefaultAccounts
    call SelectTheme
    call MainGateway
    exit
main ENDP

; ==========================================
; BOOTSTRAP ACCOUNT
; ==========================================
InitDefaultAccounts PROC
    mov ebx, OFFSET staffList
    mov esi, OFFSET defaultStaffUser
    lea edi, (Staff PTR [ebx]).staffUsername
    call StringCopy

    mov esi, OFFSET defaultStaffPass
    lea edi, (Staff PTR [ebx]).staffPassword
    call StringCopy

    mov (Staff PTR [ebx]).staffActive, 1
    mov staffCount, 1
    ret
InitDefaultAccounts ENDP

; ==========================================
; THEME SELECTION
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
; GATEWAYS & MENUS
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

GuestOrderLoop:
    call getInput
    call GenerateInvoice
    call ConfirmOrder
    cmp eax, 1
    jne GuestOrderLoop

    call PaymentReceiptModule
    jmp GatewayStart

ExitGateway:
    ret
MainGateway ENDP

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
    call PerformStaffLogin
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

MemberOrderLoop:
    call getInput
    call GenerateInvoice
    call ConfirmOrder
    cmp eax, 1
    jne MemberOrderLoop

    call PaymentReceiptModule
    jmp LoginStart

ExitLoginPortal:
    ret
LoginPortal ENDP

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
    call RegisterStaffAccount
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
; LOGIN LOGIC
; ==========================================
PerformLogin PROC
    LOCAL pUser:DWORD, pPass:DWORD
    mov pUser, esi
    mov pPass, edi

    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    call SecureZeroMemory
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

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
    call Crlf                   
    jmp PromptUser

PromptPass:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgPass
    call WriteString
    mov edi, OFFSET inPass
    mov ecx, 0  ; Counter for password length

PassLoop:
    call ReadChar
    cmp al, 0Dh                 
    je PassDone
    cmp al, 08h                 
    je PassLoop

    ; Buffer overflow protection check
    cmp ecx, 29
    jae PassLoop

    mov [edi], al
    inc edi
    inc ecx
    mov al, '*'                 
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
    call Crlf                   
    jmp PromptPass

CompareUser:
    mov esi, OFFSET inUser
    mov edi, pUser          
CompareUserLoop:
    mov al, [esi]
    mov dl, [edi]               
    cmp al, dl
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
    mov dl, [edi]               
    cmp al, dl
    jne LoginFailed
    cmp al, 0
    je LoginSuccess
    inc esi
    inc edi
    jmp ComparePassLoop

LoginSuccess:
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory
    mov eax, 1
    ret

LoginFailed:
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrL
    call WriteString
    call WaitMsg
    call Crlf                   
    mov eax, 0
    ret
PerformLogin ENDP

PerformStaffLogin PROC
    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    call SecureZeroMemory
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

StaffPromptUser:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgUser
    call WriteString
    mov edx, OFFSET inUser
    mov ecx, SIZEOF inUser
    call ReadString
    cmp inUser[0], 0
    jne StaffPromptPass

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    call Crlf                   
    jmp StaffPromptUser

StaffPromptPass:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgPass
    call WriteString
    mov edi, OFFSET inPass
    mov ecx, 0  ; Counter for password length

StaffPassLoop:
    call ReadChar
    cmp al, 0Dh
    je StaffPassDone
    cmp al, 08h
    je StaffPassLoop

    ; Buffer overflow protection check
    cmp ecx, 29
    jae StaffPassLoop

    mov [edi], al
    inc edi
    inc ecx
    mov al, '*'
    call WriteChar
    jmp StaffPassLoop

StaffPassDone:
    mov byte ptr [edi], 0
    call Crlf
    cmp inPass[0], 0
    jne StaffCheckList

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    call Crlf                   
    jmp StaffPromptPass

StaffCheckList:
    mov ebx, OFFSET staffList
    mov ecx, MAX_STAFF

StaffLoginScan:
    push ecx
    cmp (Staff PTR [ebx]).staffActive, 0
    je StaffScanNext

    mov esi, OFFSET inUser
    lea edi, (Staff PTR [ebx]).staffUsername
    call StringCompare
    cmp eax, 1
    jne StaffScanNext

    mov esi, OFFSET inPass
    lea edi, (Staff PTR [ebx]).staffPassword
    call StringCompare
    cmp eax, 1
    je StaffLoginSuccessPop

StaffScanNext:
    add ebx, TYPE Staff
    pop ecx
    dec ecx
    jz StaffLoginFail
    jmp StaffLoginScan

StaffLoginFail:
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrL
    call WriteString
    call WaitMsg
    call Crlf                   
    mov eax, 0
    ret

StaffLoginSuccessPop:
    pop ecx
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory
    mov eax, 1
    ret
PerformStaffLogin ENDP


; ==========================================
; DASHBOARDS
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
    je DoViewStaffList
    cmp al, '6'
    je MgrExit
    jmp MgrInvalid

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
DoViewStaffList:
    call Clrscr
    call ShowStaffTable
    call Crlf
    call WaitMsg
    jmp MgrStart
MgrExit:
    ret
ManagerDashboard ENDP

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
    je DoViewStock
    cmp al, '5'
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
DoViewStock:
    call ViewStock
    jmp StaffStart
StaffExit:
    ret
StaffDashboard ENDP


; ==========================================
; STAFF MANAGEMENT LOGIC
; ==========================================
AddStaff PROC
    call RegisterStaffAccount
    ret
AddStaff ENDP

RegisterStaffAccount PROC
    cmp staffCount, MAX_STAFF
    jl StaffSlotAvailable

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgStaffListFull
    call WriteString
    call WaitMsg
    ret

StaffSlotAvailable:
PromptStaffRegUser:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr

    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    call SecureZeroMemory

    mov edx, OFFSET msgRegUser
    call WriteString
    mov edx, OFFSET inUser
    mov ecx, SIZEOF inUser
    call ReadString
    cmp inUser[0], 0
    jne StaffDupCheck

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp PromptStaffRegUser

StaffDupCheck:
    call CheckDuplicateUser
    cmp eax, 1
    je PromptStaffRegUser

PromptStaffRegPass:
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgRegPass
    call WriteString
    mov edx, OFFSET inPass
    mov ecx, SIZEOF inPass
    call ReadString

    cmp inPass[0], 0
    jne StaffRegSave

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    call Crlf                   
    jmp PromptStaffRegPass

StaffRegSave:
    mov esi, OFFSET staffList
    mov ecx, MAX_STAFF

FindEmptySlot:
    cmp (Staff PTR [esi]).staffActive, 0
    je EmptySlotFound
    add esi, TYPE Staff
    dec ecx
    jz EmptySlotDone 
    jmp FindEmptySlot
EmptySlotDone:
    ret                          

EmptySlotFound:
    mov ebx, esi                 

    mov esi, OFFSET inUser
    lea edi, (Staff PTR [ebx]).staffUsername
    call StringCopy

    mov esi, OFFSET inPass
    lea edi, (Staff PTR [ebx]).staffPassword
    call StringCopy

    mov (Staff PTR [ebx]).staffActive, 1
    inc staffCount

    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgSuccReg
    call WriteString
    call Crlf
    call WaitMsg
    ret
RegisterStaffAccount ENDP

RemoveStaff PROC
RemStaffStart:
    call Clrscr

    cmp staffCount, 0
    jne RemStaffPromptUser

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgNoStaffReg
    call WriteString
    call WaitMsg
    ret

RemStaffPromptUser:
    call ShowStaffTable         
    call Crlf
    
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgEnterStaffUserRem
    call WriteString

    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    call SecureZeroMemory

    mov edx, OFFSET inUser
    mov ecx, SIZEOF inUser
    call ReadString
    
    cmp inUser[0], 0
    jne RemStaffSearch
    
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp RemStaffStart

RemStaffSearch:
    mov ebx, OFFSET staffList
    mov ecx, MAX_STAFF

RemStaffSearchLoop:
    push ecx
    cmp (Staff PTR [ebx]).staffActive, 0
    je RemStaffSearchNext

    mov esi, OFFSET inUser
    lea edi, (Staff PTR [ebx]).staffUsername
    call StringCompare
    cmp eax, 1
    je RemStaffFoundPop

RemStaffSearchNext:
    add ebx, TYPE Staff
    pop ecx
    dec ecx
    jz RemStaffFail
    jmp RemStaffSearchLoop

RemStaffFail:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgStaffNotFound
    call WriteString
    call WaitMsg
    jmp RemStaffStart

RemStaffFoundPop:
    pop ecx
    mov edi, ebx
    mov ecx, SIZEOF Staff
    call SecureZeroMemory

    dec staffCount

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgStaffRemoved
    call WriteString
    call Crlf
    call WaitMsg
    ret
RemoveStaff ENDP

UpdateStaff PROC
UpdStaffStart:
    call Clrscr

    cmp staffCount, 0
    jne UpdStaffPromptUser

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgNoStaffReg
    call WriteString
    call WaitMsg
    ret

UpdStaffPromptUser:
    call ShowStaffTable         
    call Crlf
    
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgEnterStaffUserUpd
    call WriteString

    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    call SecureZeroMemory

    mov edx, OFFSET inUser
    mov ecx, SIZEOF inUser
    call ReadString
    
    cmp inUser[0], 0
    jne UpdStaffSearch
    
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    jmp UpdStaffStart

UpdStaffSearch:
    mov ebx, OFFSET staffList
    mov ecx, MAX_STAFF

UpdStaffSearchLoop:
    push ecx
    cmp (Staff PTR [ebx]).staffActive, 0
    je UpdStaffSearchNext

    mov esi, OFFSET inUser
    lea edi, (Staff PTR [ebx]).staffUsername
    call StringCompare
    cmp eax, 1
    je UpdStaffFoundPop

UpdStaffSearchNext:
    add ebx, TYPE Staff
    pop ecx
    dec ecx
    jz UpdStaffFail
    jmp UpdStaffSearchLoop

UpdStaffFail:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgStaffNotFound
    call WriteString
    call WaitMsg
    jmp UpdStaffStart

UpdStaffFoundPop:
    pop ecx                       

UpdStaffPromptPass:
    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgRegPass
    call WriteString
    mov edx, OFFSET inPass
    mov ecx, SIZEOF inPass
    call ReadString

    cmp inPass[0], 0
    jne UpdStaffSavePass

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgErrEmpty
    call WriteString
    call WaitMsg
    call Crlf                   
    jmp UpdStaffPromptPass

UpdStaffSavePass:
    mov esi, OFFSET inPass
    lea edi, (Staff PTR [ebx]).staffPassword
    call StringCopy

    mov edi, OFFSET inPass
    mov ecx, SIZEOF inPass
    call SecureZeroMemory

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgStaffUpdated
    call WriteString
    call Crlf
    call WaitMsg
    ret
UpdateStaff ENDP

ShowStaffTable PROC
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET staffListTitle
    call WriteString

    cmp staffCount, 0
    jne ShowStaffEntriesHelper

    mov edx, OFFSET staffListEmpty
    call WriteString
    ret

ShowStaffEntriesHelper:
    mov edx, OFFSET staffListHeader
    call WriteString

    mov esi, OFFSET staffList
    mov ecx, MAX_STAFF
    mov ebx, 1

ViewStaffLoopHelper:
    push ecx
    cmp (Staff PTR [esi]).staffActive, 0
    je SkipStaffDisplayHelper

    mov eax, ebx
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar

    lea edx, (Staff PTR [esi]).staffUsername
    call WriteString

    lea edx, (Staff PTR [esi]).staffUsername
    call StrLength
    mov ecx, 33
    sub ecx, eax
PadStaffNameLoopHelper:
    mov al, ' '
    call WriteChar
    loop PadStaffNameLoopHelper

    lea edx, (Staff PTR [esi]).staffPassword
    call WriteString
    call Crlf

    inc ebx

SkipStaffDisplayHelper:
    add esi, TYPE Staff
    pop ecx
    dec ecx
    jz ViewStaffLoopHelperDone
    jmp ViewStaffLoopHelper
ViewStaffLoopHelperDone:
    ret
ShowStaffTable ENDP

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
    
    mov edi, OFFSET inUser
    mov ecx, SIZEOF inUser
    call SecureZeroMemory

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
    call SecureZeroMemory

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
    call Crlf                   
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
    mov edi, OFFSET memUser
    call StringCompare
    cmp eax, 1
    je DupFound

    mov ebx, OFFSET staffList
    mov ecx, MAX_STAFF

CheckStaffDupLoop:
    push ecx
    cmp (Staff PTR [ebx]).staffActive, 0
    je SkipStaffDupCheck

    mov esi, OFFSET inUser
    lea edi, (Staff PTR [ebx]).staffUsername
    call StringCompare
    cmp eax, 1
    je DupFoundPopFirst

SkipStaffDupCheck:
    add ebx, TYPE Staff
    pop ecx
    dec ecx
    jz CheckStaffDupDone
    jmp CheckStaffDupLoop

CheckStaffDupDone:
    mov eax, 0
    ret

DupFoundPopFirst:
    pop ecx
    jmp DupFound

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
; UTILITY & HELPER PROCS
; ==========================================
GetSizeOffset PROC
    sub eax, MIN_SIZE
    shl eax, 2
    ret
GetSizeOffset ENDP

PrintDynamicIDErrMsg PROC
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET errStockID1
    call WriteString
    mov eax, NUM_SHOES
    call WriteDec
    mov edx, OFFSET errStockID2
    call WriteString
    ret
PrintDynamicIDErrMsg ENDP

SecureZeroMemory PROC
    push eax
    mov al, 0
    rep stosb
    pop eax
    ret
SecureZeroMemory ENDP

StringCompare PROC
CompareLoop:
    mov al, [esi]
    mov dl, [edi]       
    cmp al, dl
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

ReadValidInt PROC
    LOCAL rviBuf[16]:BYTE
    push ebx
    push edx
    push esi
    push edi

    lea edi, rviBuf
    mov ecx, 16
    mov al, 0
    rep stosb
    lea edx, rviBuf
    mov ecx, 15
    call ReadString
    pop edi

    cmp eax, 0
    je RVI_Bad

    mov ecx, eax
    lea esi, rviBuf
    mov ebx, 0
RVI_Loop:
    movzx eax, BYTE PTR [esi]
    cmp al, '0'
    jb RVI_Bad
    cmp al, '9'
    ja RVI_Bad
    sub eax, '0'
    imul ebx, ebx, 10
    add ebx, eax
    inc esi
    
    dec ecx
    jz RVI_EndLoop
    jmp RVI_Loop

RVI_EndLoop:
    mov eax, ebx
    mov ecx, 1
    pop esi
    pop edx
    pop ebx
    ret
RVI_Bad:
    mov eax, 0
    mov ecx, 0
    pop esi
    pop edx
    pop ebx
    ret
ReadValidInt ENDP

; ==========================================
; INVENTORY / CATALOG MANAGEMENT
; ==========================================
AddStock PROC
    call Clrscr
    call displayCatalog

PromptAddID:
    mov edx, OFFSET msgPromptShoeID
    call Crlf
    call WriteString
    mov eax, NUM_SHOES
    call WriteDec
    mov edx, OFFSET msgPromptShoeID2
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je AddIDNoOverflow

    call PrintDynamicIDErrMsg
    jmp PromptAddID

AddIDNoOverflow:
    cmp eax, 1
    jl InvalidShoeAdd
    cmp eax, NUM_SHOES
    jg InvalidShoeAdd
    jmp AddIDValid

InvalidShoeAdd:
    call PrintDynamicIDErrMsg
    jmp PromptAddID

AddIDValid:
    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoes
    add esi, eax                    ; ESI now points to selected Shoe

PromptAddSize:
    mov edx, OFFSET msgPromptSize
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je AddSizeValid

    mov edx, OFFSET errSize
    call WriteString
    jmp PromptAddSize

AddSizeValid:
    cmp eax, MIN_SIZE
    jl InvalidAddSize
    cmp eax, MAX_SIZE
    jg InvalidAddSize
    mov selectedSize, eax
    jmp PromptAddQty

InvalidAddSize:
    mov edx, OFFSET errSize
    call WriteString
    jmp PromptAddSize

PromptAddQty:
    mov edx, OFFSET msgPromptAddQty
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je AddQtyNoOverflow
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptAddQty

AddQtyNoOverflow:
    cmp eax, 0
    jle InvalidQtyAdd

    ; Calculate pointer to exact size array block
    push eax
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]   ; 40 is offset inside STRUCT to where sizes start
    pop eax

    add [edi], eax
    mov edx, OFFSET msgStockUpdated
    call Crlf
    call WriteString
    call WaitMsg
    ret

InvalidQtyAdd:
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptAddQty
AddStock ENDP

RemoveStock PROC
    call Clrscr
    call displayCatalog

PromptRemID:
    mov edx, OFFSET msgPromptShoeID
    call Crlf
    call WriteString
    mov eax, NUM_SHOES
    call WriteDec
    mov edx, OFFSET msgPromptShoeID2
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je RemIDNoOverflow
    
    call PrintDynamicIDErrMsg
    jmp PromptRemID

RemIDNoOverflow:
    cmp eax, 1
    jl InvalidShoeRem
    cmp eax, NUM_SHOES
    jg InvalidShoeRem
    jmp RemIDValid

InvalidShoeRem:
    call PrintDynamicIDErrMsg
    jmp PromptRemID

RemIDValid:
    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoes
    add esi, eax

PromptRemSize:
    mov edx, OFFSET msgPromptSize
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je RemSizeValid

    mov edx, OFFSET errSize
    call WriteString
    jmp PromptRemSize

RemSizeValid:
    cmp eax, MIN_SIZE
    jl InvalidRemSize
    cmp eax, MAX_SIZE
    jg InvalidRemSize
    mov selectedSize, eax
    jmp PromptRemQty

InvalidRemSize:
    mov edx, OFFSET errSize
    call WriteString
    jmp PromptRemSize

PromptRemQty:
    mov edx, OFFSET msgPromptRemQty
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je RemQtyNoOverflow
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptRemQty

RemQtyNoOverflow:
    cmp eax, 0
    jle InvalidQtyRem

    push eax
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax] 
    pop eax

    cmp eax, [edi]
    ja InvalidRemoveTooMuch

    sub [edi], eax

    mov edx, OFFSET msgStockUpdated
    call Crlf
    call WriteString
    call WaitMsg
    ret

InvalidRemoveTooMuch:
    mov edx, OFFSET errRemoveQty
    call WriteString
    jmp PromptRemQty

InvalidQtyRem:
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptRemQty
RemoveStock ENDP

UpdateStock PROC
    call Clrscr
    call displayCatalog

PromptUpdID:
    mov edx, OFFSET msgPromptShoeID
    call Crlf
    call WriteString
    mov eax, NUM_SHOES
    call WriteDec
    mov edx, OFFSET msgPromptShoeID2
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je UpdIDNoOverflow

    call PrintDynamicIDErrMsg
    jmp PromptUpdID

UpdIDNoOverflow:
    cmp eax, 1
    jl InvalidShoeUpd
    cmp eax, NUM_SHOES
    jg InvalidShoeUpd
    jmp UpdIDValid

InvalidShoeUpd:
    call PrintDynamicIDErrMsg
    jmp PromptUpdID

UpdIDValid:
    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoes
    add esi, eax

PromptUpdSize:
    mov edx, OFFSET msgPromptSize
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je UpdSizeValid

    mov edx, OFFSET errSize
    call WriteString
    jmp PromptUpdSize

UpdSizeValid:
    cmp eax, MIN_SIZE
    jl InvalidUpdSize
    cmp eax, MAX_SIZE
    jg InvalidUpdSize
    mov selectedSize, eax
    jmp PromptUpdQty

InvalidUpdSize:
    mov edx, OFFSET errSize
    call WriteString
    jmp PromptUpdSize

PromptUpdQty:
    mov edx, OFFSET msgPromptNewQty
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je UpdQtyNoOverflow
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptUpdQty

UpdQtyNoOverflow:
    cmp eax, 0
    jle InvalidQtyUpd

    push eax
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax] 
    pop eax

    mov [edi], eax

PromptUpdPrice:
    mov edx, OFFSET msgPromptNewPrice
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je UpdPriceNoOverflow
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptUpdPrice

UpdPriceNoOverflow:
    cmp eax, 0
    jle InvalidPriceUpd

    mov (Shoe PTR [esi]).shoePrice, eax

    mov edx, OFFSET msgStockUpdated
    call Crlf
    call WriteString
    call WaitMsg
    ret

InvalidQtyUpd:
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptUpdQty

InvalidPriceUpd:
    mov edx, OFFSET errStockQty
    call WriteString
    jmp PromptUpdPrice
UpdateStock ENDP

ViewStock PROC
    call Clrscr
    call displayCatalog
    call Crlf
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET returnMsg
    call WriteString
    call ReadChar
    ret
ViewStock ENDP

; ==========================================
; RICH TERMINAL CATALOG DISPLAY
; ==========================================
displayCatalog PROC
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET header
    call WriteString

    mov esi, OFFSET shoes        
    mov ecx, NUM_SHOES     
    mov bl, 3                    

L1:
    push ecx
    mov eax, currentTheme
    call SetTextColor

    ; ID
    mov dh, bl                   
    mov dl, 0
    call Gotoxy
    mov eax, (Shoe PTR [esi]).shoeID
    call WriteDec

    ; Name
    mov dh, bl
    mov dl, 4
    call Gotoxy
    lea edx, (Shoe PTR [esi]).shoeName   
    call WriteString

    ; Price
    mov dh, bl
    mov dl, 36
    call Gotoxy
    mov eax, (Shoe PTR [esi]).shoePrice
    call WriteDec

    ; Separator
    mov dh, bl
    mov dl, 43
    call Gotoxy
    mov al, '|'
    call WriteChar

    ; Iterate over 6 Sizes (40-45)
    mov ecx, NUM_SIZES
    mov edi, 0          ; Total sum accumulator
    lea edx, [esi + 40] ; Start of size arrays offset
    mov printCol, 45    

PrintSizeLoop:
    push ecx
    push edx            
    
    mov dh, bl
    mov dl, printCol    
    call Gotoxy

    pop edx             

    mov eax, [edx]      
    add edi, eax        

    cmp eax, 10
    jge SetGreenQty
    cmp eax, 3
    jl SetRedQty
    mov eax, currentTheme
    call SetTextColor
    jmp DoPrintQty

SetGreenQty:
    mov eax, currentTheme
    and eax, 0F0h               
    or  eax, green              
    call SetTextColor
    jmp DoPrintQty
SetRedQty:
    mov eax, currentTheme
    and eax, 0F0h               
    or  eax, lightRed           
    call SetTextColor

DoPrintQty:
    mov eax, [edx]
    call WriteDec

    mov eax, currentTheme
    call SetTextColor

    add edx, 4          
    add printCol, 4     
    
    pop ecx
    dec ecx
    jz PrintSizeLoopDone
    jmp PrintSizeLoop

PrintSizeLoopDone:
    mov dh, bl
    mov dl, 68
    call Gotoxy
    mov al, '|'
    call WriteChar

    mov dh, bl
    mov dl, 70
    call Gotoxy
    mov eax, edi
    call WriteDec

    inc bl                       
    add esi, TYPE Shoe
    
    pop ecx                     
    dec ecx
    jz L1_Done
    jmp L1                      

L1_Done:
    mov dh, bl
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET footer
    call WriteString
    ret 
displayCatalog ENDP


; ==========================================
; PURCHASE (INPUT) & CART SYSTEM
; ==========================================
getInput PROC
.REPEAT
getInputTop:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    call displayCatalog
    call DisplayCart       

inputID:
    mov edx, OFFSET getShoeID1
    call Crlf
    call WriteString
    mov eax, NUM_SHOES
    call WriteDec
    mov edx, OFFSET getShoeID2
    call WriteString
    mov eax, NUM_SHOES
    inc eax
    call WriteDec
    mov edx, OFFSET getShoeID3
    call WriteString

    call ReadValidInt
    cmp ecx, 1
    je IDReadOK
    call PrintDynamicIDErrMsg
    jmp inputID

IDReadOK:
    mov ebx, NUM_SHOES
    inc ebx
    cmp eax, ebx
    je GoEditCart

    cmp eax, NUM_SHOES
    jg ErrInput
    cmp eax, 1
    jl ErrInput
    jmp ExitInputID

ErrInput:
    call PrintDynamicIDErrMsg
    jmp inputID

GoEditCart:
    call EditCart
    jmp getInputTop

ExitInputID:
    mov id, eax     

PromptCartSize:
    mov edx, OFFSET msgPromptSize
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je CartSizeValid

    mov edx, OFFSET errSize
    call WriteString
    jmp PromptCartSize

CartSizeValid:
    cmp eax, MIN_SIZE
    jl InvalidCartSize
    cmp eax, MAX_SIZE
    jg InvalidCartSize
    mov selectedSize, eax
    jmp CalculateSizeLimit

InvalidCartSize:
    mov edx, OFFSET errSize
    call WriteString
    jmp PromptCartSize

CalculateSizeLimit:
    mov ebx, id
    dec ebx                         
    mov eax, TYPE Shoe
    mul ebx
    mov ebx, eax                    
    
    mov esi, OFFSET shoes
    add esi, ebx

    push ebx
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax] 
    mov eax, [edi]                      ; Store Stock
    pop ebx

    mov limit, eax                  
    
    mov edi, OFFSET shoeCart
    add edi, ebx

    push ebx
    mov eax, selectedSize
    call GetSizeOffset
    lea esi, [edi + 40 + eax]
    mov eax, [esi]                      ; Cart Stock
    pop ebx

    mov edx, limit
    sub edx, eax                  
    mov limit, edx                  

    mov eax, limit
    cmp eax, 0
    jg inputQty
    
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET errEmpty
    call Crlf
    call WriteString
    call WaitMsg
    call Crlf                       
    jmp inputID                     

inputQty:
    mov edx, OFFSET getShoeQty
    call Crlf
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je QtyReadOK
    mov edx, OFFSET errQty
    call WriteString
    jmp inputQty

QtyReadOK:
    mov edx, limit
    cmp eax, edx
    jg ErrMsg
    cmp eax, 1
    jl ErrMsg
    jmp ExitInputQty
   
ErrMsg:
    mov edx, OFFSET errQty
    call WriteString
    jmp inputQty

ExitInputQty:
    mov qty, eax    
    
    ; Add Cart (Per Size Array Index)
    mov ebx, id
    dec ebx                     
    mov eax, TYPE Shoe
    mul ebx                     
    mov ebx, eax

    mov esi, OFFSET shoeCart
    add esi, ebx                
    
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]

    mov eax, qty
    add [edi], eax

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

ClearCart PROC
    mov esi, OFFSET shoeCart
    mov ecx, NUM_SHOES
ClearLoop:
    push ecx
    mov ecx, NUM_SIZES
    lea edi, [esi + 40]
ZeroArray:
    mov DWORD PTR [edi], 0
    add edi, 4
    dec ecx
    jz ZeroArrayDone
    jmp ZeroArray
ZeroArrayDone:

    pop ecx
    add esi, TYPE Shoe
    dec ecx
    jz ClearLoopDone
    jmp ClearLoop
ClearLoopDone:
    ret
ClearCart ENDP

DisplayCart PROC
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET cartTitle
    call WriteString

    mov esi, OFFSET shoeCart
    mov ecx, NUM_SHOES
    mov ebx, 0                      ; Tracking total discrete items printed
    mov currentID, 1

DisplayCartLoop:
    push ecx
    
    mov ecx, NUM_SIZES
    mov id, MIN_SIZE                ; recycle id var purely as iterator offset

SizeDisplayLoop:
    push ecx
    mov eax, id
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov eax, [edi]                  ; Fetch size quantity
    cmp eax, 0
    je SkipSizeItem

    inc ebx

    ; --- Print Item ID ---
    mov eax, currentID
    call WriteDec
    mov edx, OFFSET idSeparator     ; Define this in .data (e.g., idSeparator BYTE ". ", 0)
    call WriteString
    ; ----------------------

    lea edx, (Shoe PTR [esi]).shoeName
    call WriteString

    mov edx, OFFSET szText1
    call WriteString
    mov eax, id
    call WriteDec
    mov edx, OFFSET szText2
    call WriteString

    mov edx, OFFSET quantityLabel
    call WriteString
    mov eax, [edi]
    call WriteDec

    mov edx, OFFSET subtotalLabel
    call WriteString
    mov eax, (Shoe PTR [esi]).shoePrice
    mov ecx, [edi]
    mul ecx                         ; Subtotal = Price * SizeQty
    mov ecx, CENT
    mul ecx
    call DisplayMoney
    call Crlf

SkipSizeItem:
    inc id
    pop ecx
    dec ecx
    jz SizeDisplayDone
    jmp SizeDisplayLoop

SizeDisplayDone:
    pop ecx
    add esi, TYPE Shoe
    inc currentID                   ; <--- Increment ID for the next shoe model
    dec ecx
    jz DisplayCartLoopDone
    jmp DisplayCartLoop

DisplayCartLoopDone:
    cmp ebx, 0
    jne CartDone
    mov edx, OFFSET cartEmptyMsg
    call WriteString

CartDone:
    mov edx, OFFSET cartFooter
    call WriteString
    ret
DisplayCart ENDP

EditCart PROC
    LOCAL edCartPtr:DWORD, edStorePtr:DWORD, edLimit:DWORD

EditCartLoop:
    mov eax, currentTheme
    call SetTextColor
    call Clrscr
    call DisplayCart

    mov edx, OFFSET msgEditCartPrompt
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je EditIDReadOK
    mov edx, OFFSET msgInvalidEntry
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditIDReadOK:
    cmp eax, 0
    je EditCartDone

    cmp eax, 1
    jl EditCartBadID
    cmp eax, NUM_SHOES
    jg EditCartBadID
    jmp EditIDValid

EditCartBadID:
    call PrintDynamicIDErrMsg
    call WaitMsg
    jmp EditCartLoop

EditIDValid:
    dec eax
    mov ebx, TYPE Shoe
    mul ebx
    mov esi, OFFSET shoeCart
    add esi, eax
    mov edCartPtr, esi

    mov esi, OFFSET shoes
    add esi, eax
    mov edStorePtr, esi

EditPromptSize:
    mov edx, OFFSET msgEditSizePrompt
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je EditSizeOK

    mov edx, OFFSET msgInvalidEntry
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditSizeOK:
    cmp eax, MIN_SIZE
    jl EditCartBadSize
    cmp eax, MAX_SIZE
    jg EditCartBadSize
    mov selectedSize, eax

    ; Verify if item/size is actually in cart
    mov esi, edCartPtr
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov eax, [edi]
    cmp eax, 0
    jne EditShowSubMenu

    mov edx, OFFSET msgItemNotInCart
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditCartBadSize:
    mov edx, OFFSET errSize
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditShowSubMenu:
    mov edx, OFFSET msgEditSubMenu
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je EditSubOK
    mov edx, OFFSET msgInvalidEntry
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditSubOK:
    cmp eax, 1
    je EditDoUpdateSize
    cmp eax, 2
    je EditDoUpdateQty
    cmp eax, 3
    je EditDoRemove
    jmp EditCartLoop           

EditDoRemove:
    mov esi, edCartPtr
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov DWORD PTR [edi], 0
    mov edx, OFFSET msgItemRemoved
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditDoUpdateQty:
    mov esi, edStorePtr
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov eax, [edi]   
    mov edLimit, eax
    jmp EditQtyPrompt           ; <-- Redirects control flow directly to quantity prompt

EditDoUpdateSize:
    ; 1. Store the existing quantity for the old size
    mov esi, edCartPtr
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov ebx, [edi]              ; Save existing quantity into EBX

EditNewSizePrompt:
    ; 2. Prompt for the new shoe size
    mov edx, OFFSET msgEditSizePrompt
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    jne EditNewSizeInvalid

    ; 3. Validate new size boundary
    cmp eax, MIN_SIZE
    jl EditNewSizeInvalid
    cmp eax, MAX_SIZE
    jg EditNewSizeInvalid

    ; 4. Clear old size quantity in cart
    mov DWORD PTR [edi], 0

    ; 5. Update selectedSize and write saved quantity to new slot
    mov selectedSize, eax
    mov esi, edCartPtr
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov [edi], ebx              ; Transfer saved quantity to new size

    mov edx, OFFSET msgCartUpdated 
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditNewSizeInvalid:
    mov edx, OFFSET errSize
    call WriteString
    call WaitMsg
    jmp EditNewSizePrompt

EditQtyPrompt:
    mov edx, OFFSET msgPromptNewQty
    call WriteString
    call ReadValidInt
    cmp ecx, 1
    je EditQtyReadOK
    mov edx, OFFSET errStockQty
    call WriteString
    jmp EditQtyPrompt

EditQtyReadOK:
    cmp eax, 0
    jle EditQtyBad
    mov ebx, edLimit
    cmp eax, ebx
    jg EditQtyBad
    jmp EditQtyGood

EditQtyBad:
    mov edx, OFFSET errStockQty
    call WriteString
    jmp EditQtyPrompt

EditQtyGood:
    mov ecx, eax
    mov esi, edCartPtr
    mov eax, selectedSize
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov [edi], ecx

    mov edx, OFFSET msgCartUpdated
    call WriteString
    call WaitMsg
    jmp EditCartLoop

EditCartDone:
    ret
EditCart ENDP

; ==========================================
; RECEIPT & FINANCIAL ENGINE
; ==========================================
GenerateInvoice PROC
    mov eax, currentTheme
    call SetTextColor
    call Clrscr

    mov eax, 0                  
    mov esi, OFFSET shoeCart
    mov ecx, NUM_SHOES

CalcCartTotal:
    push ecx
    mov ecx, NUM_SIZES
    mov id, MIN_SIZE

AggregateSizePrice:
    push ecx
    mov ebx, id
    mov eax, ebx
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov ebx, [edi]                  ; Size Quantity
    cmp ebx, 0
    je SkipSizeCalc

    mov eax, (Shoe PTR [esi]).shoePrice
    mul ebx
    add totalSubtotal, eax          ; Temporary storage logic

SkipSizeCalc:
    inc id
    pop ecx
    dec ecx
    jz AggregateSizeDone
    jmp AggregateSizePrice

AggregateSizeDone:
    pop ecx
    add esi, TYPE Shoe
    dec ecx
    jz CalcCartTotalDone
    jmp CalcCartTotal

CalcCartTotalDone:
    mov eax, totalSubtotal
    mov ebx, CENT
    mul ebx
    mov totalSubtotal, eax          ; Formatted into cents

    call CalculateDiscount
    call CalculateTaxableAmount
    call CalculateSST
    call CalculateGrandTotal
    call DisplayInvoice
    ret
GenerateInvoice ENDP

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

CalculateTaxableAmount PROC
    mov eax, totalSubtotal
    sub eax, discountAmount
    mov taxableAmount, eax
    ret
CalculateTaxableAmount ENDP

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

CalculateGrandTotal PROC
    mov eax, totalSubtotal
    sub eax, discountAmount
    add eax, sstAmount
    mov grandTotal, eax
    ret
CalculateGrandTotal ENDP

DisplayInvoice PROC
    mov edx, OFFSET invoiceTitle
    call WriteString

    mov esi, OFFSET shoeCart
    mov ecx, NUM_SHOES

DisplayInvoiceLoop:
    push ecx
    
    mov ecx, NUM_SIZES
    mov id, MIN_SIZE
InvSizeLoop:
    push ecx
    mov eax, id
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov ebx, [edi]
    cmp ebx, 0
    je InvSkipItem

    lea edx, (Shoe PTR [esi]).shoeName
    call WriteString

    mov edx, OFFSET szText1
    call WriteString
    mov eax, id
    call WriteDec
    mov edx, OFFSET szText2
    call WriteString

    mov edx, OFFSET quantityLabel
    call WriteString
    mov eax, ebx
    call WriteDec
    
    mov edx, OFFSET subtotalLabel
    call WriteString
    mov eax, (Shoe PTR [esi]).shoePrice
    mul ebx
    mov ecx, CENT
    mul ecx
    call DisplayMoney
    call Crlf

InvSkipItem:
    inc id
    pop ecx
    dec ecx
    jz InvSizeLoopDone
    jmp InvSizeLoop

InvSizeLoopDone:
    pop ecx
    add esi, TYPE Shoe
    dec ecx
    jz DisplayInvoiceLoopDone
    jmp DisplayInvoiceLoop

DisplayInvoiceLoopDone:
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

ConfirmOrder PROC
ConfirmLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET msgConfirmOrder
    call WriteString

    call ReadChar
    call WriteChar
    call Crlf

    cmp al, 'Y'
    je ConfirmYes
    cmp al, 'y'
    je ConfirmYes
    cmp al, 'N'
    je ConfirmNo
    cmp al, 'n'
    je ConfirmNo

    mov edx, OFFSET invalidConfirmMsg
    call WriteString
    jmp ConfirmLoop

ConfirmYes:
    mov eax, 1
    ret

ConfirmNo:
    mov totalSubtotal, 0
    mov edx, OFFSET msgModifyOrder
    call WriteString
    call WaitMsg
    mov eax, 0
    ret
ConfirmOrder ENDP

; ==========================================
; PAYMENT & TRANSACTIONS
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

    call ReadValidInt
    cmp ecx, 1
    je PaymentNoOverflow
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidPayment
    call WriteString
    jmp PaymentMenuLoop

PaymentNoOverflow:
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

    mov al, inputBuffer[0]
    cmp al, '0'
    jne CashNotCancelled
    cmp inputBuffer[1], 0
    je CashCancelled

CashNotCancelled:
    mov edx, OFFSET inputBuffer
    call ParseRMToCents

    cmp ebx, 1
    je ValidCashAmount

    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidAmountMsg
    call WriteString
    call Crlf                   
    jmp CashPaymentLoop

CashCancelled:
    jmp PaymentMenuLoop

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
    mov edx, OFFSET msgSwitchMethod
    call WriteString

    call ReadChar
    call WriteChar
    call Crlf

    cmp al, 'C'
    je CashCancelled
    cmp al, 'c'
    je CashCancelled
    call Crlf                   
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
    cmp ecx, 0
    je CardEntryCancelled
    cmp ecx, 16
    jne InvalidCardInput

    mov BYTE PTR [esi], 0
    call Crlf
    jmp ExpiryInputLoop

CardEntryCancelled:
    call Crlf
    jmp PaymentMenuLoop

InvalidCardInput:
    call Crlf
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidCardMsg
    call WriteString
    call Crlf                   

    mov edi, OFFSET cardNumber
    mov ecx, SIZEOF cardNumber
    call SecureZeroMemory

    jmp CardNumberLoop

ExpiryInputLoop:
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET expiryMsg
    call WriteString

    mov edx, OFFSET expiryDate
    mov ecx, SIZEOF expiryDate
    call ReadString

    mov edx, OFFSET expiryDate
    call ValidateExpiryDate

    cmp eax, 1                  
    je CVVLoop

    call Crlf                   
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidExpiryMsg
    call WriteString
    call Crlf                   
    jmp ExpiryInputLoop

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
    
    call Crlf                   
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidCVVMsg
    call WriteString
    call Crlf                   
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
    
    call Crlf                   
    mov eax, currentTheme
    call SetTextColor
    mov edx, OFFSET invalidQRMsg
    call WriteString
    call Crlf                   
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

GenerateReceipt PROC
    mov eax, currentTheme
    call SetTextColor
    call Crlf

    mov edx, OFFSET receiptTitle
    call WriteString
    
    mov edx, OFFSET productHeader
    call WriteString
    mov edx, OFFSET separatorMsg
    call WriteString

    mov esi, OFFSET shoeCart
    mov ecx, NUM_SHOES

ReceiptItemLoop:
    push ecx
    
    mov ecx, NUM_SIZES
    mov id, MIN_SIZE
RcpSizeLoop:
    push ecx
    mov eax, id
    call GetSizeOffset
    lea edi, [esi + 40 + eax]
    mov ebx, [edi]
    cmp ebx, 0
    je RcpSkipSize

    lea edx, (Shoe PTR [esi]).shoeName
    call WriteString

    mov edx, OFFSET szText1
    call WriteString
    mov eax, id
    call WriteDec
    mov edx, OFFSET szText2
    call WriteString

    ; Pad Shoe Name Column
    lea edx, (Shoe PTR [esi]).shoeName
    call StrLength             
    mov ecx, 32
    sub ecx, eax
PadNameLoop:
    mov al, ' '
    call WriteChar
    dec ecx
    jz PadNameLoopDone
    jmp PadNameLoop
PadNameLoopDone:

    mov eax, ebx
    call WriteDec
    
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov eax, (Shoe PTR [esi]).shoePrice
    mov ecx, CENT
    mul ecx                     
    call DisplayMoney

    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov eax, (Shoe PTR [esi]).shoePrice
    mul ebx
    mov ecx, CENT
    mul ecx                     
    call DisplayMoney
    call Crlf

RcpSkipSize:
    inc id
    pop ecx
    dec ecx
    jz RcpSizeLoopDone
    jmp RcpSizeLoop

RcpSizeLoopDone:
    pop ecx
    add esi, TYPE Shoe
    dec ecx
    jz ReceiptItemLoopDone
    jmp ReceiptItemLoop

ReceiptItemLoopDone:
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
    call RecordTransaction            
    call UpdateStockAfterPurchase    

    ; Zero Sensitive Data Before Exiting Receipt Screen
    mov edi, OFFSET cardNumber
    mov ecx, SIZEOF cardNumber
    call SecureZeroMemory
    mov edi, OFFSET cvvNumber
    mov ecx, SIZEOF cvvNumber
    call SecureZeroMemory
    mov edi, OFFSET expiryDate
    mov ecx, SIZEOF expiryDate
    call SecureZeroMemory
    mov totalSubtotal, 0

    mov edx, OFFSET returnMsg
    call WriteString
    call ReadChar
    ret
GenerateReceipt ENDP

DisplayMoney PROC
    push ebx
    push edx

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

    pop edx
    pop ebx
    ret
DisplayMoney ENDP

RecordTransaction PROC
    mov eax, salesCount
    mov ebx, TYPE PurchaseRecord
    mul ebx
    mov esi, OFFSET salesHistory
    add esi, eax

    mov eax, lifetimeTransactions
    inc eax
    mov lifetimeTransactions, eax
    mov (PurchaseRecord PTR [esi]).transactionID, eax

    mov eax, grandTotal
    mov (PurchaseRecord PTR [esi]).totalAmount, eax

    mov eax, paymentMethod
    mov (PurchaseRecord PTR [esi]).paymentType, eax

    ; --- Extract Shoe ID and Calculate Total Pairs ---
    mov edi, OFFSET shoeCart
    mov ecx, NUM_SHOES
    mov ebx, 0            ; Total pairs counter
    mov edx, 0            ; Store first matched Shoe ID

CountItemsLoop:
    push ecx
    mov ecx, NUM_SIZES
    lea eax, [edi + 40]   ; Pointer to size array

SumSizesForRec:
    push eax
    mov eax, [eax]
    cmp eax, 0
    je SkipShoeIDCapture

    ; Capture shoeID if not already set
    cmp edx, 0
    jne KeepShoeID
    mov edx, (Shoe PTR [edi]).shoeID

KeepShoeID:
    add ebx, eax

SkipShoeIDCapture:
    pop eax
    add eax, 4
    dec ecx
    jz SumSizesForRecDone
    jmp SumSizesForRec

SumSizesForRecDone:
    pop ecx
    add edi, TYPE Shoe
    dec ecx
    jz CountItemsLoopDone
    jmp CountItemsLoop

CountItemsLoopDone:
    mov (PurchaseRecord PTR [esi]).shoeID, edx
    mov (PurchaseRecord PTR [esi]).itemCount, ebx

    inc salesCount
    mov eax, salesCount
    cmp eax, MAX_SALES
    jb RecordTransactionDone
    
    mov salesCount, 0

RecordTransactionDone:
    ret
RecordTransaction ENDP

GenerateSalesReport PROC
    LOCAL totalRev:DWORD, totalPairs:DWORD, countCash:DWORD, countCard:DWORD, countQR:DWORD, iterLimit:DWORD
    
    mov totalRev, 0
    mov totalPairs, 0
    mov countCash, 0
    mov countCard, 0
    mov countQR, 0

    mov eax, currentTheme
    call SetTextColor
    call Clrscr

    mov edx, OFFSET reportTitle
    call WriteString

    cmp lifetimeTransactions, 0
    jne SetupReportLoop

    mov edx, OFFSET repNoSales
    call WriteString
    call Crlf
    call WaitMsg
    ret

SetupReportLoop:
    mov edx, OFFSET repHeader
    call WriteString

    mov eax, lifetimeTransactions
    cmp eax, MAX_SALES
    jae SetupMaxLoop
    mov iterLimit, eax
    jmp StartReportPrint

SetupMaxLoop:
    mov iterLimit, MAX_SALES

StartReportPrint:
    mov esi, OFFSET salesHistory
    mov ecx, iterLimit

ReportLoop:
    push ecx

    ; 1. Print Transaction ID
    mov eax, (PurchaseRecord PTR [esi]).transactionID
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar


    ; 2. Print Quantity (itemCount)
    mov eax, (PurchaseRecord PTR [esi]).itemCount
    add totalPairs, eax             
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    ; 3. Print Payment Method
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

    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar

    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar

    ; 4. Print Total Amount
    mov eax, (PurchaseRecord PTR [esi]).totalAmount
    add totalRev, eax               
    call DisplayMoney
    call Crlf

    add esi, TYPE PurchaseRecord
    pop ecx
    dec ecx
    jz ReportLoopDone
    jmp ReportLoop

ReportLoopDone:
    mov edx, OFFSET separatorMsg
    call WriteString

    mov edx, OFFSET repTotalTx
    call WriteString
    mov eax, lifetimeTransactions
    call WriteDec

    mov edx, OFFSET repTotalPairs    
    call WriteString
    mov eax, totalPairs
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

UpdateStockAfterPurchase PROC
    mov esi, OFFSET shoeCart
    mov edi, OFFSET shoes
    mov ecx, NUM_SHOES

UpdateLoop:
    push ecx
    
    mov ecx, NUM_SIZES
    lea edx, [esi + 40]         ; cart sizes ptr
    lea ebx, [edi + 40]         ; store sizes ptr

UpdateSizeLoop:
    mov eax, [edx]
    cmp eax, 0
    je SkipStockUpdate

    cmp eax, [ebx]
    ja InventoryUnderflow           

    sub [ebx], eax
    jmp SkipStockUpdate

InventoryUnderflow:
    mov DWORD PTR [ebx], 0

SkipStockUpdate:
    add edx, 4
    add ebx, 4
    dec ecx
    jz UpdateSizeLoopDone
    jmp UpdateSizeLoop

UpdateSizeLoopDone:
    pop ecx
    add esi, TYPE Shoe
    add edi, TYPE Shoe
    dec ecx
    jz UpdateLoopDone
    jmp UpdateLoop

UpdateLoopDone:
    ret
UpdateStockAfterPurchase ENDP

ValidateExpiryDate PROC
    push esi
    push ebx
    mov esi, edx

    call StrLength
    cmp eax, 5
    jne InvalidExpiry

    mov al, BYTE PTR [esi + 2]
    cmp al, '/'
    jne InvalidExpiry

    mov al, BYTE PTR [esi]
    cmp al, '0'
    jb InvalidExpiry
    cmp al, '9'
    ja InvalidExpiry

    mov al, BYTE PTR [esi + 1]
    cmp al, '0'
    jb InvalidExpiry
    cmp al, '9'
    ja InvalidExpiry

    mov al, BYTE PTR [esi]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, BYTE PTR [esi + 1]
    sub bl, '0'
    add al, bl                     

    cmp al, 1
    jl InvalidExpiry
    cmp al, 12
    jg InvalidExpiry

    mov al, BYTE PTR [esi + 3]
    cmp al, '0'
    jb InvalidExpiry
    cmp al, '9'
    ja InvalidExpiry

    mov al, BYTE PTR [esi + 4]
    cmp al, '0'
    jb InvalidExpiry
    cmp al, '9'
    ja InvalidExpiry

    mov al, BYTE PTR [esi + 3]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, BYTE PTR [esi + 4]
    sub bl, '0'
    add al, bl                     

    cmp al, 26                     
    jl InvalidExpiry

    mov eax, 1                     
    pop ebx
    pop esi
    ret

InvalidExpiry:
    mov eax, 0                     
    pop ebx
    pop esi
    ret
ValidateExpiryDate ENDP

END main