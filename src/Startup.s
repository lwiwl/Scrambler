;/****************************************Copyright (c)**************************************************
;**                               Guangzou ZLG-MCU Development Co.,LTD.
;**                                      graduate school
;**                                 http://www.zlgmcu.com
;**
;**--------------File Info-------------------------------------------------------------------------------
;** File name: 			Startup.s
;** Last modified Date:  2004-09-17
;** Last Version: 		1.0
;** Descriptions: 		The start up codes for LPC2100, including the initializing codes for the entry point of exceptions and the stacks of user tasks.
;**				Every project should have a independent copy of this file for related modifications
;**------------------------------------------------------------------------------------------------------
;** Created by: 			Chenmingji
;** Created date:   		2004-02-02
;** Version:				1.0
;** Descriptions: 		The original version
;**
;**------------------------------------------------------------------------------------------------------
;** Modified by: 		Chenmingji
;** Modified date:		2004-09-17
;** Version:				1.01
;** Descriptions: 		Modified the bus setting to adapt for many common situations 
;**
;**------------------------------------------------------------------------------------------------------
;** Modified by: 		Chenmingji
;** Modified date:		2004-09-17
;** Version:				1.02
;** Descriptions: 		Added codes to support the enciphering of the chip
;**
;**------------------------------------------------------------------------------------------------------
;** Modified by: 		Chenmingji
;** Modified date:		2004-09-17
;** Version:				1.04
;** Descriptions: 		Renewed the template, added codes to support more compilers 
;**
;**------------------------------------------------------------------------------------------------------
;** Modified by: 		
;** Modified date:
;** Version:	
;** Descriptions: 
;**
;********************************************************************************************************/

;define the stack size
;�����ջ�Ĵ�С
SVC_STACK_LEGTH         EQU         0
FIQ_STACK_LEGTH         EQU         0
IRQ_STACK_LEGTH         EQU         256
ABT_STACK_LEGTH         EQU         0
UND_STACK_LEGTH         EQU         0

NoInt       EQU 0x80

USR32Mode   EQU 0x10
SVC32Mode   EQU 0x13
SYS32Mode   EQU 0x1f
IRQ32Mode   EQU 0x12
FIQ32Mode   EQU 0x11

    IMPORT __use_no_semihosting_swi

;The imported labels
;������ⲿ�����������
    IMPORT  FIQ_Exception                   ;Fast interrupt exceptions handler �����ж��쳣�������
    IMPORT  __main                          ;The entry point to the main function C������������� 
    IMPORT  TargetResetInit                 ;initialize the target board Ŀ��������ʼ��

;The emported labels
;���ⲿʹ�õı����������
    EXPORT  bottom_of_heap
    EXPORT  StackUsr
    
    EXPORT  Reset
    EXPORT __user_initial_stackheap

    CODE32

    AREA    vectors,CODE,READONLY
        ENTRY

;interrupt vectors
;�ж�������
Reset
        LDR     PC, ResetAddr
        LDR     PC, UndefinedAddr
        LDR     PC, SWI_Addr
        LDR     PC, PrefetchAddr
        LDR     PC, DataAbortAddr
        DCD     0xb9205f80
        LDR     PC, [PC, #-0xff0]
        LDR     PC, FIQ_Addr

ResetAddr           DCD     ResetInit
UndefinedAddr       DCD     Undefined
SWI_Addr            DCD     SoftwareInterrupt
PrefetchAddr        DCD     PrefetchAbort
DataAbortAddr       DCD     DataAbort
Nouse               DCD     0
IRQ_Addr            DCD     0
FIQ_Addr            DCD     FIQ_Handler


;δ����ָ��
Undefined
        B       Undefined

;���ж�
SoftwareInterrupt			
        B       SoftwareInterrupt	

;ȡָ����ֹ
PrefetchAbort
        B       PrefetchAbort

;ȡ������ֹ
DataAbort
        B       DataAbort

;�����ж�
FIQ_Handler
        STMFD   SP!, {R0-R3, LR}
        BL      FIQ_Exception
        LDMFD   SP!, {R0-R3, LR}
        SUBS    PC,  LR,  #4
        
;/*********************************************************************************************************
;** unction name 	��������: 	InitStack
;** Descriptions 	��������: 	Initialize the stacks  ��ʼ����ջ
;** input parameters 	�䡡��:   	None ��
;** Returned value   	�䡡�� :  	None ��
;** Used global variables ȫ�ֱ���: 	None ��
;** Calling modules 	����ģ��: 	None ��
;** 
;** Created by 		������: 	Chenmingji ������
;** Created Date 	�ա���: 	2004/02/02 2004��2��2��
;**-------------------------------------------------------------------------------------------------------
;** Modified by 	�ޡ���: 
;** Modified date 	�ա���: 
;**-------------------------------------------------------------------------------------------------------
;********************************************************************************************************/
InitStack    
        MOV     R0, LR
;Build the SVC stack
;���ù���ģʽ��ջ
        MSR     CPSR_c, #0xd3		
        LDR     SP, StackSvc	
;Build the IRQ stack	
;�����ж�ģʽ��ջ
        MSR     CPSR_c, #0xd2
        LDR     SP, StackIrq
;Build the FIQ stack
;���ÿ����ж�ģʽ��ջ
        MSR     CPSR_c, #0xd1
        LDR     SP, StackFiq
;Build the DATAABORT stack
;������ֹģʽ��ջ
        MSR     CPSR_c, #0xd7
        LDR     SP, StackAbt
;Build the UDF stack
;����δ����ģʽ��ջ
        MSR     CPSR_c, #0xdb
        LDR     SP, StackUnd
;Build the SYS stack
;����ϵͳģʽ��ջ
        MSR     CPSR_c, #0xdf
        LDR     SP, =StackUsr

        MOV     PC, R0

;/*********************************************************************************************************
;** unction name 	��������: 	ResetInit
;** Descriptions 	��������: 	RESET  ��λ���
;** input parameters 	�䡡��:   	None ��
;** Returned value   	�䡡�� :  	None ��
;** Used global variables ȫ�ֱ���: 	None ��
;** Calling modules 	����ģ��: 	None ��
;** 
;** Created by 		������: 	Chenmingji ������
;** Created Date 	�ա���: 	2004/02/02 2004��2��2��
;**-------------------------------------------------------------------------------------------------------
;** Modified by 	�ޡ���: Chenmingji ������
;** Modified date 	�ա���: 2004/02/02 2004��3��3��
;**-------------------------------------------------------------------------------------------------------
;********************************************************************************************************/
ResetInit
        
        BL      InitStack               ;��ʼ����ջ Initialize the stack
        BL      TargetResetInit         ;Ŀ��������ʼ�� Initialize the target board
                                        ;��ת��c������� Jump to the entry point of C program
        B       __main

;/*********************************************************************************************************
;** unction name 	��������: 	__user_initial_stackheap
;** Descriptions 	��������: 	Initial the function library stacks and heaps, can not deleted!   �⺯����ʼ���Ѻ�ջ������ɾ��
;** input parameters 	�䡡��:   	reference by function library �ο��⺯���ֲ�
;** Returned value   	�䡡�� :  	reference by function library �ο��⺯���ֲ�
;** Used global variables ȫ�ֱ���: 	None ��
;** Calling modules 	����ģ��: 	None ��
;** 
;** Created by 		������: 	Chenmingji ������
;** Created Date 	�ա���: 	2004/02/02 2004��2��2��
;**-------------------------------------------------------------------------------------------------------
;** Modified by 	
;** Modified date 	
;**-------------------------------------------------------------------------------------------------------
;********************************************************************************************************/
__user_initial_stackheap    
    LDR   r0,=bottom_of_heap
;    LDR   r1,=StackUsr
    MOV   pc,lr


StackSvc           DCD     SvcStackSpace + (SVC_STACK_LEGTH - 1)* 4
StackIrq           DCD     IrqStackSpace + (IRQ_STACK_LEGTH - 1)* 4
StackFiq           DCD     FiqStackSpace + (FIQ_STACK_LEGTH - 1)* 4
StackAbt           DCD     AbtStackSpace + (ABT_STACK_LEGTH - 1)* 4
StackUnd           DCD     UndtStackSpace + (UND_STACK_LEGTH - 1)* 4

;/*********************************************************************************************************
;** unction name 	��������: 	CrpData
;** Descriptions 	��������: 	encrypt the chip
;** input parameters 	�䡡��:   	None ��
;** Returned value   	�䡡�� :  	None ��
;** Used global variables ȫ�ֱ���: 	None ��
;** Calling modules 	����ģ��: 	None ��
;** 
;** Created by 		������: 	Chenmingji ������
;** Created Date 	�ա���: 	2004/03/27 2004��3��27��
;**-------------------------------------------------------------------------------------------------------
;** Modified by 	�ޡ���: 
;** Modified date 	�ա���: 
;**-------------------------------------------------------------------------------------------------------
;********************************************************************************************************/
    IF :DEF: EN_CRP
        IF  . >= 0x1fc
        INFO    1,"\nThe data at 0x000001fc must be 0x87654321.\nPlease delete some source before this line."
        ENDIF
CrpData
    WHILE . < 0x1fc
    NOP
    WEND
CrpData1
    DCD     0x87654321          ;/*When the Data is Ϊ0x87654321,user code be protected. ������Ϊ0x87654321ʱ���û����򱻱��� */
    ENDIF
    
;/* �����ջ�ռ� */
        AREA    MyStacks, DATA, NOINIT, ALIGN=2
SvcStackSpace      SPACE   SVC_STACK_LEGTH * 4  ;Stack spaces for Administration Mode ����ģʽ��ջ�ռ�
IrqStackSpace      SPACE   IRQ_STACK_LEGTH * 4  ;Stack spaces for Interrupt ReQuest Mode �ж�ģʽ��ջ�ռ�
FiqStackSpace      SPACE   FIQ_STACK_LEGTH * 4  ;Stack spaces for Fast Interrupt reQuest Mode �����ж�ģʽ��ջ�ռ�
AbtStackSpace      SPACE   ABT_STACK_LEGTH * 4  ;Stack spaces for Suspend Mode ��ֹ��ģʽ��ջ�ռ�
UndtStackSpace     SPACE   UND_STACK_LEGTH * 4  ;Stack spaces for Undefined Mode δ����ģʽ��ջ


        AREA    Heap, DATA, NOINIT
bottom_of_heap    SPACE   1

        AREA    Stacks, DATA, NOINIT
StackUsr

    END
;/*********************************************************************************************************
;**                            End Of File
;********************************************************************************************************/
