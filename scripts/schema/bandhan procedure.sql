--------------------------------------------------------
--  File created - Tuesday-June-20-2023   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure BALANCE_ON_DATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  BALANCE_ON_DATE (P_CroId IN Users.id%TYPE,
P_ACCOUNTID IN accounts.accountid%TYPE,
P_Date IN TIMESTAMP,
P_CurrentBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count1 NUMBER;
V_count2 NUMBER;
Bal number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_ACCOUNTID IS NULL and P_CroId is NULL THEN
      RAISE Null_Data;
   ELSE
    Select count(*)
 into V_count1 FROM users where Users.id=P_CroId;
    Select count(*)
 into V_count2 FROM accounts where ACCOUNTS.ACCOUNTID=P_ACCOUNTID;
      IF(V_count1=1 and V_count2=1) THEN 
                SELECT CURRENTBALANCE INTO Bal
                FROM USERS 
                JOIN CUSTOMERS ON users.id = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE 
                USERS.ID=P_CroId and Accounts.accountid=P_ACCOUNTID
                AND TRUNC(transactionhistory.currentdate)= TRUNC(P_Date);

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Balance_On_Date;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_DATA (P_CroId IN users.id%TYPE,
 show_data OUT SYS_REFCURSOR)IS
V_Count number;
DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
     select count(*)
 into V_Count from users where users.id=P_CroId;
     IF P_CroId IS NULL THEN
      RAISE Null_Data;
     ELSE
         IF V_Count>=1 then


                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID                
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;


            open show_data FOR
            SELECT accountid, custid, customername, accountnumber, mobileno, accounttype, accounttype2, customerid,
                   nooftransactioninlast30day, currentbalance
            FROM (
              SELECT accounts.accountid, customers.custid, customers.customername, accounts.accountnumber, customers.mobileno,
                     accounts.accounttype, accounts.accounttype2, customers.customerid,
                     transactionhistory.nooftransactioninlast30day, transactionhistory.currentbalance,
                     ROW_NUMBER() OVER (PARTITION BY accounts.accountid ORDER BY transactionhistory.currentbalance DESC) AS rn
              FROM USERS
              JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
              JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
              JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID
              WHERE USERS.ID = P_CroId
                AND TRUNC(TRANSACTIONHISTORY.CURRENTDATE) = TRUNC(DAT)
            ) subquery
            WHERE rn = 1;


         ELSE
         Raise Data_Not_Found;
         END IF;
     END IF;
            EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);   

END Caller_Data;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_CUURENT_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_CUURENT_BALANCE (P_CroId IN users.id%TYPE,
 P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 
                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DAT);

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Cuurent_Balance;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_GAP_PERCENTAGE_TARGET_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_GAP_PERCENTAGE_TARGET_SA_CA (
P_CroId IN users.id%TYPE,
P_Target IN transactionhistory.currentbalance%Type,
P_Account_Type IN Accounts.accounttype%type,
P_GapToTargetPercentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_7th number;
DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;



                SELECT SUM(CURRENTBALANCE) INTO V_7th
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND accounts.accounttype in(P_Account_Type)
                AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(DAT);

                if P_Target=0 then 
                   P_GapToTargetPercentage:=0;
                else
                   Select (V_7th/P_Target)*100 into P_GapToTargetPercentage from dual;

        end if;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Gap_Percentage_Target_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_GAP_PERCENTAGE_TARGET
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_GAP_PERCENTAGE_TARGET (
P_CroId IN users.id%TYPE,
P_Target IN transactionhistory.currentbalance%Type,
P_GapToTargetPercentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
v_subvalue NUMBER;
v_subvalue1 NUMBER;
DAT TIMESTAMP;
DAT1 TIMESTAMP;
V_current number;
v_first_day_balance number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                SELECT (TO_TIMESTAMP((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;



                SELECT (TO_TIMESTAMP((
                SELECT CURRENTDATE 
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE asc fetch first 1 row only)))INTO DAT1 FROM DUAL; 



                SELECT SUM(CURRENTBALANCE) INTO V_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TO_TIMESTAMP(TransactionHistory.CURRENTDATE)=TO_TIMESTAMP(DAT);



                SELECT SUM(CURRENTBALANCE) INTO v_first_day_balance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TO_TIMESTAMP(TransactionHistory.CURRENTDATE)=TO_TIMESTAMP(DAT1);


        select  (V_current-v_first_day_balance), (P_Target-v_first_day_balance) into v_subvalue, v_subvalue1 from dual;

         if (v_subvalue1 =0) then 
            P_GapToTargetPercentage:=0;
         else 
            Select (v_subvalue/v_subvalue1) *100 into P_GapToTargetPercentage from dual;

         --Select ((V_current-v_first_day_balance)/(P_Target-v_first_day_balance))*100 into P_GapToTargetPercentage from dual;

end if;
          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Gap_Percentage_Target;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_GAP_TARGET
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_GAP_TARGET (
P_CroId IN users.id%TYPE,
P_Target transactionhistory.currentbalance%Type, 
P_GapToTargetAchieve OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_DAT TIMESTAMP;
V_CurrentAchieve number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO V_DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO V_CurrentAchieve
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);

                select (P_Target-V_CurrentAchieve) INTO P_GapToTargetAchieve from dual;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Gap_Target;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_NEXT_CONTACT_DATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_NEXT_CONTACT_DATE (P_UserId IN users.id%Type,
P_AccountId IN accounts.accountid%TYPE,
P_last_date out timestamp )IS
V_count1 NUMBER;
V_count2 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_AccountId IS NULL THEN
      RAISE Null_Data;
   ELSE
    Select count(*) into V_count1 FROM Accounts where AccountId=P_AccountId;
    Select count(*) into V_count2 FROM Accounts where AccountId=P_AccountId;
      IF(V_count1>=1 and V_count2>=1) THEN 

            SELECT NEXTCONTACTDATE INTO P_last_date  
            FROM USERS 
            JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
            JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
            JOIN leads ON ACCOUNTS.ACCOUNTID = leads.ACCOUNTID
            WHERE Accounts.AccountId=P_AccountId AND Users.id=P_UserId ORDER BY NEXTCONTACTDATE DESC FETCH FIRST 1 ROW ONLY;
      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Next_Contact_Date;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_GAP_TARGET_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_GAP_TARGET_SA_CA (
P_CroId IN users.id%TYPE,
P_Target IN transactionhistory.currentbalance%Type, 
P_Account_Type IN Accounts.accounttype%type,
P_GapToTargetAchieve OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_DAT TIMESTAMP;
V_CurrentAchieve number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO V_DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO V_CurrentAchieve
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND accounts.accounttype in(P_Account_Type)
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);

                select (P_Target-V_CurrentAchieve) * -1 INTO P_GapToTargetAchieve from dual;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Gap_Target_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure CALLER_VIEW_PERCENTAGE_INCREASE_BALANCE_ON25MAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CALLER_VIEW_PERCENTAGE_INCREASE_BALANCE_ON25MAY (P_CroId IN users.id%TYPE,
 P_Custdate IN timestamp,
 P_Percentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_25th number;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       


                SELECT SUM(CURRENTBALANCE) INTO V_25th
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(P_Custdate);


                SELECT SUM(CURRENTBALANCE) INTO V_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC((
                SELECT CURRENTDATE 
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only));
                dbms_output.put_line(V_25th);
                dbms_output.put_line(V_current);

                if(V_25th=0) then 
                P_Percentage:=0;
                else
                SELECT ((V_25th-V_current)/V_25th)*100  INTO P_Percentage FROM DUAL;
                end if;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Caller_View_Percentage_Increase_Balance_on25MAY;

/
--------------------------------------------------------
--  DDL for Procedure COSTOMER_CONTACTED_7DAYS_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  COSTOMER_CONTACTED_7DAYS_SA_CA (P_CroId IN Accounts.AccountNumber%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
v_7TH number;
v_Current number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by leads.contacteddate desc fetch first 1 row only)))INTO DAT FROM DUAL;



                SELECT COUNT(DISTINCT(leads.accountid)) INTO v_Current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<TRUNC(DAT)
                 AND accounts.accounttype in(P_Account_Type);


                SELECT COUNT(DISTINCT(leads.accountid)) INTO  v_7TH
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<TRUNC((DAT)-7)
                 AND accounts.accounttype in(P_Account_Type);
                DBMS_OUTPUT.PUT_LINE(v_Current);
                DBMS_OUTPUT.PUT_LINE(v_7TH);
                select (v_Current-v_7TH) INTO P_Costomer_Contacted FROM DUAL;

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Costomer_Contacted_7days_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure COUNT_COSTOMER_CONTACTED_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  COUNT_COSTOMER_CONTACTED_7DAYS (P_CroId IN Accounts.AccountNumber%TYPE,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
v_7TH number;

BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by leads.contacteddate desc fetch first 1 row only)))INTO DAT FROM DUAL;
                DBMS_OUTPUT.PUT_LINE(TRUNC(DAT));
                DBMS_OUTPUT.PUT_LINE(TRUNC(DAT-7));




                SELECT COUNT(DISTINCT(leads.accountid)) INTO P_Costomer_Contacted
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<=TRUNC(DAT)  AND TRUNC(LEADS.CONTACTEDDATE)>=TRUNC((DAT)-7);


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Count_Costomer_Contacted_7days;

/
--------------------------------------------------------
--  DDL for Procedure COSTOMER_CONTACTED_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  COSTOMER_CONTACTED_7DAYS (P_CroId IN Accounts.AccountNumber%TYPE,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 



                SELECT COUNT(DISTINCT(leads.accountid)) INTO  P_Costomer_Contacted
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                LEADS.ISLEAD = 1 AND 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)>=TRUNC((SYSDATE)-7) 
                AND TRUNC(LEADS.CONTACTEDDATE)<TRUNC(SYSDATE);

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Costomer_Contacted_7days;

/
--------------------------------------------------------
--  DDL for Procedure COUNTDELAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  COUNTDELAY (P_CroId IN Users.id%TYPE,
P_ACCOUNTID IN accounts.accountid%TYPE,
P_TotalLeads OUT number ,
P_Delay_Lead OUT number,
P_No_Delay OUT number)IS
V_Total_Product_Leads number;
V_Total_Service_Leads number;
V_Total_Product_Leads_Under_TAT number;
V_Total_Service_Leads_Under_TAT number;
V_Total_Service_Leads_Over_Tat number;
V_Total_Product_Leads_Over_Tat number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT COUNT(*)
                INTO V_Total_Product_Leads
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                LEADS.productid IS NOT NULL AND LEADS.leadstage NOT IN(0,3);


                SELECT COUNT(*)
                INTO V_Total_Service_Leads
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                leads.serviceid IS NOT NULL AND LEADS.leadstage NOT IN(0,2);

           --Status Under TAT

                SELECT COUNT(*)
                INTO V_Total_Product_Leads_Under_TAT
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                LEADS.productid IS NOT NULL AND LEADS.leadstage NOT IN(0,3) AND TRUNC(SYSDATE)<=TRUNC(leads.estimateddate);


                SELECT COUNT(*)
                INTO V_Total_Service_Leads_Under_TAT
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                leads.serviceid IS NOT NULL AND LEADS.leadstage NOT IN(0,2) AND TRUNC(SYSDATE)<=TRUNC(leads.estimateddate);

           --Status Over TAT

                SELECT COUNT(*)
                INTO V_Total_Product_Leads_Over_Tat
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                LEADS.productid IS NOT NULL AND LEADS.leadstage NOT IN(0,3) AND TRUNC(SYSDATE)>TRUNC(leads.estimateddate);


                SELECT COUNT(*)
                INTO V_Total_Service_Leads_Over_Tat
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                leads.serviceid IS NOT NULL AND LEADS.leadstage NOT IN(0,2) AND TRUNC(SYSDATE)>TRUNC(leads.estimateddate);  



                SELECT (V_Total_Product_Leads_Under_TAT+V_Total_Service_Leads) INTO P_TotalLeads  FROM DUAL;
                SELECT (V_Total_Product_Leads_Under_TAT+V_Total_Service_Leads_Under_TAT) INTO P_No_Delay FROM DUAL;
                SELECT (V_Total_Product_Leads_Over_Tat+V_Total_Service_Leads_Over_Tat) INTO P_Delay_Lead FROM DUAL;




      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END CountDelay;

/
--------------------------------------------------------
--  DDL for Procedure CRO_FIRST_DAY_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CRO_FIRST_DAY_BALANCE (P_CroId IN Users.Id%TYPE,
P_Balance OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
V_bal1 NUMBER;
DATFirst TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
      Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE asc fetch first 1 row only)))INTO DATFirst FROM DUAL;

        --=====================================================QUERY TO FIND BALANACE ON SECOND TRANSACTION DATE
                SELECT SUM(CURRENTBALANCE) INTO V_bal1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DATFirst);



        --=====================================================QUERY TO CALCULATE PERCENTAGE INCREARE OR DECREASE

               select V_bal1 into P_Balance from dual;




      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END CRO_FIRST_DAY_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure CURENT_BALANCES_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CURENT_BALANCES_SA_CA (P_CroId IN users.id%TYPE,
P_Account_Type IN Accounts.accounttype%type,P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 




                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE DESC fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId AND accounts.accounttype=P_Account_Type
                AND TRUNC(TransactionHistory.CURRENTDATE) =TRUNC(DAT);


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END CURENT_BALANCES_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure CRO_STARTING_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CRO_STARTING_BALANCE (P_CroId IN users.id%TYPE,
P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 
                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE asc fetch first 1 row only)))INTO DAT FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DAT);

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END CRO_STARTING_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure CUSTOMER_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CUSTOMER_BALANCE (P_CroId IN Users.id%TYPE,
P_Status IN leads.status%TYPE ,P_Percentage OUT number)IS
StatusCount number;
AllCount number;
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)

 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO StatusCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                WHERE USERS.ID=P_CroId AND CUSTOMERS.CUST_STATUS=P_Status;


                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO AllCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                AND USERS.ID=P_CroId;


         if(AllCount=0) then
         P_Percentage:=0;
         else
                select (StatusCount/AllCount)*100  into P_Percentage from dual;
                end if;



      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END customer_balance;

/
--------------------------------------------------------
--  DDL for Procedure CUSTOMER_BALANCE_OF_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CUSTOMER_BALANCE_OF_7DAYS (P_CroId IN Users.id%TYPE,
P_Status IN leads.status%TYPE ,
P_Percentage OUT number)IS
StatusCount number;
AllCount number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
V1_Percentage number;
V2_Percentage number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)

 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                customer_balance(P_CroId,P_Status,V1_Percentage);

                SELECT (TRUNC((
                SELECT CONTACTEDDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by LEADS.CONTACTEDDATE desc fetch first 1 row only))) INTO V_DAT 
                FROM DUAL;



                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO StatusCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
                WHERE leads.islead=1 and USERS.ID=P_CroId AND leads.status=P_Status AND leads.contacteddate<(SYSDATE-7);

                DBMS_OUTPUT.PUT_LINE(StatusCount);
                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO AllCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
                where USERS.ID=P_CroId AND leads.contacteddate<(SYSDATE-7) and leads.islead=1;
                DBMS_OUTPUT.PUT_LINE(AllCount);
      if(AllCount=0) then 
        V2_Percentage:=0;
      else
        select (StatusCount/AllCount)*100  into V2_Percentage from dual;
        dbms_output.put_line(V2_Percentage || 'P_Percentage');
       -- SELECT (V1_Percentage-V2_Percentage)  INTO P_Percentage FROM DUAL; 
      end if;
        SELECT (V1_Percentage-V2_Percentage)  INTO P_Percentage FROM DUAL; 

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END customer_balance_of_7days;

/
--------------------------------------------------------
--  DDL for Procedure CUSTOMER_BALANCE_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CUSTOMER_BALANCE_SA_CA (P_CROID IN NUMBER, P_STSTUS IN varchar2, 
P_Account_Type IN Accounts.accounttype%type,
OP_BALANCE_OUT OUT NUMBER
)
AS
v_ststus_count number;
v_croid_count number;
begin
--open OP_BALANCE_OUT for
            select count(*) 
            into v_ststus_count  
            from Leads JOIN ACCOUNTS
            ON  ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
            where croid=P_CROID and status=P_STSTUS
            AND accounts.accounttype in(P_Account_Type);

            select count(croid) 
            into v_croid_count  
            from Leads JOIN ACCOUNTS
            ON  ACCOUNTS.ACCOUNTID =LEADS.ACCOUNTID
            where croid=P_CROID
            AND accounts.accounttype in(P_Account_Type);
            DBMS_OUTPUT.PUT_LINE(v_ststus_count);
            DBMS_OUTPUT.PUT_LINE(v_croid_count);
        if(v_croid_count=0) then 
           OP_BALANCE_OUT:=0;
        else
           select round(v_ststus_count/v_croid_count*100,0) into OP_BALANCE_OUT from dual;
        end if;
exception
    when others then 
    v_ststus_count:=null;
    v_croid_count:=null;

end customer_balance_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure CUSTOMER_LEADS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NON  PROCEDURE  CUSTOMER_LEADS (p_ACCOUNTID number,op_product_dtls out SYS_REFCURSOR)
as
begin 
open op_product_dtls for
        SELECT DISTINCT leadid,servicename,
            (
                SELECT LISTAGG(productname, ',') WITHIN GROUP(
                ORDER BY productname) AS productname
                FROM
                    (
                        SELECT DISTINCT l.leadid,servicename,productname productname
                        FROM
                            leads l
                            INNER JOIN leadproductdetails lp ON l.leadid = lp.leadid
                            INNER JOIN products p ON p.productid = lp.productid
                            LEFT OUTER JOIN services s ON l.serviceid = s.serviceid
                        WHERE
                            accountid =p_ACCOUNTID
                        GROUP BY servicename,productname,l.leadid
                    )
            ) AS productname
        FROM
            (
                SELECT DISTINCT l.leadid,servicename,productname productname
                FROM
                    leads l
                    INNER JOIN leadproductdetails lp ON l.leadid = lp.leadid
                    INNER JOIN products p ON p.productid = lp.productid
                    LEFT OUTER JOIN services s ON l.serviceid = s.serviceid
                WHERE
                    accountid =p_ACCOUNTID
                GROUP BY servicename,productname,l.leadid
            );

end Customer_leads;

/
--------------------------------------------------------
--  DDL for Procedure CUURENT_BALANCE_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  CUURENT_BALANCE_SA_CA (P_CroId IN users.id%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
DATT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 




                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE DESC fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId AND accounts.accounttype=P_Account_Type
                AND TRUNC(TransactionHistory.CURRENTDATE) =TRUNC(DAT);


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END CUURENT_BALANCE_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure DELETE_ALL_RECORDS_FROM_TEMP_TABLE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  DELETE_ALL_RECORDS_FROM_TEMP_TABLE IS
BEGIN
  DELETE FROM temp_table;
  COMMIT; -- Optional: Commit the transaction if necessary
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('DATA CAN NOT DELETED');
END;

/
--------------------------------------------------------
--  DDL for Procedure GROWTH_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  GROWTH_BALANCE (P_CroId IN Accounts.AccountNumber%TYPE,
  P_AccountId accounts.accountid%TYPE,
  P_Balance_Growth OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
V_bal1 NUMBER;
DAT TIMESTAMP;
V_bal2 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
      Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO V_bal1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                and Accounts.accountid=P_AccountId
                AND TRUNC(TransactionHistory.CURRENTDATE)= TRUNC(DAT);
        --=====================================================QUERY TO FIND BALANACE ON SECOND TRANSACTION DATE
                SELECT SUM(CURRENTBALANCE) INTO V_bal2
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                and Accounts.accountid=P_AccountId
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC((select min(currentdate) from TRANSACTIONHISTORY 
                where accountid=P_AccountId ));
        --=====================================================QUERY TO CALCULATE PERCENTAGE INCREARE OR DECREASE

             if (V_bal2=0) then 
                 P_Balance_Growth:=0;
            
             else
                 select ((V_bal1-V_bal2)/V_bal2)*100 into P_Balance_Growth from dual;

             end if;

              dbms_output.put_line( 'DECREASES BY ' || P_Balance_Growth || 'PERCENT');


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Growth_Balance;

/
--------------------------------------------------------
--  DDL for Procedure DELAYLEADS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  DELAYLEADS (P_CroId IN Users.id%TYPE,
P_ACCOUNTID IN accounts.accountid%TYPE,P_Delay_Lead  OUT number)IS
V_Total_Service_Leads_Over_Tat number;
V_Total_Product_Leads_Over_Tat number;
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


           --Status Over TAT

                SELECT COUNT(*)
                INTO V_Total_Product_Leads_Over_Tat
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                LEADS.productid IS NOT NULL AND LEADS.leadstage NOT IN(0,3) AND TRUNC(SYSDATE)>TRUNC(leads.estimateddate);


                SELECT COUNT(*)
                INTO V_Total_Service_Leads_Over_Tat
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                leads.serviceid IS NOT NULL AND LEADS.leadstage NOT IN(0,2) AND TRUNC(SYSDATE)>TRUNC(leads.estimateddate);  


                SELECT (V_Total_Product_Leads_Over_Tat+V_Total_Service_Leads_Over_Tat) INTO P_Delay_Lead FROM DUAL;




      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END DelayLeads;

/
--------------------------------------------------------
--  DDL for Procedure GROWTH_BALANCE_SINCE_START_01_06_2023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  GROWTH_BALANCE_SINCE_START_01_06_2023 (P_CroId IN Accounts.AccountNumber%TYPE,
 P_AccountId accounts.accountid%TYPE,
 P_Balance OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
V_bal1 NUMBER;
DAT TIMESTAMP;
V_bal2 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
      Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO V_bal1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                and Accounts.accountid=P_AccountId
                AND TRUNC(TransactionHistory.CURRENTDATE)= TRUNC(DAT);

        --=====================================================QUERY TO FIND BALANACE ON SECOND TRANSACTION DATE
                SELECT SUM(CURRENTBALANCE) INTO V_bal2
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                and Accounts.accountid=P_AccountId
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC((select min(currentdate) from TRANSACTIONHISTORY 
                where accountid=P_AccountId ));

        --=====================================================QUERY TO CALCULATE PERCENTAGE INCREARE OR DECREASE

               select (V_bal1-V_bal2) into P_Balance from dual;


              dbms_output.put_line(V_bal1 );
              dbms_output.put_line( V_bal2);

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Growth_Balance_Since_Start_01_06_2023 ;

/
--------------------------------------------------------
--  DDL for Procedure LIFE_CYCLE_PRODUCT_TAT_ADHERANCE_OF_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  LIFE_CYCLE_PRODUCT_TAT_ADHERANCE_OF_7DAYS (P_CroId IN Users.id%TYPE,
 Tat_Adherance_OF_7DAYS OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder1 number;
ConvertedOver1 number;
V2_PERCENTAGE number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
V1_Percentage number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                LIFE_CYCLE_PRODUCTS_TAT_ADHERANCE(P_CroId,V1_Percentage);

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO 
                WHERE LIFECYCLE_ID = P_CroId)
                order by leads.contacteddate desc fetch first 1 row only)))INTO V_DAT FROM DUAL;
--=========================================================

                SELECT COUNT(*)
                INTO ConvertedUnder1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) AND 
                TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT-7) 
                and leads.productid IS NOT NULL AND LEADS.leadstage=3 AND 
                TRUNC(LEADS.CONVERTEDDATE)<=TRUNC(LEADS.estimateddate);


            DBMS_OUTPUT.PUT_LINE(V_DAT-7);

                SELECT COUNT(*)
                INTO ConvertedOver1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) 
                AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT-7)
                and LEADS.productid IS NOT NULL AND (LEADS.leadstage <> 0) AND 
                TRUNC(LEADS.CONVERTEDDATE)>TRUNC(LEADS.estimateddate) OR (LEADS.CONVERTEDDATE IS NULL 
                AND TRUNC(SYSDATE)>TRUNC(LEADS.estimateddate));
                DBMS_OUTPUT.PUT_LINE(ConvertedUnder1);
                DBMS_OUTPUT.PUT_LINE(ConvertedOver1);

           if((ConvertedUnder1+ConvertedOver1)=0) then
                Tat_Adherance_OF_7DAYS:=0;

           else 
                SELECT (ConvertedUnder1/(ConvertedUnder1+ConvertedOver1))*100 INTO V2_PERCENTAGE FROM DUAL;

                SELECT (V1_PERCENTAGE-V2_PERCENTAGE)INTO Tat_Adherance_OF_7DAYS FROM DUAL;
          end if;

                DBMS_OUTPUT.PUT_LINE(V1_PERCENTAGE);
                DBMS_OUTPUT.PUT_LINE(V2_PERCENTAGE);
--===========================================================

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END LIFE_CYCLE_Product_Tat_Adherance_OF_7DAYS;

/
--------------------------------------------------------
--  DDL for Procedure LIFE_CYCLE_PRODUCTS_TAT_ADHERANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  LIFE_CYCLE_PRODUCTS_TAT_ADHERANCE (P_CroId IN Users.id%TYPE,
  Tat_Adherance OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder1 number;
ConvertedOver1 number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO 
                WHERE LIFECYCLE_ID = P_CroId)
                order by leads.contacteddate desc fetch first 1 row only)))INTO V_DAT FROM DUAL;



                SELECT COUNT(*)
                INTO ConvertedUnder1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) 
                AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT) and leads.productid IS NOT NULL AND LEADS.leadstage=3 AND 
                TRUNC(LEADS.CONVERTEDDATE)<=TRUNC(LEADS.estimateddate);

                SELECT COUNT(*)
                INTO ConvertedOver1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) 
                AND TRUNC(LEADS.contacteddate)<=TRUNC((V_DAT)) and LEADS.productid IS NOT NULL AND
                (LEADS.leadstage <> 0) AND 
                (TRUNC(LEADS.CONVERTEDDATE)>TRUNC(LEADS.estimateddate) OR 
                (LEADS.CONVERTEDDATE IS NULL AND TRUNC(SYSDATE)>TRUNC(LEADS.estimateddate)));
                    dbms_output.put_line(ConvertedOver1);
                    dbms_output.put_line(ConvertedUnder1);
                    dbms_output.put_line(V_DAT);

      if((ConvertedOver1+ConvertedUnder1)=0) then 
        Tat_Adherance:=0;

      else
        select (ConvertedUnder1/(ConvertedOver1+ConvertedUnder1))*100  into Tat_Adherance from dual;

      end if;
                dbms_output.put_line(Tat_Adherance || 'Tat_Adherance');            


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END LIFE_CYCLE_PRODUCTS_TAT_ADHERANCE;

/
--------------------------------------------------------
--  DDL for Procedure LIFE_CYCLE_SERVICES_TAT_ADHERANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  LIFE_CYCLE_SERVICES_TAT_ADHERANCE (P_CroId IN Users.id%TYPE,
 Tat_Adherance OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder1 number;
ConvertedOver1 number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
     INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO 
                WHERE LIFECYCLE_ID = P_CroId)
                order by leads.contacteddate desc fetch first 1 row only)))INTO V_DAT FROM DUAL;



                SELECT COUNT(*)
                INTO ConvertedUnder1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) 
                AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT) and LEADS.serviceid IS NOT NULL AND LEADS.leadstage=2 AND 
                TRUNC(LEADS.CONVERTEDDATE)<=TRUNC(LEADS.estimateddate);




                SELECT COUNT(*)
                INTO ConvertedOver1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) 
                AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT) and LEADS.serviceid IS NOT NULL AND 
                ((TRUNC(LEADS.CONVERTEDDATE)>TRUNC(LEADS.estimateddate))
                OR (LEADS.CONVERTEDDATE IS NULL AND TRUNC(leads.estimateddate)<TRUNC(SYSDATE)));
                dbms_output.put_line(V_DAT);
                dbms_output.put_line(ConvertedUnder1);
                dbms_output.put_line(ConvertedOver1);

          IF ((ConvertedOver1+ConvertedUnder1)=0) THEN 
             Tat_Adherance:=0;
          ELSE
             select (ConvertedUnder1/(ConvertedOver1+ConvertedUnder1))*100  into Tat_Adherance from dual;
             dbms_output.put_line(Tat_Adherance || 'Tat_Adherance');            
          END IF ;

        ELSE
        RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END LIFE_CYCLE_SERVICES_TAT_ADHERANCE;

/
--------------------------------------------------------
--  DDL for Procedure LIFE_CYCLE_SERVICES_TAT_ADHERANCE_OF_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  LIFE_CYCLE_SERVICES_TAT_ADHERANCE_OF_7DAYS (P_CroId IN Users.id%TYPE,
Tat_Adherance_OF_7DAYS OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder1 number;
ConvertedOver1 number;
V1_Percentage number;
V2_Percentage number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                LIFE_CYCLE_SERVICES_TAT_ADHERANCE(P_CroId,V2_Percentage);




                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO 
                WHERE LIFECYCLE_ID = P_CroId)
                order by leads.contacteddate desc fetch first 1 row only)))INTO V_DAT FROM DUAL;



                SELECT COUNT(*)
                INTO ConvertedUnder1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId) 
                AND (TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT-7) )
                and LEADS.serviceid IS NOT NULL AND LEADS.leadstage=2 AND 
                TRUNC(LEADS.CONVERTEDDATE)<=TRUNC(LEADS.estimateddate);




                SELECT COUNT(*)
                INTO ConvertedOver1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID IN(SELECT CRO_ID FROM LIFECYCLECRO WHERE LIFECYCLE_ID = P_CroId)
                AND (TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT-7) )
                and LEADS.serviceid IS NOT NULL AND 
                TRUNC(LEADS.CONVERTEDDATE)>TRUNC(LEADS.estimateddate) 
                OR (LEADS.CONVERTEDDATE IS NULL AND TRUNC(leads.estimateddate)<(SYSDATE));

            
            if((ConvertedUnder1+ConvertedOver1)=0) then 
                Tat_Adherance_OF_7DAYS:=0;
            else
                SELECT (ConvertedUnder1/(ConvertedUnder1+ConvertedOver1))*100 INTO V1_Percentage FROM DUAL ;
                SELECT (V2_Percentage - V1_Percentage) INTO Tat_Adherance_OF_7DAYS FROM DUAL ;
            end if;

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END LIFE_CYCLE_SERVICES_TAT_ADHERANCE_OF_7DAYS;

/
--------------------------------------------------------
--  DDL for Procedure MINTAT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  MINTAT (P_CroId IN Users.id%TYPE,
P_ACCOUNTID IN accounts.accountid%TYPE,P_Min_Tat OUT NUMBER)IS
V_Min_Tat_Product NUMBER;
V_Min_Tat_Service NUMBER;

BEGIN

                SELECT MIN(PRODUCTS.USUALTATDAYS)
                INTO V_Min_Tat_Product
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
                JOIN PRODUCTS ON leads.productid = products.productid
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                LEADS.productid IS NOT NULL AND LEADS.leadstage NOT IN(0,3);


                SELECT MIN(Services.USUALTATDAYS)
                INTO V_Min_Tat_Service
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID  
                JOIN PRODUCTS ON leads.productid = products.productid
                JOIN SERVICES ON leads.SERVICEID = SERVICES.SERVICEID
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                leads.serviceid IS NOT NULL AND LEADS.leadstage NOT IN(0,2);

                IF(V_Min_Tat_Service IS NULL)THEN
                  P_Min_Tat:=V_Min_Tat_Product;
                ELSE
                  SELECT CASE WHEN V_Min_Tat_Product < V_Min_Tat_Service THEN V_Min_Tat_Product ELSE V_Min_Tat_Service END
                  INTO P_Min_Tat FROM DUAL;
                END IF;   

                  dbms_output.put_line(V_Min_Tat_Product);
                  dbms_output.put_line(V_Min_Tat_Service);



END MinTat;

/
--------------------------------------------------------
--  DDL for Procedure NO_OF_LEADS_OF_PRODUCTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  NO_OF_LEADS_OF_PRODUCTS (P_CroId IN users.id%TYPE,
 P_7DAY_LEAD OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_7th number;
DAT TIMESTAMP;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                SELECT (TRUNC((
                SELECT CONTACTEDDATE
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid 
                WHERE USERS.ID=P_CroId AND PRODUCTID is not null 
                order by CONTACTEDDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT Count(leads.productid) as aggregate INTO V_7th
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid  
                WHERE USERS.ID=P_CroId AND PRODUCTID is not null 
                AND TRUNC(LEADS.CONTACTEDDATE)=TRUNC(DAT-7) ;


                SELECT Count(leads.productid) as aggregate INTO V_current
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid
                WHERE USERS.ID=P_CroId AND PRODUCTID is not null 
                AND TRUNC(LEADS.CONTACTEDDATE)=TRUNC(DAT);
                dbms_output.put_line(V_7th);
                dbms_output.put_line(V_current);

                SELECT V_7th-V_current  INTO P_7DAY_LEAD FROM DUAL;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END No_Of_leads_of_Products;

/
--------------------------------------------------------
--  DDL for Procedure NO_OF_LEADS_OF_PRODUCTS_CONVERTED_PERCENTAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  NO_OF_LEADS_OF_PRODUCTS_CONVERTED_PERCENTAGE (P_CroId IN users.id%TYPE,
P_7DAY_LEAD_CONVERTED OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_7th number;
DAT TIMESTAMP;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                SELECT (TO_TIMESTAMP((
                SELECT CONTACTEDDATE
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid 
                WHERE USERS.ID=P_CroId AND PRODUCTID is not null and leads.leadstage=4
                order by CONTACTEDDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT Count(leads.productid) as aggregate INTO V_7th
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid  
                WHERE USERS.ID=P_CroId AND PRODUCTID is not null and leads.leadstage=4
                AND TO_TIMESTAMP(LEADS.CONTACTEDDATE)=TO_TIMESTAMP(DAT-7) ;


                SELECT Count(leads.productid) as aggregate INTO V_current
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid
                WHERE USERS.ID=P_CroId AND PRODUCTID is not null and leads.leadstage=4
                AND TO_TIMESTAMP(LEADS.CONTACTEDDATE)=TO_TIMESTAMP(DAT);
                
                dbms_output.put_line(V_7th);
                dbms_output.put_line(V_current);
                dbms_output.put_line(DAT-7);
                dbms_output.put_line(DAT);
                
                if(V_7th=0) then
                   P_7DAY_LEAD_CONVERTED:=0;
                else
                   SELECT (V_7th-V_current)/V_7th*100*-1  INTO P_7DAY_LEAD_CONVERTED FROM DUAL;
                end if;


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END No_Of_leads_of_Products_Converted_Percentage;

/
--------------------------------------------------------
--  DDL for Procedure NO_OF_LEADS_OF_SERVICES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  NO_OF_LEADS_OF_SERVICES (P_CroId IN users.id%TYPE,
P_7DAY_LEAD OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_7th number;
DAT TIMESTAMP;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                SELECT (TRUNC((
                SELECT CONTACTEDDATE
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid 
                WHERE USERS.ID=P_CroId AND SERVICEID is not null 
                order by CONTACTEDDATE desc fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT Count(leads.SERVICEID) as aggregate INTO V_7th
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid  
                WHERE USERS.ID=P_CroId AND SERVICEID is not null 
                AND TRUNC(LEADS.CONTACTEDDATE)=TRUNC(DAT-7) ;

                SELECT Count(leads.SERVICEID) as aggregate INTO V_current
                FROM USERS 
                JOIN leads ON USERS.ID = leads.croid
                WHERE USERS.ID=P_CroId AND SERVICEID is not null 
                AND TRUNC(LEADS.CONTACTEDDATE)=TRUNC(DAT);
                dbms_output.put_line(V_7th);
                dbms_output.put_line(V_current);

                SELECT V_7th-V_current  INTO P_7DAY_LEAD FROM DUAL;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END No_Of_leads_of_Services;

/
--------------------------------------------------------
--  DDL for Procedure NODELAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  NODELAY (P_CroId IN Users.id%TYPE,
P_ACCOUNTID IN accounts.accountid%TYPE,P_No_Delay OUT number)IS
V_Total_Product_Leads_Under_TAT number;
V_Total_Service_Leads_Under_TAT number;
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

           --Status Under TAT

                SELECT COUNT(*)
                INTO V_Total_Product_Leads_Under_TAT
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                LEADS.productid IS NOT NULL AND LEADS.leadstage NOT IN(0,3) AND TRUNC(SYSDATE)<=TRUNC(leads.estimateddate);


                SELECT COUNT(*)
                INTO V_Total_Service_Leads_Under_TAT
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND ACCOUNTS.ACCOUNTID=P_ACCOUNTID AND 
                leads.serviceid IS NOT NULL AND LEADS.leadstage NOT IN(0,2) AND TRUNC(SYSDATE)<=TRUNC(leads.estimateddate);

                SELECT (V_Total_Product_Leads_Under_TAT+V_Total_Service_Leads_Under_TAT) INTO P_No_Delay FROM DUAL;

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END NoDelay ;

/
--------------------------------------------------------
--  DDL for Procedure P_PERCENTAGE_LAST_7DAYS_CONTACT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  P_PERCENTAGE_LAST_7DAYS_CONTACT (P_CroId IN users.id%TYPE,
 P_Percentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_DAT timestamp;
V_count NUMBER;
V_7th number;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
         
          IF(V_count>=1) THEN       

                SELECT (TRUNC((
                SELECT CONTACTEDDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CONTACTEDDATE desc fetch first 1 row only)))INTO V_DAT FROM DUAL;

                SELECT Count(CONTACTEDDATE) INTO V_7th
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
                WHERE USERS.ID=P_CroId AND  TRUNC(LEADS.CONTACTEDDATE)<TRUNC((V_DAT)-7);




                SELECT Count(CONTACTEDDATE) INTO V_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
                WHERE USERS.ID=P_CroId AND 
                 TRUNC(LEADS.CONTACTEDDATE)<TRUNC((V_DAT));

                dbms_output.put_line(V_7th);
                dbms_output.put_line(V_current);

                if(V_7th=0) then 
                    P_Percentage:=0;
                else
                    SELECT ((V_current-V_7th)/V_7th)*100  INTO P_Percentage FROM DUAL;
                end if;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);           

END P_Percentage_Last_7Days_Contact;

/
--------------------------------------------------------
--  DDL for Procedure P_PRODUCTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  P_PRODUCTS (p_ACCOUNTID number,op_product_dtls out SYS_REFCURSOR)
as
begin 
open op_product_dtls for
        SELECT DISTINCT leadid,servicename,
            (
                SELECT
                    LISTAGG(productname, ',') WITHIN GROUP( ORDER BY productname) AS productname
                FROM
                    (
                        SELECT DISTINCT l.leadid,servicename,productname productname
                        FROM
                            leads l
                            INNER JOIN leadproductdetails lp ON l.leadid = lp.leadid
                            INNER JOIN products p ON p.productid = lp.productid
                            LEFT OUTER JOIN services s ON l.serviceid = s.serviceid
                        WHERE
                            accountid =p_ACCOUNTID
                        GROUP BY
                            servicename,
                            productname,
                            l.leadid
                    )
            ) AS productname
        FROM
            (
                SELECT DISTINCT l.leadid,servicename,productname productname
                FROM
                         leads l
                    INNER JOIN leadproductdetails lp ON l.leadid = lp.leadid
                    INNER JOIN products p ON p.productid = lp.productid
                    LEFT OUTER JOIN services s ON l.serviceid = s.serviceid
                WHERE
                    accountid =p_ACCOUNTID
                GROUP BY servicename,productname,l.leadid
            );

end P_products;

/
--------------------------------------------------------
--  DDL for Procedure PER_ACCOUNT_INCREASE_BALANACE_TOTAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PER_ACCOUNT_INCREASE_BALANACE_TOTAL (P_CroId IN users.id%TYPE,
 P_Custdate IN timestamp,
 P_Percentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_25th number;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       


                SELECT SUM(CURRENTBALANCE) INTO V_25th
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId  AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(P_Custdate);



                SELECT SUM(CURRENTBALANCE) INTO V_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId AND accounts.accounttype='P_Account_Type' 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC((
                SELECT CURRENTDATE 
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only));
                dbms_output.put_line(V_25th);
                dbms_output.put_line(V_current);

                if (V_25th=0) then
                  P_Percentage:=0;
                else
                  SELECT ((V_25th-V_current)/V_25th)*100*-1  INTO P_Percentage FROM DUAL;
                end if;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Per_Account_Increase_Balanace_Total;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_COSTOMER_CONTACTED_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_COSTOMER_CONTACTED_7DAYS (P_CroId IN Accounts.AccountNumber%TYPE,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
v_7TH number;
v_Current number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by leads.contacteddate desc fetch first 1 row only)))INTO DAT FROM DUAL;
                DBMS_OUTPUT.PUT_LINE(TRUNC(DAT));
                DBMS_OUTPUT.PUT_LINE(TRUNC(DAT-7));




                SELECT COUNT(DISTINCT(leads.accountid)) INTO v_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<=TRUNC(DAT);

                SELECT COUNT(DISTINCT(leads.accountid)) INTO v_7TH
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<=TRUNC((DAT)-7);
               DBMS_OUTPUT.PUT_LINE(v_7TH || 'v_7TH');
                DBMS_OUTPUT.PUT_LINE(v_current  || 'v_current');
                IF v_7TH = 0 then
                    P_Costomer_Contacted:=0;
                ELSE
                    select ((v_current-v_7TH)/v_7TH) into P_Costomer_Contacted from dual;
                END IF;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Percentage_Costomer_Contacted_7days;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_INCREASE_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_INCREASE_BALANCE (P_CroId IN users.id%TYPE,
P_Percentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
v_balance_increased_account number;
v_total_account number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       



            SELECT count(DISTINCT (th.accountid)) INTO v_balance_increased_account
            FROM transactionhistory th
            JOIN (
                SELECT accountid, MIN(currentdate) AS min_date, MAX(currentdate) AS max_date
                FROM transactionhistory
                GROUP BY accountid
            ) t ON th.accountid = t.accountid
            JOIN accounts a ON th.accountid = a.accountid
            JOIN customers c ON a.customerid = c.customerid
            JOIN users u ON c.createdby = u.id
            WHERE u.id = P_CroId
            AND th.currentdate = t.min_date
            AND th.currentbalance < (
                SELECT currentbalance
                FROM transactionhistory
                WHERE accountid = t.accountid AND currentdate = t.max_date
            );


            SELECT COUNT(*)
            INTO v_total_account
            FROM USERS 
            JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
            JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
            WHERE USERS.ID=P_CroId;

            SELECT (v_balance_increased_account/v_total_account)*100 INTO P_Percentage FROM DUAL;
            DBMS_OUTPUT.PUT_LINE(v_balance_increased_account);
            DBMS_OUTPUT.PUT_LINE(v_total_account);


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END PERCENTAGE_INCREASE_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_INCREASE_BALANCE_LAST7_DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_INCREASE_BALANCE_LAST7_DAYS (P_CroId IN users.id%TYPE,
P_Percentageday OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
v_balance_increased_account number;
v_balance_increased_account_day7 number;
v_total_account number;
v_Percentagday7 number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN   

            PERCENTAGE_INCREASE_BALANCE(P_CroId,v_balance_increased_account);

            SELECT COUNT(DISTINCT th.accountid) INTO v_balance_increased_account_day7
            FROM transactionhistory th
            JOIN (
                SELECT accountid, TRUNC(MIN(currentdate)) AS min_date, TRUNC(MAX(currentdate)-7) AS max_date
                FROM transactionhistory
                GROUP BY accountid
            ) t ON th.accountid = t.accountid
            JOIN accounts a ON th.accountid = a.accountid
            JOIN customers c ON a.customerid = c.customerid
            JOIN users u ON c.createdby = u.id
            WHERE u.id = P_CroId
            AND TRUNC(th.currentdate) = TRUNC(t.max_date)
            AND th.currentbalance > (
                SELECT th2.currentbalance
                FROM transactionhistory th2
                WHERE th2.accountid = t.accountid AND TRUNC(th2.currentdate) = TRUNC(t.min_date)
                );


            SELECT COUNT(*)
            INTO v_total_account
            FROM USERS 
            JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
            JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
            WHERE USERS.ID=P_CroId;
   if v_total_account=0 then 
     P_Percentageday:=0;
     else
            SELECT (v_balance_increased_account_day7/v_total_account)*100 INTO v_Percentagday7 FROM DUAL;

            select (v_balance_increased_account-v_Percentagday7) into P_Percentageday from dual;
            dBMS_OUTPUT.PUT_LINE('=========================');
            DBMS_OUTPUT.PUT_LINE(v_balance_increased_account);
            DBMS_OUTPUT.PUT_LINE(v_balance_increased_account_day7);
            DBMS_OUTPUT.PUT_LINE(v_total_account);
             DBMS_OUTPUT.PUT_LINE(v_Percentagday7);
   end if;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END PERCENTAGE_INCREASE_BALANCE_LAST7_DAYS;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_COSTOMER_CONTACTED_7DAYS_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_COSTOMER_CONTACTED_7DAYS_SA_CA (P_CroId IN Accounts.AccountNumber%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
v_7TH number;
v_Current number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by leads.contacteddate desc fetch first 1 row only)))INTO DAT FROM DUAL;
                DBMS_OUTPUT.PUT_LINE(TRUNC(DAT));
                DBMS_OUTPUT.PUT_LINE(TRUNC(DAT-7));




                SELECT COUNT(DISTINCT(leads.accountid)) INTO v_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<=TRUNC(DAT)
                 AND accounts.accounttype in(P_Account_Type);

                SELECT COUNT(DISTINCT(leads.accountid)) INTO v_7TH
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(LEADS.CONTACTEDDATE)<=TRUNC((DAT)-7)
                 AND accounts.accounttype in(P_Account_Type);
               DBMS_OUTPUT.PUT_LINE(v_7TH || 'v_7TH');
                DBMS_OUTPUT.PUT_LINE(v_current  || 'v_current');
                IF v_7TH = 0 then
                    P_Costomer_Contacted:=0;
                ELSE
                    select ((v_current-v_7TH)/v_7TH) into P_Costomer_Contacted from dual;
                END IF;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Percentage_Costomer_Contacted_7days_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_INCREASE_BALANCE_ON_DATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_INCREASE_BALANCE_ON_DATE (P_CroId IN users.id%TYPE,
P_Custdate IN timestamp,
P_balance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_25th number;
DAT TIMESTAMP;
V_current number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       


                SELECT (TO_TIMESTAMP((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE DESC fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO V_25th
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID=P_CroId AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(P_Custdate);


                SELECT SUM(CURRENTBALANCE) INTO V_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE 
                USERS.ID=P_CroId AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(DAT);

                dbms_output.put_line(V_25th || 'last data inserted');
                dbms_output.put_line(V_current || 'first day data inserted');
                SELECT (V_current - V_25th)  INTO P_balance FROM DUAL;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Percentage_Increase_Balance_on_Date;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_INCREASE_BALANCE_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_INCREASE_BALANCE_SA_CA (P_CroId IN users.id%TYPE, 
P_Account_Type IN Accounts.accounttype%type,
P_Percentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_Firstth number;
V_Lastth number;
DAT_Last TIMESTAMP;
DAT_First TIMESTAMP;

Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE asc fetch first 1 row only)))INTO DAT_First FROM DUAL;

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT_Last FROM DUAL;



                SELECT SUM(CURRENTBALANCE) INTO V_Firstth
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
              AND accounts.accounttype in(P_Account_Type)
                AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(DAT_First) ;





                SELECT SUM(CURRENTBALANCE) INTO V_Lastth
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                AND accounts.accounttype in(P_Account_Type)
                AND TRUNC(TransactionHistory.CURRENTDATE)=
                TRUNC(DAT_Last);
                DBMS_OUTPUT.PUT_LINE(V_Firstth);
                DBMS_OUTPUT.PUT_LINE(V_Lastth);

                if V_Firstth=0 then 
                   P_Percentage :=0;
                else
                  SELECT ((V_Lastth-V_Firstth)/V_Firstth)*100  INTO P_Percentage FROM DUAL;
                end if ;
          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END PERCENTAGE_INCREASE_BALANCE_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure PERCENTAGE_INCREASE_BALANCE123
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PERCENTAGE_INCREASE_BALANCE123 (P_CroId IN users.id%TYPE,
 P_Percentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
v_balance_increased_account number;
v_total_account number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       



            SELECT count(DISTINCT (th.accountid)) INTO v_balance_increased_account
            FROM transactionhistory th
            JOIN (
                SELECT accountid, MIN(currentdate) AS min_date, MAX(currentdate) AS max_date
                FROM transactionhistory
                GROUP BY accountid
            ) t ON th.accountid = t.accountid
            JOIN accounts a ON th.accountid = a.accountid
            JOIN customers c ON a.customerid = c.customerid
            JOIN users u ON c.createdby = u.id
            WHERE u.id = P_CroId
            AND th.currentdate = t.min_date
            AND th.currentbalance < (
                SELECT currentbalance
                FROM transactionhistory
                WHERE accountid = t.accountid AND currentdate =trunc( t.max_date-7)
            );


            SELECT COUNT(*)
            INTO v_total_account
            FROM USERS 
            JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
            JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
            WHERE USERS.ID=P_CroId;

            SELECT (v_balance_increased_account/v_total_account)*100 INTO P_Percentage FROM DUAL;
            DBMS_OUTPUT.PUT_LINE(v_balance_increased_account);
            DBMS_OUTPUT.PUT_LINE(v_total_account);


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END PERCENTAGE_INCREASE_BALANCE123;

/
--------------------------------------------------------
--  DDL for Procedure PRDUCTS_TAT_ADHERANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PRDUCTS_TAT_ADHERANCE (P_CroId IN Users.id%TYPE,
Tat_Adherance OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder1 number;
ConvertedOver1 number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by leads.contacteddate desc fetch first 1 row only)))INTO V_DAT FROM DUAL;



                SELECT COUNT(*)
                INTO ConvertedUnder1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT) and leads.productid IS NOT NULL AND LEADS.leadstage=3 AND 
                TRUNC(LEADS.CONVERTEDDATE)<=TRUNC(LEADS.estimateddate);

 SELECT COUNT(*)
                INTO ConvertedOver1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND TRUNC(LEADS.contacteddate)<=TRUNC((V_DAT)) 
                and LEADS.productid IS NOT NULL AND (LEADS.leadstage <> 0) AND 
                (TRUNC(LEADS.CONVERTEDDATE)>TRUNC(LEADS.estimateddate) OR (LEADS.CONVERTEDDATE IS NULL 
                AND TRUNC(SYSDATE)>TRUNC(LEADS.estimateddate)));

            dbms_output.put_line(ConvertedOver1);
            dbms_output.put_line(ConvertedUnder1);

          if (ConvertedOver1+ConvertedUnder1)=0 then
               Tat_Adherance:=0;
          else
                    select (ConvertedUnder1/(ConvertedOver1+ConvertedUnder1))*100  into Tat_Adherance from dual;
                    dbms_output.put_line(Tat_Adherance || 'Tat_Adherance');            
          end if;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Prducts_Tat_Adherance;

/
--------------------------------------------------------
--  DDL for Procedure PRODUCT_TAT_ADHERANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PRODUCT_TAT_ADHERANCE (P_CroId IN Accounts.AccountNumber%TYPE,Tat_Adherance OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder number;
ConvertedOver number;
V_count NUMBER;
DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT COUNT(*) INTO ConvertedUnder
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND LEADS.productid IS NOT NULL AND LEADS.leadstage=3
                AND ((TO_DATE(TO_CHAR(LEADS.CONVERTEDDATE,'DD,MON.YYYY'),'DD,MON.YY'))<=
                (TO_DATE(TO_CHAR(LEADS.estimateddate,'DD,MON.YYYY'),'DD,MON.YY')));

                SELECT COUNT(*) INTO ConvertedOver
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND LEADS.productid IS NOT NULL AND LEADS.leadstage=3 
                AND ((TO_DATE(TO_CHAR(LEADS.CONVERTEDDATE,'DD,MON.YYYY'),'DD,MON.YY'))>
                (TO_DATE(TO_CHAR(LEADS.estimateddate,'DD,MON.YYYY'),'DD,MON.YY')));

                IF ConvertedOver =0 THEN 
                  Tat_Adherance:=0;
                ELSE
                  select (ConvertedOver/ConvertedOver)*100 into Tat_Adherance from dual;
                END IF;



      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Product_Tat_Adherance;

/
--------------------------------------------------------
--  DDL for Procedure PRODUCT_TAT_ADHERANCE_OF_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  PRODUCT_TAT_ADHERANCE_OF_7DAYS (P_CroId IN Users.id%TYPE,
 Tat_Adherance_OF_7DAYS OUT transactionhistory.currentbalance%TYPE )IS
ConvertedUnder1 number;
ConvertedOver1 number;
V2_PERCENTAGE number;
V_count NUMBER;
V_DAT TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
V1_Percentage number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                Prducts_Tat_Adherance(P_CroId,V1_Percentage);

                SELECT (TRUNC((
                SELECT leads.contacteddate
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE USERS.ID=P_CroId
                order by leads.contacteddate desc fetch first 1 row only)))INTO V_DAT FROM DUAL;
--=========================================================

                SELECT COUNT(*)
                INTO ConvertedUnder1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT-7) 
                and leads.productid IS NOT NULL AND LEADS.leadstage=3 AND 
                TRUNC(LEADS.CONVERTEDDATE)<=TRUNC(LEADS.estimateddate);


 DBMS_OUTPUT.PUT_LINE(V_DAT-7);

                SELECT COUNT(*)
                INTO ConvertedOver1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID           
                WHERE USERS.ID=P_CroId AND TRUNC(LEADS.contacteddate)<=TRUNC(V_DAT-7)
                and LEADS.productid IS NOT NULL AND (LEADS.leadstage <> 0) AND 
                TRUNC(LEADS.CONVERTEDDATE)>TRUNC(LEADS.estimateddate) OR (LEADS.CONVERTEDDATE IS NULL 
                AND TRUNC(SYSDATE)>TRUNC(LEADS.estimateddate));
                DBMS_OUTPUT.PUT_LINE(ConvertedUnder1);
                DBMS_OUTPUT.PUT_LINE(ConvertedOver1);

               IF  (ConvertedUnder1+ConvertedOver1)=0 THEN
               Tat_Adherance_OF_7DAYS:=0;

               ELSE

                SELECT (ConvertedUnder1/(ConvertedUnder1+ConvertedOver1))*100 INTO V2_PERCENTAGE FROM DUAL;

                SELECT (V1_PERCENTAGE-V2_PERCENTAGE)INTO Tat_Adherance_OF_7DAYS FROM DUAL;
                DBMS_OUTPUT.PUT_LINE(V1_PERCENTAGE);
                DBMS_OUTPUT.PUT_LINE(V2_PERCENTAGE);
--===========================================================
     END IF;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Product_Tat_Adherance_OF_7DAYS;

/
--------------------------------------------------------
--  DDL for Procedure ROLL_UP_GROWTH_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLL_UP_GROWTH_BALANCE (P_CroId IN Users.Id%TYPE,
 P_Balance_Growth OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
V_bal1 NUMBER;
DATFirst TIMESTAMP;
DATCurrent TIMESTAMP;
V_bal2 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
      Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE asc fetch first 1 row only)))INTO DATFirst FROM DUAL;



                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DATCurrent FROM DUAL ;




                SELECT SUM(CURRENTBALANCE) INTO V_bal2
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)= TRUNC(DATCurrent);




                SELECT SUM(CURRENTBALANCE) INTO V_bal1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DATFirst);





   IF V_bal1=0 THEN
         P_Balance_Growth:=0;

         ELSE

               select ((V_bal2-V_bal1)/V_bal1)*100 into P_Balance_Growth from dual;



   END IF;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END ROLL_UP_GROWTH_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure ROLL_UP_CRO_TARGET_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLL_UP_CRO_TARGET_BALANCE (
P_CroId IN users.id%TYPE,
P_TYPE IN VARCHAR2,
P_Target_Balance OUT CRO_DTLS.TARGET_BALANCE%TYPE)IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN       

            delete_all_records_from_temp_table;
            RollUp_All_Data(P_CroId);

            IF P_TYPE='CA' THEN 
    
                SELECT SUM(CRO_DTLS.CA_TARGET_BALANCE) into P_Target_Balance
                FROM USERS
                JOIN CRO_DTLS ON USERS.ID=CRO_DTLS.CRO_ID
                where USERS.ID in (select * from temp_table);
    
            ELSIF  P_TYPE ='SA' THEN 
    
                 SELECT SUM(CRO_DTLS.SA_TARGET_BALANCE) into P_Target_Balance
                FROM USERS
                JOIN CRO_DTLS ON USERS.ID=CRO_DTLS.CRO_ID
                where USERS.ID in (select * from temp_table);
    
            ELSE 
    
                SELECT SUM(CRO_DTLS.TARGET_BALANCE) into P_Target_Balance
                FROM USERS
                JOIN CRO_DTLS ON USERS.ID=CRO_DTLS.CRO_ID
                where USERS.ID in (select * from temp_table);
    
            END IF ;
      ELSE
        RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END Roll_Up_Cro_Target_Balance;

/
--------------------------------------------------------
--  DDL for Procedure ROLL_UP_GROWTH_BALANCE_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLL_UP_GROWTH_BALANCE_SA_CA (P_CroId IN Users.Id%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_Balance_Growth OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
V_bal1 NUMBER;
DATFirst TIMESTAMP;
DATCurrent TIMESTAMP;
V_bal2 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
      Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE asc fetch first 1 row only)))INTO DATFirst FROM DUAL;



                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId
                order by CURRENTDATE desc fetch first 1 row only)))INTO DATCurrent FROM DUAL ;


                SELECT SUM(CURRENTBALANCE) INTO V_bal2
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)= TRUNC(DATCurrent)
                AND accounts.accounttype in(P_Account_Type);


                SELECT SUM(CURRENTBALANCE) INTO V_bal1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID=P_CroId 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DATFirst)
                AND accounts.accounttype in(P_Account_Type);


                IF V_bal1=0 THEN
                    P_Balance_Growth:=0;
                ELSE 
                    select ((V_bal2-V_bal1)/V_bal1)*100 into P_Balance_Growth from dual;
                END IF;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END ROLL_UP_GROWTH_BALANCE_SA_CA ;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP (
P_CroId IN users.id%TYPE,P_Percentage OUT NUMBER)IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

            delete_all_records_from_temp_table;
            RollUp_All_Data(P_CroId);

            SELECT COUNT(*) into P_Percentage
            FROM USERS
            JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
            JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
            where USERS.ID IN (select * from temp_table);


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CALLER_VIEW_CUURENT_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CALLER_VIEW_CUURENT_BALANCE (P_CroId IN users.id%TYPE,
P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
V_DAT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE desc fetch first 1 row only)))INTO V_DAT FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE) 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);



          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_CALLER_VIEW_CUURENT_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CALLER_VIEW_GAP_PERCENTAGE_TARGET
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CALLER_VIEW_GAP_PERCENTAGE_TARGET (
P_CroId IN users.id%TYPE,P_GapToTargetPercentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
DAT2 TIMESTAMP;
V_Target NUMBER;
DAT1 TIMESTAMP;
V_current number;
v_first_day_balance number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT SUM(TARGET_BALANCE) INTO  V_Target FROM USERS
                JOIN CRO_DTLS ON USERS.ID=CRO_DTLS.CRO_ID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE);

                SELECT (TRUNC((
                SELECT CURRENTDATE 
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE asc fetch first 1 row only)))INTO DAT1 FROM DUAL;

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE desc fetch first 1 row only)))INTO DAT2 FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO V_current
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DAT2);

                SELECT SUM(CURRENTBALANCE) INTO v_first_day_balance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DAT1);


        IF ((V_Target-v_first_day_balance)=0) THEN 
            P_GapToTargetPercentage :=0;
        ELSE
            Select ((V_current-v_first_day_balance)/(V_Target-v_first_day_balance))*100 into P_GapToTargetPercentage from dual;
        END IF;



          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_Caller_View_Gap_Percentage_Target;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_ALL_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_ALL_DATA (P_CroId IN users.id%TYPE)IS
V_Count number;
V_FETCHER SYS_REFCURSOR;
V_date date;
TYPE ARRAY IS TABLE OF NUMBER;
my_array ARRAY;
V_ROLE_TYPE VARCHAR2(256);
Null_Data Exception;
Data_Not_Found Exception;
BEGIN


     IF P_CroId IS NULL THEN
        RAISE Null_Data;
     ELSE

         select count(*)into V_Count from users where users.id=P_CroId;
            IF(V_COUNT=1) THEN
                    SELECT ROLES.NAME INTO V_ROLE_TYPE FROM USERS
                    JOIN ROLES ON USERS.ROLE_ID=ROLES.ID WHERE USERS.ID=P_CroId;
                IF V_ROLE_TYPE = 'Super Admin' THEN 
                
                    delete_all_records_from_temp_table;
                    
                    SELECT ID BULK COLLECT INTO my_array 
                    FROM USERS WHERE PARENTID IN
                    (SELECT ID FROM USERS WHERE PARENTID IN 
                    (SELECT ID FROM USERS WHERE PARENTID IN                    
                    (SELECT ID FROM USERS WHERE PARENTID IN 
                    (SELECT ID FROM USERS WHERE PARENTID=P_CroId))));                        
                ELSIF V_ROLE_TYPE = 'Central' THEN 
                
                    delete_all_records_from_temp_table;
                    
                    SELECT ID BULK COLLECT INTO my_array
                    FROM USERS WHERE PARENTID IN
                    (SELECT ID FROM USERS WHERE PARENTID IN
                    (SELECT ID FROM USERS WHERE PARENTID IN 
                    (SELECT ID FROM USERS WHERE PARENTID=P_CroId)));
                ELSIF V_ROLE_TYPE = 'Regional' THEN 
                
                    delete_all_records_from_temp_table;
                    
                    SELECT ID BULK COLLECT INTO my_array
                    FROM USERS WHERE PARENTID IN
                    (SELECT ID FROM USERS WHERE PARENTID IN 
                    (SELECT ID FROM USERS WHERE PARENTID=P_CroId));
                ELSIF V_ROLE_TYPE = 'Zonal' THEN 
                
                    delete_all_records_from_temp_table;
                    
                    SELECT ID BULK COLLECT INTO my_array
                    FROM USERS WHERE PARENTID IN 
                    (SELECT ID FROM USERS WHERE PARENTID=P_CroId);
                ELSIF V_ROLE_TYPE = 'Cluster' THEN 
                
                    delete_all_records_from_temp_table;
                    
                    SELECT ID BULK COLLECT INTO my_array
                    FROM USERS WHERE PARENTID=P_CroId;
                ELSIF V_ROLE_TYPE = 'CRO' THEN
                
                    delete_all_records_from_temp_table;
                    
                    SELECT ID BULK COLLECT INTO my_array
                    FROM USERS WHERE users.id=P_CroId;
                END IF;

                 FOR i IN 1..my_array.COUNT LOOP
                    DBMS_OUTPUT.PUT_LINE('Element ' || i || ': ' || my_array(i));
                 END LOOP;

                 FORALL i IN 1..my_array.COUNT
                    INSERT INTO temp_table (ID) VALUES (my_array(i));



        ELSE
            RAISE DATA_NOT_FOUND;
        END IF;
     END IF;
            EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);   

END RollUp_All_Data;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CALLER_VIEW_GAP_PERCENTAGE_TARGET_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CALLER_VIEW_GAP_PERCENTAGE_TARGET_SA_CA (
P_CroId IN users.id%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_GapToTargetPercentage OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_First_Achieve number;
V_Current_Achieve number;
V_CA_TARGET_BALANCE NUMBER;
V_SA_TARGET_BALANCE NUMBER;
V_DAT1 TIMESTAMP;
V_DAT2 TIMESTAMP;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN    

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);



                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE 
                accounts.accounttype =P_Account_Type AND USERS.ID IN (select * from temp_table)
                order by CURRENTDATE asc fetch first 1 row only)))INTO V_DAT1 FROM DUAL;



                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE 
                accounts.accounttype =P_Account_Type AND USERS.ID IN (select * from temp_table)
                order by CURRENTDATE desc fetch first 1 row only)))INTO V_DAT2 FROM DUAL;


            IF(P_Account_Type='CA') THEN

                    SELECT SUM(CA_TARGET_BALANCE) INTO V_CA_TARGET_BALANCE
                    FROM USERS
                    JOIN CRO_DTLS ON users.id=CRO_DTLS.CRO_ID WHERE USERS.ID IN (select * from temp_table);

                    SELECT SUM(CURRENTBALANCE) INTO V_First_Achieve
                    FROM USERS 
                    JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                    JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                    JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                    IN(select * from temp_table)
                    AND accounts.accounttype =P_Account_Type
                    AND TRUNC(TransactionHistory.CURRENTDATE)=
                    TRUNC(V_DAT1);

                    SELECT SUM(CURRENTBALANCE) INTO V_Current_Achieve
                    FROM USERS 
                    JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                    JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                    JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                    IN(select * from temp_table)
                    AND accounts.accounttype =P_Account_Type
                    AND TRUNC(TransactionHistory.CURRENTDATE)=
                    TRUNC(V_DAT2);

                         IF (V_CA_TARGET_BALANCE-V_First_Achieve)=0 THEN 
                             P_GapToTargetPercentage:=0;
                         ELSE
                             Select ((V_Current_Achieve-V_First_Achieve)/(V_CA_TARGET_BALANCE-V_First_Achieve))*100 into P_GapToTargetPercentage from dual;
                         END IF ;

            ELSIF(P_Account_Type='SA') THEN

                    SELECT SUM(SA_TARGET_BALANCE) INTO V_SA_TARGET_BALANCE
                    FROM USERS
                    JOIN CRO_DTLS ON users.id=CRO_DTLS.CRO_ID WHERE USERS.ID IN(select * from temp_table);

                    SELECT SUM(CURRENTBALANCE) INTO V_First_Achieve
                    FROM USERS 
                    JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                    JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                    JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                    IN(select * from temp_table)
                    AND accounts.accounttype = P_Account_Type
                    AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT1);

                    SELECT SUM(CURRENTBALANCE) INTO V_Current_Achieve
                    FROM USERS 
                    JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                    JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                    JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                    IN(select * from temp_table)
                    AND accounts.accounttype = P_Account_Type
                    AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT2);

                    IF (V_SA_TARGET_BALANCE-V_First_Achieve)=0 THEN
                        P_GapToTargetPercentage:=0 ;
                    ELSE
                        Select ((V_Current_Achieve-V_First_Achieve)/(V_SA_TARGET_BALANCE-V_First_Achieve))*100 into P_GapToTargetPercentage from dual;
                    END IF;
            END IF;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END ROLLUP_CALLER_VIEW_GAP_PERCENTAGE_TARGET_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CALLER_VIEW_GAP_TARGET
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CALLER_VIEW_GAP_TARGET (
P_CroId IN users.id%TYPE,
P_GapToTargetAchieve OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
V_DAT TIMESTAMP;
V_Target NUMBER;
V_CurrentAchieve number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT SUM(TARGET_BALANCE) INTO V_Target FROM USERS
                JOIN CRO_DTLS ON USERS.ID=CRO_DTLS.CRO_ID WHERE users.id IN(SELECT * FROM TEMP_TABLE);


                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE desc fetch first 1 row only)))INTO V_DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO V_CurrentAchieve
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);

                select (V_Target-V_CurrentAchieve) INTO P_GapToTargetAchieve from dual;

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_Caller_View_Gap_Target;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CALLER_VIEW_GAP_TARGET_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CALLER_VIEW_GAP_TARGET_SA_CA (
P_CroId IN users.id%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_GapToTargetAchieve OUT TransactionHistory.CurrentBalance%TYPE )IS
V_CA_TARGET_BALANCE NUMBER;
V_SA_TARGET_BALANCE NUMBER;
V_count NUMBER;
V_DAT TIMESTAMP;
V_CurrentAchieve number;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN

               delete_all_records_from_temp_table;
               RollUp_All_Data(P_CroId);

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE 
                accounts.accounttype =P_Account_Type AND USERS.ID IN(select * from temp_table)
                order by CURRENTDATE desc fetch first 1 row only)))INTO V_DAT FROM DUAL;


               IF(P_Account_Type='CA') THEN

                        SELECT SUM(CA_TARGET_BALANCE) INTO V_CA_TARGET_BALANCE
                        FROM USERS
                        JOIN CRO_DTLS ON users.id=CRO_DTLS.CRO_ID WHERE USERS.ID IN(select * from temp_table);
        
                        SELECT SUM(CURRENTBALANCE) INTO V_CurrentAchieve
                        FROM USERS 
                        JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                        JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                        JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                        IN (select * from temp_table)
                        AND accounts.accounttype =P_Account_Type
                        AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);
        
                        select (V_CA_TARGET_BALANCE-V_CurrentAchieve) INTO P_GapToTargetAchieve from dual;


--=====
                ELSIF(P_Account_Type='SA') THEN

                        SELECT SUM(SA_TARGET_BALANCE) INTO V_SA_TARGET_BALANCE
                        FROM USERS
                        JOIN CRO_DTLS ON users.id=CRO_DTLS.CRO_ID WHERE USERS.ID IN(select * from temp_table);
        
                        SELECT SUM(CURRENTBALANCE) INTO V_CurrentAchieve
                        FROM USERS 
                        JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                        JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                        JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                        IN (select * from temp_table)
                        AND accounts.accounttype =P_Account_Type
                        AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);
        
                        select (V_SA_TARGET_BALANCE-V_CurrentAchieve) INTO P_GapToTargetAchieve from dual;
                END IF;


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END ROLLUP_Caller_View_Gap_Target_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_COSTOMER_CONTACTED
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_COSTOMER_CONTACTED (P_CroId IN Accounts.AccountNumber%TYPE,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count1 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;

BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count1 FROM users where id=P_CroId;
      IF(V_count1>=1) THEN 

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT count(DISTINCT ACCOUNTS.CUSTOMERID)
                INTO P_Costomer_Contacted
                FROM LEADS
                JOIN ACCOUNTS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID
                WHERE CROID IN (SELECT * FROM TEMP_TABLE) AND LEADS.islead = 1;


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_COSTOMER_CONTACTED;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_COSTOMER_CONTACTED_7DAYS_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_COSTOMER_CONTACTED_7DAYS_SA_CA (P_CroId IN Accounts.AccountNumber%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS

V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

           delete_all_records_from_temp_table;
           RollUp_All_Data(P_CroId);

                SELECT COUNT(DISTINCT(leads.accountid)) INTO  P_Costomer_Contacted
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE leads.islead=1 and
                USERS.ID  IN (SELECT * FROM TEMP_TABLE) AND TRUNC(LEADS.CONTACTEDDATE)>=TRUNC((SYSDATE)-7) 
                AND accounts.accounttype in(P_Account_Type)
                AND TRUNC(LEADS.CONTACTEDDATE)<TRUNC(SYSDATE);

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END ROLLUP_COSTOMER_CONTACTED_7DAYS_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CRO_STARTING_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CRO_STARTING_BALANCE (P_CroId IN users.id%TYPE,
P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
V_DAT TIMESTAMP;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE asc fetch first 1 row only)))INTO V_DAT FROM DUAL;

                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE) 
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(V_DAT);



          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_CRO_STARTING_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_COSTOMER_CONTACTED_7DAYS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_COSTOMER_CONTACTED_7DAYS (P_CroId IN Accounts.AccountNumber%TYPE,
P_Costomer_Contacted OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;

BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*) INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT COUNT(DISTINCT(leads.accountid)) INTO  P_Costomer_Contacted
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN LEADS ON ACCOUNTS.ACCOUNTID = LEADS.ACCOUNTID WHERE leads.islead=1 and
                USERS.ID  IN (SELECT * FROM TEMP_TABLE) AND TRUNC(LEADS.CONTACTEDDATE)>=TRUNC((SYSDATE)-7) 
                AND TRUNC(LEADS.CONTACTEDDATE)<TRUNC(SYSDATE);


      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_Costomer_Contacted_7days;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CUSTOMER_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CUSTOMER_BALANCE (P_CroId IN Users.id%TYPE,
 P_Status IN leads.status%TYPE ,P_Percentage OUT number)IS
StatusCount number;
AllCount number;
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
     Select count(*)INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO StatusCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE) 
                AND CUSTOMERS.CUST_STATUS=P_Status;


                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO AllCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                AND USERS.ID IN (SELECT * FROM TEMP_TABLE);


     IF AllCount= 0 THEN 
     P_Percentage:= 0 ;
     ELSE

                select (StatusCount/AllCount)*100  into P_Percentage from dual;

    END IF ;

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_CUSTOMER_BALANCE;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CUSTOMER_BALANCE_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CUSTOMER_BALANCE_SA_CA (P_CROID IN NUMBER, P_Status IN varchar2, 
P_Account_Type IN Accounts.accounttype%type,
OP_BALANCE_OUT OUT NUMBER)
AS
StatusCount number;
AllCount number;
begin

         delete_all_records_from_temp_table;
         RollUp_All_Data(P_CroId);
         
                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO StatusCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON ACCOUNTS.CUSTOMERID = CUSTOMERS.CUSTOMERID
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE) AND accounts.accounttype = P_Account_Type
                AND CUSTOMERS.CUST_STATUS=P_Status;

                DBMS_OUTPUT.PUT_LINE(StatusCount);
                SELECT COUNT(distinct(CUSTOMERS.CUSTOMERID))
                INTO AllCount
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON ACCOUNTS.CUSTOMERID = CUSTOMERS.CUSTOMERID
                AND USERS.ID IN (SELECT * FROM TEMP_TABLE) AND accounts.accounttype = P_Account_Type;
                DBMS_OUTPUT.PUT_LINE(AllCount);

            IF AllCount= 0 THEN 
                OP_BALANCE_OUT:= 0 ;
            ELSE 
                select (StatusCount/AllCount)*100  into OP_BALANCE_OUT from dual;
                dbms_output.put_line(OP_BALANCE_OUT || 'OP_BALANCE_OUT');  
            END IF;

exception
when others then 
StatusCount:=null;
AllCount:=null;

end ROLLUP_CUSTOMER_BALANCE_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_CUURENT_BALANCE_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_CUURENT_BALANCE_SA_CA (P_CroId IN users.id%TYPE,
P_Account_Type IN Accounts.accounttype%type,
P_TotalBalance OUT TransactionHistory.CurrentBalance%TYPE )IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
DAT TIMESTAMP;

BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
          Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN 

              delete_all_records_from_temp_table;
              RollUp_All_Data(P_CroId);
                
                SELECT (TRUNC((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                IN(select * from temp_table)
                order by CURRENTDATE DESC fetch first 1 row only)))INTO DAT FROM DUAL;


                SELECT SUM(CURRENTBALANCE) INTO P_TotalBalance
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID
                IN(select * from temp_table)
                AND accounts.accounttype=P_Account_Type
                AND TRUNC(TransactionHistory.CURRENTDATE) =TRUNC(DAT);


          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END ROLLUP_CUURENT_BALANCE_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_GET_ALL_CUSTOMER_ACCOUNT_SA_CA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_GET_ALL_CUSTOMER_ACCOUNT_SA_CA (
P_CroId IN users.id%TYPE,
p_accounttype IN varchar2,
P_Percentage OUT TransactionHistory.CurrentBalance%TYPE)IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
 v_Total_CA_Account_Assign number;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
            Select count(*) INTO V_count FROM users where id=P_CroId;
         IF(V_count>=1) THEN       

            delete_all_records_from_temp_table;
            RollUp_All_Data(P_CroId);

            SELECT COUNT(*) into P_Percentage
            FROM USERS
            JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
            JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
            where USERS.ID in (select * from temp_table) AND accounts.accounttype in(p_accounttype);

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_GET_ALL_CUSTOMER_ACCOUNT_SA_CA;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_GET_TOTAL_CUSTOMER_ACCOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_GET_TOTAL_CUSTOMER_ACCOUNT (
P_CroId IN users.id%TYPE,P_Percentage OUT TransactionHistory.CurrentBalance%TYPE)IS
V_count NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
                Select count(*) INTO V_count FROM users where id=P_CroId;
          IF(V_count>=1) THEN       

                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);
    
                SELECT COUNT(accounts.accountid) into P_Percentage
                FROM USERS
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                where USERS.ID in (select * from temp_table);

          ELSE
            RAISE Data_Not_Found;
          END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_GET_Total_Customer_Account;

/
--------------------------------------------------------
--  DDL for Procedure ROLLUP_GROWTH_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE   PROCEDURE  ROLLUP_GROWTH_BALANCE (P_CroId IN Users.Id%TYPE,
P_Balance_Growth OUT transactionhistory.currentbalance%TYPE )IS
V_count NUMBER;
V_bal1 NUMBER;
DATFirst TIMESTAMP;
DATCurrent TIMESTAMP;
V_bal2 NUMBER;
Null_Data Exception;
Data_Not_Found Exception;
BEGIN
   IF P_CroId IS NULL THEN
      RAISE Null_Data;
   ELSE
      Select count(*)
 INTO V_count FROM users where id=P_CroId;
      IF(V_count>=1) THEN 


                delete_all_records_from_temp_table;
                RollUp_All_Data(P_CroId);

                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID 
                WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE asc fetch first 1 row only)))INTO DATFirst FROM DUAL;



                SELECT (trunc((
                SELECT CURRENTDATE
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                order by CURRENTDATE desc fetch first 1 row only)))INTO DATCurrent FROM DUAL ;



                SELECT SUM(CURRENTBALANCE) INTO V_bal2
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE) 
                AND TRUNC(TransactionHistory.CURRENTDATE)= TRUNC(DATCurrent);


                SELECT SUM(CURRENTBALANCE) INTO V_bal1
                FROM USERS 
                JOIN CUSTOMERS ON USERS.ID = CUSTOMERS.CREATEDBY
                JOIN ACCOUNTS ON CUSTOMERS.CUSTOMERID = ACCOUNTS.CUSTOMERID
                JOIN TRANSACTIONHISTORY ON ACCOUNTS.ACCOUNTID = TRANSACTIONHISTORY.ACCOUNTID WHERE USERS.ID IN (SELECT * FROM TEMP_TABLE)
                AND TRUNC(TransactionHistory.CURRENTDATE)=TRUNC(DATFirst);

        IF V_bal1=0 THEN
        P_Balance_Growth:=0 ;

        ELSE

               select ((V_bal2-V_bal1)/V_bal1)*100 into P_Balance_Growth from dual;

              dbms_output.put_line( 'DECREASES BY ' || P_Balance_Growth || 'PERCENT');

              END IF ;

      ELSE
       RAISE Data_Not_Found;
      END IF;
   END IF; 
        EXCEPTION
        WHEN Null_Data THEN
            DBMS_OUTPUT.PUT_LINE('DATA CANNOT BE NULL');
        WHEN Data_Not_Found THEN
            DBMS_OUTPUT.PUT_LINE('NO DATA FOUND WITH GIVEN ACCOUNT NUMBER');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' INVALID ACCOUNT NO ' || SQLERRM);      

END RollUp_GROWTH_BALANCE;

/
