--=================================================================================================================================================
--=================================================================================================================================================

--DATA INSETION QUERIES

--=================================================================================================================================================
--=================================================================================================================================================

 
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('Super Admin','web',to_timestamp('29-MAY-23 09.55.51.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.51.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('Central','web',to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('Zonal','web',to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('Cluster','web',to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('Region','web',to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('CRO','web',to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into  ROLES (NAME,GUARD_NAME,CREATED_AT,UPDATED_AT) values ('Life Cycle','web',to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.55.52.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'));

Insert into  SERVICES (SERVICENAME,USUALTATDAYS) values ('Mobile Banking',1);
Insert into  SERVICES (SERVICENAME,USUALTATDAYS) values ('Internet Banking',1);
Insert into  SERVICES (SERVICENAME,USUALTATDAYS) values ('NEFT or RTGS',1);
Insert into  SERVICES (SERVICENAME,USUALTATDAYS) values ('Email',1);
Insert into  SERVICES (SERVICENAME,USUALTATDAYS) values ('Debit Card',1);
Insert into  SERVICES (SERVICENAME,USUALTATDAYS) values ('NEFT or RTGS',1);

Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Personal Loan',2,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Home Loan',2,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Credit Card Loan',4,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Insurance',3,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Mutual Funds',1,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Account Upgrade',2,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Savings Account',2,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Current Account',3,null);
Insert into  PRODUCTS (PRODUCTNAME,USUALTATDAYS,PRODUCT_ORDER) values ('Gold Loan',4,null);
 
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Center','center@example.com',2,null,'$2y$10$iZH4T.Q5x5dHiGpQihhfxOB..Es/Abl6TOivv02AU39TFJgfHE7Du',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),null);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Zonal 1','zonal.1@example.com',3,null,'$2y$10$yrtFy5qmhPk3R5vD8Etmxe6SeR8vGG2rUsQRTLvsykd/v/oaef3YG',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),1);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Zonal 2','zonal.2@example.com',3,null,'$2y$10$ddmGira1YLLjdyZ5BIxwZeEw5djdtOol2NtZCnbeGs7.J.JW1wlk2',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),1);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Region 1','region.1@example.com',5,null,'$2y$10$uE3F3kLMgZ0SzJNQi6.nwOmfB9AjrjG2fsHryR32kRFeJXnZHOSG2',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),2);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Region 2','region.2@example.com',5,null,'$2y$10$0/4/cGjdnG4k6pLdgvYbk.Iz7BoVQk1NtAWMX1E6TG.9MNac18DPK',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),3);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Cluster 1','cluster.1@example.com',4,null,'$2y$10$RoTFx1xQQESR.YRcG2UKI.eB.byjUoiQWzpdDcctzgziISQoSwmfi',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),4);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Cluster 2','cluster.2@example.com',4,null,'$2y$10$JHdHa7efwqkWbHBYJeJsOuKXJ1xhLA8W1pneK50uum9rDOu.VJsHi',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),5);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Cro 1','cro.1@example.com',6,null,'$2y$10$JHdHa7efwqkWbHBYJeJsOuKXJ1xhLA8W1pneK50uum9rDOu.VJsHi',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),6);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Cro 2','cro.2@example.com',6,null,'$2y$10$JHdHa7efwqkWbHBYJeJsOuKXJ1xhLA8W1pneK50uum9rDOu.VJsHi',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),6);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Cro 3','cro.3@example.com',6,null,'$2y$10$JHdHa7efwqkWbHBYJeJsOuKXJ1xhLA8W1pneK50uum9rDOu.VJsHi',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),7);
Insert into  USERS (NAME,EMAIL,ROLE_ID,EMAIL_VERIFIED_AT,PASSWORD,REMEMBER_TOKEN,CREATED_AT,UPDATED_AT,PARENTID) values ('Cro 4','cro.4@example.com',6,null,'$2y$10$JHdHa7efwqkWbHBYJeJsOuKXJ1xhLA8W1pneK50uum9rDOu.VJsHi',null,to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('29-MAY-23 09.57.20.000000000 PM','DD-MON-RR HH.MI.SSXFF AM'),7);


Insert into  CENTRALS (CENTRALNAME) values ('Indian');

Insert into  ZONALS (CENTRALID,ZONENAME) values (1,'Zone2');

Insert into  REGIONALS (ZONALID,REGIONALNAME) values (1,'Reg1');
Insert into  REGIONALS (ZONALID,REGIONALNAME) values (1,'Reg2');

Insert into  CLUSTERES (REGIONALID,CLUSTERNAME) values (1,'Clust1');
Insert into  CLUSTERES (REGIONALID,CLUSTERNAME) values (1,'Clust2');
Insert into  CLUSTERES (REGIONALID,CLUSTERNAME) values (2,'Clust3');
Insert into  CLUSTERES (REGIONALID,CLUSTERNAME) values (2,'Clust4');


Insert into  BRANCHES (CLUSTERID,BRANCHNAME) values (1,'BRANCH 1');
Insert into  BRANCHES (CLUSTERID,BRANCHNAME) values (2,'BRANCH 2');
Insert into  BRANCHES (CLUSTERID,BRANCHNAME) values (3,'BRANCH 1');
Insert into  BRANCHES (CLUSTERID,BRANCHNAME) values (4,'BRANCH 2');

 

 
Insert into  CRO_DTLS (CRO_ID,TARGET_BALANCE,SA_TARGET_BALANCE,CA_TARGET_BALANCE,MIN_DATE) values (8,10000000,500000,500000,to_date('01-JUN-23','DD-MON-RR'));
Insert into  CRO_DTLS (CRO_ID,TARGET_BALANCE,SA_TARGET_BALANCE,CA_TARGET_BALANCE,MIN_DATE) values (9,10000000,500000,500000,to_date('01-JUN-23','DD-MON-RR'));
Insert into  CRO_DTLS (CRO_ID,TARGET_BALANCE,SA_TARGET_BALANCE,CA_TARGET_BALANCE,MIN_DATE) values (10,10000000,500000,500000,to_date('01-JUN-23','DD-MON-RR'));
Insert into  CRO_DTLS (CRO_ID,TARGET_BALANCE,SA_TARGET_BALANCE,CA_TARGET_BALANCE,MIN_DATE) values (11,10000000,500000,500000,to_date('01-JUN-23','DD-MON-RR'));

