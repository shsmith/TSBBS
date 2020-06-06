
/*
 *      Automatic Investment Management
 *
 *      Coded for CP/M (BDS-C)
 *         by: David McCourt
 *
 *      Ported to MSDOS (Datalight C v2.03) and Enhanced
 *         by: Samuel H. Smith (8-27-86)
 *
 */

#include <stdio.h>

#define VERSION "v2.0 (SHS 28-Aug-86)"

const char DATA_FILE[]   = "AIM21.DAT";
const char BACKUP_FILE[] = "AIM21.BAK";

#define MAX_ISSUES      15         /* number of stocks or mutual funds */

#define MAX_NAME_LENGTH 15         /* number of letters in name */


#define REQUIRED_FILE_FORMAT 4     /* used to determine if data file format
                                      is compatible with this version */


struct header_rec {                /* record of data file header information */
   int file_format;
   int issue_count;
   int display_text;
   int spare[100];
};

struct header_rec file_header;

#define FILE_FORMAT       (file_header.file_format)
#define ISSUE_COUNT       (file_header.issue_count)
#define DISPLAY_TEXT      (file_header.display_text)


struct issue_rec {                 /* record of information about each issue */
   char name[MAX_NAME_LENGTH + 1];
   double shares_owned;
   double current_price;
   double total_cost;
   double total_value;
   double control_value;
   char spare[50];
};

struct issue_rec issue[MAX_ISSUES],  /* the table of all issues */
                 *work_issue;        /* the current issue */

int work;                            /* issue currently being worked on */

                                     /* macros to shorten references to
                                        the working issue */
#define NAME            (work_issue->name)
#define SHARES_OWNED    (work_issue->shares_owned)
#define CURRENT_PRICE   (work_issue->current_price)
#define TOTAL_COST      (work_issue->total_cost)
#define TOTAL_VALUE     (work_issue->total_value)
#define CONTROL_VALUE   (work_issue->control_value)
#define AVERAGE_COST    (TOTAL_COST / SHARES_OWNED)

                                     /* predicate is true when the
                                        working issue is valid */
#define VALID_ISSUE (work != -1)


double buy_sell_amount;               /* the buy sell amount */
char buy_sell_advice[5];             /* 'buy' or 'sell' instruction */

char str[80];                        /* used for input strings */


char *get_string();

#define round(num) ((long)((num)+0.5))

extern double atof();                /* get float with default on empty str */
#define get_float(to) get_string(str); if (*str) to = atof(str)

extern int atoi();                   /* get integer with no default */
#define get_integer(to) to = atoi(get_string(str))



enum transaction_codes {             /* all possible main menu options */
       T_ORIGINAL_INVESTMENT = 1,
       T_DIVIDENDS_RECEIVED,
       T_CASH_INVESTED,
       T_AIM_SELL_ORDER,
       T_AIM_BUY_ORDER,
       T_REVIEW_PORTFOLIO,
       T_SAVE_FILE,
       T_LOAD_FILE,
       T_DELETE_ISSUE,
       T_UPDATE_ISSUE,
       T_ORIGINAL_MONEY_MARKET,
       T_DEPOSIT_MONEY_MARKET,
       T_DISPLAY_TEXT,
       T_END_SESSION = 99 };

enum transaction_codes transaction_code;     /* current main menu selection */


signon_screen()
{
   disp_puts("\n\n\n");
   disp_puts("\tAIM is based on the book,  'How to make $1,000,000 in the\n");
   disp_puts("\tStock Market'  by Robert Lichello.\n\n");

   disp_puts("\tInitial CP/M coding in BDS-C\n");
   disp_puts("\t\tby: David McCourt\n\n");

   disp_puts("\tPorted to MSDOS and Enhanced\n");
   disp_puts("\t\tby: Samuel H. Smith, ");
   disp_puts(VERSION);
   disp_puts("\n\n");
}



main()
{
   ISSUE_COUNT = 0;
   disp_open();
   load_file();
   main_menu();
   save_file();
   clear_screen();
}



main_menu()
{
   while (TRUE) {
      transaction_code = 0;

      clear_screen();
      disp_puts("\n");
      disp_puts("\tAutomatic Investment Management             ");
      disp_puts(VERSION);
      disp_puts("\n");
      disp_puts("\t=============================== \n\n");
      disp_puts("\t\t 1) Original stock investment\n");
      disp_puts("\t\t 2) Dividends received as stock (no cash outlay)\n");
      disp_puts("\t\t 3) Additional cash invested (control adjusted)\n");
      disp_puts("\t\t 4) AIM Market order - SELL \n");
      disp_puts("\t\t 5) AIM Market order - BUY (control adjusted)\n");
      disp_puts("\t\t 6) Review portfolio\n");
      disp_puts("\t\t 7) Save file\n");
      disp_puts("\t\t 8) Read file\n");
      disp_puts("\t\t 9) Delete issue\n");
      disp_puts("\t\t10) Update prices\n");
      disp_puts("\t\t11) Money Market original investment\n");
      disp_puts("\t\t12) Money Market deposits, withdrawal, and interest received\n");
      disp_puts("\t\t13) Toggle text display mode\n");
      disp_puts("\t\t99) End session\n");

      disp_puts("\n\n\tEnter your choice: ");
      get_integer(transaction_code);

      switch (transaction_code) {
      case T_ORIGINAL_INVESTMENT:
         new_issue();
         shares_purchased();
         break;

      case T_DIVIDENDS_RECEIVED:
         select_issue();
         shares_purchased();
         break;

      case T_CASH_INVESTED:
         new_cash_investment();
         break;

      case T_AIM_SELL_ORDER:
      case T_AIM_BUY_ORDER:
         select_issue();
         shares_purchased();
         break;

      case T_REVIEW_PORTFOLIO:
         review_portfolio();
         break;

      case T_SAVE_FILE:
         save_file();
         break;

      case T_LOAD_FILE:
         load_file();
         break;

      case T_DELETE_ISSUE:
         select_issue();
         delete_issue();
         break;

      case T_UPDATE_ISSUE:
         select_issue();
         update_issue_information();
         break;

      case T_ORIGINAL_MONEY_MARKET:
         new_issue();
         deposit_money_market();
         break;

      case T_DEPOSIT_MONEY_MARKET:
         select_issue();
         deposit_money_market();
         break;

      case T_DISPLAY_TEXT:
         DISPLAY_TEXT = !DISPLAY_TEXT;
         break;

      case T_END_SESSION:
         return;

      default:
         break;
      }
   }

} /* main_menu */



/*
 * Top level services
 *
 */

new_issue()
{
   clear_screen();
   disp_puts("\nOpen new investments\n");
   put_dashes();

   if (ISSUE_COUNT == MAX_ISSUES-1) {
      disp_puts("\n\nWARNING !!! You already have the maximum number of issues.\n");
      work = -1;
      hold();
      return;
   }

   disp_puts("\n\nEnter exchange and name of new stock or fund.... ");
   disp_puts("[...............]\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
   get_string(str);

   /* abort the new issue if a blank name is entered */
   if (*str == 0) {
      work = -1;
      return;
   }


   /* create the new issue */
   work = ISSUE_COUNT++;
   work_issue = &issue[work];

   str[MAX_NAME_LENGTH] = 0;
   while(strlen(str) < MAX_NAME_LENGTH)
      strcat(str, " ");
   strcpy(NAME, str);

   CURRENT_PRICE = 0;
   TOTAL_COST = 0;
   CONTROL_VALUE = 0;
   SHARES_OWNED = 0;
   TOTAL_VALUE = 0;

} /* new_issue */


select_issue()
{
   do {
      clear_screen();
      disp_puts("\n\n\t\t  Number\t     Name\n");
      disp_puts("\t\t  ======\t===============");

      for (work = 0; work < ISSUE_COUNT; work++) {
         work_issue = &issue[work];
         disp_printf("\n\t\t%6d\t\t %s\t  %s", work + 1, NAME );
      }

      disp_puts("\n\n\tSelect issue number:  ");
      get_integer(work);

      work--;
   }
   while ((work < -1) || (work >= ISSUE_COUNT));

   work_issue = &issue[work];

} /* select_issue */


shares_purchased()
{
   double added_shares;
   double added_investment;

   if (!VALID_ISSUE)
      return;

   clear_screen();
   disp_printf("\nPurchase shares: %s\n", NAME);
   put_dashes();

   disp_puts("\n(enter negative figures for shares sold)\n\n");
   disp_puts("\nEnter number of shares bought/sold.... ");
   get_float(added_shares);
   disp_puts("\n\n");

   if (CURRENT_PRICE != 0)
      disp_printf("Recorded price per share is........... %1.3f\n",
                    CURRENT_PRICE);

   disp_puts("Enter current price per share......... ");
   get_float(CURRENT_PRICE);

   added_investment = added_shares * CURRENT_PRICE;
   disp_printf("\n\n\nThis transaction = %1.2f", added_investment);

   SHARES_OWNED += added_shares;
   TOTAL_VALUE = CURRENT_PRICE * SHARES_OWNED;

   switch (transaction_code) {
   case T_ORIGINAL_INVESTMENT:
      TOTAL_COST = CURRENT_PRICE * SHARES_OWNED;
      CONTROL_VALUE = TOTAL_COST;
      break;

   case T_CASH_INVESTED:
      TOTAL_COST += added_investment;
      CONTROL_VALUE += added_investment * 1.1;
      break;

   case T_AIM_SELL_ORDER:
      TOTAL_COST += added_investment;
      break;

   case T_AIM_BUY_ORDER:
      TOTAL_COST += added_investment;
      CONTROL_VALUE += added_investment * 0.5;
      break;
   }

   hold();

} /* shares_purchased */


new_cash_investment()
{
   int investment_type;

   clear_screen();
   disp_puts("\nNew cash investment\n");
   put_dashes();

   disp_puts("\n\n\n");
   disp_puts("\t\t1) Open a new issue\n");
   disp_puts("\t\t     (like Original investment, but with higher control value)\n\n");
   disp_puts("\t\t2) Buy more stock in an existing issue\n");

   disp_puts("\n\n\tEnter your choice: ");
   get_integer(investment_type);

   switch (investment_type) {
   case 1:
      new_issue();
      shares_purchased();
      return;

   case 2:
      select_issue();
      shares_purchased();
      return;
   }

} /* new_cash_investment */


review_portfolio()
{
   double gains;
   double portfolio_value;

   portfolio_value = 0;
   gains = 0;

   clear_screen();
   disp_puts(" Exchange and    Shares  Current   Average   Current   Control     Buy/Sell\n");
   disp_puts(" Name of Issue   Owned    Price     Cost      Value    Amount       Advice\n");
   disp_puts("===============  ====== ========= ========= ========= =========  =============\n");


   for (work = 0; work < ISSUE_COUNT; ++work) {
      work_issue = &issue[work];
      auto_invest_advice();
      gains += TOTAL_VALUE - TOTAL_COST;
      portfolio_value += TOTAL_VALUE;

      disp_printf(" %s", NAME);
      disp_printf("%6g", SHARES_OWNED);
      disp_printf("%10.3f", CURRENT_PRICE);
      disp_printf("%10.3f", AVERAGE_COST);
      disp_printf("%10.2f", TOTAL_VALUE);
      disp_printf("%10.2f", CONTROL_VALUE);

      disp_printf("     %s", buy_sell_advice);
      if (buy_sell_amount != 0)
         disp_printf(" %ld", round(buy_sell_amount / CURRENT_PRICE));

      disp_puts("\n");
   }

   disp_puts("\n");
   put_dashes();
   disp_printf("Portfolio Value: %1.2f", portfolio_value);
   disp_printf("\t\tGains: %1.2f", gains);
   hold();

} /* review_portfolio */


save_file()
{
   int fd;

   clear_screen();
   disp_puts("Saving data file to disk...\n");
   put_dashes();

   if (ISSUE_COUNT == 0) {
      disp_puts("CAUTION !!! no data in memory.");
      hold();
      return;
   }

   unlink(BACKUP_FILE);
   rename(DATA_FILE, BACKUP_FILE);

   fd = creat(DATA_FILE, 0);
   if (fd == ERROR) {
      disp_printf("\nCan't create %s\n", DATA_FILE);
      hold();
      return;
   }

   FILE_FORMAT = REQUIRED_FILE_FORMAT;
   write(fd, &file_header, sizeof(struct header_rec));
   write(fd, issue, ISSUE_COUNT * sizeof(struct issue_rec));
   close(fd);

} /* save_file */


load_file()
{
   int fd;

   clear_screen();
   disp_puts("Loading data file...\n");
   put_dashes();

   signon_screen();

   fd = open(DATA_FILE, 0);
   if (fd == ERROR) {
      disp_printf("\nCan't open %s\n", DATA_FILE);
      hold();
      return;
   }

   read(fd, &file_header, sizeof(struct header_rec));

   if (FILE_FORMAT != REQUIRED_FILE_FORMAT) {
      disp_printf("BAD FILE FORMAT = %d !!!,  FORMAT %d IS REQUIRED\n",
                   FILE_FORMAT, REQUIRED_FILE_FORMAT);
      close(fd);
      hold();
      return;
   }

   read(fd, issue, ISSUE_COUNT * sizeof(struct issue_rec));
   close(fd);

   hold();

} /* load_file */


delete_issue()
{
   if (!VALID_ISSUE)
      return;

   while (work < ISSUE_COUNT) {
      issue[work] = issue[work + 1];
      ++work;
   }

   ISSUE_COUNT--;

} /* delete_issue */


update_issue_information()
{
   if (!VALID_ISSUE)
      return;

   clear_screen();
   disp_printf("\nUpdate issue information: %s\n", NAME);
   put_dashes();

   disp_printf("\nRecorded exchange and name is......  %s", NAME);
   disp_puts("\nEnter new name of stock or fund.... ");
   disp_puts("[...............]\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");

   get_string(str);
   if (*str != 0) {
      str[MAX_NAME_LENGTH] = 0;
      while(strlen(str) < MAX_NAME_LENGTH)
         strcat(str, " ");
      strcpy(NAME, str);
   }

   disp_printf("\nRecorded number of shares owned is. %1g", SHARES_OWNED);
   disp_puts("\nEnter new number of shares owned... ");
   get_float(SHARES_OWNED);

   disp_printf("\nRecorded price per share is........ %1.3f", CURRENT_PRICE);
   disp_puts("\nEnter new price per share.......... ");
   get_float(CURRENT_PRICE);
   TOTAL_VALUE = CURRENT_PRICE * SHARES_OWNED;

   disp_printf("\nRecorded total cost is............. %1.2f", TOTAL_COST);
   disp_puts("\nEnter new total cose............... ");
   get_float(TOTAL_COST);
   if (TOTAL_COST == 0)
      TOTAL_COST = TOTAL_VALUE;

   disp_printf("\nRecorded control value is.......... %1.2f", CONTROL_VALUE);
   disp_puts("\nEnter new control value............ ");
   get_float(CONTROL_VALUE);
   if (CONTROL_VALUE == 0)
      CONTROL_VALUE = TOTAL_VALUE;

} /* update_issue_information */


deposit_money_market()
{
   double added_cash;

   if (!VALID_ISSUE)
      return;

   clear_screen();
   disp_printf("\nMoney market deposit: %s\n", NAME);
   put_dashes();
   disp_puts("\n (enter negative figures for withdrawals)\n\n");

   disp_puts("\nEnter the amount of the deposit....... ");
   get_float(added_cash);

   CURRENT_PRICE = 1.0;    /* set price per share to $1 */
   TOTAL_COST += added_cash;
   CONTROL_VALUE += added_cash;
   SHARES_OWNED += added_cash;
   TOTAL_VALUE += added_cash;

} /* deposit_money_market */


/*
 * Support functions
 *
 */

auto_invest_advice()
{
   double safe;
   double test;

   safe = TOTAL_VALUE * 0.1; /* percentage of value as a 'safety' band */
   test = 100;               /* minimum $ amount for buy/sell advice */

   if (TOTAL_VALUE > CONTROL_VALUE) {
      buy_sell_amount = TOTAL_VALUE - CONTROL_VALUE - safe;
      strcpy(buy_sell_advice, "Sell");
   }

   if (TOTAL_VALUE <= CONTROL_VALUE) {
      buy_sell_amount = CONTROL_VALUE - TOTAL_VALUE - safe;
      strcpy(buy_sell_advice, "Buy");
   }

   if (buy_sell_amount < test) {
      buy_sell_amount = 0;
      strcpy(buy_sell_advice, "-");
   }

} /* auto_invest_advice */



hold()
{
   disp_puts("\n\nPress <RETURN> to continue...");
   get_string(str);
}


disp_puts(s)
char *s;
{
   char c;

   if (DISPLAY_TEXT)
      while (*s)
         disp_putc(*s++);
   else
      while (*s) {
         switch (c = *s++) {
         case '-':
            disp_putc(196);
            break;

         case '=':
            disp_putc(205);
            break;

         default:
            disp_putc(c);
            break;
         }
      }
}


clear_screen()
{
   disp_move(0, 0);   /* home cursor and clear to end-of-page */
   disp_eeop();
}


put_dashes()
{
   disp_puts("------------------------------------------------------------------------------\n");
}


char *get_string(str)
char *str;
{
   disp_flush();
   gets(str);

   disp_putc('\n');
   disp_flush();

   return str;
}


