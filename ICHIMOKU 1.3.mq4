#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int TenkanSen = 9; //Tenkan-Sen
input int KijunSen = 26; //Kijun-Sen
input int SenkouSpanB = 52; //Senkou-Span-B
input ENUM_TIMEFRAMES Periodo = PERIOD_CURRENT; // Periodo do Stop Loss
input bool EnviarSinalTelegram = true; // Enviar sinal no telegram
input bool EntradaAutomatica = true; // Fazer entrada automatica
input double Lote = 0.1;
input string Bot_Token = "5283864460:AAE_i7POpxJu4A0XZnG1CEDwiRuxqlNzTV8";
input string Chat_Id = "793968607";

string cabecalho;
char post[], resultado[];

int QuantidadeDeZonasRetas = 0, 
    TotalDeBarras = 0, 
    IdentificadorDaCompra = 0, 
    IdentificadorDaVenda = 0, 
    BarraAnteriorParaCalcularKijunReta = 0, 
    BarraAnteriorParaCalcularSSBReta = 0,
    PrecoAtualDaVenda = 0,
    PrecoAtualDaCompra = 0,
    DiferencaEntreTotalDeBarrasInicialETotalDeBarrasAtual = 0,
    RespostaDoEnvioDeMensagemParaOTelegram, 
    TempoLimiteEnvioDeMensagemParaOTelegram = 5000;

bool EntrouSinalDeVendaDaEstrategiaM5DoMauricio = false, 
     EntrouSinalDeCompraDaEstrategiaM5DoMauricio = false, 
     FezPrimeiroToqueNaMediaMovelSimplesDe50 = false;
     
double ZonasRetas[], 
       ValorAtualDaMediaMovelSimlplesDe50, 
       ValorAtualDaMediaMovelExponencialDe200, 
       ValorDeEntradaNaEstrategiaDeVendaM5DoMauricio, 
       ValorDeEntradaNaEstrategiaDeCompraM5DoMauricio,
       ValorDoLimiteDePerdaDaVenda = 0, 
       ValorDoLimiteDePerdaDaCompra = 0;

int OnInit() {
   
   
   /*
   
      BOOK OFERTAS: INforma todas as demandas e todas as ordens apregoadas
      
      Filtro 1: mostrar apenas os lotes maiores que X
      Filtro 2: mostrar apenas os lotes maiores que X
         o local onde tem mais lotes é um suporte ou uma resistencia
         
         Traçar suporte e resistencia de ate 2 dias anteriores
         Traçar o preço de ajuste
         
         
         15 BANCO 100 lotes
         14  
         13 
         12 
         11 
         10 BANCO 200 lotes
   
   */
   
   
   datetime d1=D'2022.05.01';  // Year Month Day Hours Minutes Seconds

   int RequisicaoDeBarras = Bars(_Symbol,_Period,d1,TimeCurrent());
   Print("RequisicaoDeBarras "+RequisicaoDeBarras);   
   
   TotalDeBarras = iBars(_Symbol,_Period);
   Print("TotalDeBarras iBars "+TotalDeBarras);

   int TotalDeBarraBars = Bars(_Symbol, _Period);
   Print("TotalDeBarra Bars "+TotalDeBarraBars);

   Print("CHAMANDO MapearTodasAsZonasRetasDaKjunSen()");
   MapearTodasAsZonasRetasDaKjunSen();
   
   //MapearTodasAsZonasRetasDaSSB();
   
   return(INIT_SUCCEEDED);

}

void OnTick() {

   if (EntrouSinalDeVendaDaEstrategiaM5DoMauricio) 
      {
      
         double ValorMaximoDaBarraAtual = iHigh(_Symbol,_Period,0);
         
         if (ValorDeEntradaNaEstrategiaDeVendaM5DoMauricio > ValorMaximoDaBarraAtual)
            {
               
                     
               if (ValorMaximoDaBarraAtual >= ValorAtualDaMediaMovelSimlplesDe50 && !FezPrimeiroToqueNaMediaMovelSimplesDe50) 
                  { 
                     
                     if(EnviarSinalTelegram){
                        //Enviar mensagem que tocou na SMA de 50
                        RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL ESTRATEGIA MR M tocou sma 50",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);                    
                     }
                     
                     FezPrimeiroToqueNaMediaMovelSimplesDe50 = true;
                  }         
                  
               if (ValorMaximoDaBarraAtual >= ValorAtualDaMediaMovelExponencialDe200)
                  {
                     //FecharOrdensDeCompraEmAberto();
                     if(EnviarSinalTelegram){
                        //Enviar mensagem que tocou na EMA de 200
                        RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL ESTRATEGIA MR M tocou ema 200",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                     }
                     
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
                     if (EnviarSinalTelegram) {
                        //Enviar mensagem que tocou na SMA de 50
                        RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY ESTRATEGIA MR M tocou sma 50",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                     }
                     
                     FezPrimeiroToqueNaMediaMovelSimplesDe50 = true;
                  }
               
               if (ValorMinimoDaBarraAtual <= ValorAtualDaMediaMovelExponencialDe200)
                  {
                     
                     //FecharOrdensDeVendaEmAberto();
                     if (EnviarSinalTelegram) {
                        //Enviar mensagem que tocou na EMA de 200
                        RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY ESTRATEGIA MR M tocou ema 200",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                     }
                     
                     EntrouSinalDeCompraDaEstrategiaM5DoMauricio = false;              
                  }  
                           
            }
      } 

   bool NovaBarra = isNewBar();
   
   if (NovaBarra) {
      
            double ValorDaChikouSpan26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_CHIKOUSPAN,27);
            
            double ValorDaSSA26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANA,27);
            double ValorDaSSB26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,27);
            
            double ValorDaSSA26PeriodosAFrente = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANA,-26);
            double ValorDaSSB26PeriodosAFrente = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,-26);
            
            double ValorDaTenkanSen26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_TENKANSEN,27);
            double ValorDaKijunSen26PeriodosAtras = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,27);  
      
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
                                  
                                  
                        if (EnviarSinalTelegram) {
                           RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY ESTRATEGIA MR M",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);                        
                        }
                        
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
                                    
                                   if (EntradaAutomatica) {
                                       Comprar();
                                   }
                                   
                                   if (EnviarSinalTelegram) {
                                       RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                                   }
                                   
                                 }
                               else 
                                 {
                                    int twist = ValorDaSSB26PeriodosAFrente - ValorDaSSA26PeriodosAFrente;

                                    if (twist <= 5) 
                                       {
                                          
                                          if (EntradaAutomatica) {
                                             Comprar();
                                          }
                                          
                                          if (EnviarSinalTelegram) {
                                             RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" BUY",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                                          }
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
                           
                     
                           if (EnviarSinalTelegram) {
                             
                              RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL ESTRATEGIA MR M",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                           }
                           
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
                                    
                                    if (EntradaAutomatica) {
                                       Vender();
                                    }
                                    
                                    if (EnviarSinalTelegram) {
                                       RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                                    }
                                 }
                               else 
                                 {
                                    int twist = ValorDaSSA26PeriodosAFrente - ValorDaSSB26PeriodosAFrente;

                                    if (twist <= 5) 
                                       {
                                          if (EntradaAutomatica) {
                                             Vender();
                                          }
                                          
                                          if (EnviarSinalTelegram) {
                                             RespostaDoEnvioDeMensagemParaOTelegram = WebRequest("POST","https://api.telegram.org/bot"+Bot_Token+"/sendMessage?chat_id="+Chat_Id+"&text="+_Symbol+" M"+_Period+" SELL",NULL,NULL,TempoLimiteEnvioDeMensagemParaOTelegram,post,0,resultado,cabecalho);
                                          }
                                       }
                                 }
                              
                           }
                     
                     }
               
               }
   }

}

void Comprar() {

   LimiteDePerdaDaCompra();

   DiferencaEntreTotalDeBarrasInicialETotalDeBarrasAtual = iBars(_Symbol,_Period) - TotalDeBarras;

   MapearNovasZonasRetasDaKijunSen();
   MapearNovasZonasRetasDaSSB();

   // ordenando o array do menor preço para o maior preço
   ArraySort(ZonasRetas,WHOLE_ARRAY,0,MODE_ASCEND);
   
   bool CompraFeitaComSucesso = false;  
   
   int ZonaRetaAtual = 0, TotalDeZonasRetas = ArraySize(ZonasRetas);
   double PrecoDaZonaRetaAtual = 0;
   
   // Percorrendo todas as zonas retas do array
   while(!CompraFeitaComSucesso && ZonaRetaAtual < TotalDeZonasRetas) {
      
      PrecoDaZonaRetaAtual = ZonasRetas[ZonaRetaAtual];
      
      // Entrar apenas na zona reta com preço maior que a compra
      if (PrecoDaZonaRetaAtual > Ask) {

         PrecoAtualDaCompra = Ask;
         PrecoAtualDaCompra = NormalizeDouble(PrecoAtualDaCompra,_Digits);

         if (PrecoDaZonaRetaAtual > 0) {
            IdentificadorDaCompra = OrderSend(_Symbol,OP_BUY,Lote,PrecoAtualDaCompra,100000,ValorDoLimiteDePerdaDaCompra,0,"",1);
            
            if(IdentificadorDaCompra > 0){
               CompraFeitaComSucesso = True;
            }
         }  else {
            CompraFeitaComSucesso = True;
         }
      }
      
      ZonaRetaAtual++;
   }


   /*
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
         //ValorDoLimiteDeLucroDaSSB = NormalizeDouble(ValorAtualDaSSB,_Digits);   
         
         IdentificadorDaCompra = OrderSend(_Symbol,OP_BUY,Lote,PrecoAtualDaCompra,100000,ValorDoLimiteDePerda,ValorDoLimiteDeLucro,"",1);      
         
         if(IdentificadorDaCompra > 0) {
            CompraFeitaComSucesso = True;
         } else {
            
            PrecoAtualDaCompraParaCalcularLimiteDeLucro = ValorDoLimiteDeLucro;
            
         }
      
      }
      
      return(CompraFeitaComSucesso); 
   */
}

void LimiteDePerdaDaCompra() {

   int BarraAnterior = 0;
   double ValorMinimoDaBarraAtual = 0;
   double ValorMinimoDaBarraAnterior = 0;
   bool EncontrouLimiteDePerda = False;
   
   while(!EncontrouLimiteDePerda) {
   
      BarraAnterior += 1;
      ValorMinimoDaBarraAtual = iLow(_Symbol, Periodo, BarraAnterior);
      
      if(ValorMinimoDaBarraAtual > ValorMinimoDaBarraAnterior && ValorMinimoDaBarraAnterior < Ask && ValorMinimoDaBarraAnterior > 0) {
      
         EncontrouLimiteDePerda = True; 
                               
       }
      
      if (!EncontrouLimiteDePerda) {
         ValorMinimoDaBarraAnterior = ValorMinimoDaBarraAtual;
      }
   } 
   
   ValorDoLimiteDePerdaDaCompra = ValorMinimoDaBarraAnterior;
}

void Vender() {

   

   LimiteDePerdaDaVenda();

   DiferencaEntreTotalDeBarrasInicialETotalDeBarrasAtual = iBars(_Symbol,_Period) - TotalDeBarras;

   MapearNovasZonasRetasDaKijunSen();
   MapearNovasZonasRetasDaSSB();
   
   // ordenando o array do maior preço para o menor preço
   ArraySort(ZonasRetas,WHOLE_ARRAY,0,MODE_DESCEND);
   
   bool VendaFeitaComSucesso = false;  
   
   int ZonaRetaAtual = 0, ZonaRetaParaFecharAVendaManualmente = 0, TotalDeZonasRetas = ArraySize(ZonasRetas);
   double PrecoDaZonaRetaAtual = 0;
   
   // Percorrendo todas as zonas retas do array
   while(!VendaFeitaComSucesso && ZonaRetaAtual < TotalDeZonasRetas) {
      
      PrecoDaZonaRetaAtual = ZonasRetas[ZonaRetaAtual];
      
      // Entrar apenas na zona reta com preço menor que o da venda
      if (PrecoDaZonaRetaAtual < Ask) {

         PrecoAtualDaVenda = Ask;   
         PrecoAtualDaVenda = NormalizeDouble(PrecoAtualDaVenda,_Digits);

         if (PrecoDaZonaRetaAtual > 0) {
            IdentificadorDaVenda = OrderSend(_Symbol,OP_SELL,Lote,PrecoAtualDaVenda,100000,ValorDoLimiteDePerdaDaVenda,0,"",1);
            
            if(IdentificadorDaVenda > 0){
               VendaFeitaComSucesso = True;
            }
         } else {
            VendaFeitaComSucesso = True;
         }

      }
      
      ZonaRetaAtual++;
   }

}

void LimiteDePerdaDaVenda() {

   int BarraAnterior = 0;
   double ValorMaximoDaBarraAtual = 0;
   double ValorMaximoDaBarraAnterior = 0;
   bool EncontrouLimiteDePerda = False;
   
   while(!EncontrouLimiteDePerda) {
   
      BarraAnterior += 1;
      ValorMaximoDaBarraAtual = iHigh(_Symbol, Periodo, BarraAnterior);
      
      if(ValorMaximoDaBarraAtual < ValorMaximoDaBarraAnterior && ValorMaximoDaBarraAnterior > Ask && ValorMaximoDaBarraAnterior > 0) {
      
         EncontrouLimiteDePerda = True; 
                               
       }
      
      if (!EncontrouLimiteDePerda) {
         ValorMaximoDaBarraAnterior = ValorMaximoDaBarraAtual;
      }
   } 

   ValorDoLimiteDePerdaDaVenda = ValorMaximoDaBarraAnterior;
}

void FecharOrdensDeVendaEmAberto() {

   int TotalDeOrdenEmAberto = OrdersTotal();
   for(int i = 0; i < TotalDeOrdenEmAberto; i++ ) { 
      
       OrderSelect(i, SELECT_BY_POS, MODE_TRADES ); 
       
       if(OrderType() == OP_SELL) {
         OrderClose(OrderTicket(),Lote,Ask,10000,Red);
       }
   } 

}

void FecharOrdensDeCompraEmAberto() {

   int TotalDeOrdenEmAberto = OrdersTotal();
   for(int i = 0; i < TotalDeOrdenEmAberto; i++ ) { 
      
       OrderSelect(i, SELECT_BY_POS, MODE_TRADES ); 
       
       if(OrderType() == OP_BUY) {
         OrderClose(OrderTicket(),Lote,Ask,10000,Red);
       }
   } 

}

void MapearTodasAsZonasRetasDaSSB() {
   
   double ValorAtualDaSSB = 0, ValorAnteriorDaSSB = 0, ZonaRetaAnteriorDaSSB = 0;
   
   BarraAnteriorParaCalcularSSBReta = 0;
   
   while(BarraAnteriorParaCalcularSSBReta <= TotalDeBarras) {       
      
      ValorAtualDaSSB = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,BarraAnteriorParaCalcularSSBReta);
      
      if(ValorAtualDaSSB == ValorAnteriorDaSSB) {
         
         if(ValorAtualDaSSB != ZonaRetaAnteriorDaSSB){
            QuantidadeDeZonasRetas++;
            ArrayResize(ZonasRetas,QuantidadeDeZonasRetas);
            ZonasRetas[QuantidadeDeZonasRetas-1] = ValorAtualDaSSB;
            //string name = "Linha"+MathRand();
            //ObjectCreate(ChartID(),name,OBJ_HLINE,0,0,ValorAtualDaSSB);           
         }
         
         ZonaRetaAnteriorDaSSB = ValorAtualDaSSB;
        
      }
      
      ValorAnteriorDaSSB = ValorAtualDaSSB;
      
      BarraAnteriorParaCalcularSSBReta += 1;      
   }

}

void MapearNovasZonasRetasDaSSB() {

   double ValorAtualDaSSB = 0, ValorAnteriorDaSSB = 0, ZonaRetaAnteriorDaSSB = 0;
   
   BarraAnteriorParaCalcularSSBReta = 0;
   while(BarraAnteriorParaCalcularSSBReta <= DiferencaEntreTotalDeBarrasInicialETotalDeBarrasAtual) {
      
      ValorAtualDaSSB = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_SENKOUSPANB,BarraAnteriorParaCalcularSSBReta);
      
      //&& ValorAtualDaSSB < PrecoAtualDaVenda
      if(ValorAtualDaSSB == ValorAnteriorDaSSB) {
         
         if(ValorAtualDaSSB != ZonaRetaAnteriorDaSSB){
            QuantidadeDeZonasRetas++;
            ArrayResize(ZonasRetas,QuantidadeDeZonasRetas);
            ZonasRetas[QuantidadeDeZonasRetas-1] = ValorAtualDaSSB;   
            //string name = "Linha"+MathRand();
            //ObjectCreate(ChartID(),name,OBJ_HLINE,0,0,ValorAtualDaSSB);                         
         }
         
         ZonaRetaAnteriorDaSSB = ValorAtualDaSSB;
        
      }
      
      ValorAnteriorDaSSB = ValorAtualDaSSB;      
      
      BarraAnteriorParaCalcularSSBReta += 1;      
      
   }

}

void MapearTodasAsZonasRetasDaKjunSen() {

   Print("ENTROU MapearTodasAsZonasRetasDaKjunSen");

   // MAPEAR TODAS AS ZONAS RETAS DA KIJUN 
   double ValorAtualDaKijunSen = 0, ValorAnteriorDaKijunSen = 0, ZonaRetaAnteriorDaKijunSen = 0;
  
   Print("BarraAnteriorParaCalcularKijunReta "+BarraAnteriorParaCalcularKijunReta);

   while(BarraAnteriorParaCalcularKijunReta <= TotalDeBarras) {       
      
      ValorAtualDaKijunSen = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,BarraAnteriorParaCalcularKijunReta);

      //Print("VALOR KIJUN: "+ValorAtualDaKijunSen);

      if(ValorAtualDaKijunSen == ValorAnteriorDaKijunSen) {
         
         if(ValorAtualDaKijunSen != ZonaRetaAnteriorDaKijunSen){
            QuantidadeDeZonasRetas++;
            ArrayResize(ZonasRetas,QuantidadeDeZonasRetas);
            ZonasRetas[QuantidadeDeZonasRetas-1] = ValorAtualDaKijunSen;           
         }
         
         ZonaRetaAnteriorDaKijunSen = ValorAtualDaKijunSen;
        
      }

      if (ValorAtualDaKijunSen == 0) {
         int vaitomanocu = BarraAnteriorParaCalcularKijunReta-1;
         datetime DateTime = iTime(_Symbol,PERIOD_M5,vaitomanocu);
         Print("DateTime "+DateTime);
      }
      
      ValorAnteriorDaKijunSen = ValorAtualDaKijunSen;
      
      BarraAnteriorParaCalcularKijunReta += 1;   
      //Print("BarraAnteriorParaCalcularKijunReta no While: "+BarraAnteriorParaCalcularKijunReta); 
      
   }   

   Print("BarraAnteriorParaCalcularKijunReta "+BarraAnteriorParaCalcularKijunReta); 
}

void MapearNovasZonasRetasDaKijunSen() {

   double ValorAtualDaKijunSen = 0, ValorAnteriorDaKijunSen = 0, ZonaRetaAnteriorDaKijunSen = 0;

   BarraAnteriorParaCalcularKijunReta = 0;
   while(BarraAnteriorParaCalcularKijunReta <= DiferencaEntreTotalDeBarrasInicialETotalDeBarrasAtual) {
      
      ValorAtualDaKijunSen = iIchimoku(_Symbol,_Period,TenkanSen,KijunSen,SenkouSpanB,MODE_KIJUNSEN,BarraAnteriorParaCalcularKijunReta);
      
      //&& ValorAtualDaKijunSen < PrecoAtualDaVenda
      if(ValorAtualDaKijunSen == ValorAnteriorDaKijunSen) {
         
         if(ValorAtualDaKijunSen != ZonaRetaAnteriorDaKijunSen){
            QuantidadeDeZonasRetas++;
            ArrayResize(ZonasRetas,QuantidadeDeZonasRetas);
            ZonasRetas[QuantidadeDeZonasRetas-1] = ValorAtualDaKijunSen;
            //string name = "Linha"+MathRand();
            //ObjectCreate(ChartID(),name,OBJ_HLINE,0,0,ValorAtualDaKijunSen);                           
         }
         
         ZonaRetaAnteriorDaKijunSen = ValorAtualDaKijunSen;
        
      }
      
      ValorAnteriorDaKijunSen = ValorAtualDaKijunSen;      
      
      BarraAnteriorParaCalcularKijunReta += 1;      
      
   }

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

class CDynamicArray
  {
private:
   int               m_ChunkSize;    // Chunk size
   int               m_ReservedSize; // Actual size of the array
   int               m_Size;         // Number of active elements in the array
public:
   double            Element[];      // The array proper. It is located in the public section, 
                                     // so that we can use it directly, if necessary
   //+------------------------------------------------------------------+
   //|   Constructor                                                    |
   //+------------------------------------------------------------------+
   void CDynamicArray(int ChunkSize=1024)
     {
      m_Size=0;                            // Number of active elements
      m_ChunkSize=ChunkSize;               // Chunk size
      m_ReservedSize=ChunkSize;            // Actual size of the array
      ArrayResize(Element,m_ReservedSize); // Prepare the array
     }
   //+------------------------------------------------------------------+
   //|   Function for adding an element at the end of array             |
   //+------------------------------------------------------------------+
   void AddValue(double Value)
     {
      m_Size++; // Increase the number of active elements
      if(m_Size>m_ReservedSize)
        { // The required number is bigger than the actual array size
         m_ReservedSize+=m_ChunkSize; // Calculate the new array size
         ArrayResize(Element,m_ReservedSize); // Increase the actual array size
        }
      Element[m_Size-1]=Value; // Add the value
     }
   //+------------------------------------------------------------------+
   //|   Function for getting the number of active elements in the array|
   //+------------------------------------------------------------------+
   int Size()
     {
      return(m_Size);
     }
  };
  
  
  /*
        int TPMinimo = MarketInfo(_Symbol, MODE_STOPLEVEL);
      Print("PIPSSSSSSSS: "+(PrecoAtualDaVenda - ZonasRetas[ZonaRetaAtual]));
      int pips = PrecoAtualDaVenda - ZonasRetas[ZonaRetaAtual];
      if(pips * 100 <= TPMinimo)
        {
         Print("TP muito perto");
        }*/


           /*int obj_total=ObjectsTotal();
   for(int i=obj_total-1;i>=0;i--)
   {
      string name=ObjectName(i);
      
      ObjectDelete(name);
   }*/
