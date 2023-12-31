//+------------------------------------------------------------------+
//|                                                     MQL4ToSF.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <JAson.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart() {

    while(true){
        if(Bars<100 || IsTradeAllowed()==false) return;
        Callout();
        Sleep(1000);
    }
    
}

void Callout() {

    CJAVal service_sf;
    service_sf["AccountCompany"]=AccountCompany();
    service_sf["AccountBalance"]=DoubleToString(AccountBalance(),2);
    service_sf["AccountCredit"]=DoubleToString(AccountCredit(),2);
    service_sf["AccountCurrency"]=AccountCurrency();
    service_sf["AccountEquity"]=DoubleToString(AccountEquity(),2);;
    service_sf["AccountFreeMargin"]=DoubleToString(AccountFreeMargin(),2);;
    service_sf["AccountMargin"]=DoubleToString(AccountMargin(),2);;
    service_sf["AccountName"]=AccountName();
    service_sf["AccountNumber"]=AccountNumber();
    service_sf["AccountProfit"]=DoubleToString(AccountProfit(),2);;
    service_sf["AccountServer"]=AccountServer();

    string symbol_to_split = "AUDCAD,AUDNZD,NZDCAD";
    string symbol_split_result[];
    string sep=",";                // A separator as a character
    ushort u_sep;                  // The code of the separator character
    u_sep=StringGetCharacter(sep,0);
    int k =StringSplit(symbol_to_split,u_sep,symbol_split_result);
    if(k > 0){
        for(int i=0;i<k;i++){
            CJAVal symbol_sf;
            string symbol = symbol_split_result[i];
            symbol_sf["Name"]=symbol;
            symbol_sf["Sell"]=MarketInfo(symbol,MODE_BID);
            symbol_sf["Buy"]=MarketInfo(symbol,MODE_ASK);
            symbol_sf["Spread"]=MarketInfo(symbol,MODE_SPREAD);
            symbol_sf["LotSize"]=MarketInfo(symbol,MODE_LOTSIZE);
            symbol_sf["Highest"]=MarketInfo(symbol,MODE_HIGH);
            symbol_sf["Lowest"]=MarketInfo(symbol,MODE_LOW);
            int total=OrdersTotal();
            for(int j=0;j<total;j++){
                if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false){
                    Print("Orders OrderSelect returned the error of ",GetLastError());
                    continue;
                }
                if (OrderSymbol()==symbol) {
                    CJAVal order_sf;
                    order_sf["Ticket"]=OrderTicket();
                    order_sf["OpenTime"]=TimeToString(OrderOpenTime(), TIME_DATE | TIME_SECONDS);
                    order_sf["OpenPrice"]=OrderOpenPrice();
                    order_sf["Lots"]=OrderLots();
                    order_sf["Type"]=OrderType();
                    order_sf["TakeProfit"]=OrderTakeProfit();
                    order_sf["Swap"]=OrderSwap();
                    order_sf["StopLoss"]=OrderStopLoss();
                    order_sf["Profit"]=OrderProfit();
                    order_sf["Expiration"]=TimeToString(OrderExpiration(), TIME_DATE | TIME_SECONDS);
                    order_sf["CloseTime"]=TimeToString(OrderCloseTime(), TIME_DATE | TIME_SECONDS);
                    symbol_sf["Orders"].Add(order_sf);
                }
            }
            int h,historyTotal=OrdersHistoryTotal();
                for(h=0;h<historyTotal;h++){
                if(OrderSelect(h,SELECT_BY_POS,MODE_HISTORY)==false){
                    Print("HistoryOrders OrderSelect returned the error of ",GetLastError());
                    continue;
                }
                if (OrderSymbol()==symbol) {
                    CJAVal order_sf;
                    order_sf["Ticket"]=OrderTicket();
                    order_sf["OpenTime"]=TimeToString(OrderOpenTime(), TIME_DATE | TIME_SECONDS);
                    order_sf["OpenPrice"]=OrderOpenPrice();
                    order_sf["Lots"]=OrderLots();
                    order_sf["Type"]=OrderType();
                    order_sf["TakeProfit"]=OrderTakeProfit();
                    order_sf["Swap"]=OrderSwap();
                    order_sf["StopLoss"]=OrderStopLoss();
                    order_sf["Profit"]=OrderProfit();
                    order_sf["Expiration"]=TimeToString(OrderExpiration(), TIME_DATE | TIME_SECONDS);
                    order_sf["CloseTime"]=TimeToString(OrderCloseTime(), TIME_DATE | TIME_SECONDS);
                    symbol_sf["Orders"].Add(order_sf);
                }
            }

            service_sf["Symbols"].Add(symbol_sf);
        }
    }

    string json_str = service_sf.Serialize();

    string url = "https://aiden-dev-ed.my.salesforce.com/services/apexrest/MQL4ToSF",
           cookie = NULL,
           headers = "Content-Type: application/json\r\n";

    int timeout = 5000; 

    char request_body[],
         response_body[];

    int status_code;

    string result_data,
           result_headers;

    StringToCharArray(json_str, request_body, 0, StringLen(json_str));

    ResetLastError();

    status_code = WebRequest("POST",
        url,
        headers,
        timeout,
        request_body,
        response_body,
        result_headers
    );
    if (status_code == -1) Print("Error in WebRequest. Error code  =", GetLastError()); 
    else {
        for (int i = 0; i < ArraySize(response_body); i++) {
            if ((response_body[i] == 10) // == '\n'  // <LF>
                ||
                (response_body[i] == 13) // == '\r'  // <CR>
            )
                continue;
            else result_data += CharToStr(response_body[i]);
        }
        //Print("------------------ SF Return:: ", result_data);
    }

}