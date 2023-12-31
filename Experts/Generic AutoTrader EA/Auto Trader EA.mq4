//+------------------------------------------------------------------+
//|                                               Auto Trader EA.mq5 |
//|                                                      Daniel Jose |
//+------------------------------------------------------------------+
#property copyright "Daniel Jose"
#property description "This one is an automatic Expert Advisor"
#property description "for demonstration. To understand how to"
#property description "develop yours in order to use a particular"
#property description "operational, see the articles where there"
#property description "is an explanation of how to proceed."
#property version   "1.02"
#property link      "https://www.mql5.com/pt/articles/11223"
//+------------------------------------------------------------------+
#include <Generic Auto Trader\C_Orders.mqh>
//+------------------------------------------------------------------+
C_Orders *orders;
ulong m_ticket;
//+------------------------------------------------------------------+
input int   user01   = 1;		//Fator de alavancagem
input int   user02   = 100;	//Take Profit ( FINANCEIRO )
input int   user03   = 75;		//Stop Loss ( FINANCEIRO )
input bool  user04   = true;	//Day Trade ?
input double user05 	= 84.00;	//Preço de entrada...
//+------------------------------------------------------------------+
int OnInit()
{
	orders = new C_Orders();
	
	return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
	delete orders;
}
//+------------------------------------------------------------------+
void OnTick()
{
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
#define KEY_UP 	38
#define KEY_DOWN 	40

	switch (id)
	{
		case CHARTEVENT_KEYDOWN:
			switch ((int)lparam)
			{
				case KEY_UP:
					m_ticket = orders.CreateOrder(ORDER_TYPE_BUY, user05, user03, user02, user01, user04);
					break;
				case KEY_DOWN:
					m_ticket = orders.CreateOrder(ORDER_TYPE_SELL, user05, user03, user02, user01, user04);
					break;
			}
			break;
	}
#undef KEY_DOWN
#undef KEY_UP
}
//+------------------------------------------------------------------+
