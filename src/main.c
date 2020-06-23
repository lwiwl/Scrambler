/*
 * File: main.c
 * Project: Scrambler
 * Created Date: Tuesday June 23rd 2020
 * Author: hong
 * -----
 * Last Modified: Tuesday, June 23rd 2020, 11:04:37 pm
 * Modified By: wei
 * -----
 * Copyright (c) 2020 hong
 */
#include "config.h"

#define UART_BPS 4800

unsigned char display[]={0xc0,0xf9,0xa4,0xb0,
0x99,0x92,0x82,0xf8,0x80};//���������0-8

#define COMPERE (1<<15)
#define PLAYER1 (1<<16)
#define PLAYER2 (1<<17)
#define PLAYER3 (1<<18)
#define PLAYER4 (1<<19)
#define PLAYER5 (1<<20)
#define PLAYER6 (1<<21)
#define PLAYER7 (1<<22)
#define PLAYER8 (1<<23)

volatile uint8 isStart;
volatile uint8 isGet;
volatile uint8 key_value;

void UART0_Ini(void)
{
	uint16 Fdiv;
	PINSEL0=0x05;
	U0LCR=0x9A;
	Fdiv=(Fpclk/16)/UART_BPS;
	U0DLM=Fdiv/256;
	U0DLL=Fdiv%256;
	U0LCR=0x1A;  
}

void UART0_SendByte(char data)
{
   	U0THR = data;				    
  	while ((U0LSR&0x20)==0);	   
}

void UART0_SendStr(const char *str)
{
	char huiche[1]={13};
   	while(1)
   	{
      	if(*str=='\0')
      	{
      		UART0_SendByte(*huiche);
         	break;
        }
      	UART0_SendByte(*str++);	 
   	}
}

void daojishi()
{
	int i,j;
	char time[3]={" s"};
	for(i=3;i>0;i--)
	{
		IO0CLR|=0x3FC;
		IO0SET|=(display[i]<<2);
		time[0]=i+'0';
		UART0_SendStr(time);
		for(j=0;j<3000000;j++);
	}
}

int Who_Get()
{
	int i=0;
	uint8 value = ~key_value;
	while((value >> i) != 1)
		i++;
	return i + 1;
}

void __irq EINT2_ISR()
{
	VICIntEnClr |= 1 << 16;		//Clear enable
	isStart = TRUE;
	EXTINT = 0x0f;
	VICVectAddr = 0;
}

void __irq EINT3_ISR()
{
	key_value = IO0PIN >> 16;
	VICIntEnClr |= 1 << 17;		//Clear enable
	isGet = TRUE;
	EXTINT = 0x0f;
	VICVectAddr = 0;
}

void EXT_Init()
{
	PINSEL0 |= 0x80000000;
	PINSEL0 &= ~0x4000000;		//Set 0.15	EINT2
	PINSEL1 |= 0x20000000;
	PINSEL1 &= ~0x10000000;		//Set p0.30 EINT3
	EXTMODE |= 12;
	EXTPOLAR &= ~4;			//EINT2	�½��ش���
	EXTPOLAR |= 8;			//EINT3	�Ͻ��ش���
	VICIntSelect = 0;
	VICVectAddr0 = (uint32)EINT2_ISR;
	VICVectCntl0 = 0x20 | 16;
	VICVectAddr1 = (uint32)EINT3_ISR;
	VICVectCntl1 = 0x20 | 17;
	VICIntEnable |= 1 << 16;
}

void LED_Init()
{
	PINSEL2 = PINSEL2 & ~(3<<2);
	IO1DIR |= 0xff000000;
	IO1SET |= 0xff000000;
}

void LED_Off()
{
	IO1SET |= 0xff000000;
}

void LED_On(int i)
{
	IO1SET |= 0xff000000;
	IO1CLR |= (1<<(i+23));	//i is 1 to 8
}

int main (void)
{
	int i,j;
	
	char message[]={"player  get the chance!"};
	PINSEL0=0;
	PINSEL1=0;
	IO0DIR=0x7FFF;
	UART0_Ini();
	EXT_Init();
	VICIntEnable |= 1 << 16;
	LED_Init();
	isStart = FALSE;
	isGet = FALSE;
	UART0_SendStr("Please prepare for game!");
	while(1)
	{
		if(isStart)
		{
			daojishi();
			IO0CLR|=0x3FC;
			UART0_SendStr("game start!");
			UART0_SendStr("Please press the button to get the chance!");
			VICIntEnable |= 1 << 17;		//Open
			while(!isGet);
			i = Who_Get();
			IO0SET|=(display[i]<<2);
			message[6]=i+'0';
			UART0_SendStr(message);
			LED_On(i);
			//����ʱ�䣬��ֹ����
			UART0_SendStr("please wait player's answer!");
			for(j=0;j<20000000;j++);
			UART0_SendStr("game is over,please wait we reset the game!");
			isStart = FALSE;
			isGet = FALSE;
			VICIntEnable |= 1 << 16;		//Open
		}
		LED_Off();
	} 
	return 0;
}