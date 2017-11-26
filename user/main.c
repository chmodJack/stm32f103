#include"delay.h"
#include"sys.h"

#define ON 999
#define OFF 999

int add(int a,int b);
int main(void)
{
	volatile int a=3,b=4;
	a=add(a,b);

	delay_init();
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC,ENABLE);
	GPIO_InitTypeDef led=
	{
		.GPIO_Pin=GPIO_Pin_13,
		.GPIO_Mode=GPIO_Mode_Out_PP,
		.GPIO_Speed=GPIO_Speed_50MHz,
	};

	GPIO_Init(GPIOC,&led);
	while(1)
	{
		GPIO_SetBits(GPIOC,GPIO_Pin_13);
		delay_ms(OFF);
		GPIO_ResetBits(GPIOC,GPIO_Pin_13);
		delay_ms(ON);
	}
}

int add(int a,int b)
{
	return a*b;
}
