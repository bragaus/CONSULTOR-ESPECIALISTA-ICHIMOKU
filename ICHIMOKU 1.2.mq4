#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int TenkanSen = 9; //Tenkan-Sen
input int KijunSen = 26; //Kijun-Sen
input int SenkouSpanB = 52; //Senkou-Span-B

input double Lote = 0.1;
input string Bot_Token = "5283864460:AAE_i7POpxJu4A0XZnG1CEDwiRuxqlNzTV8";
input string Chat_Id = "793968607";

bool EntrouSinalDeVendaDaEstrategiaM5DoMauricio = false, EntrouSinalDeCompraDaEstrategiaM5DoMauricio = false, FezPrimeiroToqueNaMediaMovelSimplesDe50 = false;
double ValorAtualDaMediaMovelSimlplesDe50, ValorAtualDaMediaMovelExponencialDe200, ValorDeEntradaNaEstrategiaDeVendaM5DoMauricio, ValorDeEntradaNaEstrategiaDeCompraM5DoMauricio;

string cabecalho;
char post[],resultado[];
int resposta,tempolimite = 5000;
int TicketOrdemMauricio, IdentificadorDaCompra, IdentificadorDaVenda, BarraAnteriorParaCalcularKijunReta, BarraAnteriorParaCalcularSSBReta;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {  

      if (EntrouSinalDeVendaDaEstrategiaM5DoMauricio) 
         {
         
            double ValorMaximoDaBarraAtual = iHigh(_Symbol,_Period,0);
            
            if (ValorDeEntradaNaEstrategiaDeVendaM5DoMauricio > ValorMaximoDaBarraAtual)
               {
                  
                        
                  if (ValorMaximoDaBarraAtual >= ValorAtualDaMediaMovelSimlplesDe50 && !FezPrimeiroToqueNaMediaMovelSimplesDe50) 
                     { 
                        //Enviar mensagem que tocou na SMA de 50
                        resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL ESTRATEGIA 20050EMASMA tocou sma 50",NULL,NULL,tempolimite,post,0,resultado,cabecalho);                    
                        
                        
                        FezPrimeiroToqueNaMediaMovelSimplesDe50 = true;
                     }         
                     
                  if (ValorMaximoDaBarraAtual >= ValorAtualDaMediaMovelExponencialDe200)
                    {
                        //Enviar mensagem que tocou na EMA de 200
                        resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL ESTRATEGIA 20050EMASMA tocou ema 200",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
                      
                        
                        EntrouSinalDeVendaDaEstrategiaM5DoMauricio = false;              
                    }                  
               }
            

         }
      
      if (EntrouSinalDeCompraDaEstrategiaM5DoMauricio) 
         {
         
            double ValorMinimoDaBarraAtual = iLow(_Symbol,_Period,0);
           
            if (ValorDeEntradaNaEstrategiaDeCompraM5DoMauricio < ValorMinimoDaBarraAtual)
            
               {            
            
                  if (ValorMinimoDaBarraAtual <= ValorAtualDaMediaMovelSimlplesDe50 && !FezPrimeiroToqueNaMediaMovelSimplesDe50) 
                     { 
                        //Enviar mensagem que tocou na SMA de 50
                        resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY ESTRATEGIA 20050EMASMA tocou sma 50",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
                      
                        
                        FezPrimeiroToqueNaMediaMovelSimplesDe50 = true;
                     }
                  
                  if (ValorMinimoDaBarraAtual <= ValorAtualDaMediaMovelExponencialDe200)
                    {
                        //Enviar mensagem que tocou na EMA de 200
                        resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY ESTRATEGIA 20050EMASMA tocou ema 200",NULL,NULL,tempolimite,post,0,resultado,cabecalho);

                        EntrouSinalDeCompraDaEstrategiaM5DoMauricio = false;              
                    }  
                              
              }
         } 

      bool NovaBarra = isNewBar();
      
      if (NovaBarra) 
         {
      
            double ValorDaChikouSpan26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_CHIKOUSPAN,26);
            
            double ValorDaSSA26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANA,26);
            double ValorDaSSB26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,26);
            
            double ValorDaSSA26PeriodosAFrente = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANA,-26);
            double ValorDaSSB26PeriodosAFrente = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,-26);
            
            double ValorDaTenkanSen26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_TENKANSEN,26);
            double ValorDaKijunSen26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,26);  
      
            double ValorDaSSANaBarraAnterior = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANA,1);
            double ValorDaSSBNaBarraAnterior = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,1); 
             
            double ValorAtualDaTenkanSen = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_TENKANSEN,0);
            double ValorAtualDaKijunSen = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,0);           
            
            double ValorDeFechamentoDaBarraDe26PeriodosAtras = iClose(_Symbol,_Period,27);
            double ValorDeAberturaDaBarraDe26PeriodosAtras = iOpen(_Symbol,_Period,27);
            
            double ValorDeAberturaDaBarraAnterior = iOpen(_Symbol,_Period,1);
            double ValorDeFechamentoDaBarraAnterior = iClose(_Symbol,_Period,1);
            
            ValorAtualDaMediaMovelExponencialDe200 = iMA(_Symbol,_Period,200,0,MODE_EMA,0,0);
            ValorAtualDaMediaMovelSimlplesDe50 = iMA(_Symbol,_Period,50,0,MODE_SMA,0,0);         
            
            // SINAL DE COMPRA
            // Chikou span livre
            if (ValorDaChikouSpan26PeriodosAtras > ValorDaSSA26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras > ValorDaSSB26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras > ValorDaTenkanSen26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras > ValorDaKijunSen26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras > ValorDeFechamentoDaBarraDe26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras > ValorDeAberturaDaBarraDe26PeriodosAtras) 
               {  
                  
                  // Sinal de compra da estratégia de 5 minutos do Mauricio
                  if (ValorDeAberturaDaBarraAnterior < ValorDaSSANaBarraAnterior 
                  && ValorDeAberturaDaBarraAnterior < ValorDaSSBNaBarraAnterior 
                  && ValorDeAberturaDaBarraAnterior < ValorAtualDaTenkanSen 
                  && ValorDeAberturaDaBarraAnterior < ValorAtualDaKijunSen 
                  && ValorDeAberturaDaBarraAnterior < ValorAtualDaMediaMovelExponencialDe200 
                  && ValorDeAberturaDaBarraAnterior < ValorAtualDaMediaMovelSimlplesDe50 
                  && ValorDeFechamentoDaBarraAnterior > ValorDaSSANaBarraAnterior 
                  && ValorDeFechamentoDaBarraAnterior > ValorDaSSBNaBarraAnterior 
                  && ValorDeFechamentoDaBarraAnterior > ValorAtualDaTenkanSen 
                  && ValorDeFechamentoDaBarraAnterior > ValorAtualDaMediaMovelExponencialDe200 
                  && ValorDeFechamentoDaBarraAnterior > ValorAtualDaMediaMovelSimlplesDe50) 
                     {                     
                        resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY ESTRATEGIA 20050EMASMA",NULL,NULL,tempolimite,post,0,resultado,cabecalho);                        
                        
                        ValorDeEntradaNaEstrategiaDeCompraM5DoMauricio = iClose(_Symbol, _Period, 1);
                        EntrouSinalDeCompraDaEstrategiaM5DoMauricio = true;
                        FezPrimeiroToqueNaMediaMovelSimplesDe50 = false;      
                     }                  
                  
                  // Vela atual livre
                  if(ValorDaChikouSpan26PeriodosAtras > ValorDaSSANaBarraAnterior && ValorDaChikouSpan26PeriodosAtras > ValorDaSSBNaBarraAnterior && ValorDaChikouSpan26PeriodosAtras > ValorAtualDaTenkanSen && ValorDaChikouSpan26PeriodosAtras > ValorAtualDaKijunSen)
                     {
                        
                        double PrecoDeAberturaDaBarraAnterior = iOpen(_Symbol,_Period,1);
                        
                        if (PrecoDeAberturaDaBarraAnterior < ValorDaSSANaBarraAnterior || PrecoDeAberturaDaBarraAnterior < ValorDaSSBNaBarraAnterior) 
                           {

                              // Nuvem na tendencia ou twist
                              if (ValorDaSSA26PeriodosAFrente >= ValorDaSSB26PeriodosAFrente) 
                                 {

                                   Comprar();
                                   resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
                                   
                                 }
                               else 
                                 {
                                    int twist = ValorDaSSB26PeriodosAFrente - ValorDaSSA26PeriodosAFrente;

                                    if (twist <= 5) 
                                       {
                                          Comprar();
                                          resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
                                       }
                                 }       
                           
                           }
                          
                     }
               
               }
         
            // SINAL DE VENDA
            // Chikou span livre
            if (ValorDaChikouSpan26PeriodosAtras < ValorDaSSA26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras < ValorDaSSB26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras < ValorDaTenkanSen26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras < ValorDaKijunSen26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras < ValorDeFechamentoDaBarraDe26PeriodosAtras 
            && ValorDaChikouSpan26PeriodosAtras < ValorDeAberturaDaBarraDe26PeriodosAtras) 
               {
               
               
                  // Sinal de venda da estratégia de 5 minutos do Mauricio
                  if (ValorDeAberturaDaBarraAnterior > ValorDaSSANaBarraAnterior 
                  && ValorDeAberturaDaBarraAnterior > ValorDaSSBNaBarraAnterior 
                  && ValorDeAberturaDaBarraAnterior > ValorAtualDaTenkanSen 
                  && ValorDeAberturaDaBarraAnterior > ValorAtualDaKijunSen 
                  && ValorDeAberturaDaBarraAnterior > ValorAtualDaMediaMovelExponencialDe200 
                  && ValorDeAberturaDaBarraAnterior > ValorAtualDaMediaMovelSimlplesDe50 
                  && ValorDeFechamentoDaBarraAnterior < ValorDaSSANaBarraAnterior
                  && ValorDeFechamentoDaBarraAnterior < ValorDaSSBNaBarraAnterior
                  && ValorDeFechamentoDaBarraAnterior < ValorAtualDaTenkanSen
                  && ValorDeFechamentoDaBarraAnterior < ValorAtualDaMediaMovelExponencialDe200
                  && ValorDeFechamentoDaBarraAnterior < ValorAtualDaMediaMovelSimlplesDe50) 
                     {
                           resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL ESTRATEGIA 20050EMASMA",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
                      
                           ValorDeEntradaNaEstrategiaDeVendaM5DoMauricio = iClose(_Symbol, _Period, 1);
                           EntrouSinalDeVendaDaEstrategiaM5DoMauricio = true;
                           FezPrimeiroToqueNaMediaMovelSimplesDe50 = false;
                     }               
               
                  // Vela atual livre
                  if(ValorDaChikouSpan26PeriodosAtras < ValorDaSSANaBarraAnterior && ValorDaChikouSpan26PeriodosAtras < ValorDaSSBNaBarraAnterior && ValorDaChikouSpan26PeriodosAtras < ValorAtualDaTenkanSen && ValorDaChikouSpan26PeriodosAtras < ValorAtualDaKijunSen)
                     {
                      
                        double PrecoDeAberturaDaBarraAnterior = iOpen(_Symbol,_Period,1);
                      
                        // Cruzamento da nuvem
                        if (PrecoDeAberturaDaBarraAnterior > ValorDaSSANaBarraAnterior || PrecoDeAberturaDaBarraAnterior > ValorDaSSBNaBarraAnterior) 
                           {
  
                              if (ValorDaSSA26PeriodosAFrente <= ValorDaSSB26PeriodosAFrente) 
                                 {                
                                    
             
                                    Vender();
                                    resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
                                 }
                               else 
                                 {
                                    int twist = ValorDaSSA26PeriodosAFrente - ValorDaSSB26PeriodosAFrente;

                                    if (twist <= 5) 
                                       {
                                       
                                          Vender();
                                          resposta = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL",NULL,NULL,tempolimite,post,0,resultado,cabecalho);
 
                                       }
                                 }
                              
                           }
                     
                     }
               
               }
         }
   }

bool Vender() {

   bool VendaFeitaComSucesso = False;
   int PrecoAtualDaVenda = 0, PrecoAtualDaVendaParaCalcularLimiteDePerda = 0, PrecoAtualDaVendaParaCalcularLimiteDeLucro = 0;

   BarraAnteriorParaCalcularKijunReta = 0;
   BarraAnteriorParaCalcularSSBReta = 0;
   
   while(!VendaFeitaComSucesso){
   
      PrecoAtualDaVenda = Ask;   
      PrecoAtualDaVenda = NormalizeDouble(PrecoAtualDaVenda,_Digits);
      PrecoAtualDaVendaParaCalcularLimiteDePerda = PrecoAtualDaVenda;
      
      if(PrecoAtualDaVendaParaCalcularLimiteDeLucro == 0){
         PrecoAtualDaVendaParaCalcularLimiteDeLucro = PrecoAtualDaVenda;
      }

      double ValorDoLimiteDePerda = LimiteDePerdaDaVenda(PrecoAtualDaVendaParaCalcularLimiteDePerda);
      double ValorDoLimiteDeLucro = LimiteDeLucroDaVenda(PrecoAtualDaVendaParaCalcularLimiteDeLucro);  
   
      IdentificadorDaVenda = OrderSend(_Symbol,OP_SELL,Lote,PrecoAtualDaVenda,100000,ValorDoLimiteDePerda,ValorDoLimiteDeLucro,"",1);
      
      if(IdentificadorDaVenda > 0){
         VendaFeitaComSucesso = True;
      } else {
         
         PrecoAtualDaVendaParaCalcularLimiteDeLucro = ValorDoLimiteDeLucro;
         
      }
      
   }

   return(VendaFeitaComSucesso);
}

bool Comprar() {

   bool CompraFeitaComSucesso = False;
   int PrecoAtualDaCompra = 0, PrecoAtualDaCompraParaCalcularLimiteDePerda = 0, PrecoAtualDaCompraParaCalcularLimiteDeLucro = 0;
   
   BarraAnteriorParaCalcularKijunReta = 0;
   BarraAnteriorParaCalcularSSBReta = 0;
   
   while(!CompraFeitaComSucesso) {
      
      PrecoAtualDaCompra = Ask;
      PrecoAtualDaCompra = NormalizeDouble(PrecoAtualDaCompra,_Digits);
      PrecoAtualDaCompraParaCalcularLimiteDePerda = PrecoAtualDaCompra;
      
      if(PrecoAtualDaCompraParaCalcularLimiteDeLucro == 0){
         PrecoAtualDaCompraParaCalcularLimiteDeLucro = PrecoAtualDaCompra;
      }

      double ValorDoLimiteDePerda = LimiteDePerda(PrecoAtualDaCompraParaCalcularLimiteDePerda);
      double ValorDoLimiteDeLucro = LimiteDeLucro(PrecoAtualDaCompraParaCalcularLimiteDeLucro);
      
      IdentificadorDaCompra = OrderSend(_Symbol,OP_BUY,Lote,PrecoAtualDaCompra,100000,ValorDoLimiteDePerda,ValorDoLimiteDeLucro,"",1);      
      
      if(IdentificadorDaCompra > 0) {
         CompraFeitaComSucesso = True;
      } else {
         
         PrecoAtualDaCompraParaCalcularLimiteDeLucro = ValorDoLimiteDeLucro;
         
      }
   
   }
   
   return(CompraFeitaComSucesso); 
}

double LimiteDeLucro(double PrecoAtualDaCompra) {
   
   int ValorAtualDaKijunSen = 0, ValorAnteriorDaKijunSen = 0, ValorAtualDaSSB = 0, ValorAnteriorDaSSB = 0, ValorDoLimiteDeLucro = 0, ValorDoLimiteDeLucroDaKijunSen = 0, ValorDoLimiteDeLucroDaSSB = 0;
   bool EncontrouLimiteDeLucroDaKijunSen = False, EncontrouLimiteDeLucroDaSSB = False;
   
   while(!EncontrouLimiteDeLucroDaKijunSen) {
    
      BarraAnteriorParaCalcularKijunReta += 1;
      
      if(BarraAnteriorParaCalcularKijunReta != Bars) {
      
         ValorAtualDaKijunSen = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,BarraAnteriorParaCalcularKijunReta);
         
         if(ValorAtualDaKijunSen == ValorAnteriorDaKijunSen && ValorAtualDaKijunSen > PrecoAtualDaCompra) {
          
           ValorDoLimiteDeLucroDaKijunSen = NormalizeDouble(ValorAtualDaKijunSen,_Digits);
           EncontrouLimiteDeLucroDaKijunSen = True;
           
         }
         
         ValorAnteriorDaKijunSen = ValorAtualDaKijunSen;
         
      } else {
         EncontrouLimiteDeLucroDaKijunSen = True;
         ValorDoLimiteDeLucroDaKijunSen = 0;
      }
      
   }   
   
   while(!EncontrouLimiteDeLucroDaSSB) {
    
      BarraAnteriorParaCalcularSSBReta += 1;
      
      if(BarraAnteriorParaCalcularSSBReta != Bars) {
      
         ValorAtualDaSSB = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,BarraAnteriorParaCalcularSSBReta);
                 
         if(ValorAtualDaSSB == ValorAnteriorDaSSB && ValorAtualDaSSB > PrecoAtualDaCompra) {
          
           ValorDoLimiteDeLucroDaSSB = NormalizeDouble(ValorAtualDaSSB,_Digits);
           EncontrouLimiteDeLucroDaSSB = True;
           
         }
         
         ValorAnteriorDaSSB = ValorAtualDaSSB;

      } else {
         EncontrouLimiteDeLucroDaSSB = True;
         ValorDoLimiteDeLucroDaSSB = 0;
      }
      
   }       
   
   if(ValorDoLimiteDeLucroDaKijunSen == 0){
      ValorDoLimiteDeLucro = ValorDoLimiteDeLucroDaSSB;
   }
   
   if(ValorDoLimiteDeLucroDaSSB == 0){
      ValorDoLimiteDeLucro = PrecoAtualDaCompra+5;
   }
   
   if(ValorDoLimiteDeLucroDaSSB > 0 && ValorDoLimiteDeLucroDaKijunSen > 0){
      
      if(ValorDoLimiteDeLucroDaSSB < ValorDoLimiteDeLucroDaKijunSen){
         ValorDoLimiteDeLucro = ValorDoLimiteDeLucroDaSSB;
      } else {
         ValorDoLimiteDeLucro = ValorDoLimiteDeLucroDaKijunSen;
      }
      
   }
   
   return(ValorDoLimiteDeLucro);
}

double LimiteDeLucroDaVenda(double PrecoAtualDaVenda) {
   
   int ValorAtualDaKijunSen = 0, ValorAnteriorDaKijunSen = 0, ValorAtualDaSSB = 0, ValorAnteriorDaSSB = 0, ValorDoLimiteDeLucro = 0, ValorDoLimiteDeLucroDaKijunSen = 0, ValorDoLimiteDeLucroDaSSB = 0;
   bool EncontrouLimiteDeLucroDaKijunSen = False, EncontrouLimiteDeLucroDaSSB = False;
   
   while(!EncontrouLimiteDeLucroDaKijunSen) {
    
      BarraAnteriorParaCalcularKijunReta += 1;
      
      if(BarraAnteriorParaCalcularKijunReta <= Bars) {
      
         ValorAtualDaKijunSen = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,BarraAnteriorParaCalcularKijunReta);
         
         if(ValorAtualDaKijunSen == ValorAnteriorDaKijunSen && ValorAtualDaKijunSen < PrecoAtualDaVenda) {
          
           ValorDoLimiteDeLucroDaKijunSen = NormalizeDouble(ValorAtualDaKijunSen,_Digits);
           EncontrouLimiteDeLucroDaKijunSen = True;
           
         }
         
         ValorAnteriorDaKijunSen = ValorAtualDaKijunSen;
         
      } else {
         EncontrouLimiteDeLucroDaKijunSen = True;
         ValorDoLimiteDeLucroDaKijunSen = 0;
      }
      
   }   

   while(!EncontrouLimiteDeLucroDaSSB) {
    
      BarraAnteriorParaCalcularSSBReta += 1;

      if(BarraAnteriorParaCalcularSSBReta <= Bars) {
      
         ValorAtualDaSSB = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,BarraAnteriorParaCalcularSSBReta);
         
         if(ValorAtualDaSSB == ValorAnteriorDaSSB && ValorAtualDaSSB < PrecoAtualDaVenda) {
          
           ValorDoLimiteDeLucroDaSSB = NormalizeDouble(ValorAtualDaSSB,_Digits);
           EncontrouLimiteDeLucroDaSSB = True;
           
         }
         
         ValorAnteriorDaSSB = ValorAtualDaSSB;

      } else {
         EncontrouLimiteDeLucroDaSSB = True;
         ValorDoLimiteDeLucroDaSSB = 0;
      }
      
   }       

   if(ValorDoLimiteDeLucroDaKijunSen == 0){
      ValorDoLimiteDeLucro = ValorDoLimiteDeLucroDaSSB;
   }
   
   if(ValorDoLimiteDeLucroDaSSB == 0){
      ValorDoLimiteDeLucro = PrecoAtualDaVenda-5;
   }
   
   if(ValorDoLimiteDeLucroDaSSB > 0 && ValorDoLimiteDeLucroDaKijunSen > 0){
      
      if(ValorDoLimiteDeLucroDaSSB < ValorDoLimiteDeLucroDaKijunSen){
         ValorDoLimiteDeLucro = ValorDoLimiteDeLucroDaSSB;
      } else {
         ValorDoLimiteDeLucro = ValorDoLimiteDeLucroDaKijunSen;
      }
      
   }   

   return(ValorDoLimiteDeLucro);
}


double LimiteDePerda(double PrecoAtualDaCompra) {

   int BarraAnterior = 0;
   double ValorMinimoDaBarraAtual = 0;
   double ValorMinimoDaBarraAnterior = 0;
   bool EncontrouLimiteDePerda = False;
   
   while(!EncontrouLimiteDePerda) {
   
      BarraAnterior += 1;
      ValorMinimoDaBarraAtual = iLow(_Symbol, PERIOD_M5, BarraAnterior);
      
      if(ValorMinimoDaBarraAtual > ValorMinimoDaBarraAnterior && ValorMinimoDaBarraAnterior < PrecoAtualDaCompra && ValorMinimoDaBarraAnterior > 0) {
      
         EncontrouLimiteDePerda = True; 
                               
       }
      
      if (!EncontrouLimiteDePerda) {
         ValorMinimoDaBarraAnterior = ValorMinimoDaBarraAtual;
      }
   } 
   
   return(ValorMinimoDaBarraAnterior);
}

double LimiteDePerdaDaVenda(double PrecoAtualDaVenda) {

   int BarraAnterior = 0;
   double ValorMaximoDaBarraAtual = 0;
   double ValorMaximoDaBarraAnterior = 0;
   bool EncontrouLimiteDePerda = False;
   
   while(!EncontrouLimiteDePerda) {
   
      BarraAnterior += 1;
      ValorMaximoDaBarraAtual = iHigh(_Symbol, PERIOD_M5, BarraAnterior);
      
      if(ValorMaximoDaBarraAtual < ValorMaximoDaBarraAnterior && ValorMaximoDaBarraAnterior > PrecoAtualDaVenda && ValorMaximoDaBarraAnterior > 0) {
      
         EncontrouLimiteDePerda = True; 
                               
       }
      
      if (!EncontrouLimiteDePerda) {
         ValorMaximoDaBarraAnterior = ValorMaximoDaBarraAtual;
      }
   } 
   
   return(ValorMaximoDaBarraAnterior);
}











//+------------------------------------------------------------------+
//| Returns true if a new bar has appeared for a symbol/period pair  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
