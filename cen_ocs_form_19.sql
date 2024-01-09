create or replace PACKAGE BODY CEN_OCS_FORM19 AS
  
  
PROCEDURE FETCH_FORM_19_CLAIM_DTLS	
( 
    IN_TRACKING_ID      IN CEN_OCS_FORM_19.TRACKING_ID%TYPE,
    OUT_CLAIM_DTLS      OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE,
	OUT_MESSAGE OUT VARCHAR2,
    OUT_STATUS OUT NUMBER
)AS
  BEGIN
  OUT_MESSAGE:='';
  OUT_STATUS :=0;
  
  OPEN OUT_CLAIM_DTLS FOR
    SELECT 
        OCS.TRACKING_ID,
        OCS.MEMBER_ID,
        OCS.MEMBER_NAME,
        OCS.CLAIM_FORM_TYPE,
        OCS.UAN,
        OCS.FATHER_SPOUSE_NAME,
        CASE
          WHEN OCS.GENDER = 'M' THEN 'Male'
          WHEN OCS.GENDER = 'F' THEN 'Female'			
          WHEN OCS.GENDER = 'T' THEN 'Transgender'			
        END AS GENDER,
        OCS.DOJ_EPF,
        OCS.DOE_EPF,
        OCS.DOB,
        OCS.REASON_EXIT,
        OCS.FLAG_15GH,
        OCS.PAN,
        OCS.CLAIM_MODE,
        OCS.ADDRESS1,
        OCS.ADDRESS_CITY,
        OCS.ADDRESS_PIN,
        DIS.NAME AS ADDRESS_DIST,
        ST.NAME AS ADDRESS_STATE,
        OCS.BANK_ACC_NO,
        OCS.IFSC_CODE,
        CBR.BRANCH_NAME ,
        CB.BANK_NAME,
        EST.NAME AS EST_NAME,
        SPM.PARA_DESCRIPTION || '-' || SPM.PARA_DETAILS AS SCHEME_PARA,
        OCS.ESTABLISHMENT_ID,
        MER.REASON, 
        OCS.LATEST_REMARK,
        OCS.CLAIM_STATUS,
        S.NAME AS BANK_STATE,
        CBR.BRANCH_ADDRESS,
        OCS.REASON_EXIT_TDS,
        OCS.LATEST_APPROVAL_STATUS,
        OCS.CRITERIA_FLOW_ID,
        OCS.CRITERIA_ID,
        OCS.PROCESS_ID,
        OCS.PROCESS_GROUP_ID,
        (SELECT GROUP_TYPE FROM FO_AUTH_PROCESS_CRITERIA  where criteria_id=(select criteria_id from CEN_OCS_FORM_19 
		WHERE TRACKING_ID=IN_TRACKING_ID))as g_type
    FROM 
        CEN_OCS_FORM_19 OCS
    INNER JOIN 
        CPPS_BANK CB 
    ON 
        OCS.BANK_ID = CB.BANK_CODE
    INNER JOIN 
        CPPS_BRANCH CBR 
    ON 
        OCS.IFSC_CODE = CBR.IFSC_CODE
    INNER JOIN 
        ESTABLISHMENT EST 
    ON 
        OCS.EST_SL_NO = EST.SL_NO 
    INNER JOIN 
        SCHEME_PARA_MASTER SPM 
    ON 
        SPM.PARA_CODE = OCS.PARA_CODE 
    AND 
        SPM.SUB_PARA_CODE = OCS.SUB_PARA_CODE
    INNER JOIN 
        MEMBER_EXIT_REASON MER 
    ON 
        OCS.REASON_EXIT = MER.ID
    INNER JOIN STATE ST 
    ON 
        OCS.ADDRESS_STATE = ST.ID
    INNER JOIN 
        DISTRICT DIS 
    ON 
        OCS.ADDRESS_DIST = DIS.ID
    INNER JOIN 
        STATE S 
    ON 
        S.ID = CBR.STATE_ID
    WHERE  
        OCS.TRACKING_ID=IN_TRACKING_ID;
	
	IF OUT_CLAIM_DTLS%NOTFOUND THEN
    OUT_MESSAGE="Details not found";
	
	EXCEPTION  
	WHEN OTHERS THEN
		OUTPUT_STATUS:=1;
		OUT_MESSAGE:=SQLERRM;
		
  END  FETCH_FORM_19_CLAIM_DTLS;
  
  
PROCEDURE CHANGE_CLAIM_STATUS
(
    IN_TRACKING_ID      IN CEN_OCS_FORM_19.TRACKING_ID%TYPE
)AS
    BEGIN
    UPDATE CEN_OCS_FORM_19
    SET CLAIM_STATUS = 'P'
    WHERE TRACKING_ID = IN_TRACKING_ID;
    COMMIT;
    END CHANGE_CLAIM_STATUS;


PROCEDURE INSERT_IN_PYMT_CLAIM_DTLS
(
    IN_TRACKING_ID              IN CEN_PYMT_CLAIM_DTLS.TRACKING_ID%TYPE,
    IN_UAN                      IN CEN_PYMT_CLAIM_DTLS.UAN%TYPE,
    IN_MEMBER_ID                IN CEN_PYMT_CLAIM_DTLS.MEMBER_ID%TYPE,
    IN_MEMBER_NAME              IN CEN_PYMT_CLAIM_DTLS.MEMBER_NAME%TYPE,
    IN_ESTABLISHMENT_ID         IN CEN_PYMT_CLAIM_DTLS.ESTABLISHMENT_ID%TYPE,
    IN_PAYMENT_APPROVAL_DATE    IN CEN_PYMT_CLAIM_DTLS.PAYMENT_APPROVAL_DATE%TYPE,
    IN_OFFICE_CODE              IN CEN_PYMT_CLAIM_DTLS.OFFICE_CODE%TYPE,
    IN_IFSC_CODE                IN CEN_PYMT_CLAIM_DTLS.IFSC_CODE%TYPE,
    IN_SESSION_ID               IN CEN_PYMT_CLAIM_DTLS.SESSION_ID%TYPE    
)AS
    BEGIN
    INSERT INTO CEN_PYMT_CLAIM_DTLS(
    TRACKING_ID,
    UAN,
    MEMBER_ID,
    MEMBER_NAME,
    ESTABLISHMENT_ID,
    PAYMENT_APPROVAL_DATE,
    OFFICE_CODE,
    IFSC_CODE,
    SESSION_ID
    ) VALUES (
    IN_TRACKING_ID,
    IN_UAN,
    IN_MEMBER_ID,
    IN_MEMBER_NAME,
    IN_ESTABLISHMENT_ID,
    NVL(IN_PAYMENT_APPROVAL_DATE, SYSDATE),
    IN_OFFICE_CODE,
    IN_IFSC_CODE,
    IN_SESSION_ID
    );
    
    COMMIT;
    END INSERT_IN_PYMT_CLAIM_DTLS;
    
PROCEDURE GET_PDF_15GH
(
    IN_TRACKING_ID      IN CEN_OCS_FORM_19.TRACKING_ID%TYPE,
    OUT_PDF_15GH        OUT VARCHAR
)AS
    BEGIN
    SELECT PDF_15GH INTO OUT_PDF_15GH
    FROM CEN_OCS_FORM_19
    WHERE TRACKING_ID = IN_TRACKING_ID;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    OUT_PDF_15GH := NULL;
    COMMIT;
    END GET_PDF_15GH;

PROCEDURE CHANGE_CLAIM_STATUS_REJECT
(
    IN_TRACKING_ID      IN CEN_OCS_FORM_19.TRACKING_ID%TYPE,
    IN_LATEST_REMARK    IN CEN_OCS_FORM_19.LATEST_REMARK%TYPE
)AS
    BEGIN
    UPDATE CEN_OCS_FORM_19
    SET CLAIM_STATUS = 'R' ,  LATEST_REMARK = IN_LATEST_REMARK
    WHERE TRACKING_ID = IN_TRACKING_ID;
    COMMIT;
    END CHANGE_CLAIM_STATUS_REJECT;

PROCEDURE CHANGE_LATEST_APP_STATUS_NE
(
    IN_TRACKING_ID      IN CEN_OCS_FORM_19.TRACKING_ID%TYPE,
    IN_REMARK           IN CEN_OCS_FORM_19.LATEST_REMARK%TYPE
)AS
    BEGIN
    UPDATE CEN_OCS_FORM_19
    SET LATEST_APPROVAL_STATUS = 'NE' , CLAIM_STATUS = 'E', LATEST_REMARK = IN_REMARK
    WHERE TRACKING_ID = IN_TRACKING_ID;
    
    UPDATE CEN_OCS_FORM_19_LOG
        SET
            LATEST_APPROVAL_STATUS = 'NE',
            CLAIM_STATUS = 'E',
            LATEST_REMARK = IN_REMARK,
            OPERATION_TIMESTAMP = SYSTIMESTAMP
        WHERE
            TRACKING_ID = IN_TRACKING_ID;
            
    COMMIT;
    END CHANGE_LATEST_APP_STATUS_NE;

PROCEDURE GET_REJECTION_REASON (
    OUT_REJECTION_REASON OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)AS
    BEGIN
    OPEN OUT_REJECTION_REASON FOR 
    SELECT *
    FROM CEN_OCS_REJECTION_REASON;
    COMMIT;
    END GET_REJECTION_REASON;
    
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- new modification -- procedure for user management
-- modification date 27/09/2023


procedure GET_ESTABLISHMENT_AND_PG_ID(
        IN_USER_ID       in   number,
        IN_OFFICE_ID     in   number,
        IN_PROCESS_ID    in   fo_auth_process.process_id%type,
        IN_PROCESS_NAME  in   fo_auth_process.process_name%type,
        OUT_EST_P_FLOW   out  COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)as
    begin
        open OUT_EST_P_FLOW for select
                                    OFFICE_ID,
                                    TASK_ID,
                                    EST_GROUP_ID,
                                    PROCESS_GROUP_ID,
                                    EST_ID,
                                    MEM_SPLITS_FROM,
                                    MEM_SPLITS_TO,
                                    case
                                        when LEVEL_0 = IN_USER_ID  then
                                            '0'
                                        when LEVEL_1 = IN_USER_ID  then
                                            '1'
                                        when LEVEL_2 = IN_USER_ID  then
                                            '2'
                                        when LEVEL_3 = IN_USER_ID  then
                                            '3'
                                        when LEVEL_4 = IN_USER_ID  then
                                            '4'
                                        when LEVEL_5 = IN_USER_ID  then
                                            '5'
                                        when LEVEL_6 = IN_USER_ID  then
                                            '6'
                                        when LEVEL_7 = IN_USER_ID  then
                                            '7'
                                        when LEVEL_8 = IN_USER_ID  then
                                            '8'
                                        else
                                            null
                                    end as ACTOR_LEVEL
                                from
                                    FO_AUTH_TASK_EST_GR_USER_MAP
                                where
                                    ( LEVEL_0 = IN_USER_ID
                                      or LEVEL_1 = IN_USER_ID
                                      or LEVEL_2 = IN_USER_ID
                                      or LEVEL_3 = IN_USER_ID
                                      or LEVEL_4 = IN_USER_ID
                                      or LEVEL_5 = IN_USER_ID
                                      or LEVEL_6 = IN_USER_ID
                                      or LEVEL_7 = IN_USER_ID
                                      or LEVEL_8 = IN_USER_ID )
                                    and OFFICE_ID = IN_OFFICE_ID AND
                                    PROCESS_GROUP_ID=(SELECT PROCESS_GROUP_ID
FROM (
    SELECT PROCESS_GROUP_ID
    FROM FO_AUTH_PROCESS_CRITERIA
    WHERE PROCESS_ID = IN_PROCESS_ID
) 
WHERE ROWNUM <= 1);               
        commit;    
END GET_ESTABLISHMENT_AND_PG_ID;

 --modified on 17-08-2023 while optimising the code .innner join with fo_auth_task_est_grp_user_map removed    
    
       PROCEDURE GET_TRACKING_IDS (
        IN_PROCESS_GROUP_ID  IN   NUMBER,
        IN_ESTABLISHMENT_ID  IN   VARCHAR2,
        IN_ACTOR_ID          IN   NUMBER,
        IN_EST_GROUPID       IN   NUMBER,
        IN_OFFICE_ID         IN   NUMBER,
        IN_USER_ID           IN   NUMBER,
        IN_CLAIM_MODE         IN   CHAR,
        OUT_T_ID_LIST        OUT  COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
    ) AS
    BEGIN
        OPEN OUT_T_ID_LIST FOR SELECT
                                   FORM19.TRACKING_ID,
                                   FORM19.MEMBER_ID,
                                   FORM19.UAN,
                                   FORM19.MEMBER_NAME,
                                   EXTRACT(DAY FROM SYSTIMESTAMP - FORM19.RECEIPT_DATE)       AS PENDING_DAYS,
                                   TO_CHAR(FORM19.RECEIPT_DATE, 'DD-MM-YYYY')                 AS RECEIPT_DATE,
                                   FORM19.CLAIM_STATUS,
                                   FORM19.UAN
                               FROM
                                   CEN_OCS_FORM_19 FORM19
                               WHERE
                                       SUBSTR(FORM19.MEMBER_ID, 0, 15) = IN_ESTABLISHMENT_ID
                                   AND FORM19.OFFICE_ID = IN_OFFICE_ID
                                   AND (FORM19.CLAIM_STATUS='N' OR FORM19.CLAIM_STATUS='P' OR FORM19.CLAIM_STATUS='E')
--                                   AND FORM20.PROCESS_GROUP_ID = IN_PROCESS_GROUP_ID
                                   AND ( ( IN_ACTOR_ID = 0
                                           AND FORM19.NEXT_USER_ID = 0
                                           OR FORM19.NEXT_USER_ID = IN_USER_ID )
                                         OR ( IN_ACTOR_ID <> 0
                                              AND FORM19.NEXT_USER_ID = IN_USER_ID ) )
                                    AND CLAIM_MODE  = IN_CLAIM_MODE 
                               ORDER BY
                                   SUBSTR(FORM19.MEMBER_ID, 0, 15);

        COMMIT;
    END GET_TRACKING_IDS;

procedure GET_USER_ID 
( 
    IN_ACTOR_LEVEL  IN NUMBER,
    IN_TRACKING_ID IN CEN_OCS_FORM_19.TRACKING_ID%TYPE,
    IN_GROUP_TYPE IN VARCHAR2,
    IN_MEMBER_ID IN VARCHAR2,
    OUT_USER_ID  out VARCHAR2
)as
 
SQL_STMT varchar2(2000);
--DYNAMIC_CURSOR sys_refcursor; -- Declare a local cursor variable
begin
SQL_STMT := 'select  distinct  FATEGU_MAP.LEVEL_' || IN_ACTOR_LEVEL || ' AS EXPECTED_LEVEL
FROM  CEN_OCS_FORM_19 FORM19 
INNER JOIN fo_auth_task_est_gr_user_map  FATEGU_MAP ON substr(FORM19.member_id, 0, 15) = FATEGU_MAP.est_id
INNER JOIN fo_auth_process_flow  FAP_FLOW ON FAP_FLOW.criteria_id=FORM19.criteria_id
where FORM19.tracking_id= :tracking_id  AND
FAP_FLOW.group_type= :group_type  AND
:member_id BETWEEN FATEGU_MAP.MEM_SPLITS_FROM AND FATEGU_MAP.MEM_SPLITS_TO';

DBMS_OUTPUT.PUT_LINE(SQL_STMT);
--open DYNAMIC_CURSOR for SQL_STMT;
--OUT_USER_ID := DYNAMIC_CURSOR;
EXECUTE IMMEDIATE SQL_STMT INTO OUT_USER_ID
USING IN_TRACKING_ID, IN_GROUP_TYPE, IN_MEMBER_ID;
end GET_USER_ID;

PROCEDURE GET_LEVEL_OF_USER(
        IN_USER_ID       IN   FO_OFFICE_USERS.id%type,
        IN_OFFICE_ID     IN   CEN_OCS_FORM_20.OFFICE_ID%type,
        IN_CRITERIA_ID   IN   NUMBER,
        IN_MEMBER_ID     IN   VARCHAR2,
        OUT_ACTOR_LEVEL  OUT  VARCHAR2

 ) AS
    BEGIN
         SELECT  CASE
                                         when LEVEL_0 = IN_USER_ID  then
                                             '0'
                                         when LEVEL_1 = IN_USER_ID  then
                                             '1'
                                         when LEVEL_2 = IN_USER_ID  then
                                             '2'
                                         when LEVEL_3 = IN_USER_ID  then
                                             '3'
                                         when LEVEL_4 = IN_USER_ID  then
                                             '4'
                                         when LEVEL_5 = IN_USER_ID  then
                                             '5'
                                         when LEVEL_6 = IN_USER_ID  then
                                           '6'
                                         when LEVEL_7 = IN_USER_ID  then
                                             '7'
                                         when LEVEL_8 = IN_USER_ID  then
                                             '8'
                                         else
                                             null
                                     END INTO OUT_ACTOR_LEVEL 
                                   
                                 FROM
                                     FO_AUTH_TASK_EST_GR_USER_MAP
                                 WHERE
                                 ( LEVEL_0 = IN_USER_ID
                                       or LEVEL_1 = IN_USER_ID
                                       or LEVEL_2 = IN_USER_ID
                                       or LEVEL_3 = IN_USER_ID
                                       or LEVEL_4 = IN_USER_ID
                                       or LEVEL_5 = IN_USER_ID
                                       or LEVEL_6 = IN_USER_ID
                                       or LEVEL_7 = IN_USER_ID
                                       or LEVEL_8 = IN_USER_ID )AND
                                     OFFICE_ID = IN_OFFICE_ID
                                     AND IN_MEMBER_ID BETWEEN MEM_SPLITS_FROM AND MEM_SPLITS_TO
                                     AND PROCESS_GROUP_ID = (
                                        SELECT
                                            PROCESS_GROUP_ID
                                        FROM
                                            FO_AUTH_PROCESS_CRITERIA
                                        WHERE
                                                CRITERIA_ID = IN_CRITERIA_ID
                                    );
        COMMIT;
    end GET_LEVEL_OF_USER;

PROCEDURE GET_PROCESS_FLOW 
(
    IN_CRITERIA_ID      IN CEN_OCS_FORM_19.CRITERIA_ID%TYPE,
    IN_PROCESS_ID       IN FO_AUTH_PROCESS_FLOW.PROCESS_ID%TYPE,
    IN_CRITERIA_FLOW_ID IN CEN_OCS_FORM_19.CRITERIA_FLOW_ID%TYPE,
    OUT_PROCESS_FLOW    OUT  COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)AS 
    BEGIN
        OPEN OUT_PROCESS_FLOW FOR
    SELECT
            FROM_ACTOR,
            TO_ACTOR,
            GROUP_TYPE,
            MULTI_GROUP,
            MULTI_OFFICE,
            IS_LAST_GROUP,
            IS_LAST_OFFICE,
            IS_CURRENT_GROUP_END,
            OPTIONS,
            IS_LAST_ROW,
            OPTIONS,
            ADVANCED_OPTIONS

             FROM FO_AUTH_PROCESS_FLOW  
             where CRITERIA_ID= IN_CRITERIA_ID
             AND PROCESS_ID=IN_PROCESS_ID
             AND CRITERIA_FLOW_ID=IN_CRITERIA_FLOW_ID
             order by CREATED_TIME;
  COMMIT;
  END GET_PROCESS_FLOW;
  
procedure GET_CURRENT_FLOW 
( 
    IN_CRITERIA_ID      IN FO_AUTH_PROCESS_FLOW.CRITERIA_ID%TYPE,
    IN_PROCESS_ID       IN FO_AUTH_PROCESS_FLOW.PROCESS_ID%TYPE,
    IN_CRITERIA_FLOW_ID IN FO_AUTH_PROCESS_FLOW.CRITERIA_FLOW_ID%TYPE,
    IN_FROM_ACTOR       IN FO_AUTH_PROCESS_FLOW.FROM_ACTOR%TYPE,
    IN_GROUP_TYPE       IN FO_AUTH_PROCESS_FLOW.GROUP_TYPE%TYPE,
    OUT_CURRENT_FLOW  out  COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)AS 
    BEGIN
        OPEN OUT_CURRENT_FLOW FOR
    SELECT
            FROM_ACTOR,
            TO_ACTOR,
            GROUP_TYPE,
            MULTI_GROUP,
            MULTI_OFFICE,
            IS_LAST_GROUP,
            IS_LAST_OFFICE,
            IS_CURRENT_GROUP_END,
            OPTIONS,
            IS_LAST_ROW,
            OPTIONS,
            ADVANCED_OPTIONS
            
             FROM FO_AUTH_PROCESS_FLOW 
             where CRITERIA_ID = IN_CRITERIA_ID
             AND PROCESS_ID=IN_PROCESS_ID
             AND CRITERIA_FLOW_ID=IN_CRITERIA_FLOW_ID
             AND FROM_ACTOR = IN_FROM_ACTOR
             AND GROUP_TYPE = IN_GROUP_TYPE
             order by CREATED_TIME;
  COMMIT;
  END GET_CURRENT_FLOW;
  
PROCEDURE GET_PROCESS_FLOW_BY_GROUP 
(
    IN_CRITERIA_ID      IN CEN_OCS_FORM_19.CRITERIA_ID%TYPE,
    IN_PROCESS_ID       IN FO_AUTH_PROCESS_FLOW.PROCESS_ID%TYPE,
    IN_CRITERIA_FLOW_ID IN CEN_OCS_FORM_19.CRITERIA_FLOW_ID%TYPE,
    IN_GROUP_TYPE       IN FO_AUTH_PROCESS_FLOW.GROUP_TYPE%TYPE,
    OUT_PROCESS_FLOW    OUT  COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)AS 
    BEGIN
        OPEN OUT_PROCESS_FLOW FOR
    SELECT
        FROM_ACTOR,
            TO_ACTOR,
            GROUP_TYPE,
            MULTI_GROUP,
            MULTI_OFFICE,
            IS_LAST_GROUP,
            IS_LAST_OFFICE,
            IS_CURRENT_GROUP_END,
            OPTIONS,
            IS_LAST_ROW,
            OPTIONS,
            ADVANCED_OPTIONS
            
             FROM FO_AUTH_PROCESS_FLOW 
             where CRITERIA_ID = IN_CRITERIA_ID
             AND PROCESS_ID=IN_PROCESS_ID
             AND CRITERIA_FLOW_ID=IN_CRITERIA_FLOW_ID
             AND GROUP_TYPE = IN_GROUP_TYPE
             order by CREATED_TIME;
  COMMIT;
  END GET_PROCESS_FLOW_BY_GROUP;

PROCEDURE UPDATE_LAS_AND_NEXT_USER(
    IN_APPROVAL_STATUS  IN CEN_OCS_FORM_19.LATEST_APPROVAL_STATUS%TYPE,
    IN_TRACKING_ID      IN CEN_OCS_FORM_19.TRACKING_ID%TYPE,
    IN_NEXT_USER        IN CEN_OCS_FORM_19.NEXT_USER_ID%TYPE,
    IN_LATEST_REMARK    IN CEN_OCS_FORM_19.LATEST_REMARK%TYPE,
    OUT_STATUS OUT NUMBER
)AS
    V_COUNT NUMBER;
    BEGIN
        V_COUNT:=0;
        
        IF IN_APPROVAL_STATUS = 'SB' THEN 
            UPDATE CEN_OCS_FORM_19
            SET NEXT_USER_ID =IN_NEXT_USER, 
                CLAIM_STATUS = 'E',
                LATEST_APPROVAL_STATUS=IN_APPROVAL_STATUS,
                LATEST_REMARK = IN_LATEST_REMARK
            WHERE TRACKING_ID = IN_TRACKING_ID;
        ELSE
            UPDATE CEN_OCS_FORM_19
            SET NEXT_USER_ID =IN_NEXT_USER, 
            CLAIM_STATUS = 'N',
            LATEST_APPROVAL_STATUS=IN_APPROVAL_STATUS,
            LATEST_REMARK = IN_LATEST_REMARK
            WHERE TRACKING_ID = IN_TRACKING_ID;
        END IF;
        V_COUNT  :=SQL%ROWCOUNT;
        IF V_COUNT>0 THEN
            OUT_STATUS :=0;
            END IF;
        IF V_COUNT=0 THEN
            OUT_STATUS :=1;
            END IF;
        EXCEPTION
            WHEN CASE_NOT_FOUND THEN
                OUT_STATUS:=1;
            WHEN OTHERS THEN
                OUT_STATUS:=1;
    COMMIT;
    END UPDATE_LAS_AND_NEXT_USER;
    
END CEN_OCS_FORM19;