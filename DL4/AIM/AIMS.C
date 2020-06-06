
/*
 * AIMS - Automatic Investment Management Simulator
 *
 * This program will simulate the effects of the "AIM" system under
 * market conditions specified by a data file.
 *
 * Author: S.H.Smith, 29-Aug-86
 *
 */

#define VERSION "v1.0 (SHS 30-Aug-86)"

#include <stdio.h>
#include <ctype.h>
extern double atof();
extern int disp_printf();
extern int printf();


/* working storage */
FILE *fd;
char *infile;
char issue[80];
int verbose = FALSE;
int gains_only = FALSE;
int lines = 0;
int lines_per_page = 24;
int page = 1;

int (*printfun)() = disp_printf;
#define PRINTF (*printfun)


/* inputs from data file */
char   date[20];
double stock_price;


/* initialized and running registers */
double shares_owned = 0;
double cash = 0;
double portfolio_control = 0;
double periods = 0;



/* AIM adjustments */
double initial_portfolio = 10000;  /* initial divided between cash/stock */
double safe_frac = 0.1;            /* S.A.F.E. fraction of stock value */
double control_buy_frac = 0.5;     /* control adjustment frac for buys */
double cash_interest = 0.0044;     /* period interest on cash */
double sell_stop = 100.0;          /* minimum buy/sell amount */



/* AIM calculated values */
double stock_value;
double safe;
char   *aim_action;
double buy_advice;
double shares_bot;
double market_order;
double portfolio_value;



/* perform the aim calculations */
aim_calculation()
{
   if (shares_owned == 0) {  /* make sure initial stock investment
                                equals the cash-on-hand value */
      cash = initial_portfolio / 2.0;
      portfolio_control = cash;
      shares_owned = cash / stock_price;
   }
   else
      cash += cash * cash_interest;
                            /* otherwise deposit interest on cash */

   stock_value = shares_owned * stock_price;
   buy_advice = portfolio_control - stock_value;
   safe = stock_value * safe_frac;

   aim_action = "-";

   if (buy_advice >= 0) {
      market_order = buy_advice - safe;

      if (market_order < sell_stop)
         market_order = 0;
      else {
         aim_action = "Buy";
         portfolio_control += market_order * control_buy_frac;
      }
   }
   else {
      market_order = buy_advice + safe;

      if (market_order > -sell_stop)
         market_order = 0;
      else
         aim_action = "Sell";
   }

   shares_bot = market_order / stock_price;
   shares_owned += shares_bot;
   cash -= market_order;
   portfolio_value = (shares_owned * stock_price) + cash;
   periods ++;
}


report_aim_settings()
{
   PRINTF("\nAutomatic Investment Management (AIM) Simulator   %s",VERSION);

   if (verbose) {
      PRINTF("\n\nAIM Settings:");
      PRINTF("\n\tInitial portfolio           = ");
      print_double(initial_portfolio);
      PRINTF("\n\tS.A.F.E. fraction           = ");
      print_double(safe_frac);
      PRINTF("\n\tControl adjustment fraction = ");
      print_double(control_buy_frac);
      PRINTF("\n\tPeriod interest on cash     = ");
      print_double(cash_interest);
      PRINTF("\n\tMinimum transaction         = ");
      print_double(sell_stop);
      lines += 10;
   }
}


/* report title lines */
report_title()
{
   PRINTF("\n\nFile: %-14s Issue: %-40s Page: %d\n", infile, issue, page++);
   lines += 3;

   if (!gains_only) {
      PRINTF("\n");
      PRINTF("  -----------Conditions----------     ----Advice----     --------Result--------\n");
      PRINTF("           Stock   Shares  Stock       AIM    Market     Shares   Cash  Portfol\n");
      PRINTF("   Date    Price   Owned   Value      Action  Order      Bought  Resrvs  Value\n");
      PRINTF(" ========  ======  ======  ======     ======  ======     ======  ======  ======\n");
      lines += 4;
   }
}


/* report on current data */
report()
{
   if (gains_only) return;

   more_check();

   PRINTF("%8.8s ",date);
   print_double(stock_price);
   print_double(shares_owned);
   print_double(stock_value);
   PRINTF("   ");

   PRINTF("   %4s ",aim_action);
   print_double(market_order);
   PRINTF("   ");

   print_double(shares_bot);
   print_double(cash);
   print_double(portfolio_value);

   PRINTF("\n");
   lines++;
}


report_footer()
{
   double gains = (portfolio_value-initial_portfolio)/initial_portfolio*100.0;
   more_check();

   PRINTF("\nTotal gains(losses) in portfolio value =");
   print_double(gains); PRINTF("%%\n");

   PRINTF("Average gains(losses) in each period   =");
   print_double(gains/periods); PRINTF("%%\n");

   if ((printfun == printf) && (!gains_only))
      PRINTF("%c",12);
}


print_double(data)
double data;
{
   int sign;
   char buf[20];

   if (data < 0) {                /* determine sign for (...) handling */
      sign = 1;
      data = -data;
   }
   else
      sign = 0;

   if (data == 0)                 /* determine format based on number range */
      strcpy(buf,"      -");
   else if (data < 0.1)
      sprintf(buf,"%7.4f",data);
   else if (data < 1.0)
      sprintf(buf,"%7.3f",data);
   else if (data < 10.0)
      sprintf(buf,"%7.2f",data);
   else if (data < 100.0)
      sprintf(buf,"%7.1f",data);
   else if (data < 100000.0)
      sprintf(buf,"%7ld",(long)data);
   else
      sprintf(buf,"%7ldk",((long)data) / 1000L);

   while ((buf[0] == ' ') || (buf[0] == '0'))
      strcpy(buf,buf+1);          /* remove leading spaces and zeros */

   if (sign)
      PRINTF(" (%5s)",buf);       /* output the string with format based */
   else                           /* on the sign */
      PRINTF("%7s ",buf);
}


more_check()
{
   if (printfun == disp_printf)   /* give ^S a chance to work with fast mode */
      printf(" \b");

   if (lines >= lines_per_page) {
      if (printfun == disp_printf) {
         PRINTF("  More? ");
         if (toupper(getch()) == 'N')
            exit(1);
         PRINTF("\r       \n");
      }
      else
         PRINTF("%c",12);

      lines = 0;
      report_title();
   }
}


getline(fd,s)
FILE *fd;
char *s;
{
   while ((*s = fgetc(fd)) != '\n')
      s++;
   *s = 0;
}



/* print command line usage instructions */
usage()
{
   PRINTF("\nAIM Simulator   %s\n\n",VERSION);
   PRINTF("Usage:\tAIMS datfil [-v] [-g] [-sN] [-cN] [-iN] [-tN] [-rN] [-mN] [-z]\n\n");
   PRINTF("Where:\tdatfil\tselects a price/date datafile (default=%s)\n",infile);
   PRINTF("\t-v\tVerbose mode - print AIM settings\n");
   PRINTF("\t-g\treport only total Gains\n");
   PRINTF("\t-pN\tsets initial Portfolio to N (default=%g)\n",initial_portfolio);
   PRINTF("\t-sN\tsets S.A.F.E. fraction to N (default=%g)\n",safe_frac);
   PRINTF("\t-cN\tsets Control adjustment fraction to N (default=%g)\n",control_buy_frac);
   PRINTF("\t-iN\tsets per-period cash Interest to N (default=%6.4f)\n",cash_interest);
   PRINTF("\t-tN\tsets smallest Transaction to N (default=%g)\n",sell_stop);
   PRINTF("\t-z\toutput slowly through DOS to allow redirection\n");
   exit(1);
}



/* initialize system, open files, etc. */
initialize(argc,argv)
int argc;
char **argv;
{
   char *arg;

   disp_open();
   disp_move(24,0);
   disp_flush();

   infile = "AIMS.A";

   while (--argc) {
      arg = argv[argc];
      if (arg[0] != '-')
         infile = arg;
      else
         switch(tolower(arg[1])) {
            case 'v':  verbose = TRUE;                      break;
            case 'g':  gains_only = TRUE;                   break;
            case 'p':  initial_portfolio = atof(&arg[2]);   break;
            case 's':  safe_frac = atof(&arg[2]);           break;
            case 'c':  control_buy_frac = atof(&arg[2]);    break;
            case 'i':  cash_interest = atof(&arg[2]);       break;
            case 't':  sell_stop = atof(&arg[2]);           break;
            case 'z':  printfun = printf;
                       lines_per_page = 60;                 break;

            default:
               PRINTF("Unknown switch:  %s\n",arg);
               usage();
         }
   }


   fd = fopen(infile,"r");
   if (fd == NULL) {
      printf("Can't open data file: %s\n",infile);
      usage();
   }

   getline(fd,issue);
}


/* read input variables; report EOF when end of input reached */
read_inputs()
{
   return fscanf(fd,"%f %s\n", &stock_price, date);
}


/* process a single AIM period */
main(argc,argv)
int argc;
char **argv;
{
   initialize(argc,argv);

   report_aim_settings();
   report_title();

   while (read_inputs() != EOF) {
      aim_calculation();
      report();
   }

   report_footer();
}

