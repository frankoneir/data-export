      '********************************************************************** _
      '* json0840 - Export data to json.                                    * _
      '**********************************************************************
      REM $INCLUDE:'iccommon.b'
      REM $INCLUDE:'icfuncts.b'
      PGM.CHGDATE$="EXPO 181009"

      CALL spcolor(CL.STD%,CL.BAK%)
      CALL spcls
      CALL spmainbox("Export data to json.",3,0,MAX.SCREEN.ROW%-4,79)
      CALL spcolor(CL.STD%,CL.BAK%)
      MSGBOX.START.ROW%=MAX.SCREEN.ROW%-3
      CALL spmsgbox(1,"",0,0,0) '*** Initialize MsgBox.

      DIM SCROLL2$(1),GLIX.BF$(2),GLAC.BF$(109),GLBG.BF$(38),GLBK.BF$(22),GLSA.DEFINITION$(32),GLAC.DVPC$(99)

      CALL splocate(3,3) : PRINT "1-GL, 2-IN, 3-AR, 4-AP, 5-PR, 6-IV, 7-PS, 8-PO, 99-All:";
      CALL spinput(3,59,2,-1,0,0,0,-1,2,CURSOR$,ANSWER$,0,0,0)
      ANSWER$=RTRIM$(LTRIM$(ANSWER$))
      IF ANSWER$="1" OR ANSWER$="99" THEN
         OPEN FNWHERE$("glindex") FOR RANDOM ACCESS READ SHARED AS #2 LEN=8
         OPEN FNWHERE$("glaccts") FOR RANDOM ACCESS READ SHARED AS #3 LEN=643
         OPEN FNWHERE$("glbudget") FOR RANDOM ACCESS READ SHARED AS #4 LEN=800
         OPEN FNWHERE$("glspacct") FOR RANDOM ACCESS READ SHARED AS #5 LEN=17
         FIELD #2,6 AS GLIX.BF$(1),2 AS GLIX.BF$(2)
         FIELD #3,6 AS GLAC.BF$(1),30 AS GLAC.BF$(2),1 AS GLAC.BF$(3),1 AS GLAC.BF$(4),1 AS GLAC.BF$(5),1 AS GLAC.BF$(6),         _
                   1 AS GLAC.BF$(7),1 AS GLAC.BF$(8),1 AS GLAC.BF$(9),6 AS GLAC.BF$(10)
         FOR SI%=1 TO 99
            FIELD #3,(SI%-1)*6+49 AS DUMMY$,6 AS GLAC.BF$(SI%+10)
         NEXT
         FIELD #4,10 AS GLBG.BF$(1),8 AS GLBG.BF$(2)
         FOR SI%=1 TO 12
            FIELD #4,(SI%-1)*16+18 AS DUMMY$,16 AS GLBG.BF$(SI%+2)
         NEXT
         FOR SI%=1 TO 24
            FIELD #4,(SI%-1)*24+210 AS DUMMY$,24 AS GLBG.BF$(SI%+14)
         NEXT
         FIELD #5,17 AS GLSA.BUFF$

         NO.GLIX%=0
         IF LOF(2)>0 THEN
            GET #2,1
            NO.GLIX%=CVI(LEFT$(GLIX.BF$(1),2))
         END IF
         NO.GLBG%=0
         IF LOF(4)>0 THEN
            GET #4,1
            NO.GLBG%=CVI(LEFT$(GLBG.BF$(1),2))
         END IF
         GET #5,1
         NO.GLSA%=CVI(LEFT$(GLSA.BUFF$,2))

         ' export glspacct - general section.
         GLSA.DEFINITION$(1)="Bank - 1 (cash)"
         GLSA.DEFINITION$(2)="Bank - 2 (cash)"
         GLSA.DEFINITION$(3)="Bank - 3 (cash)"
         GLSA.DEFINITION$(4)="Accounts payable"
         GLSA.DEFINITION$(5)="Discount taken (A/P)"
         GLSA.DEFINITION$(6)="Accounts receivable"
         GLSA.DEFINITION$(7)="Discount given (A/R)"
         GLSA.DEFINITION$(8)="Provincial sales tax payable"
         GLSA.DEFINITION$(9)="GST/HST payable"
         GLSA.DEFINITION$(10)="GST/HST  - Input Tax Credit"
         GLSA.DEFINITION$(11)="Finance charges received"
         GLSA.DEFINITION$(12)="Inventory"
         GLSA.DEFINITION$(13)="Net profit balancing"
         GLSA.DEFINITION$(14)="Retained earnings"
         GLSA.DEFINITION$(15)="Currency holding"
         GLSA.DEFINITION$(16)="Finance charges paid"
         GLSA.DEFINITION$(17)="Deposits from customers"
         GLSA.DEFINITION$(18)="Deposits to vendors"
         GLSA.DEFINITION$(19)="Accrued accounts payable"
         GLSA.DEFINITION$(20)="Federal withholding tax"
         GLSA.DEFINITION$(21)="Quebec withholding tax"
         GLSA.DEFINITION$(22)="EI payable"
         GLSA.DEFINITION$(23)="CPP payable"
         GLSA.DEFINITION$(24)="QPP payable"
         GLSA.DEFINITION$(25)="Quebec health insurance"
         GLSA.DEFINITION$(26)="Accrued vacation pay"
         GLSA.DEFINITION$(27)="Payroll bank"
         GLSA.DEFINITION$(28)="Employees' arrears"
         GLSA.DEFINITION$(29)="Work in progress"
         GLSA.DEFINITION$(30)="Overhead applied"
         GLSA.DEFINITION$(31)="EHT payable"
         GLSA.DEFINITION$(32)="Payroll clearing"
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glspacct_general_schema.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"schema";CHR$(34);":{"
         PRINT #99,CHR$(34);"defination";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"account_number";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"foreign key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"}"
         PRINT #99,"}"
         PRINT #99,"}"
         CLOSE #99
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glspacct_general_data.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"data";CHR$(34);":"
         PRINT #99,"["
         LAST.RECORD$=""
         FOR GLSA.SI%=2 TO 33
            GET #5,GLSA.SI%
            IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$;"," : LAST.RECORD$=""
            PRINT #99,"{"
            PRINT #99,CHR$(34);"defination";CHR$(34);":";CHR$(34);GLSA.DEFINITION$(GLSA.SI%-1);CHR$(34);","
            IF LEFT$(GLSA.BUFF$,1)="@" THEN
               IN$=MID$(GLSA.BUFF$,2,6) : GOSUB CLEN:
            ELSE
               IN$=""
            END IF
            IN$=RTRIM$(LTRIM$(IN$))
            PRINT #99,CHR$(34);"account_number";CHR$(34);":";CHR$(34);IN$;CHR$(34)
            LAST.RECORD$="}"
            NO.GLSPACCT&=NO.GLSPACCT&+1
            X.COR%=X.COR%+1 : IF X.COR%>22 THEN FOR CLEAN%=1 TO 22 : CALL splocate(CLEAN%,3) : PRINT SPACE$(76); : NEXT : X.COR%=5
            CALL splocate(X.COR%,3) : PRINT "<glspacct_general>",GLSA.DEFINITION$(GLSA.SI%-1),MID$(GLSA.BUFF$,2,6) : CALL sprefresh()
         NEXT
         IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$ : LAST.RECORD$=""
         PRINT #99,"]"
         PRINT #99,"}"
         CLOSE #99

         ' export glspacct - sales and cost.
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glspacct_sales_cost_schema.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"schema";CHR$(34);":{"
         PRINT #99,CHR$(34);"product_line";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"3";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"allow ? as wild card";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"sales_account_number";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"foreign key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"cost_account_number";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"foreign key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"profit_center_code";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"2";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"}"
         PRINT #99,"}"
         PRINT #99,"}"
         CLOSE #99
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glspacct_sales_cost_data.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"data";CHR$(34);":"
         PRINT #99,"["
         LAST.RECORD$=""
         FOR GLSA.SI%=1 TO NO.GLSA%
            GET #5,GLSA.SI%+49
            IN$=MID$(GLSA.BUFF$,4,12) : GOSUB CLEN:
            IF RTRIM$(IN$)<>"" THEN
               IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$;"," : LAST.RECORD$=""
               PRINT #99,"{"
               IN$=LEFT$(GLSA.BUFF$,3) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"product_line";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=MID$(GLSA.BUFF$,4,6) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"sales_account_number";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=MID$(GLSA.BUFF$,10,6) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"cost_account_number";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=MID$(GLSA.BUFF$,16,2) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"profit_center_code";CHR$(34);":";CHR$(34);IN$;CHR$(34)
               LAST.RECORD$="}"
               NO.GLSPACCT&=NO.GLSPACCT&+1
               X.COR%=X.COR%+1 : IF X.COR%>22 THEN FOR CLEAN%=1 TO 22 : CALL splocate(CLEAN%,3) : PRINT SPACE$(76); : NEXT : X.COR%=5
               CALL splocate(X.COR%,3) : PRINT "<glspacct_sales_cost>",GLSA.BUFF$ : CALL sprefresh()
            END IF
         NEXT
         IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$ : LAST.RECORD$=""
         PRINT #99,"]"
         PRINT #99,"}"
         CLOSE #99

         ' export glaccts.
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glaccts_schema.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"schema";CHR$(34);":{"
         PRINT #99,CHR$(34);"num";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"primary key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"account number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"name";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"30";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"type";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"1";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"H, R, T";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"H for header account, R for regular account, T for total account";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"debit";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"1";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"D, C";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"D for normally debit, C for normally credit";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"sales";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"boolean";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"is this accounts for recording sales";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"report";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"1";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"I, B";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"I for income statement account, B for balance sheet account";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"lines";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"numeric";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"1";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"between 0 and 9";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"0 for no spacing, 1 for 1 line, etc";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"level";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"numeric";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"1";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"between 0 and 9";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"dv";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"foreign key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"4";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"maximum 99 division and profit center combinations";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"}"
         PRINT #99,"}"
         PRINT #99,"}"
         CLOSE #99      
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glaccts_data.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"data";CHR$(34);":"
         PRINT #99,"["
         LAST.RECORD$=""
         SCROLL.F1%=-1 : SCROLL.F2%=-1 : SCROLL.WHERE1!=0 : SCROLL.WHERE2!=0
         WHILE SCROLL.F1% OR SCROLL.F2%
            CALL splowkey(6,0,2,SCROLL2$(),1,1,NO.GLIX%,NO.SCROLL2%,SCROLL.F1%,SCROLL.F2%,SCROLL.WHERE1!,SCROLL.WHERE2!,SCROLL.REC%,"")
            IF (SCROLL.F1% OR SCROLL.F2%) AND SCROLL.REC%>0 THEN
               GET #3,SCROLL.REC%
               IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$;"," : LAST.RECORD$=""
               PRINT #99,"{"
               IN$=GLAC.BF$(1) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"num";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=GLAC.BF$(2) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"name";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=GLAC.BF$(3) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"type";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=GLAC.BF$(4) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"debit";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IF GLAC.BF$(5)="Y" THEN IN$="true" ELSE IN$="false"
               PRINT #99,CHR$(34);"sales";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=GLAC.BF$(7) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"report";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IF GLAC.BF$(8)="N" THEN IN$="0" ELSE IN$=GLAC.BF$(8) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"lines";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=GLAC.BF$(9) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"level";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               NO.GLAC.DVPC%=0
               FOR DVPC.SI%=1 TO 99
                  IF RTRIM$(LEFT$(GLAC.BF$(DVPC.SI%+10),4))<>"" AND CVI(MID$(GLAC.BF$(DVPC.SI%+10),5,2))>0 THEN
                     NO.GLAC.DVPC%=NO.GLAC.DVPC%+1
                     IN$=LEFT$(GLAC.BF$(DVPC.SI%+10),4) : GOSUB CLEN:
                     GLAC.DVPC$(NO.GLAC.DVPC%)=IN$
                  END IF
               NEXT
               FOR DVPC.SI%=1 TO NO.GLAC.DVPC%
                  IN1$=LTRIM$(STR$(DVPC.SI%))
                  IF DVPC.SI%<NO.GLAC.DVPC% THEN
                     IN$=GLAC.DVPC$(DVPC.SI%) : IN$=RTRIM$(LTRIM$(IN$))
                     PRINT #99,CHR$(34);"dv_";IN1$;CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  ELSE
                     IN$=GLAC.DVPC$(DVPC.SI%) : IN$=RTRIM$(LTRIM$(IN$))
                     PRINT #99,CHR$(34);"dv_";IN1$;CHR$(34);":";CHR$(34);IN$;CHR$(34)
                     LAST.RECORD$="}"
                  END IF
               NEXT
               NO.GLACCTS&=NO.GLACCTS&+1
               X.COR%=X.COR%+1 : IF X.COR%>22 THEN FOR CLEAN%=1 TO 22 : CALL splocate(CLEAN%,3) : PRINT SPACE$(76); : NEXT : X.COR%=5
               CALL splocate(X.COR%,3) : PRINT "<glaccts>",NO.GLACCTS&,GLAC.BF$(1),GLAC.BF$(2) : CALL sprefresh()
            END IF
         WEND
         IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$ : LAST.RECORD$=""
         PRINT #99,"]"
         PRINT #99,"}"
         CLOSE #99

         ' export glbudget.
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glbudget_schema.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"schema";CHR$(34);":{"
         PRINT #99,CHR$(34);"account_number";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"primary key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"dv_pc_code";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"primary key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"4";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"previous_year_balance";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"opening account balance for balance sheet accounts, income statement accounts are 0";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         FOR PERIOD.SI%=1 TO 12
            IN1$=LTRIM$(STR$(PERIOD.SI%)) : IF LEN(IN1$)=1 THEN IN2$="0"+IN1$ ELSE IN2$=IN1$
            PRINT #99,CHR$(34);"period";IN1$;"_opening_balance";CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            PRINT #99,"},"
            PRINT #99,CHR$(34);"first_record_in_glbket";IN2$;CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            PRINT #99,"},"
            PRINT #99,CHR$(34);"last_record_in_glbket";IN2$;CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            PRINT #99,"},"
         NEXT
         FOR PERIOD.SI%=13 TO 36
            IN1$=LTRIM$(STR$(PERIOD.SI%)) : IN2$=IN1$
            PRINT #99,CHR$(34);"period";IN1$;"_budget";CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            PRINT #99,"},"
            PRINT #99,CHR$(34);"period";IN1$;"_opening_balance";CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            PRINT #99,"},"
            PRINT #99,CHR$(34);"first_record_in_glbket";IN2$;CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            PRINT #99,"},"
            PRINT #99,CHR$(34);"last_record_in_glbket";IN2$;CHR$(34);":{"
            PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
            PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
            IF PERIOD.SI%<36 THEN
               PRINT #99,"},"
            ELSE
               PRINT #99,"}"
            END IF
         NEXT
         PRINT #99,"}"
         PRINT #99,"}"
         CLOSE #99
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glbudget_data.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"data";CHR$(34);":"
         PRINT #99,"["
         LAST.RECORD$=""
         FOR GLBG.SI%=1 TO NO.GLBG%
            GET #4,GLBG.SI%+1
            IN1$=RTRIM$(LEFT$(GLBG.BF$(1),6)) : IN2$=RTRIM$(MID$(GLBG.BF$(1),7,2)) : IN3$=RTRIM$(MID$(GLBG.BF$(1),9,2))
            IF IN1$<>"" AND IN1$<>"*@*@*@" AND IN2$<>"" AND IN2$<>"*@" AND IN3$<>"" AND IN3$<>"*@" THEN
               IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$;"," : LAST.RECORD$=""
               PRINT #99,"{"
               IN$=LEFT$(GLBG.BF$(1),6) : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"account_number";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=MID$(GLBG.BF$(1),7,4) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
               PRINT #99,CHR$(34);"dv_pc_code";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               IN$=LTRIM$(STR$(FNROUND#(CVD(GLBG.BF$(2)),2)))
               PRINT #99,CHR$(34);"previous_year_balance";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               FOR PERIOD.SI%=1 TO 12
                  IN1$=LTRIM$(STR$(PERIOD.SI%)) : IF LEN(IN1$)=1 THEN IN2$="0"+IN1$ ELSE IN2$=IN1$
                  IN$=LTRIM$(STR$(FNROUND#(CVD(LEFT$(GLBG.BF$(PERIOD.SI%+2),8)),2)))
                  PRINT #99,CHR$(34);"period";IN1$;"_opening_balance";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVL(MID$(GLBG.BF$(PERIOD.SI%+2),9,4))))
                  PRINT #99,CHR$(34);"first_record_in_glbket";IN2$;CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVL(MID$(GLBG.BF$(PERIOD.SI%+2),13,4))))
                  PRINT #99,CHR$(34);"last_record_in_glbket";IN2$;CHR$(34);":";CHR$(34);IN$;CHR$(34);","
               NEXT
               FOR PERIOD.SI%=13 TO 36
                  IN1$=LTRIM$(STR$(PERIOD.SI%)) : IN2$=IN1$
                  IN$=LTRIM$(STR$(FNROUND#(CVD(LEFT$(GLBG.BF$(PERIOD.SI%+2),8)),2)))
                  PRINT #99,CHR$(34);"period";IN1$;"_budget";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(MID$(GLBG.BF$(PERIOD.SI%+2),9,8)),2)))
                  PRINT #99,CHR$(34);"period";IN1$;"_opening_balance";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVL(MID$(GLBG.BF$(PERIOD.SI%+2),17,4))))
                  PRINT #99,CHR$(34);"first_record_in_glbket";IN2$;CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVL(MID$(GLBG.BF$(PERIOD.SI%+2),21,4))))
                  IF PERIOD.SI%<36 THEN
                     PRINT #99,CHR$(34);"last_record_in_glbket";IN2$;CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  ELSE
                     PRINT #99,CHR$(34);"last_record_in_glbket";IN2$;CHR$(34);":";CHR$(34);IN$;CHR$(34)
                     LAST.RECORD$="}"
                  END IF
               NEXT
               NO.GLBUDGET&=NO.GLBUDGET&+1
               X.COR%=X.COR%+1 : IF X.COR%>22 THEN FOR CLEAN%=1 TO 22 : CALL splocate(CLEAN%,3) : PRINT SPACE$(76); : NEXT : X.COR%=5
               CALL splocate(X.COR%,3) : PRINT "<glbudget>",NO.GLBUDGET&,GLBG.BF$(1) : CALL sprefresh()
            END IF
         NEXT
         IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$ : LAST.RECORD$=""
         PRINT #99,"]"
         PRINT #99,"}"
         CLOSE #99

         ' export glbket??.
         OPEN "O",99,ROOT.DIRECTORY$+"/data/glbket_schema.json"
         PRINT #99,"{"
         PRINT #99,CHR$(34);"schema";CHR$(34);":{"
         PRINT #99,CHR$(34);"num";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"primary key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"ignore this record when all spaces or *@*@*@";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"dvpc";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"primary key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"4";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"curr";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"2";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"U, C, B";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"U for US dollar, C for Canadian dollar, B for British pound";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"src";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"2";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"AR, AP, GL, IS, IV, RB, PS, PO, PR";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"indicate which module the record came from";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"pdate";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"10";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"yyyy/mm/dd";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"aud_num";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"amt";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"note";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"30";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"src_key";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"foreign key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"12";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"either vendor code or ship+bill code";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"jour";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"2";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"SJ, CJ, PJ, CD, GL";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"journal type - a general accepted accounting term";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"jour_num";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"inv_num";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"cn_ck_num";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"6";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"can be credit note number or cheque number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"trans_code";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"valid_value";CHR$(34);":";CHR$(34);"0 to 14, ignore this record when 0";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"1-invoice, 2-payment, 3-dr adjustment, 4-Cr adjustment, 5-cheque reversal, 6-over payment, 7-down payment, 8-nsf, 9-standard, 10-repeat post, 11-reverse post, 12-correction, 13-discount, 14-receiving";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"disc";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"discount amount";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"yes";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"orig_date";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"10";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"yyyy/mm/dd";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"orig_amt";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"dc_amt";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"nspc";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"comm";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"number";CHR$(34);","
         PRINT #99,CHR$(34);"comment";CHR$(34);":";CHR$(34);"commission amount";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"po";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"string";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"7";CHR$(34);","
         PRINT #99,CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"},"
         PRINT #99,CHR$(34);"srep";CHR$(34);":{"
         PRINT #99,CHR$(34);"data_type";CHR$(34);":";CHR$(34);"foreign key";CHR$(34);","
         PRINT #99,CHR$(34);"length";CHR$(34);":";CHR$(34);"3";CHR$(34);","
         PRINT #99,;CHR$(34);"require";CHR$(34);":";CHR$(34);"no";CHR$(34)
         PRINT #99,"}"
         PRINT #99,"}"
         PRINT #99,"}"
         CLOSE #99
         FOR POST.PERIOD%=1 TO 36
            IN$=RIGHT$("0"+LTRIM$(STR$(POST.PERIOD%)),2)
            CLOSE #6
            OPEN FNWHERE$("glbket"+IN$) FOR RANDOM ACCESS READ SHARED AS #6 LEN=160
            FIELD #6,10 AS GLBK.BF$(1),2 AS GLBK.BF$(2),2 AS GLBK.BF$(3),6 AS GLBK.BF$(4),4 AS GLBK.BF$(5),8 AS GLBK.BF$(6),       _
                     30 AS GLBK.BF$(7),12 AS GLBK.BF$(8),2 AS GLBK.BF$(9),4 AS GLBK.BF$(10),6 AS GLBK.BF$(11),6 AS GLBK.BF$(12),   _
                     2 AS GLBK.BF$(13),8 AS GLBK.BF$(14),6 AS GLBK.BF$(15),8 AS GLBK.BF$(16),8 AS GLBK.BF$(17),8 AS GLBK.BF$(18),  _
                     8 AS GLBK.BF$(19),7 AS GLBK.BF$(20),3 AS GLBK.BF$(21),4 AS GLBK.BF$(22)
            IF LOF(6)>0 THEN
               GET #6,1
               NO.GLBK&=CVL(LEFT$(GLBK.BF$(1),4))
               CLOSE #99
               OPEN "O",99,ROOT.DIRECTORY$+"/data/glbket_data"+IN$+".json"
               PRINT #99,"{"
               PRINT #99,CHR$(34);"data";CHR$(34);":"
               PRINT #99,"["
               LAST.RECORD$=""
               FOR GLBK.SI&=1 TO NO.GLBK&
                  GET #6,GLBK.SI&+1
                  IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$;"," : LAST.RECORD$=""
                  PRINT #99,"{"
                  IN$=LEFT$(GLBK.BF$(1),6) : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"num";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=MID$(GLBK.BF$(1),7,4) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"dvpc";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(2) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"curr";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(3) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"src";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IF RTRIM$(GLBK.BF$(4))="" THEN
                     IN$=""
                  ELSEIF LEFT$(GLBK.BF$(4),2)>="80" THEN
                     IN$="19"+LEFT$(GLBK.BF$(4),2)+"/"+MID$(GLBK.BF$(4),3,2)+"/"+MID$(GLBK.BF$(4),5,2)
                  ELSE
                     IN$="20"+LEFT$(GLBK.BF$(4),2)+"/"+MID$(GLBK.BF$(4),3,2)+"/"+MID$(GLBK.BF$(4),5,2)
                  END IF
                  PRINT #99,CHR$(34);"pdate";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVS(GLBK.BF$(5))))
                  PRINT #99,CHR$(34);"aud_num";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(GLBK.BF$(6)),2)))
                  PRINT #99,CHR$(34);"amt";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(7) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"note";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(8) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"src_key";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(9) : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"jour";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVS(GLBK.BF$(10))))
                  PRINT #99,CHR$(34);"jour_num";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(11) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"inv_num";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(12) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"cn_ck_num";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(CVI(GLBK.BF$(13))))
                  PRINT #99,CHR$(34);"trans_code";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(GLBK.BF$(14)),2)))
                  PRINT #99,CHR$(34);"disc";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IF RTRIM$(GLBK.BF$(15))="" THEN
                     IN$=""
                  ELSEIF LEFT$(GLBK.BF$(15),2)>="80" THEN
                     IN$="19"+LEFT$(GLBK.BF$(15),2)+"/"+MID$(GLBK.BF$(15),3,2)+"/"+MID$(GLBK.BF$(15),5,2)
                  ELSE
                     IN$="20"+LEFT$(GLBK.BF$(15),2)+"/"+MID$(GLBK.BF$(15),3,2)+"/"+MID$(GLBK.BF$(15),5,2)
                  END IF
                  PRINT #99,CHR$(34);"orig_date";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(GLBK.BF$(16)),2)))
                  PRINT #99,CHR$(34);"orig_amt";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(GLBK.BF$(17)),2)))
                  PRINT #99,CHR$(34);"dc_amt";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(GLBK.BF$(18)),2)))
                  PRINT #99,CHR$(34);"nspc";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=LTRIM$(STR$(FNROUND#(CVD(GLBK.BF$(19)),2)))
                  PRINT #99,CHR$(34);"comm";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(20) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"po";CHR$(34);":";CHR$(34);IN$;CHR$(34);","
                  IN$=GLBK.BF$(21) : GOSUB CLEN: : IN$=RTRIM$(LTRIM$(IN$))
                  PRINT #99,CHR$(34);"srep";CHR$(34);":";CHR$(34);IN$;CHR$(34)
                  LAST.RECORD$="}"
                  NO.GLBKET&=NO.GLBKET&+1
                  X.COR%=X.COR%+1 : IF X.COR%>22 THEN FOR CLEAN%=1 TO 22 : CALL splocate(CLEAN%,3) : PRINT SPACE$(76); : NEXT : X.COR%=5
                  CALL splocate(X.COR%,3) : PRINT "<glbket"+RIGHT$("0"+LTRIM$(STR$(POST.PERIOD%)),2)+">",NO.GLBKET&,GLBK.BF$(1) : CALL sprefresh()
               NEXT
               IF LAST.RECORD$<>"" THEN PRINT #99,LAST.RECORD$ : LAST.RECORD$=""
               PRINT #99,"]"
               PRINT #99,"}"
               CLOSE #99
            END IF
            CLOSE #6
         NEXT
      END IF

      BEEP
      CALL spspace(STR$(NO.GLSPACCT&)+" glspacct records exported.",-1,0)
      CALL spspace(STR$(NO.GLACCTS&)+" glaccts records exported.",-1,0)
      CALL spspace(STR$(NO.GLBUDGET&)+" glbudget records exported.",-1,0)
      CALL spspace(STR$(NO.GLBKET&)+" glbket records exported.",-1,0)
      CALL spclose
      RETURNING$="json"+VERSION$
      CHAIN "./menu"+VERSION$
      CALL sprestart : END

CLEN: ' clean a string.
      TEMP.IN$=IN$
      IN$=""
      FOR CLEN.I%=1 TO LEN(TEMP.IN$)
         IF MID$(TEMP.IN$,CLEN.I%,1)>=CHR$(32) AND MID$(TEMP.IN$,CLEN.I%,1)<=CHR$(126) THEN
            IF MID$(TEMP.IN$,CLEN.I%,1)=CHR$(34) THEN
               IN$=IN$+"\"+MID$(TEMP.IN$,CLEN.I%,1)
            ELSEIF MID$(TEMP.IN$,CLEN.I%,1)="\" THEN
               IN$=IN$+"\"+MID$(TEMP.IN$,CLEN.I%,1)
            ELSE
               IN$=IN$+MID$(TEMP.IN$,CLEN.I%,1)
            END IF
         END IF
      NEXT
      RETURN
