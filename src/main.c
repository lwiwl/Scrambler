/****************************************Copyright (c)**************************************************
**                               Guangzou ZLG-MCU Development Co.,LTD.
**                                      graduate school
**                                 http://www.zlgmcu.com
**
**--------------File Info-------------------------------------------------------------------------------
** File name:			main.c
** Last modified Date:  2004-09-16
** Last Version:		1.0
** Descriptions:		The main() function example template
**
**------------------------------------------------------------------------------------------------------
** Created by:			Chenmingji
** Created date:		2004-09-16
** Version:				1.0
** Descriptions:		The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:
** Modified date:
** Version:
** Descriptions:
**
********************************************************************************************************/
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

int whoget()
{
	if((IO0PIN&PLAYER1)==0)
		return 1;
	if((IO0PIN&PLAYER2)==0)
		return 2;
	if((IO0PIN&PLAYER3)==0)
		return 3;
	if((IO0PIN&PLAYER4)==0)
		return 4;
	if((IO0PIN&PLAYER5)==0)
		return 5;
	if((IO0PIN&PLAYER6)==0)
		return 6;
	if((IO0PIN&PLAYER7)==0)
		return 7;
	if((IO0PIN&PLAYER8)==0)
		return 8;
}
int main (void)
{// add user source code
	int i,j;
	char message[]={"player  get the chance!"};
	PINSEL0=0;
	PINSEL1=0;
	IO0DIR=0x7FFF;
	UART0_Ini();
	while(1)
	{
		UART0_SendStr("Please prepare for game!");
		while((IO0PIN&COMPERE)!=0);
		daojishi();
		IO0CLR|=0x3FC;
		UART0_SendStr("game start!");
		UART0_SendStr("Please press the button to get the chance!");
		//��֤��ͬʱ��Ӧ�˸���ť
		while((IO0PIN&PLAYER1)&&(IO0PIN&PLAYER2)&&(IO0PIN&PLAYER3)&&(IO0PIN&PLAYER4)&&(IO0PIN&PLAYER5)&&(IO0PIN&PLAYER6)&&(IO0PIN&PLAYER7)&&(IO0PIN&PLAYER8)!=0);
		i=whoget();
		IO0SET|=(display[i]<<2);
		message[6]=i+'0';
		UART0_SendStr(message);
		//����ʱ�䣬��ֹ����
		UART0_SendStr("please wait player's answer!");
		for(j=0;j<20000000;j++);
		UART0_SendStr("game is over,please wait we reset the game!");
		while((IO0PIN&COMPERE)==0);
		IO0CLR|=0x3FC;
	}
    return 0;
}
/*********************************************************************************************************
**                            End Of File
********************************************************************************************************/
