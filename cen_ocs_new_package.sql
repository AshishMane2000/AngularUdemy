create or replace PACKAGE BODY CEN_OCS_NEW_PACKAGE AS

/*
	#ver1.1
	Date : 07-Jan-2020
	Change : Facility to view Claim PDF in track claim status functionality

	#ver1.2
	Date : 10-Jan-2020
	Change : Email from soni.smita@epfindia.gov.in dated Thu, 9 Jan 2020 12:51:38 +0530 (IST) subject : Age limit reduce up to 55 for claim settlement

	#ver1.3
	Date : 29-Jan-2020
	Change : Set the cancelled cheque BLOB field value to NULL as the physical copy of image of cancelled cheque files are also available on storage... as per directions from Harsh Sir

	#ver1.4
	Date : 06-Feb-2020
	Change : Bug fixed for 10D. Bank details of Telangana not getting populated while generating claim PDF.

	#ver1.5
	Date : 12-Feb-2020
	Change : Check digitally signed PAN instead of verified PAN for Form 15G/H upload in Form-19.

	#ver1.6
	Date : 17-Feb-2020
	Change : Check digitally signed PAN instead of verified PAN for Form 15G/H upload in Form-19.

	#ver1.7
	Date : 19-Feb-2020
	Change : As guided by Harsh sir on 19/02/2020, check PAN in UAN_REPOSITORY irrespective of verification status and digital signature status. It is assumed that if PAN is present in UAN_REPOSITORY then it is digitally signed only. Ref e-mail dated 19/02/2020 from Sandesh sir to Harsh sir.

	#ver1.8
	Date : 02-Mar-2020
	Change : ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR POWER CUT REASON. Ref email from harsh.kaushik@epfindia.gov.in dated Fri, 28 Feb 2020 Subject : Online Advance Claim (Power Cut)

	#ver1.9
	Date : 29-Mar-2020
	Change : Added new scheme para for COVID-19 CORONAVIRUS IN PF ADVANCE FORM-31

	#ver2.0
	Date : 29-Mar-2020
	Change : Order of scheme para 'OUTBREAK OF PANDEMIC (COVID-19)' changed to top in dropdown list of scheme paras for Form-31.

	#ver2.1
	Date : 30-Mar-2020
	Change : As guided by Ranjit sir, added procedure to get bank KYC approved pdf details to check existence on directory.

	#ver2.2
	Date : 31-Mar-2020
	Change : Set KYC PDF as available for claims submitting through Unified Portal.

	#ver2.3
	Date : 01-Apr-2020
	Change : Set KYC_PDF as NULL for claims submitting through Umang Application.

	#ver2.4
	Date : 02-Apr-2020
	Change : Added Bank IFSC validation while verifying Bank KYC.	--DID NOT COMPILED ON PRODUCTION AS HARSH SIR SAID GRIEVANCES WILL INCREASE IN COVID-19 PANDEMIC SITUATION

	#ver2.5
	Date : 04-Apr-2020
	Change : Allowed PF Advance claim for COVID-19 if another PF Advance claim of any other para is pending.

	#ver2.6
	Date : 15-Apr-2020
	Change : Added extra validation of single claim for COVID-19 while submitting the claim.

	#ver2.7
	Date : 20-Apr-2020
	Change : Set PDB_UPDATE_FLAG and KYC_PDF flag to 'P' while submitting online claims to validate Bank KYC PDF and AADHAAR demographic verification through scheduler.

	#ver2.8
	Date : 22-Apr-2020
	Change : Bug fix in bank account number verification. Issue reported by Ms. Smita Soni on 22/04/2020.

	#ver2.9
	Date : 24-Apr-2020
	Change : Incorporate changes related to two new columns for Bank KYC PDF and AADHAAR demographic verification scheduler.

	#ver3.0
	Date : 25-Apr-2020
	Change : Set PDB_UPDATE_FLAG and KYC_PDF flag to 'P' only for UMANG. Allow Unified Portal claims to get processed without a scheduler check.

	#ver3.1
	Date : 27-Apr-2020
	Change : Call common procedure for fetching Bank KYC PDF details for verification.

	#ver3.2
	Date : 30-Apr-2020
	Change : Allow COVID-19 claim, if no other COVID-19 claim is pending. Ref. Email by Harsh sir Dated:- 30/04/2020

	#ver3.3
	Date : 02-May-2020
	Change : Raise maximum number of claims limit from 15 to 20. Ref. Email by Harsh sir to Sandesh sir Dated:- 01/05/2020. As guided by Harsh sir over phone, limit to be increased for all the claim types.

	#ver3.4
	Date : 09-May-2020
	Changes : 1. Validation for bank account no mapped with multiple UANs. Ref. Email by Smita soni Dated:- 09/05/2020
			  2. AADHAAR verification response code logging. Guided by Ranjit sir

	#ver3.5
	Date : 22-May-2020
	Changes : Insert Bank KYC invalid PDF log 

	#ver3.6
	Date : 08-Jun-2020
	Changes : Display rejection reason while displaying claim status.

	#ver3.7
	Date : 09-Jun-2020
	Changes : Trim leading and trailing spaces in a name available against the UAN while validation for bank account no mapped with multiple UANs.

	#ver3.8
	Date : 10-Jun-2020
	Changes : Multiple Member ID selection for PF Advance Claim.

	#ver3.9
	Date : 12-Jun-2020
	Changes : Increase length of variable from 100 to 256

	#ver4.0
	Date : 26-Jun-2020
	Changes : 1. Allow PF Advance for illness once in a 30 days
			  2. Check claim revised status
			  3. Bank IFSC matching while validating bank account linked to multiple UANs
			  4. Allow alphanumeric bank account number

	#ver4.1
	Date : 29-Jun-2020
	Changes : Remove spaces in name while validating bank account linked to multiple UANs

	#ver4.2
	Date : 08-Jul-2020
	Changes : Decode Member Exit Reasons from ID 10,11,12 to 7,8,9 respectively	 --Guided by Harsh sir over phone

	#ver4.3
	Date : 18-Aug-2020
	Changes : PARA_CODE, SUB_PARA_CODE, SUB_PARA_CATEGORY not null validation added.	 --Guided by Harsh sir over phone for UMANG issue

	#ver4.4
	Date : 20-Aug-2020
	Changes : Check Bank KYC approval PDF on an alternate location as well.

	#ver4.5
	Date : 26-Aug-2020
	Changes : Check Bank KYC approval PDF on all locations.

	#ver4.6
	Date : 18-Sep-2020
	Changes : Enabled Scheme Certificate claim through UMANG.

	#ver4.7
	Date : 07-Oct-2020
	Changes : Exclude citizen portal allotted UANs from validation of Bank a/c number mapped with multiple UANs. --Ref email from Harsh sir, dated 07-OCT-2020

	#ver4.8
	Date : 07-Nov-2020
	Changes : Additional filters for para 68K , 68B1(a), 68B1(b), 68B1(bb), 68B1(c) ,68N INSIDE GET_SCHEME_PARA AND VALIDATE_SCHEME_PARA 
			  Added in parameters to insert third party details
			  Added new methods GET_PARA68M_MAX_AMOUNT,GET_CLAIM_COUNT_FOR_68K,COUNT_PARA68B7_ADVNCE,COUNT_PARA68B1_CLAIMS,COUNT_PARA68N_ADVNCE_IN_3YEARS,FETCH_MEMBERSHIP etc.
			  Added advance amount check for power cut advance claim type 

	#ver4.9
	Date : 10-Nov-2020
	Changes : Query optimization in FETCH_MEMBERSHIP

	#ver4.10
	Date : 11-Nov-2020
	Changes : Added validation on advance amt for power cut claim 
			  Update in conditions for para 26- in GET_SCHEME_PARA and VALIDATE_SCHEME_PARA

	#ver4.11
	Date : 08-dEC-2020
	Changes : Corrected error message in GET_SCHEME_PARA 
			  Chnage in condition while comparing membership in VALIDATE_SCHEME_PARA

	#ver4.12
	Date : 07-Jan-2021
	Changes : If Date of exit EPS is greater than date of attainment of 58 years of age, 
            then the service will be calculated from minimum date of joining EPS till Date of attainment of 58 years of age. Ref. email by Smita Soni (07-Jan-2020) 

	#ver4.13
	Date : 06-Feb-2021
	Changes :  Encrypted Bank Account Number Verification

	#ver4.14
	Date : 19-Feb-2021
	Changes :  LAST_MID Function updated to exclude dummy establishment details and also excluded dummy details whenever member details are required

	#ver4.15
	Date : 18-March-2021
	Changes : Handled CLAIM_REVISED_STATUS flag check in case of checking pending claim against specific Scheme Para for Form 31 (PF Advance)  

	#ver4.16
	Date : 15-April-2021
	Changes : 1] While getting member details GET_LATEST_IFSC function used for getting latest IFSC
			  2] Handled New Claim rejection status (CLAIM_STATUS = 8) in case of Online Bank Verification failure

	#ver4.17
	Date : 23-April-2021
	Changes : 1] Added check for Online bank verification status while checking OCS eligibility.
              2] Troubleshoot in GET_CLAIM_STATUS when no records against logged in UAN. 

	#ver4.18
	Date : 17-May-2021
	Changes : Enabled checking of IFSC obsolete status & claim won't be submitted if IFSC is obsolete.

	#ver4.19
	Date : 18-May-2021
	Changes : Removed the max claim limit validation (Email dated 12-May-2021 from Smita Mam)

	#ver4.20
	Date : 22-May-2021
	Changes : Allowed COVID-19 Advance claim for 2 times

	#ver4.21
	Date : 19-June-2021
	Changes : Allowed Form 19 (PF Final Settlement) Withdrawal for waiting period (less than 2 Months) based on specific withdrawal reasons

	#ver4.22
	Date : 22-June-2021
	Changes : AADHAAR Consent status logging

	#ver4.23
	Date : 28-June-2021
	Changes : Allowed Form 10C (WB) Withdrawal for waiting period (less than 2 Months) based on specific withdrawal reasons

	#ver4.24
	Date : 23-July-2021
	Changes : Form 10C(WB) Service Calculation based on Actual Service[excluding settled case]

	#ver4.25
	Date : 24-Sep-2021
	Changes : Relaxation of PF exemption status check on Form 31 selection. 
            If more then one member id linked with same UAN then advance claim option should be allowed 
            for all those member ids which are associated with unexempted establishment.

	#ver4.26
	Date : 07-Oct-2021
	Changes : UMANG : Restrict Form 31 for all those member ids which are associated with exempted establishment.

	#ver4.27
	Date : 17-Nov-2021
	Changes : FETCH_MEMBERSHIP function (for Form 31) updated to exclude the settled services (Form 19) linked with same Aadhaar and take the oldest date of joining to calculate the membership length.(Email dated 29-Oct-2021 from Harsh Sir)

	#ver4.28
	Date : 23-Nov-2021
	Changes : UMANG - Added check for UAN Deactivation status.

	#ver4.29
	Date : 30-Nov-2021
	Changes : Added Scheme Certificate claim through Unified Portal.

	#ver4.30
	Date : 3-Dec-2021
	Changes : Additional check for UAN Deactivation status after claim submission.

	#ver4.31
	Date : 8-Dec-2021
	Changes : Bank Acc No & AADHAAR check with existing claim data.

	#ver4.32
	Date : 23-Dec-2021
	Changes : Added Nomination check for Form 31(PF Advance) Scheme Paras except for Illness para.

	#ver4.33
	Date : 25-Jan-2022
	Changes : Disable Nomination check for Form 31(PF Advance).

	#ver4.34
	Date : 16-Feb-2022
	Changes : Form 10C Service Calculation Check with updated function on final submit

	#ver4.35
	Date : 22-Feb-2022
	Changes : Descriptive error messages for additional troubleshooting.

	#ver4.36
	Date : 19-Apr-2022
	Changes : Sync Nomination module changes to avoid NOMINEE RELATION issue in case of EPS Nominee

	#ver4.37
	Date : 08-Jun-2022
	Changes : 1] Form10c Service calculation considering days
            2] CHECK BANK_ACC_NO ALONG WITH BANK_IFSC

  #ver4.38
	Date : 05-Aug-2022
	Changes : 1] BANK_IFSC_CHANGE_UPPER_TRIM

  #ver4.39
	Date : 11-Nov-2022
	Changes : Added OCS_UTILITY.VERIFY_DOJ_AT58_10D in CHECK_ELIGIBILITY procedure to allow member for filing claim at age of 58 yrs having multiple memberid without checking DOJ_EPS and DOE_EPS.

*/	    

PROCEDURE CHECK_ANY_PENDING_KYC(
        IN_UAN IN NUMBER,
        OUT_ERROR_MESSAGE OUT VARCHAR2
)
AS
        CURSOR CUR_PENDING_KYC_ERRORS IS
                SELECT
                        'KYC change in '|| DECODE(MKT.DOCUMENT_TYPE_ID, 1, 'Bank Account Number', 2, 'PAN', 3, 'AADHAAR') ||' submitted by '|| DECODE(TYPE_ID,9,'you','employer') ||' on '||TO_CHAR(MKT.VERIFIED_ON,'DD/MM/YYYY') ||' is pending with '||EST.NAME ||' for approval. You will be able to submit the claim once this KYC is approved/rejected.' AS ERROR_MESSAGE
                FROM
                        MEMBER_KYC_TRANS MKT
                 INNER JOIN EST_ACTIVITY_LOG EAL        --NEED TO ASK
                         ON EAL.ID = MKT.ACTIVITY_ID
                INNER JOIN ESTABLISHMENT EST
                        ON EST.SL_NO = EAL.EST_SL_NO    --NEED TO ASK
--      ON EST.SL_NO = MKT.EST_SL_NO

                WHERE
                        MKT.UAN = IN_UAN AND--100204839455
                --      EAL.STATUS IN ('P','I') AND
                        EAL.STATUS IN ('P','I') AND             --ADDED ON 20/06/2019
                        -- MKT.DOCUMENT_TYPE_ID IN (1,2,3) --I.E. BANK, PAN, AADHAAR RESPECTIVELY	--COMMENTED ON 06/09/2019 AND ADDED CHECK ONLY FOR BANK A/C NO AS BELOW
                        MKT.DOCUMENT_TYPE_ID = 1 -- 1= BANK	--ADDED ON 06/09/2019 TO CHECK ONLY FOR BANK A/C NO
                UNION ALL

                SELECT
                        'KYC change in '|| DECODE(MK.DOCUMENT_TYPE_ID, 1, 'Bank Account Number', 2, 'PAN', 3, 'AADHAAR') ||' submitted by '|| DECODE(TYPE_ID,9,'you','employer') ||' on '||TO_CHAR(MK.VERIFIED_ON,'DD/MM/YYYY') ||' is pending with '||EST.NAME ||' for approval. You will be able to submit the claim once this KYC is approved/rejected.' AS ERROR_MESSAGE
                FROM
                        MEMBER_KYC MK
                INNER JOIN EST_ACTIVITY_LOG EAL
                        ON EAL.ID = MK.ACTIVITY_ID
                INNER JOIN ESTABLISHMENT EST
                        ON EST.SL_NO = EAL.EST_SL_NO
                WHERE
                        MK.UAN = IN_UAN AND --100204839455
                        -- MK.DOCUMENT_TYPE_ID IN (1,2,3)  AND--I.E. BANK, PAN, AADHAAR RESPECTIVELY	--COMMENTED ON 06/09/2019 AND ADDED CHECK ONLY FOR BANK A/C NO AS BELOW
						MK.DOCUMENT_TYPE_ID = 1 AND-- 1= BANK	--ADDED ON 06/09/2019 TO CHECK ONLY FOR BANK A/C NO
                        EAL.STATUS IN ('A','O') AND
                        EAL.DS_STATUS = 'N'
                        -- AND (CASE               --ADDED ON 28/06/2019	--COMMENTED ON 06/09/2019 AND ADDED CHECK ONLY FOR BANK A/C NO
                                        -- WHEN MK.DOCUMENT_TYPE_ID = 2 AND PKG_LATEST_KYC.GET_DSC_PAN(MK.UAN,MK.DOCUMENT_NO,'N') = 1 THEN 0
                                        -- ELSE 1
                                -- END ) =1
                        -- AND (CASE               --ADDED ON 28/06/2019	--COMMENTED ON 06/09/2019 AND ADDED CHECK ONLY FOR BANK A/C NO
                                        -- WHEN ( MK.DOCUMENT_TYPE_ID = 3 AND PKG_LATEST_KYC.GET_AADHAAR_BY_UAN(MK.UAN,'Y') = MK.DOCUMENT_NO ) THEN 0
                                        -- ELSE 1
                                -- END
                                -- ) =1

                UNION ALL

                SELECT
                    CASE WHEN IS_VERIFICATION_SERV_AVAIL = 'Y' AND IS_ELIGIBLE_FOR_DS <> 'Y' THEN --#ver4.28
                            'KYC change in '|| DECODE(MKYTM.DOCUMENT_TYPE_ID, 1, 'Bank Account Number', 2, 'PAN', 3, 'AADHAAR') ||' submitted by you on '||TO_CHAR(MKYTM.VERIFIED_ON,'DD/MM/YYYY') ||' is under process.' 
                    ELSE 
                            'KYC change in '|| DECODE(MKYTM.DOCUMENT_TYPE_ID, 1, 'Bank Account Number', 2, 'PAN', 3, 'AADHAAR') ||' submitted by you on '||TO_CHAR(MKYTM.VERIFIED_ON,'DD/MM/YYYY') ||' is pending with '||EST.NAME ||' for digital signing.'
                    END AS ERROR_MESSAGE
                FROM
                        MEMBER_KYC_BY_MEM_TRANS MKYTM
                INNER JOIN ESTABLISHMENT EST
                        ON EST.SL_NO = MKYTM.EST_SL_NO
                WHERE
                        MKYTM.UAN = IN_UAN AND --100204839455
                        -- MKYTM.DOCUMENT_TYPE_ID IN (1,2,3)       --I.E. BANK, PAN, AADHAAR RESPECTIVELY	--COMMENTED ON 06/09/2019 AND ADDED CHECK ONLY FOR BANK A/C NO AS BELOW
                        MKYTM.DOCUMENT_TYPE_ID = 1     -- 1= BANK	--ADDED ON 06/09/2019 TO CHECK ONLY FOR BANK A/C NO
                ;
        V_ERROR_MESSAGE VARCHAR2(4000):= '';
BEGIN
        FOR V_ERROR IN CUR_PENDING_KYC_ERRORS
  LOOP
                IF V_ERROR_MESSAGE IS NULL THEN
                        V_ERROR_MESSAGE := V_ERROR.ERROR_MESSAGE;
                ELSE
                        V_ERROR_MESSAGE := V_ERROR_MESSAGE ||', '|| V_ERROR.ERROR_MESSAGE;
                END IF;
        END LOOP;
		IF V_ERROR_MESSAGE IS NULL THEN  -- ADDED TO  PORT ONLINE VERIFIED BANK KYC RECORD FOR DIGITAL SIGNING
          PKG_INVD_UR_ON_VER_BANK.CHECK_FOR_VERIFICATION(IN_UAN,OUT_ERROR_MESSAGE); 
          ELSE
        OUT_ERROR_MESSAGE := V_ERROR_MESSAGE;
		END IF;
EXCEPTION
        WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001,'Z#Error while validating pending KYC details. Please try sfter some time.#Z'||SQLERRM);
END CHECK_ANY_PENDING_KYC;

--ADDED BY AKSHAY ON 03/09/2019
FUNCTION IS_BANK_ACCOUNT_NUMBER_BLOCKED
(
	IN_BANK_ACCOUNT_NUMBER IN VARCHAR2
)
RETURN NUMBER
AS
	V_BLOCKED_BANK_CNT NUMBER(3);
BEGIN
	SELECT COUNT(1) INTO V_BLOCKED_BANK_CNT FROM UNIFIED_PORTAL.BLOCKED_BANK_DETAILS WHERE BANK_ACC_NO=IN_BANK_ACCOUNT_NUMBER AND STATUS = 'B';
	IF V_BLOCKED_BANK_CNT > 0 THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
END IS_BANK_ACCOUNT_NUMBER_BLOCKED;
--ADDITION BY AKSHAY ON 03/09/2019 ENDED

FUNCTION GEN_TRACKING_ID_UAN
(
        IN_UAN IN NUMBER,
        IN_CLAIM_TYPE IN VARCHAR2
) RETURN NUMBER
IS
        V_CLM_CNT NUMBER(10);
        OUTPUT VARCHAR2(50);
BEGIN
        OUTPUT:='';
     CASE IN_CLAIM_TYPE 
      WHEN '01' THEN
        SELECT
                COUNT(1)
        INTO
                V_CLM_CNT
        FROM
                CEN_OCS_FORM_19
        WHERE
                UAN = IN_UAN AND
                CLAIM_FORM_TYPE = IN_CLAIM_TYPE;

                RETURN IN_UAN || IN_CLAIM_TYPE || TRIM(TO_CHAR(V_CLM_CNT+1,'099'));
       WHEN '06' THEN
         SELECT
                COUNT(1)
        INTO
                V_CLM_CNT
        FROM
                CEN_OCS_FORM_31
        WHERE
                UAN = IN_UAN AND
                CLAIM_FORM_TYPE = IN_CLAIM_TYPE;

                RETURN IN_UAN || IN_CLAIM_TYPE || TRIM(TO_CHAR(V_CLM_CNT+1,'099'));
      WHEN '04' THEN
        SELECT
                COUNT(1)
        INTO
                V_CLM_CNT
        FROM
                CEN_OCS_FORM_10_C
        WHERE
                UAN = IN_UAN AND
                CLAIM_FORM_TYPE = IN_CLAIM_TYPE;

                RETURN IN_UAN || IN_CLAIM_TYPE || TRIM(TO_CHAR(V_CLM_CNT+1,'099')); 
      WHEN '0104' THEN
        SELECT
                COUNT(1)
        INTO
                V_CLM_CNT
        FROM
                CEN_OCS_CCF_CLAIMS
        WHERE
                UAN = IN_UAN AND
                CLAIM_FORM_TYPE = IN_CLAIM_TYPE;

                RETURN IN_UAN || IN_CLAIM_TYPE || TRIM(TO_CHAR(V_CLM_CNT+1,'099'));         
        ELSE RAISE CASE_NOT_FOUND;   
      END CASE;          
EXCEPTION 
WHEN CASE_NOT_FOUND THEN
  OUTPUT:='CASE NOT FOUND EXCEPTION FROM GEN_TRACKING_ID_UAN'||SQLERRM;
WHEN OTHERS THEN
  OUTPUT:='EXCEPTION OTHER '||SQLERRM;
END GEN_TRACKING_ID_UAN;

FUNCTION GET_MEMBER_AGE (IN_UAN IN NUMBER) RETURN NUMBER
AS
V_AGE NUMBER(3):=0;
BEGIN
  SELECT
    FLOOR(MONTHS_BETWEEN(SYSDATE,DOB) / 12)
  INTO
    V_AGE
  FROM
    UAN_REPOSITORY
  WHERE
    UAN = IN_UAN;
RETURN V_AGE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN V_AGE;
END GET_MEMBER_AGE;

FUNCTION GET_EST_SL_NO(
    IN_MEMBER_ID IN VARCHAR2)
  RETURN NUMBER
AS
  SLNO    NUMBER;
  V_COUNT NUMBER;
BEGIN
  SLNO :=0;
  SELECT SL_NO
  INTO SLNO
  FROM ESTABLISHMENT
  WHERE EST_ID=SUBSTR(IN_MEMBER_ID,0,15);
  RETURN SLNO;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN 0;
END GET_EST_SL_NO;
FUNCTION GET_OFFICE_ID(
    IN_MEMBER_ID IN VARCHAR2)
  RETURN NUMBER
AS
  OFCID   NUMBER;
  V_COUNT NUMBER;
BEGIN
  OFCID :=0;
  SELECT O.ID
  INTO OFCID
  FROM OFFICE O
  JOIN REGION R
  ON O.REGION_ID=R.ID
  WHERE R.CODE
    ||O.CODE=SUBSTR(IN_MEMBER_ID,0,5);
  RETURN OFCID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN 0;
END GET_OFFICE_ID;

--ADDED BY AKSHAY ON 17/09/2019 TO ADD 68HH IN PURPOSE OF PF ADVANCE
FUNCTION GET_68HH_CLAIMS_THR_LAST_ESTAB (
	IN_UAN IN NUMBER,
	IN_FORM_TYPE IN VARCHAR2
)
RETURN NUMBER
AS
	V_TOTAL_68HH_CLAIMS NUMBER(2):=0;
	V_LATEST_MEM_ID VARCHAR2(24) := '';
BEGIN
	V_LATEST_MEM_ID:=last_mid(IN_UAN);

	SELECT
		COUNT(1)
	INTO
		V_TOTAL_68HH_CLAIMS
	FROM
        CEN_OCS_FORM_31 COF31
--		OCS_CLAIM_DATA OCD
--	INNER JOIN OCS_CRD OCRD
--		ON OCD.TRACKING_ID = OCRD.TRACKING_ID
	WHERE
		COF31.UAN = IN_UAN
		AND COF31.CLAIM_FORM_TYPE = IN_FORM_TYPE
--		AND OCD.PDB_UPDATE_FLAG = 'Y'
		AND COF31.PARA_CODE = '4'
		AND COF31.SUB_PARA_CODE = '11'
		AND COF31.SUB_PARA_CATEGORY = '-'
		-- AND OCRD.CLAIM_STATUS <> 4	--COMMENTED FOR --#ver2.9
		AND COF31.CLAIM_STATUS NOT IN ('R') --#ver2.9 --#ver4.16
		AND COF31.ESTABLISHMENT_ID = SUBSTR(V_LATEST_MEM_ID,0,15)
		AND CASE WHEN COF31.CLAIM_STATUS = 'S'  THEN 0 ELSE 1 END = 1	--#ver4.0
    ;
	RETURN 	V_TOTAL_68HH_CLAIMS;
END GET_68HH_CLAIMS_THR_LAST_ESTAB;
--ADDITION BY AKSHAY ON 17/09/2019 ENDED

--#ver1.8
--ADDED ON 02/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR POWER CUT REASON
FUNCTION COUNT_CLAIM_FOR_POWERCUT (
	IN_UAN IN NUMBER
)
RETURN NUMBER
AS
  V_TOTAL_POWERCUT_CLAIMS NUMBER(2):=0;
BEGIN	
	SELECT
		COUNT(1)
	INTO
		V_TOTAL_POWERCUT_CLAIMS
	FROM
        CEN_OCS_FORM_31 COF31
--		OCS_CLAIM_DATA OCD
--	INNER JOIN OCS_CRD OCRD
--		ON OCD.TRACKING_ID = OCRD.TRACKING_ID
	WHERE
		COF31.UAN = IN_UAN			
--    AND OCRD.CLAIM_STATUS = 5
    -- AND OCRD.CLAIM_STATUS <> 4 --COMMENTED FOR --#ver2.9
		AND COF31.CLAIM_STATUS NOT IN ('R') --#ver2.9 --#ver4.16
		AND COF31.CLAIM_FORM_TYPE = '06'
		-- AND OCD.PDB_UPDATE_FLAG = 'Y'	--#ver2.7
		AND COF31.PARA_CODE = '9'
		AND COF31.SUB_PARA_CODE = '14'
		AND COF31.SUB_PARA_CATEGORY = '-'
    AND CASE WHEN COF31.CLAIM_STATUS = 'S'  THEN 0 ELSE 1 END = 1 	--#ver4.0
    ;
	RETURN 	V_TOTAL_POWERCUT_CLAIMS;
END COUNT_CLAIM_FOR_POWERCUT;
--ADDITION ON 02/03/2020 ENDED

--#ver1.9
--ADDED ON 28/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR COVID-19 CORONAVIRUS REASON
FUNCTION COUNT_CLAIM_FOR_CORONAVIRUS (
	IN_UAN IN NUMBER
)
RETURN NUMBER
AS
  V_TOTAL_CORONAVIRUS_CLAIMS NUMBER(2):=0;
BEGIN	
	SELECT
		COUNT(1)
	INTO
		V_TOTAL_CORONAVIRUS_CLAIMS
	FROM
        CEN_OCS_FORM_31 COF31
--		OCS_CLAIM_DATA OCD
--	INNER JOIN OCS_CRD OCRD
--		ON OCD.TRACKING_ID = OCRD.TRACKING_ID
	WHERE
		COF31.UAN = IN_UAN			
--    AND OCRD.CLAIM_STATUS = 5
    -- AND OCRD.CLAIM_STATUS <> 4 --COMMENTED FOR --#ver2.9
--		AND OCRD.CLAIM_STATUS NOT IN (4,6,7) --#ver2.9 --COMMENTED FOR --#ver3.2
--		AND OCRD.CLAIM_STATUS NOT IN (4,5,6,7) --#ver3.2
    		AND COF31.CLAIM_STATUS NOT IN ('R')	 --#ver4.0  --#ver4.16
		AND COF31.CLAIM_FORM_TYPE = '06'
--		AND OCD.PDB_UPDATE_FLAG = 'Y'
		AND COF31.PARA_CODE = '8'
		AND COF31.SUB_PARA_CODE = '13'
		AND COF31.SUB_PARA_CATEGORY = '3'
    AND CASE WHEN COF31.CLAIM_STATUS = 'S'  THEN 0 ELSE 1 END = 1 	--#ver4.0
    ;
	RETURN 	V_TOTAL_CORONAVIRUS_CLAIMS;
END COUNT_CLAIM_FOR_CORONAVIRUS;
--ADDITION ON 28/03/2020 ENDED

--#ver4.0
--ADDED ON 26/06/2020 TO ALLOW ONLY ONE ADVANCE FOR ILLNESS IN 30 DAYS
FUNCTION COUNT_ILLNESS_ADVNCE_IN_30DAYS (
	IN_UAN IN NUMBER
)
RETURN NUMBER
AS
  V_TOTAL_ILLNESS_CLAIMS NUMBER(2):=0;
BEGIN	
	SELECT
		COUNT(1)
	INTO
		V_TOTAL_ILLNESS_CLAIMS
	FROM
        CEN_OCS_FORM_31 COF31
--		OCS_CLAIM_DATA OCD
--	INNER JOIN OCS_CRD OCRD
--		ON OCD.TRACKING_ID = OCRD.TRACKING_ID
	WHERE
		COF31.UAN = IN_UAN			
--    AND OCRD.CLAIM_STATUS = 5
    		AND COF31.CLAIM_STATUS NOT IN ('R')  --#ver4.16
		AND COF31.CLAIM_FORM_TYPE = '06'
--		AND OCD.PDB_UPDATE_FLAG = 'Y' --COMMENTED ON 20/04/2020
		AND COF31.PARA_CODE = '5'
		AND COF31.SUB_PARA_CODE = '11'
		AND COF31.SUB_PARA_CATEGORY = '-'
    AND CASE WHEN COF31.CLAIM_STATUS = 'S'  THEN 0 ELSE 1 END = 1
    AND COF31.RECEIPT_DATE >= SYSDATE-30
    ;
	RETURN 	V_TOTAL_ILLNESS_CLAIMS;
END COUNT_ILLNESS_ADVNCE_IN_30DAYS;
--ADDITION ON 26/06/2020 ENDED

--************************SAVE_OCS_CLAIM_DATA****************************BY PANKAJ KUMAR
PROCEDURE SAVE_OCS_CLAIM_DATA(
      T_OFFICE_ID                     IN CEN_OCS_FORM_19.OFFICE_ID%TYPE ,
      T_TRACKING_ID                   IN CEN_OCS_FORM_19.TRACKING_ID%TYPE ,
      T_UAN                           IN CEN_OCS_FORM_19.UAN%TYPE ,
      T_MEMBER_ID                     IN CEN_OCS_FORM_19.MEMBER_ID%TYPE ,
      T_MEMBER_NAME                   IN CEN_OCS_FORM_19.MEMBER_NAME%TYPE ,
      T_FATHER_SPOUSE_NAME            IN CEN_OCS_FORM_19.FATHER_SPOUSE_NAME%TYPE ,
      T_CLAIM_FORM_TYPE               IN CEN_OCS_FORM_19.CLAIM_FORM_TYPE%TYPE ,
      T_RECEIPT_DATE                  IN CEN_OCS_FORM_19.RECEIPT_DATE%TYPE ,
      T_ESTABLISHMENT_ID              IN CEN_OCS_FORM_19.ESTABLISHMENT_ID%TYPE ,
      T_FLAG_FS                       IN CEN_OCS_FORM_19.FLAG_FS%TYPE ,
      T_PAN                           IN CEN_OCS_FORM_19.PAN%TYPE ,
      T_AADHAAR                       IN CEN_OCS_FORM_19.AADHAAR%TYPE ,
      T_MOBILE                        IN CEN_OCS_FORM_19.MOBILE%TYPE ,
      T_EMAIL_ID                      IN CEN_OCS_FORM_19.EMAIL_ID%TYPE ,
      T_GENDER                        IN CEN_OCS_FORM_19.GENDER%TYPE ,
      T_DOB                           IN CEN_OCS_FORM_19.DOB%TYPE ,
      T_DOJ_EPF                       IN CEN_OCS_FORM_19.DOJ_EPF%TYPE ,
      T_DOJ_EPS                       IN CEN_OCS_FORM_19.DOJ_EPS%TYPE ,
      T_DOE_EPF                       IN CEN_OCS_FORM_19.DOE_EPF%TYPE ,
      T_DOE_EPS                       IN CEN_OCS_FORM_19.DOE_EPS%TYPE ,
      T_REASON_EXIT                   IN CEN_OCS_FORM_19.REASON_EXIT%TYPE ,
      T_PARA_CODE                     IN CEN_OCS_FORM_19.PARA_CODE%TYPE ,
      T_SUB_PARA_CODE                 IN CEN_OCS_FORM_19.SUB_PARA_CODE%TYPE ,
      T_SUB_PARA_CATEGORY             IN CEN_OCS_FORM_19.SUB_PARA_CATEGORY%TYPE ,
      T_ADV_AMOUNT                    IN CEN_OCS_FORM_31.ADV_AMOUNT%TYPE ,
      T_BANK_ACC_NO                   IN CEN_OCS_FORM_19.BANK_ACC_NO%TYPE ,
      T_IFSC_CODE                     IN CEN_OCS_FORM_19.IFSC_CODE%TYPE ,
      T_CLAIM_SOURCE_FLAG             IN CEN_OCS_FORM_19.CLAIM_SOURCE_FLAG%TYPE ,
      T_ADDRESS1                      IN CEN_OCS_FORM_19.ADDRESS1%TYPE ,
      T_ADDRESS2                      IN CEN_OCS_FORM_19.ADDRESS2%TYPE ,
      T_ADDRESS_CITY                  IN CEN_OCS_FORM_19.ADDRESS_CITY%TYPE ,
      T_ADDRESS_DIST                  IN CEN_OCS_FORM_19.ADDRESS_DIST%TYPE ,
      T_ADDRESS_STATE                 IN CEN_OCS_FORM_19.ADDRESS_STATE%TYPE ,
      T_ADDRESS_PIN                   IN CEN_OCS_FORM_19.ADDRESS_PIN%TYPE ,
      T_AGENCY_EMPLOYER_FLAG          IN CEN_OCS_FORM_31.AGENCY_EMPLOYER_FLAG%TYPE ,
      T_AGENCY_NAME                   IN CEN_OCS_FORM_31.AGENCY_NAME%TYPE ,
      T_AGENCY_ADDRESS                IN CEN_OCS_FORM_31.AGENCY_ADDRESS%TYPE ,
      T_AGENCY_ADDRESS_CITY           IN CEN_OCS_FORM_31.AGENCY_ADDRESS_CITY%TYPE ,
      T_AGENCY_ADDERSS_DIST           IN CEN_OCS_FORM_31.AGENCY_ADDERSS_DIST%TYPE ,
      T_AGENCY_ADDRESS_STATE          IN CEN_OCS_FORM_31.AGENCY_ADDRESS_STATE%TYPE,
      T_AGENCY_ADDRESS_PIN            IN CEN_OCS_FORM_31.AGENCY_ADDRESS_PIN%TYPE,
      T_FLAG_15GH                     IN CEN_OCS_FORM_19.FLAG_15GH%TYPE ,
      T_PDF_15GH                      IN CEN_OCS_FORM_19.PDF_15GH%TYPE,
      T_TDS_15GH                      IN CEN_OCS_FORM_19.TDS_15GH%TYPE ,
--      T_CANCEL_CHEQUE               IN CEN_OCS_FORM_19.CANCEL_CHEQUE%TYPE ,
      T_ADV_ENCLOSURE                 IN CEN_OCS_FORM_31.ADV_ENCLOSURE%TYPE ,
      T_IP_ADDRESS                    IN CEN_OCS_FORM_19.IP_ADDRESS%TYPE ,
      --ADDED BY AKSHAY FOR 10D 
      IN_CLAIM_BY                     IN CEN_OCS_FORM_19.CLAIM_BY%TYPE,
      IN_PENSION_TYPE                 IN CEN_OCS_FORM_10D.PENSION_TYPE%TYPE ,
      IN_OPTED_REDUCED_PENSION        IN NUMBER ,
      IN_OPTED_DATE                   IN VARCHAR2,
      IN_PPO_DETAILS                  IN VARCHAR2 ,
      IN_SCHEME_CERTIFICATE           IN VARCHAR2 ,
      IN_DEFERRED_PENSION             IN CHAR ,
      IN_DEFERRED_PENSION_AGE         IN NUMBER ,
      IN_DEFERRED_PENSION_CONT        IN VARCHAR2 ,
      IN_MARITAL_STATUS               IN VARCHAR2,
      IN_NOMINATION_ID                IN NUMBER,
      IN_BANK_ID                      IN NUMBER,
      IN_MEMBER_PHOTOGRAPH            IN BLOB,
      --ADDITION BY AKSHAY FOR 10D ENDED
--      IN_CANCEL_CHEQUE_PATH IN VARCHAR2,  --ADDED BY AKSHAY ON 09/08/2019 TO STORE PHYSICAL LOCATION OF UPLOADED CANCELLED CHEQUE
      IN_APPLICATION_TYPE IN VARCHAR2,	--#ver4.6
      IN_WITHDRAWAL_REASON IN VARCHAR2,  --ADDED ON 28/09/2020 --#ver4.21
      IN_AADHAAR_CONSENT_STATUS IN CHAR, --#ver4.22
      IN_AADHAAR_CONSENT_REF_ID IN NUMBER,--#ver4.22
      ----- IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH STARTS HERE ADDED ON 18/09/2020
      IN_3RDPARTY_NAME     IN VARCHAR2  DEFAULT NULL,
      IN_3RDPARTY_BANK_ACCNO IN VARCHAR2 DEFAULT NULL,
      IN_3RDPARTY_BANK_IFSC  IN VARCHAR2 DEFAULT NULL,
      IN_AUTH_LETTER_FILE_PATH IN VARCHAR2 DEFAULT NULL,
      ------ IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH ENDS HERE
--Yash Patidar Edits HERE
	  IN_BANK_NAME 					IN CEN_OCS_FORM_10_C.BANK_NAME%TYPE,
	  IN_BRANCH_NAME 				IN CEN_OCS_FORM_10_C.BRANCH_NAME%TYPE,
	  IN_NOMINATION_FAMILY_ID 		IN CEN_OCS_FORM_10_C.NOMINATION_FAMILY_ID%TYPE,
	  IN_NOMINEE_NAME 				IN CEN_OCS_FORM_10_C.NOMINEE_NAME%TYPE,
	  IN_NOMINEE_DOB				IN CEN_OCS_FORM_10_C.NOMINEE_DOB%TYPE,
	  IN_NOMINEE_GENDER				IN CEN_OCS_FORM_10_C.NOMINEE_GENDER%TYPE,
	  IN_NOMINEE_AADHAAR			IN CEN_OCS_FORM_10_C.NOMINEE_AADHAAR_NO%TYPE,
	  IN_NOMINEE_RELATION			IN CEN_OCS_FORM_10_C.NOMINEE_RELATION%TYPE,
	  IN_NOMINEE_RELATION_OTHER		IN CEN_OCS_FORM_10_C.NOMINEE_RELATION_OTHER%TYPE,
	  IN_NOMINEE_ADDRESS			IN CEN_OCS_FORM_10D.NOMINEE_ADDRESS%TYPE,
	  IN_IS_MINOR_NOMINEE			IN CEN_OCS_FORM_10_C.IS_MINOR_NOMINEE%TYPE,
	  IN_IS_LUNATIC					IN CEN_OCS_FORM_10_C.IS_LUNATIC%TYPE,
	  IN_NOM_SHARE_IN_PERCENT 		IN CEN_OCS_FORM_10_C.NOM_SHARE_IN_PERCENT%TYPE,
	  IN_GUARDIAN_NAME 				IN CEN_OCS_FORM_10_C.GUARDIAN_NAME%TYPE,
	  IN_GUARDIAN_RELATION 			IN CEN_OCS_FORM_10_C.GUARDIAN_RELATION%TYPE,
	  IN_GUARDIAN_ADDRESS 			IN CEN_OCS_FORM_10_C.GUARDIAN_ADDRESS%TYPE,
	  IN_NOM_ADDRESS1				IN CEN_OCS_FORM_10_C.NOM_ADDRESS1%TYPE,
	  IN_NOM_ADDRESS2				IN CEN_OCS_FORM_10_C.NOM_ADDRESS2%TYPE,
	  IN_NOM_CITY					IN CEN_OCS_FORM_10_C.NOM_CITY%TYPE,
	  IN_NOM_DISTRICT				IN CEN_OCS_FORM_10_C.NOM_DISTRICT%TYPE,
	  IN_NOM_STATE					IN CEN_OCS_FORM_10_C.NOM_STATE%TYPE,
	  IN_NOM_DISTRICT_ID			IN CEN_OCS_FORM_10_C.NOM_DISTRICT_ID%TYPE,
	  IN_NOM_STATE_ID				IN CEN_OCS_FORM_10_C.NOM_STATE_ID%TYPE,
	  IN_NOM_PIN					IN CEN_OCS_FORM_10_C.NOM_PIN%TYPE,	  
	  IN_OFFICE_NAME				IN CEN_OCS_FORM_10_C.OFFICE_NAME%TYPE,
	  IN_ADDRESS_OF_OFFICE			IN CEN_OCS_FORM_10D.ADDRESS_OF_OFFICE%TYPE,
	  IN_PINCODE_OF_OFFICE			IN CEN_OCS_FORM_10D.PINCODE_OF_OFFICE%TYPE,
	  IN_IS_WIDTHRAWAL_BENFIT_REQ	IN CEN_OCS_FORM_10_C.IS_WIDTHRAWAL_BENFIT_REQ%TYPE,
	  IN_IS_WIDTHRAWAL_BENFIT_TAKEN	IN CEN_OCS_FORM_10_C.IS_WIDTHRAWAL_BENFIT_TAKEN%TYPE,
    STATUS OUT NUMBER,
    OUTPUT OUT VARCHAR2 )
AS
  V_COUNT NUMBER;
  VMODULE VARCHAR(200);
  V_CLAIM_STATUS VARCHAR2(2 BYTE);
  V_CLAIM_MODE CHAR(1 BYTE);
  V_CLAIM_BY CHAR(1 BYTE);
  V_MARITAL_STATUS CHAR(1 BYTE);
  V_NOMINATION_ID NUMBER(12,0);
  V_LATEST_APPROVAL_STATUS VARCHAR2(2 BYTE);
  V_EST_SL_NO NUMBER(10,0);
  V_MEM_SYS_ID NUMBER(8,0);
  V_AADHAAR_OTP_VRFC_STAT CHAR(1 BYTE);
  V_AADHAAR_DEMO_VRFC_STAT CHAR(1 BYTE);
  V_AADHAAR_BIO_VRFC_STAT CHAR(1 BYTE);
  V_AADHAAR_VRFC_STATUS CHAR(1 BYTE);
  V_BANK_ID NUMBER(4,0);
  V_BANK_NAME VARCHAR2(128);
  V_CRITERIA_ID NUMBER;
  V_CRITERIA_FLOW_ID NUMBER;
  
BEGIN
LOG_ERROR('INSIDE SAVE_OCS_CLAIM_DATA :','BY YASH');
  STATUS :=0;
  OUTPUT :='';
  V_COUNT:=0;
  V_CLAIM_STATUS:='N';
  V_CLAIM_MODE:='O';
  V_CLAIM_BY:='M';
  V_MARITAL_STATUS:='';
  V_NOMINATION_ID:=0;
  V_LATEST_APPROVAL_STATUS:='NC';
  V_EST_SL_NO:=0;
  V_MEM_SYS_ID:=0;
  V_AADHAAR_OTP_VRFC_STAT:='';
  V_AADHAAR_DEMO_VRFC_STAT:='';
  V_AADHAAR_BIO_VRFC_STAT:='';
  V_AADHAAR_VRFC_STATUS:='';
  V_BANK_NAME:= '';
  
    SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = T_UAN AND STATUS ='E';
    SELECT MARITAL_STATUS INTO V_MARITAL_STATUS FROM UAN_REPOSITORY WHERE UAN = T_UAN;
    SELECT EST_SLNO,ID INTO V_EST_SL_NO,V_MEM_SYS_ID FROM MEMBER WHERE MEMBER_ID = T_MEMBER_ID;
    SELECT AADHAAR_OTP_VERIFICATION_STAT,AADHAAR_DEMO_VERIFICATION_STAT,AADHAAR_BIO_VERIFICATION_STAT 
    INTO V_AADHAAR_OTP_VRFC_STAT,V_AADHAAR_DEMO_VRFC_STAT,V_AADHAAR_BIO_VRFC_STAT
    FROM UAN_REPOSITORY
    WHERE UAN = T_UAN;
    IF V_AADHAAR_OTP_VRFC_STAT='S' OR V_AADHAAR_DEMO_VRFC_STAT='S' OR V_AADHAAR_BIO_VRFC_STAT='S' THEN
     V_AADHAAR_VRFC_STATUS:='S';
    END IF;
--    SELECT BANK_ID INTO V_BANK_ID FROM BANK_IFSC WHERE IFSC_CODE=T_IFSC_CODE; 
--    SELECT NAME, ID INTO V_BANK_NAME, V_BANK_ID FROM BANK WHERE ID = (SELECT BANK_ID FROM BANK_IFSC WHERE IFSC_CODE=T_IFSC_CODE);
     SELECT BANK_NAME, BANK_CODE INTO V_BANK_NAME, V_BANK_ID FROM CPPS_BANK WHERE IFS_CODE = T_IFSC_CODE;
--     SELECT CBK.BANK_NAME, CBK.BANK_CODE, CBH.BRANCH_NAME, CBH.BRANCH_ADDRESS, CBH.STATE_ID  INTO V_BANK_NAME, V_BANK_ID, V_BRANCH_NAME, V_BRANCH_ADDRESS, V_STATE
--     FROM CPPS_BANK CBK 
--      INNER JOIN CPPS_BRANCH CBH 
--      ON CBK.BANK_CODE = CBH.BANK_CODE 
--     WHERE CBK.IFS_CODE = CBH.IFSC_CODE;

--    IF T_CLAIM_FORM_TYPE = '04' THEN
--      BEGIN
--        SELECT NAME INTO V_BANK_NAME FROM BANK WHERE ID = V_BANK_ID;
--      END;
--    END IF;
-- IF T_CLAIM_FORM_TYPE = '06' THEN
--    CEN_OCS_NEW_PACKAGE.GET_CRITERIA(T_ADV_AMOUNT,T_CLAIM_FORM_TYPE,V_CRITERIA_ID,V_CRITERIA_FLOW_ID);
--    END IF;

  VMODULE:='OCS_NEW_PACKAGE.SAVE_OCS_CLAIM_DATA';
  BEGIN
  IF T_CLAIM_FORM_TYPE = '01' THEN
    LOG_ERROR('SAVE_CEN_OCS_FORM_19: SAVING DATA IN TABLE:',
    'T_OFFICE_ID:'||T_OFFICE_ID||'#~#'||
    'T_TRACKING_ID:'||T_TRACKING_ID||'#~#'||
    'T_UAN:'||T_UAN||'#~#'||
    'T_MEMBER_ID:'||T_MEMBER_ID||'#~#'||
    'T_MEMBER_NAME:'||T_MEMBER_NAME||'#~#'||
    'T_FATHER_SPOUSE_NAME:'||T_FATHER_SPOUSE_NAME||'#~#'||
    'T_CLAIM_FORM_TYPE:'||T_CLAIM_FORM_TYPE||'#~#'||
    'T_RECEIPT_DATE:'||to_char(T_RECEIPT_DATE)||'#~#'||
    'T_ESTABLISHMENT_ID:'||T_ESTABLISHMENT_ID||'#~#'||
    'T_FLAG_FS:'||T_FLAG_FS||'#~#'||
    'T_PAN:'||T_PAN||'#~#'||
    'T_AADHAAR:'||T_AADHAAR||'#~#'||
    'T_MOBILE:'||T_MOBILE||'#~#'||
    'T_EMAIL_ID:'||T_EMAIL_ID||'#~#'||
    'T_GENDER:'||T_GENDER||'#~#'||
    'T_DOB:'||to_char(T_DOB)||'#~#'||
    'T_DOJ_EPF:'||TO_CHAR(T_DOJ_EPF)||'#~#'||
    'T_DOJ_EPS:'||TO_CHAR(T_DOJ_EPS)||'#~#'||
    'T_DOE_EPF:'||TO_CHAR(T_DOE_EPF)||'#~#'||
    'T_DOE_EPS:'||TO_CHAR(T_DOE_EPS)||'#~#'||
    'T_REASON_EXIT:'||T_REASON_EXIT||'#~#'||
    'T_PARA_CODE:'||T_PARA_CODE||'#~#'||
    'T_SUB_PARA_CODE:'||T_SUB_PARA_CODE||'#~#'||
    'T_SUB_PARA_CATEGORY:'||T_SUB_PARA_CATEGORY||'#~#'||
    'T_ADV_AMOUNT:'||T_ADV_AMOUNT||'#~#'||
    'T_BANK_ACC_NO:'||T_BANK_ACC_NO||'#~#'||
    'T_IFSC_CODE:'||T_IFSC_CODE||'#~#'||
    'T_CLAIM_SOURCE_FLAG:'||T_CLAIM_SOURCE_FLAG||'#~#'||
    'T_ADDRESS1:'||T_ADDRESS1||'#~#'||
    'T_ADDRESS2:'||T_ADDRESS2||'#~#'||
    'T_ADDRESS_CITY:'||T_ADDRESS_CITY||'#~#'||
    'T_ADDRESS_DIST:'||T_ADDRESS_DIST||'#~#'||
    'T_ADDRESS_STATE:'||T_ADDRESS_STATE||'#~#'||
    'T_ADDRESS_PIN:'||T_ADDRESS_PIN||'#~#'||
    'T_AGENCY_EMPLOYER_FLAG:'||T_AGENCY_EMPLOYER_FLAG||'#~#'||
    'T_AGENCY_NAME:'||T_AGENCY_NAME||'#~#'||
    'T_AGENCY_ADDRESS:'||T_AGENCY_ADDRESS||'#~#'||
    'T_AGENCY_ADDRESS_CITY:'||T_AGENCY_ADDRESS_CITY||'#~#'||
    'T_AGENCY_ADDERSS_DIST:'||T_AGENCY_ADDERSS_DIST||'#~#'||
    'T_AGENCY_ADDRESS_STATE:'||T_AGENCY_ADDRESS_STATE||'#~#'||
    'T_AGENCY_ADDRESS_PIN:'||T_AGENCY_ADDRESS_PIN||'#~#'||
    'T_FLAG_15GH:'||T_FLAG_15GH||'#~#'||
    'T_PDF_15GH:'||T_PDF_15GH||'#~#'|| 
    'T_TDS_15GH:'||T_TDS_15GH||'#~#'||
--    'T_CANCEL_CHEQUE:'|| CASE WHEN T_CANCEL_CHEQUE IS NULL THEN 'NOT AVAILABLE' ELSE 'AVAILABLE' END ||'#~#'||
    'T_ADV_ENCLOSURE:'||T_ADV_ENCLOSURE||'#~#'||
    'T_IP_ADDRESS:'||T_IP_ADDRESS||'#~#'||
    'IN_CLAIM_BY:'||IN_CLAIM_BY||'#~#'||
    'IN_PENSION_TYPE:'||IN_PENSION_TYPE||'#~#'||
    'IN_OPTED_REDUCED_PENSION:'||IN_OPTED_REDUCED_PENSION||'#~#'||
    'IN_OPTED_DATE:'||IN_OPTED_DATE||'#~#'||
    'IN_PPO_DETAILS:'||IN_PPO_DETAILS||'#~#'||
    'IN_SCHEME_CERTIFICATE:'||IN_SCHEME_CERTIFICATE||'#~#'||
    'IN_DEFERRED_PENSION:'||IN_DEFERRED_PENSION||'#~#'||
    'IN_DEFERRED_PENSION_AGE:'||IN_DEFERRED_PENSION_AGE||'#~#'||
    'IN_DEFERRED_PENSION_CONT:'||IN_DEFERRED_PENSION_CONT||'#~#'||
    'IN_MARITAL_STATUS:'||IN_MARITAL_STATUS||'#~#'||
    'IN_NOMINATION_ID:'||IN_NOMINATION_ID||'#~#'||
--    'IN_BANK_ID:'||IN_BANK_ID||'#~#'||
    'IN_BANK_ID:'||IN_BANK_ID||'#~#'||
--    'IN_CANCEL_CHEQUE_PATH: '||IN_CANCEL_CHEQUE_PATH
    'AADHAAR_VERIFICATION_STATUS:'||V_AADHAAR_VRFC_STATUS||'#~#'||
    'CRITERIA_ID:'||V_CRITERIA_ID||'#~#'||
    'CRITERIA_FLOW_ID:'||V_CRITERIA_FLOW_ID
    );
  END IF; 
  CASE T_CLAIM_FORM_TYPE 
    WHEN '01' THEN
      INSERT INTO CEN_OCS_FORM_19
      (
          OFFICE_ID,
          TRACKING_ID,
          UAN,
          MEMBER_ID,
          MEMBER_NAME,
          FATHER_SPOUSE_NAME,
          CLAIM_FORM_TYPE,
          RECEIPT_DATE,
          ESTABLISHMENT_ID,
          FLAG_FS,
          PAN,
          AADHAAR,
          MOBILE,
          EMAIL_ID,
          GENDER,
          DOB,
          DOJ_EPF,
          DOJ_EPS,
          DOE_EPF,
          DOE_EPS,
          REASON_EXIT,
          PARA_CODE,
          SUB_PARA_CODE,
          SUB_PARA_CATEGORY,
          BANK_ACC_NO,
          IFSC_CODE,
          CLAIM_SOURCE_FLAG,
          ADDRESS1,
          ADDRESS2,
          ADDRESS_CITY,
          ADDRESS_DIST,
          ADDRESS_STATE,
          ADDRESS_PIN,
          FLAG_15GH,
          TDS_15GH,
          IP_ADDRESS,
          AADHAAR_CONSENT_STATUS,
          AADHAAR_CONSENT_REF_ID,
          CLAIM_STATUS, 
          CLAIM_MODE,
          CLAIM_BY,
          MARITAL_STATUS, 
          NOMINATION_ID, 
          LATEST_APPROVAL_STATUS,
          BANK_ID,
          EST_SL_NO,
          MEM_SYS_ID,
          SCHEME_CODE,
          AADHAAR_VERIFICATION_STATUS,
          PDF_15GH,
          CRITERIA_ID,
          CRITERIA_FLOW_ID,
          NEXT_USER_ID,
          PROCESS_ID,
          PROCESS_GROUP_ID
    )
    VALUES
    (
          T_OFFICE_ID,
          T_TRACKING_ID,
          T_UAN,
          T_MEMBER_ID,
          T_MEMBER_NAME,
          T_FATHER_SPOUSE_NAME,
          T_CLAIM_FORM_TYPE,
          SYSDATE,
          T_ESTABLISHMENT_ID,
          T_FLAG_FS,
          T_PAN,
          T_AADHAAR,
          T_MOBILE,
          T_EMAIL_ID,
          T_GENDER,
          T_DOB,
          T_DOJ_EPF,
          T_DOJ_EPS,
          T_DOE_EPF,
          T_DOE_EPS,
          T_REASON_EXIT,
          T_PARA_CODE,
          T_SUB_PARA_CODE,
          T_SUB_PARA_CATEGORY,
          T_BANK_ACC_NO, 
          T_IFSC_CODE,       
          T_CLAIM_SOURCE_FLAG,
          T_ADDRESS1,
          T_ADDRESS2,
          T_ADDRESS_CITY,
          T_ADDRESS_DIST,
          T_ADDRESS_STATE,
          T_ADDRESS_PIN,
          T_FLAG_15GH,
          T_TDS_15GH,
          T_IP_ADDRESS,
          IN_AADHAAR_CONSENT_STATUS,
          IN_AADHAAR_CONSENT_REF_ID,
          V_CLAIM_STATUS, 
          V_CLAIM_MODE,
          V_CLAIM_BY,
          V_MARITAL_STATUS, 
          V_NOMINATION_ID, 
          V_LATEST_APPROVAL_STATUS,
          V_BANK_ID,
          V_EST_SL_NO,
          V_MEM_SYS_ID,
          'EPF',
          V_AADHAAR_VRFC_STATUS,
          T_PDF_15GH,
          '170',
          '19',
          '0',
          '113',
          '1'
    );
    
IF T_CLAIM_FORM_TYPE = '06' THEN
    LOG_ERROR('SAVE_CEN_OCS_FORM_31: SAVING DATA IN TABLE:',
    'T_OFFICE_ID:'||T_OFFICE_ID||'#~#'||
    'T_TRACKING_ID:'||T_TRACKING_ID||'#~#'||
    'T_UAN:'||T_UAN||'#~#'||
    'T_MEMBER_ID:'||T_MEMBER_ID||'#~#'||
    'T_MEMBER_NAME:'||T_MEMBER_NAME||'#~#'||
    'T_FATHER_SPOUSE_NAME:'||T_FATHER_SPOUSE_NAME||'#~#'||
    'T_CLAIM_FORM_TYPE:'||T_CLAIM_FORM_TYPE||'#~#'||
    'T_RECEIPT_DATE:'||to_char(T_RECEIPT_DATE)||'#~#'||
    'T_ESTABLISHMENT_ID:'||T_ESTABLISHMENT_ID||'#~#'||
    'T_FLAG_FS:'||T_FLAG_FS||'#~#'||
    'T_PAN:'||T_PAN||'#~#'||
    'T_AADHAAR:'||T_AADHAAR||'#~#'||
    'T_MOBILE:'||T_MOBILE||'#~#'||
    'T_EMAIL_ID:'||T_EMAIL_ID||'#~#'||
    'T_GENDER:'||T_GENDER||'#~#'||
    'T_DOB:'||to_char(T_DOB)||'#~#'||
    'T_DOJ_EPF:'||TO_CHAR(T_DOJ_EPF)||'#~#'||
    'T_DOJ_EPS:'||TO_CHAR(T_DOJ_EPS)||'#~#'||
    'T_DOE_EPF:'||TO_CHAR(T_DOE_EPF)||'#~#'||
    'T_DOE_EPS:'||TO_CHAR(T_DOE_EPS)||'#~#'||
    'T_REASON_EXIT:'||T_REASON_EXIT||'#~#'||
    'T_PARA_CODE:'||T_PARA_CODE||'#~#'||
    'T_SUB_PARA_CODE:'||T_SUB_PARA_CODE||'#~#'||
    'T_SUB_PARA_CATEGORY:'||T_SUB_PARA_CATEGORY||'#~#'||
    'T_ADV_AMOUNT:'||T_ADV_AMOUNT||'#~#'||
    'T_BANK_ACC_NO:'||T_BANK_ACC_NO||'#~#'||
    'T_IFSC_CODE:'||T_IFSC_CODE||'#~#'||
    'T_CLAIM_SOURCE_FLAG:'||T_CLAIM_SOURCE_FLAG||'#~#'||
    'T_ADDRESS1:'||T_ADDRESS1||'#~#'||
    'T_ADDRESS2:'||T_ADDRESS2||'#~#'||
    'T_ADDRESS_CITY:'||T_ADDRESS_CITY||'#~#'||
    'T_ADDRESS_DIST:'||T_ADDRESS_DIST||'#~#'||
    'T_ADDRESS_STATE:'||T_ADDRESS_STATE||'#~#'||
    'T_ADDRESS_PIN:'||T_ADDRESS_PIN||'#~#'||
    'T_AGENCY_EMPLOYER_FLAG:'||T_AGENCY_EMPLOYER_FLAG||'#~#'||
    'T_AGENCY_NAME:'||T_AGENCY_NAME||'#~#'||
    'T_AGENCY_ADDRESS:'||T_AGENCY_ADDRESS||'#~#'||
    'T_AGENCY_ADDRESS_CITY:'||T_AGENCY_ADDRESS_CITY||'#~#'||
    'T_AGENCY_ADDERSS_DIST:'||T_AGENCY_ADDERSS_DIST||'#~#'||
    'T_AGENCY_ADDRESS_STATE:'||T_AGENCY_ADDRESS_STATE||'#~#'||
    'T_AGENCY_ADDRESS_PIN:'||T_AGENCY_ADDRESS_PIN||'#~#'||
    'T_FLAG_15GH:'||T_FLAG_15GH||'#~#'||
    'T_PDF_15GH:'||T_PDF_15GH||'#~#'|| 
    'T_TDS_15GH:'||T_TDS_15GH||'#~#'||
--    'T_CANCEL_CHEQUE:'|| CASE WHEN T_CANCEL_CHEQUE IS NULL THEN 'NOT AVAILABLE' ELSE 'AVAILABLE' END ||'#~#'||
    'T_ADV_ENCLOSURE:'||T_ADV_ENCLOSURE||'#~#'||
    'T_IP_ADDRESS:'||T_IP_ADDRESS||'#~#'||
    'IN_CLAIM_BY:'||IN_CLAIM_BY||'#~#'||
    'IN_PENSION_TYPE:'||IN_PENSION_TYPE||'#~#'||
    'IN_OPTED_REDUCED_PENSION:'||IN_OPTED_REDUCED_PENSION||'#~#'||
    'IN_OPTED_DATE:'||IN_OPTED_DATE||'#~#'||
    'IN_PPO_DETAILS:'||IN_PPO_DETAILS||'#~#'||
    'IN_SCHEME_CERTIFICATE:'||IN_SCHEME_CERTIFICATE||'#~#'||
    'IN_DEFERRED_PENSION:'||IN_DEFERRED_PENSION||'#~#'||
    'IN_DEFERRED_PENSION_AGE:'||IN_DEFERRED_PENSION_AGE||'#~#'||
    'IN_DEFERRED_PENSION_CONT:'||IN_DEFERRED_PENSION_CONT||'#~#'||
    'IN_MARITAL_STATUS:'||IN_MARITAL_STATUS||'#~#'||
    'IN_NOMINATION_ID:'||IN_NOMINATION_ID||'#~#'||
--    'IN_BANK_ID:'||IN_BANK_ID||'#~#'||
    'IN_BANK_ID:'||IN_BANK_ID||'#~#'||
--    'IN_CANCEL_CHEQUE_PATH: '||IN_CANCEL_CHEQUE_PATH
    'AADHAAR_VERIFICATION_STATUS:'||V_AADHAAR_VRFC_STATUS||'#~#'||
    'CRITERIA_ID:'||V_CRITERIA_ID||'#~#'||
    'CRITERIA_FLOW_ID:'||V_CRITERIA_FLOW_ID
    );
  END IF;
   WHEN '06' THEN
       INSERT INTO CEN_OCS_FORM_31
      (
          OFFICE_ID,
          TRACKING_ID,
          UAN,
          MEMBER_ID,
          MEMBER_NAME,
          FATHER_SPOUSE_NAME,
          CLAIM_FORM_TYPE,
          RECEIPT_DATE,
          ESTABLISHMENT_ID,
          FLAG_FS,
          PAN,
          AADHAAR,
          MOBILE,
          EMAIL_ID,
          GENDER,
          DOB,
          DOJ_EPF,
          DOJ_EPS,
          DOE_EPF,
          DOE_EPS,
          REASON_EXIT,
          PARA_CODE,
          SUB_PARA_CODE,
          SUB_PARA_CATEGORY,
          BANK_ACC_NO,
          IFSC_CODE,
          CLAIM_SOURCE_FLAG,
          ADDRESS1,
          ADDRESS2,
          ADDRESS_CITY,
          ADDRESS_DIST,
          ADDRESS_STATE,
          ADDRESS_PIN,
          IP_ADDRESS,
          AADHAAR_CONSENT_STATUS,
          AADHAAR_CONSENT_REF_ID,
          CLAIM_STATUS, 
          CLAIM_MODE,
          CLAIM_BY,
          MARITAL_STATUS, 
          NOMINATION_ID, 
          LATEST_APPROVAL_STATUS,
          BANK_ID,
          EST_SL_NO,
          MEM_SYS_ID,
          SCHEME_CODE,
          AADHAAR_VERIFICATION_STATUS,
          ADV_AMOUNT,
          CRITERIA_ID,
          CRITERIA_FLOW_ID,
          NEXT_USER_ID,
          PROCESS_ID,
          PROCESS_GROUP_ID
    )
    VALUES
    (
          T_OFFICE_ID,
          T_TRACKING_ID,
          T_UAN,
          T_MEMBER_ID,
          T_MEMBER_NAME,
          T_FATHER_SPOUSE_NAME,
          T_CLAIM_FORM_TYPE,
          SYSDATE,
          T_ESTABLISHMENT_ID,
          T_FLAG_FS,
          T_PAN,
          T_AADHAAR,
          T_MOBILE,
          T_EMAIL_ID,
          T_GENDER,
          T_DOB,
          T_DOJ_EPF,
          T_DOJ_EPS,
          T_DOE_EPF,
          T_DOE_EPS,
          T_REASON_EXIT,
          T_PARA_CODE,
          T_SUB_PARA_CODE,
          T_SUB_PARA_CATEGORY,
          case when IN_3RDPARTY_BANK_ACCNO is null then  T_BANK_ACC_NO else IN_3RDPARTY_BANK_ACCNO end, 
          case when IN_3RDPARTY_BANK_IFSC is null then T_IFSC_CODE else IN_3RDPARTY_BANK_IFSC end,       
          T_CLAIM_SOURCE_FLAG,
          T_ADDRESS1,
          T_ADDRESS2,
          T_ADDRESS_CITY,
          T_ADDRESS_DIST,
          T_ADDRESS_STATE,
          T_ADDRESS_PIN,
          T_IP_ADDRESS,
          IN_AADHAAR_CONSENT_STATUS,
          IN_AADHAAR_CONSENT_REF_ID,
          V_CLAIM_STATUS, 
          V_CLAIM_MODE,
          V_CLAIM_BY,
          V_MARITAL_STATUS, 
          V_NOMINATION_ID, 
          V_LATEST_APPROVAL_STATUS,
          V_BANK_ID,
          V_EST_SL_NO,
          V_MEM_SYS_ID,
          'EPF',
          V_AADHAAR_VRFC_STATUS,
          T_ADV_AMOUNT,
          '166',
          '15',
          '0',
          '112',
          '1'
    );
    
	
	WHEN '04' THEN 
      CEN_OCS_NEW_PACKAGE.GET_CRITERIA(T_ADV_AMOUNT,T_CLAIM_FORM_TYPE,V_CRITERIA_ID,V_CRITERIA_FLOW_ID);
      LOG_ERROR('INSIDE SAVE_OCS_CLAIM DATA : GET_CRITERIA CALLED : ','CRITERIA ID :'||V_CRITERIA_ID||' CRITERIA_FLOW_ID'||V_CRITERIA_FLOW_ID );
      LOG_ERROR('BEFORE CEN_OCS_10D INSERT: ', 
      T_TRACKING_ID|| ' ' || 
      T_UAN|| ' ' || 
      V_MEM_SYS_ID|| ' ' || 
      T_MEMBER_ID|| ' ' || 
      T_OFFICE_ID|| ' ' || 
      IN_OFFICE_NAME|| ' ' || 
      IN_ADDRESS_OF_OFFICE|| ' ' || 
      IN_PINCODE_OF_OFFICE|| ' ' || 
      T_CLAIM_FORM_TYPE|| ' ' || 
      T_MEMBER_NAME|| ' ' || 
      T_FATHER_SPOUSE_NAME|| ' ' || 
      T_FLAG_FS|| ' ' || 
      T_DOB|| ' ' || 
      T_GENDER|| ' ' || 
      V_MARITAL_STATUS|| ' ' || 
      T_AADHAAR|| ' ' || 
      T_MOBILE|| ' ' || 
      T_EMAIL_ID|| ' ' || 
      T_ADDRESS1|| ' ' || 
      T_ADDRESS2|| ' ' || 
      T_ADDRESS_CITY|| ' ' || 
      T_ADDRESS_DIST|| ' ' || 
      T_ADDRESS_STATE|| ' ' || 
      T_ADDRESS_PIN|| ' ' || 
      'EPS'|| ' ' || 
      T_PARA_CODE|| ' ' || 
      T_SUB_PARA_CODE|| ' ' || 
      T_SUB_PARA_CATEGORY|| ' ' || 
      T_FLAG_15GH|| ' ' || 
      T_TDS_15GH|| ' ' || 
      IN_NOMINATION_ID|| ' ' || 
      IN_NOMINATION_FAMILY_ID|| ' ' || 
      IN_NOMINEE_NAME|| ' ' || 
      IN_NOMINEE_DOB|| ' ' || 
      IN_NOMINEE_GENDER|| ' ' || 
      IN_NOMINEE_AADHAAR|| ' ' || 
      IN_NOMINEE_RELATION|| ' ' || 
      IN_NOMINEE_RELATION_OTHER|| ' ' || 
      IN_NOMINEE_ADDRESS|| ' ' || 
      IN_IS_MINOR_NOMINEE|| ' ' || 
      IN_IS_LUNATIC|| ' ' || 
      IN_NOM_SHARE_IN_PERCENT|| ' ' || 
      IN_GUARDIAN_NAME|| ' ' || 
      IN_GUARDIAN_RELATION|| ' ' || 
      IN_GUARDIAN_ADDRESS|| ' ' || 
      IN_NOM_ADDRESS1|| ' ' || 
      IN_NOM_ADDRESS2|| ' ' || 
      IN_NOM_CITY|| ' ' || 
      IN_NOM_DISTRICT|| ' ' || 
      IN_NOM_STATE|| ' ' || 
      IN_NOM_DISTRICT_ID|| ' ' || 
      IN_NOM_STATE_ID|| ' ' || 
      IN_NOM_PIN|| ' ' || 
      IN_BANK_ID|| ' ' || 
      IN_BANK_NAME|| ' ' || 
      IN_BRANCH_NAME|| ' ' || 
      T_IFSC_CODE|| ' ' || 
      T_BANK_ACC_NO|| ' ' || 
      V_AADHAAR_VRFC_STATUS || ' ' || 
      IN_AADHAAR_CONSENT_STATUS|| ' ' || 
      IN_AADHAAR_CONSENT_REF_ID|| ' ' || 
      IN_CLAIM_BY|| ' ' || 
      V_CLAIM_MODE|| ' ' || 
      IN_IS_WIDTHRAWAL_BENFIT_REQ|| ' ' || 
      IN_IS_WIDTHRAWAL_BENFIT_TAKEN|| ' ' || 
      T_CLAIM_SOURCE_FLAG|| ' ' || 
      T_DOJ_EPS|| ' ' || 
      T_DOE_EPS|| ' ' || 
      T_REASON_EXIT || ' ' || 
      SYSDATE|| ' ' || 
      V_CLAIM_STATUS);
      
		INSERT INTO UNIFIED_PORTAL.CEN_OCS_FORM_10_C( 
			TRACKING_ID,
			UAN,
            MEMBER_SYS_ID,
			MEMBER_ID,
			OFFICE_ID,
			OFFICE_NAME,
			CLAIM_FORM_TYPE,
			MEMBER_NAME,
			FAT_MOT_HUS_NAME,
			MEMBER_DOB,
			MEMBER_GENDER,
			MEMBER_MARITAL_STATUS,
			MEMBER_AADHAAR_NO,
			MOBILE,
			EMAIL_ID,
			MEMBER_ADDRESS1,
			MEMBER_ADDRESS2,
			MEMBER_CITY,
			MEMBER_DISTRICT,
			MEMBER_STATE,
			MEMBER_PIN,
            SCHEME_CODE,
			PARA_CODE,
			SUB_PARA_CODE,
			SUB_PARA_CATEGORY,
			NOMINATION_ID,
			NOMINATION_FAMILY_ID,
			NOMINEE_NAME,
			NOMINEE_DOB,
			NOMINEE_GENDER,
			NOMINEE_AADHAAR_NO,
			NOMINEE_RELATION,
			NOMINEE_RELATION_OTHER,
			IS_MINOR_NOMINEE,
			IS_LUNATIC,
			NOM_SHARE_IN_PERCENT,
			GUARDIAN_NAME,
			GUARDIAN_RELATION,
			GUARDIAN_ADDRESS,
			NOM_ADDRESS1,
			NOM_ADDRESS2,
			NOM_CITY,
			NOM_DISTRICT,
			NOM_STATE,
			NOM_DISTRICT_ID,
			NOM_STATE_ID,
			NOM_PIN,
			BANK_CODE,
			BANK_NAME,
			BRANCH_NAME,
			IFSC_CODE,
			BANK_ACC_NO,
			KYC_PDF_EXISTS,
            AADHAAR_VERIFICATION_STATUS,                             -- NOT DONE
			AADHAAR_CONSENT_STATUS,
			AADHAAR_CONSENT_REF_ID,
			CLAIM_BY,
			CLAIM_MODE,
			IS_WIDTHRAWAL_BENFIT_REQ,
			IS_WIDTHRAWAL_BENFIT_TAKEN,
			CLAIM_SOURCE_FLAG,
			DOJ_EPS95,
			DOE_EPS95,
			REASON_OF_EXIT,
			DATE_OF_ATTAINING_58YRS,
            CRITERIA_ID,
			RECEIPT_DATE,
			CLAIM_STATUS,
            CRITERIA_FLOW_ID,
            FORM_10C_APPLICATION_TYPE,
            ESTABLISHMENT_ID
			)
			VALUES (
			T_TRACKING_ID,
			T_UAN,
            V_MEM_SYS_ID,
			T_MEMBER_ID,
			T_OFFICE_ID,
			IN_OFFICE_NAME,
			T_CLAIM_FORM_TYPE,
			T_MEMBER_NAME,
			T_FATHER_SPOUSE_NAME,
			T_DOB,
			T_GENDER,
			V_MARITAL_STATUS,
			T_AADHAAR,
			T_MOBILE,
			T_EMAIL_ID,
			T_ADDRESS1,
			T_ADDRESS2,
			T_ADDRESS_CITY,
			T_ADDRESS_DIST,
			T_ADDRESS_STATE,
			T_ADDRESS_PIN,
            'EPS',
			T_PARA_CODE,
			T_SUB_PARA_CODE,
			T_SUB_PARA_CATEGORY,
			IN_NOMINATION_ID,
			IN_NOMINATION_FAMILY_ID,
			IN_NOMINEE_NAME,
			IN_NOMINEE_DOB,
			IN_NOMINEE_GENDER,
			IN_NOMINEE_AADHAAR,
			IN_NOMINEE_RELATION,
			IN_NOMINEE_RELATION_OTHER,
			IN_IS_MINOR_NOMINEE,
			IN_IS_LUNATIC,
			IN_NOM_SHARE_IN_PERCENT,
			IN_GUARDIAN_NAME,
			IN_GUARDIAN_RELATION,
			IN_GUARDIAN_ADDRESS,
			IN_NOM_ADDRESS1,
			IN_NOM_ADDRESS2,
			IN_NOM_CITY,
			IN_NOM_DISTRICT,
			IN_NOM_STATE,
			IN_NOM_DISTRICT_ID,
			IN_NOM_STATE_ID,
			IN_NOM_PIN,
			IN_BANK_ID,
			IN_BANK_NAME,
			IN_BRANCH_NAME,
			T_IFSC_CODE,
			T_BANK_ACC_NO,
			'',
            V_AADHAAR_VRFC_STATUS,
			IN_AADHAAR_CONSENT_STATUS,
			IN_AADHAAR_CONSENT_REF_ID,
			IN_CLAIM_BY,
			V_CLAIM_MODE,
			IN_IS_WIDTHRAWAL_BENFIT_REQ,
            IN_IS_WIDTHRAWAL_BENFIT_TAKEN,
			T_CLAIM_SOURCE_FLAG,
			T_DOJ_EPS,
			T_DOE_EPS,
			T_REASON_EXIT,
			TO_DATE(add_months(to_date(T_DOB), 696 )),
            V_CRITERIA_ID,
			SYSDATE,
			V_CLAIM_STATUS,
            V_CRITERIA_FLOW_ID,
            IN_APPLICATION_TYPE,
            T_ESTABLISHMENT_ID
		);
    ELSE RAISE CASE_NOT_FOUND;
  END CASE;
END;
     V_COUNT  :=SQL%ROWCOUNT;
      IF V_COUNT>0 THEN
        STATUS :=0;
        OUTPUT :=V_COUNT||' ROW INSERTED SUCCESSFULLY';
      END IF;
      IF V_COUNT=0 THEN
        STATUS :=1;
        OUTPUT :=SQLERRM;
      END IF;
EXCEPTION
WHEN CASE_NOT_FOUND THEN
  STATUS:=1;
  OUTPUT:='CASE NOT FOUND EXCEPTION FROM SAVE_OCS_CLAIM_DATA'||SQLERRM;
WHEN OTHERS THEN
--LOG_ERROR(VMODULE,T_OFFICE_ID||T_TRACKING_ID||T_UAN||T_MEMBER_ID||T_MEMBER_NAME||T_FATHER_SPOUSE_NAME||T_CLAIM_FORM_TYPE||SYSDATE||T_ESTABLISHMENT_ID||T_FLAG_FS||T_PAN||T_AADHAAR||T_MOBILE||T_EMAIL_ID||T_GENDER||T_DOB||T_DOJ_EPF||T_DOJ_EPS||T_DOE_EPF||T_DOE_EPS||T_REASON_EXIT||T_PARA_CODE||T_SUB_PARA_CODE||T_SUB_PARA_CATEGORY||T_ADV_AMOUNT||T_BANK_ACC_NO||T_IFSC_CODE||T_CLAIM_SOURCE_FLAG||T_ADDRESS1||T_ADDRESS2||T_ADDRESS_CITY||T_ADDRESS_DIST||T_ADDRESS_STATE||T_ADDRESS_PIN||T_AGENCY_EMPLOYER_FLAG||T_AGENCY_NAME||T_AGENCY_ADDRESS||T_AGENCY_ADDRESS_CITY||T_AGENCY_ADDERSS_DIST||T_AGENCY_ADDRESS_STATE||T_AGENCY_ADDRESS_PIN||T_PDB_UPDATE_FLAG||T_FLAG_15GH||T_TDS_15GH||T_CANCEL_CHEQUE||T_ADV_ENCLOSURE||T_IP_ADDRESS);
  LOG_ERROR('SAVE_OCS_CLAIM_DATA IN EXCEPTION','T_UAN'||T_UAN||' SQLERRM: '||SQLERRM);
  STATUS:=1;
  OUTPUT:='EXCEPTION OTHER '||SQLERRM;
  LOG_ERROR('SAVE_OCS_CLAIM_DATA IN EXCEPTION OUTPUT','T_UAN'||T_UAN||' OUTPUT: '||OUTPUT);
END SAVE_OCS_CLAIM_DATA;


--******************************************SAVE_OCS_CLAIM_DATA_LOG********************
PROCEDURE SAVE_OCS_CLAIM_DATA_LOG(
      T_OFFICE_ID                       IN CEN_OCS_FORM_19.OFFICE_ID%TYPE ,
      T_TRACKING_ID                     IN CEN_OCS_FORM_19.TRACKING_ID%TYPE ,
      T_UAN                             IN CEN_OCS_FORM_19.UAN%TYPE ,
      T_MEMBER_ID                       IN CEN_OCS_FORM_19.MEMBER_ID%TYPE ,
      T_MEMBER_NAME                     IN CEN_OCS_FORM_19.MEMBER_NAME%TYPE ,
      T_FATHER_SPOUSE_NAME              IN CEN_OCS_FORM_19.FATHER_SPOUSE_NAME%TYPE ,
      T_CLAIM_FORM_TYPE                 IN CEN_OCS_FORM_19.CLAIM_FORM_TYPE%TYPE ,
      T_RECEIPT_DATE                    IN CEN_OCS_FORM_19.RECEIPT_DATE%TYPE ,
      T_ESTABLISHMENT_ID                IN CEN_OCS_FORM_19.ESTABLISHMENT_ID%TYPE ,
      T_FLAG_FS                         IN CEN_OCS_FORM_19.FLAG_FS%TYPE ,
      T_PAN                             IN CEN_OCS_FORM_19.PAN%TYPE ,
      T_AADHAAR                         IN CEN_OCS_FORM_19.AADHAAR%TYPE ,
      T_MOBILE                          IN CEN_OCS_FORM_19.MOBILE%TYPE ,
      T_EMAIL_ID                        IN CEN_OCS_FORM_19.EMAIL_ID%TYPE ,
      T_GENDER                          IN CEN_OCS_FORM_19.GENDER%TYPE ,
      T_DOB                             IN CEN_OCS_FORM_19.DOB%TYPE ,
      T_DOJ_EPF                         IN CEN_OCS_FORM_19.DOJ_EPF%TYPE ,
      T_DOJ_EPS                         IN CEN_OCS_FORM_19.DOJ_EPS%TYPE ,
      T_DOE_EPF                         IN CEN_OCS_FORM_19.DOE_EPF%TYPE ,
      T_DOE_EPS                         IN CEN_OCS_FORM_19.DOE_EPS%TYPE ,
      T_REASON_EXIT                     IN CEN_OCS_FORM_19.REASON_EXIT%TYPE ,
      T_PARA_CODE                       IN CEN_OCS_FORM_19.PARA_CODE%TYPE ,
      T_SUB_PARA_CODE                   IN CEN_OCS_FORM_19.SUB_PARA_CODE%TYPE ,
      T_SUB_PARA_CATEGORY               IN CEN_OCS_FORM_19.SUB_PARA_CATEGORY%TYPE ,
      T_ADV_AMOUNT                      IN CEN_OCS_FORM_31.ADV_AMOUNT%TYPE ,
      T_BANK_ACC_NO                     IN CEN_OCS_FORM_19.BANK_ACC_NO%TYPE ,
      T_IFSC_CODE                       IN CEN_OCS_FORM_19.IFSC_CODE%TYPE ,
      T_CLAIM_SOURCE_FLAG               IN CEN_OCS_FORM_19.CLAIM_SOURCE_FLAG%TYPE ,
      T_ADDRESS1                        IN CEN_OCS_FORM_19.ADDRESS1%TYPE ,
      T_ADDRESS2                        IN CEN_OCS_FORM_19.ADDRESS2%TYPE ,
      T_ADDRESS_CITY                    IN CEN_OCS_FORM_19.ADDRESS_CITY%TYPE ,
      T_ADDRESS_DIST                    IN CEN_OCS_FORM_19.ADDRESS_DIST%TYPE ,
      T_ADDRESS_STATE                   IN CEN_OCS_FORM_19.ADDRESS_STATE%TYPE ,
      T_ADDRESS_PIN                     IN CEN_OCS_FORM_19.ADDRESS_PIN%TYPE ,
      T_AGENCY_EMPLOYER_FLAG            IN CEN_OCS_FORM_31.AGENCY_EMPLOYER_FLAG%TYPE ,
      T_AGENCY_NAME                     IN CEN_OCS_FORM_31.AGENCY_NAME%TYPE ,
      T_AGENCY_ADDRESS                  IN CEN_OCS_FORM_31.AGENCY_ADDRESS%TYPE ,
      T_AGENCY_ADDRESS_CITY             IN CEN_OCS_FORM_31.AGENCY_ADDRESS_CITY%TYPE ,
      T_AGENCY_ADDERSS_DIST             IN CEN_OCS_FORM_31.AGENCY_ADDERSS_DIST%TYPE ,
      T_AGENCY_ADDRESS_STATE            IN CEN_OCS_FORM_31.AGENCY_ADDRESS_STATE%TYPE,
      T_AGENCY_ADDRESS_PIN              IN CEN_OCS_FORM_31.AGENCY_ADDRESS_PIN%TYPE,
      T_FLAG_15GH                       IN CEN_OCS_FORM_19.FLAG_15GH%TYPE ,
      T_PDF_15GH                        IN CEN_OCS_FORM_19.PDF_15GH%TYPE,
      T_TDS_15GH                        IN CEN_OCS_FORM_19.TDS_15GH%TYPE ,
--      T_CANCEL_CHEQUE                 IN CEN_OCS_FORM_19.CANCEL_CHEQUE%TYPE ,
      T_ADV_ENCLOSURE                   IN CEN_OCS_FORM_31.ADV_ENCLOSURE%TYPE ,
      T_IP_ADDRESS                      IN CEN_OCS_FORM_19.IP_ADDRESS%TYPE ,
      --ADDED BY AKSHAY FOR 10D
      IN_CLAIM_BY                       IN CEN_OCS_FORM_19.CLAIM_BY%TYPE,
      IN_PENSION_TYPE                   IN CEN_OCS_FORM_10D.PENSION_TYPE%TYPE ,
      IN_OPTED_REDUCED_PENSION          IN NUMBER ,
      IN_OPTED_DATE                     IN VARCHAR2,
      IN_PPO_DETAILS                    IN VARCHAR2 ,
      IN_SCHEME_CERTIFICATE             IN VARCHAR2 ,
      IN_DEFERRED_PENSION               IN CHAR ,
      IN_DEFERRED_PENSION_AGE           IN NUMBER ,
      IN_DEFERRED_PENSION_CONT          IN VARCHAR2 ,
      IN_MARITAL_STATUS                 IN VARCHAR2,
      IN_NOMINATION_ID                  IN NUMBER,
      IN_BANK_ID                        IN NUMBER,
      IN_MEMBER_PHOTOGRAPH              IN BLOB,
      --ADDITION BY AKSHAY FOR 10D ENDED
--      IN_CANCEL_CHEQUE_PATH IN VARCHAR2,  --ADDED BY AKSHAY ON 09/08/2019 TO STORE PHYSICAL LOCATION OF UPLOADED CANCELLED CHEQUE
      IN_APPLICATION_TYPE IN VARCHAR2,	--#ver4.6
      IN_WITHDRAWAL_REASON IN VARCHAR2,  --ADDED ON 28/09/2020 --#ver4.21
      IN_AADHAAR_CONSENT_STATUS IN CHAR, --#ver4.22
      IN_AADHAAR_CONSENT_REF_ID IN NUMBER,--#ver4.22
      ----- IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH STARTS HERE ADDED ON 18/09/2020
      IN_3RDPARTY_NAME     IN VARCHAR2  DEFAULT NULL,
      IN_3RDPARTY_BANK_ACCNO IN VARCHAR2 DEFAULT NULL,
      IN_3RDPARTY_BANK_IFSC  IN VARCHAR2 DEFAULT NULL,
      IN_AUTH_LETTER_FILE_PATH IN VARCHAR2 DEFAULT NULL,
      ------ IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH ENDS HERE
      	--Yash Patidar Edits HERE
	    IN_BANK_NAME 					IN CEN_OCS_FORM_10_C.BANK_NAME%TYPE,
	    IN_BRANCH_NAME 					IN CEN_OCS_FORM_10_C.BRANCH_NAME%TYPE,
	    IN_NOMINATION_FAMILY_ID 		IN CEN_OCS_FORM_10_C.NOMINATION_FAMILY_ID%TYPE,
	    IN_NOMINEE_NAME 				IN CEN_OCS_FORM_10_C.NOMINEE_NAME%TYPE,
	    IN_NOMINEE_DOB					IN CEN_OCS_FORM_10_C.NOMINEE_DOB%TYPE,
	    IN_NOMINEE_GENDER				IN CEN_OCS_FORM_10_C.NOMINEE_GENDER%TYPE,
	    IN_NOMINEE_AADHAAR				IN CEN_OCS_FORM_10_C.NOMINEE_AADHAAR_NO%TYPE,
	    IN_NOMINEE_RELATION				IN CEN_OCS_FORM_10_C.NOMINEE_RELATION%TYPE,
	    IN_NOMINEE_RELATION_OTHER		IN CEN_OCS_FORM_10_C.NOMINEE_RELATION_OTHER%TYPE,
	    IN_NOMINEE_ADDRESS				IN CEN_OCS_FORM_10D.NOMINEE_ADDRESS%TYPE,
	    IN_IS_MINOR_NOMINEE				IN CEN_OCS_FORM_10_C.IS_MINOR_NOMINEE%TYPE,
	    IN_IS_LUNATIC					IN CEN_OCS_FORM_10_C.IS_LUNATIC%TYPE,
	    IN_NOM_SHARE_IN_PERCENT 		IN CEN_OCS_FORM_10_C.NOM_SHARE_IN_PERCENT%TYPE,
	    IN_GUARDIAN_NAME 				IN CEN_OCS_FORM_10_C.GUARDIAN_NAME%TYPE,
	    IN_GUARDIAN_RELATION 			IN CEN_OCS_FORM_10_C.GUARDIAN_RELATION%TYPE,
	    IN_GUARDIAN_ADDRESS 			IN CEN_OCS_FORM_10_C.GUARDIAN_ADDRESS%TYPE,
	    IN_NOM_ADDRESS1					IN CEN_OCS_FORM_10_C.NOM_ADDRESS1%TYPE,
	    IN_NOM_ADDRESS2					IN CEN_OCS_FORM_10_C.NOM_ADDRESS2%TYPE,
	    IN_NOM_CITY						IN CEN_OCS_FORM_10_C.NOM_CITY%TYPE,
	    IN_NOM_DISTRICT					IN CEN_OCS_FORM_10_C.NOM_DISTRICT%TYPE,
	    IN_NOM_STATE					IN CEN_OCS_FORM_10_C.NOM_STATE%TYPE,
	    IN_NOM_DISTRICT_ID				IN CEN_OCS_FORM_10_C.NOM_DISTRICT_ID%TYPE,
	    IN_NOM_STATE_ID					IN CEN_OCS_FORM_10_C.NOM_STATE_ID%TYPE,
	    IN_NOM_PIN						IN CEN_OCS_FORM_10_C.NOM_PIN%TYPE,	  
	    IN_OFFICE_NAME					IN CEN_OCS_FORM_10_C.OFFICE_NAME%TYPE,
	    IN_ADDRESS_OF_OFFICE			IN CEN_OCS_FORM_10D.ADDRESS_OF_OFFICE%TYPE,
	    IN_PINCODE_OF_OFFICE			IN CEN_OCS_FORM_10D.PINCODE_OF_OFFICE%TYPE,
	    IN_IS_WIDTHRAWAL_BENFIT_REQ		IN CEN_OCS_FORM_10_C.IS_WIDTHRAWAL_BENFIT_REQ%TYPE,
	    IN_IS_WIDTHRAWAL_BENFIT_TAKEN	IN CEN_OCS_FORM_10_C.IS_WIDTHRAWAL_BENFIT_TAKEN%TYPE,
      STATUS OUT NUMBER,
      OUTPUT OUT VARCHAR2
    )
AS
  V_COUNT NUMBER;
  VMODULE VARCHAR(200);
  V_CLAIM_STATUS VARCHAR2(2 BYTE);
  V_CLAIM_MODE CHAR(1 BYTE);
  V_CLAIM_BY CHAR(1 BYTE);
  V_MARITAL_STATUS CHAR(1 BYTE);
  V_NOMINATION_ID NUMBER(12,0);
  V_LATEST_APPROVAL_STATUS VARCHAR2(2 BYTE);
  V_EST_SL_NO NUMBER(10,0);
  V_MEM_SYS_ID NUMBER(8,0);
  V_AADHAAR_VRFC_STATUS VARCHAR2(2 BYTE);
  V_AADHAAR_OTP_VRFC_STAT VARCHAR2(2 BYTE);
  V_AADHAAR_DEMO_VRFC_STAT VARCHAR2(2 BYTE);
  V_AADHAAR_BIO_VRFC_STAT VARCHAR2(2 BYTE);
  V_BANK_ID  NUMBER(4,0);
  V_BANK_NAME VARCHAR(30);
BEGIN

  STATUS :=0;
  OUTPUT :='';
  V_COUNT:=0;
  V_CLAIM_STATUS:='N';
  V_CLAIM_MODE:='O';
  V_CLAIM_BY:='M';
  V_MARITAL_STATUS:='';
  V_NOMINATION_ID:=0;
  V_LATEST_APPROVAL_STATUS:='M';
  V_EST_SL_NO:=0;
  V_MEM_SYS_ID:=0;
  V_AADHAAR_VRFC_STATUS:='';
  V_AADHAAR_OTP_VRFC_STAT:='';
  V_AADHAAR_DEMO_VRFC_STAT:='';
  V_AADHAAR_BIO_VRFC_STAT:='';
  
    SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = T_UAN AND STATUS ='E';
    SELECT MARITAL_STATUS INTO V_MARITAL_STATUS FROM UAN_REPOSITORY WHERE UAN = T_UAN;
    SELECT EST_SLNO,ID INTO V_EST_SL_NO,V_MEM_SYS_ID FROM MEMBER WHERE MEMBER_ID = T_MEMBER_ID;
    SELECT AADHAAR_OTP_VERIFICATION_STAT,AADHAAR_DEMO_VERIFICATION_STAT,AADHAAR_BIO_VERIFICATION_STAT 
    INTO V_AADHAAR_OTP_VRFC_STAT,V_AADHAAR_DEMO_VRFC_STAT,V_AADHAAR_BIO_VRFC_STAT
    FROM UAN_REPOSITORY
    WHERE UAN = T_UAN;
    IF V_AADHAAR_OTP_VRFC_STAT='S' OR V_AADHAAR_DEMO_VRFC_STAT='S' OR V_AADHAAR_BIO_VRFC_STAT='S' THEN
     V_AADHAAR_VRFC_STATUS:='S';
    END IF;
--    SELECT BANK_ID INTO V_BANK_ID FROM BANK_IFSC WHERE IFSC_CODE=T_IFSC_CODE; 
    SELECT BANK_NAME, BANK_CODE INTO V_BANK_NAME, V_BANK_ID FROM CPPS_BANK WHERE IFS_CODE = T_IFSC_CODE;
  VMODULE:='OCS_NEW_PACKAGE.SAVE_OCS_CLAIM_DATA_LOG';
  BEGIN
  CASE T_CLAIM_FORM_TYPE 
    WHEN '01' THEN
      INSERT INTO CEN_OCS_FORM_19_LOG
      (
          OFFICE_ID,
          TRACKING_ID,
          UAN,
          MEMBER_ID,
          MEMBER_NAME,
          FATHER_SPOUSE_NAME,
          CLAIM_FORM_TYPE,
          RECEIPT_DATE,
          ESTABLISHMENT_ID,
          FLAG_FS,
          PAN,
          AADHAAR,
          MOBILE,
          EMAIL_ID,
          GENDER,
          DOB,
          DOJ_EPF,
          DOJ_EPS,
          DOE_EPF,
          DOE_EPS,
          REASON_EXIT,
          PARA_CODE,
          SUB_PARA_CODE,
          SUB_PARA_CATEGORY,
          BANK_ACC_NO,
          IFSC_CODE,
          CLAIM_SOURCE_FLAG,
          ADDRESS1,
          ADDRESS2,
          ADDRESS_CITY,
          ADDRESS_DIST,
          ADDRESS_STATE,
          ADDRESS_PIN,
          FLAG_15GH,
          TDS_15GH,
          IP_ADDRESS,
          AADHAAR_CONSENT_STATUS,
          AADHAAR_CONSENT_REF_ID,
          CLAIM_STATUS, 
          CLAIM_MODE,
          CLAIM_BY,
          MARITAL_STATUS, 
          NOMINATION_ID, 
          LATEST_APPROVAL_STATUS,
          OPERATION_TIMESTAMP,
          BANK_ID,
          EST_SL_NO,
          MEM_SYS_ID,
          SCHEME_CODE,
          AADHAAR_VERIFICATION_STATUS,
          PDF_15GH
    )
    VALUES
    (
          T_OFFICE_ID,
          T_TRACKING_ID,
          T_UAN,
          T_MEMBER_ID,
          T_MEMBER_NAME,
          T_FATHER_SPOUSE_NAME,
          T_CLAIM_FORM_TYPE,
          SYSDATE,
          T_ESTABLISHMENT_ID,
          T_FLAG_FS,
          T_PAN,
          T_AADHAAR,
          T_MOBILE,
          T_EMAIL_ID,
          T_GENDER,
          T_DOB,
          T_DOJ_EPF,
          T_DOJ_EPS,
          T_DOE_EPF,
          T_DOE_EPS,
          T_REASON_EXIT,
          T_PARA_CODE,
          T_SUB_PARA_CODE,
          T_SUB_PARA_CATEGORY,
          T_BANK_ACC_NO, 
          T_IFSC_CODE,       
          T_CLAIM_SOURCE_FLAG,
          T_ADDRESS1,
          T_ADDRESS2,
          T_ADDRESS_CITY,
          T_ADDRESS_DIST,
          T_ADDRESS_STATE,
          T_ADDRESS_PIN,
          T_FLAG_15GH,
          T_TDS_15GH,
          T_IP_ADDRESS,
          IN_AADHAAR_CONSENT_STATUS,
          IN_AADHAAR_CONSENT_REF_ID,
          V_CLAIM_STATUS, 
          V_CLAIM_MODE,
          V_CLAIM_BY,
          V_MARITAL_STATUS, 
          V_NOMINATION_ID, 
          V_LATEST_APPROVAL_STATUS,
          SYSTIMESTAMP,
          V_BANK_ID,
          V_EST_SL_NO,
          V_MEM_SYS_ID,
          'EPF',
          V_AADHAAR_VRFC_STATUS,
          T_PDF_15GH
    );
    
        WHEN '04' THEN  
        INSERT INTO UNIFIED_PORTAL.CEN_OCS_FORM_10_C_LOG( 
			TRACKING_ID,
			UAN,
            MEMBER_SYS_ID,
			MEMBER_ID,
			OFFICE_ID,
			OFFICE_NAME,
			CLAIM_FORM_TYPE,
			MEMBER_NAME,
			FAT_MOT_HUS_NAME,
			MEMBER_DOB,
			MEMBER_GENDER,
			MEMBER_MARITAL_STATUS,
			MEMBER_AADHAAR_NO,
			MOBILE,
			EMAIL_ID,
			MEMBER_ADDRESS1,
			MEMBER_ADDRESS2,
			MEMBER_CITY,
			MEMBER_DISTRICT,
			MEMBER_STATE,
			MEMBER_PIN,
            SCHEME_CODE,
			PARA_CODE,
			SUB_PARA_CODE,
			SUB_PARA_CATEGORY,
			NOMINATION_ID,
			NOMINATION_FAMILY_ID,
			NOMINEE_NAME,
			NOMINEE_DOB,
			NOMINEE_GENDER,
			NOMINEE_AADHAAR_NO,
			NOMINEE_RELATION,
			NOMINEE_RELATION_OTHER,
			IS_MINOR_NOMINEE,
			IS_LUNATIC,
			NOM_SHARE_IN_PERCENT,
			GUARDIAN_NAME,
			GUARDIAN_RELATION,
			GUARDIAN_ADDRESS,
			NOM_ADDRESS1,
			NOM_ADDRESS2,
			NOM_CITY,
			NOM_DISTRICT,
			NOM_STATE,
			NOM_DISTRICT_ID,
			NOM_STATE_ID,
			NOM_PIN,
			BANK_CODE,
			BANK_NAME,
			BRANCH_NAME,
			IFSC_CODE,
			BANK_ACC_NO,
			KYC_PDF_EXISTS,
            AADHAAR_VERIFICATION_STATUS,                             -- NOT DONE
			AADHAAR_CONSENT_STATUS,
			AADHAAR_CONSENT_REF_ID,
			CLAIM_BY,
			CLAIM_MODE,
			IS_WIDTHRAWAL_BENFIT_REQ,
			IS_WIDTHRAWAL_BENFIT_TAKEN,
			CLAIM_SOURCE_FLAG,
			DOJ_EPS95,
			DOE_EPS95,
			REASON_OF_EXIT,
			DATE_OF_ATTAINING_58YRS,
--            CRITERIA_ID,
			RECEIPT_DATE,
			CLAIM_STATUS
--            CRITERIA_FLOW_ID
			)
			VALUES (
			T_TRACKING_ID,
			T_UAN,
            V_MEM_SYS_ID,
			T_MEMBER_ID,
			T_OFFICE_ID,
			IN_OFFICE_NAME,
			T_CLAIM_FORM_TYPE,
			T_MEMBER_NAME,
			T_FATHER_SPOUSE_NAME,
			T_DOB,
			T_GENDER,
			V_MARITAL_STATUS,
			T_AADHAAR,
			T_MOBILE,
			T_EMAIL_ID,
			T_ADDRESS1,
			T_ADDRESS2,
			T_ADDRESS_CITY,
			T_ADDRESS_DIST,
			T_ADDRESS_STATE,
			T_ADDRESS_PIN,
            'EPS',
			T_PARA_CODE,
			T_SUB_PARA_CODE,
			T_SUB_PARA_CATEGORY,
			IN_NOMINATION_ID,
			IN_NOMINATION_FAMILY_ID,
			IN_NOMINEE_NAME,
			IN_NOMINEE_DOB,
			IN_NOMINEE_GENDER,
			IN_NOMINEE_AADHAAR,
			IN_NOMINEE_RELATION,
			IN_NOMINEE_RELATION_OTHER,
			IN_IS_MINOR_NOMINEE,
			IN_IS_LUNATIC,
			IN_NOM_SHARE_IN_PERCENT,
			IN_GUARDIAN_NAME,
			IN_GUARDIAN_RELATION,
			IN_GUARDIAN_ADDRESS,
			IN_NOM_ADDRESS1,
			IN_NOM_ADDRESS2,
			IN_NOM_CITY,
			IN_NOM_DISTRICT,
			IN_NOM_STATE,
			IN_NOM_DISTRICT_ID,
			IN_NOM_STATE_ID,
			IN_NOM_PIN,
			IN_BANK_ID,
			IN_BANK_NAME,
			IN_BRANCH_NAME,
			T_IFSC_CODE,
			T_BANK_ACC_NO,
			'',
            V_AADHAAR_VRFC_STATUS,
			IN_AADHAAR_CONSENT_STATUS,
			IN_AADHAAR_CONSENT_REF_ID,
			IN_CLAIM_BY,
			V_CLAIM_MODE,
			IN_IS_WIDTHRAWAL_BENFIT_REQ,
            IN_IS_WIDTHRAWAL_BENFIT_TAKEN,
			T_CLAIM_SOURCE_FLAG,
			T_DOJ_EPS,
			T_DOE_EPS,
			T_REASON_EXIT,
			TO_DATE(add_months(to_date(T_DOB), 696 )),
--            V_CRITERIA_ID,
			SYSDATE,
			V_CLAIM_STATUS
--            V_CRITERIA_FLOW_ID
		);

   WHEN '06' THEN
       INSERT INTO CEN_OCS_FORM_31_LOG
      (
          OFFICE_ID,
          TRACKING_ID,
          UAN,
          MEMBER_ID,
          MEMBER_NAME,
          FATHER_SPOUSE_NAME,
          CLAIM_FORM_TYPE,
          RECEIPT_DATE,
          ESTABLISHMENT_ID,
          FLAG_FS,
          PAN,
          AADHAAR,
          MOBILE,
          EMAIL_ID,
          GENDER,
          DOB,
          DOJ_EPF,
          DOJ_EPS,
          DOE_EPF,
          DOE_EPS,
          REASON_EXIT,
          PARA_CODE,
          SUB_PARA_CODE,
          SUB_PARA_CATEGORY,
          BANK_ACC_NO,
          IFSC_CODE,
          CLAIM_SOURCE_FLAG,
          ADDRESS1,
          ADDRESS2,
          ADDRESS_CITY,
          ADDRESS_DIST,
          ADDRESS_STATE,
          ADDRESS_PIN,
          IP_ADDRESS,
          AADHAAR_CONSENT_STATUS,
          AADHAAR_CONSENT_REF_ID,
          CLAIM_STATUS, 
          CLAIM_MODE,
          CLAIM_BY,
          MARITAL_STATUS, 
          NOMINATION_ID, 
          LATEST_APPROVAL_STATUS,
          OPERATION_TIMESTAMP,
          BANK_ID,
          EST_SL_NO,
          MEM_SYS_ID,
          SCHEME_CODE,
          AADHAAR_VERIFICATION_STATUS,
          ADV_AMOUNT
    )
    VALUES
    (
          T_OFFICE_ID,
          T_TRACKING_ID,
          T_UAN,
          T_MEMBER_ID,
          T_MEMBER_NAME,
          T_FATHER_SPOUSE_NAME,
          T_CLAIM_FORM_TYPE,
          SYSDATE,
          T_ESTABLISHMENT_ID,
          T_FLAG_FS,
          T_PAN,
          T_AADHAAR,
          T_MOBILE,
          T_EMAIL_ID,
          T_GENDER,
          T_DOB,
          T_DOJ_EPF,
          T_DOJ_EPS,
          T_DOE_EPF,
          T_DOE_EPS,
          T_REASON_EXIT,
          T_PARA_CODE,
          T_SUB_PARA_CODE,
          T_SUB_PARA_CATEGORY,
          case when IN_3RDPARTY_BANK_ACCNO is null then  T_BANK_ACC_NO else IN_3RDPARTY_BANK_ACCNO end, 
          case when IN_3RDPARTY_BANK_IFSC is null then T_IFSC_CODE else IN_3RDPARTY_BANK_IFSC end,       
          T_CLAIM_SOURCE_FLAG,
          T_ADDRESS1,
          T_ADDRESS2,
          T_ADDRESS_CITY,
          T_ADDRESS_DIST,
          T_ADDRESS_STATE,
          T_ADDRESS_PIN,
          T_IP_ADDRESS,
          IN_AADHAAR_CONSENT_STATUS,
          IN_AADHAAR_CONSENT_REF_ID,
          V_CLAIM_STATUS, 
          V_CLAIM_MODE,
          V_CLAIM_BY,
          V_MARITAL_STATUS, 
          V_NOMINATION_ID, 
          V_LATEST_APPROVAL_STATUS,
          SYSTIMESTAMP,
          V_BANK_ID,
          V_EST_SL_NO,
          V_MEM_SYS_ID,
          'EPF',
          V_AADHAAR_VRFC_STATUS,
          T_ADV_AMOUNT
    );
      ELSE RAISE CASE_NOT_FOUND;
  END CASE;
END;
     V_COUNT  :=SQL%ROWCOUNT;
      IF V_COUNT>0 THEN
        STATUS :=0;
        OUTPUT :=V_COUNT||' ROW INSERTED SUCCESSFULLY';
      END IF;
      IF V_COUNT=0 THEN
        STATUS :=1;
        OUTPUT :=SQLERRM;
      END IF;
EXCEPTION
WHEN CASE_NOT_FOUND THEN
  STATUS:=1;
  OUTPUT:='CASE NOT FOUND EXCEPTION FROM SAVE_OCS_CLAIM_DATA_LOG'||SQLERRM;
WHEN OTHERS THEN
--LOG_ERROR(VMODULE,T_OFFICE_ID||T_TRACKING_ID||T_UAN||T_MEMBER_ID||T_MEMBER_NAME||T_FATHER_SPOUSE_NAME||T_CLAIM_FORM_TYPE||SYSDATE||T_ESTABLISHMENT_ID||T_FLAG_FS||T_PAN||T_AADHAAR||T_MOBILE||T_EMAIL_ID||T_GENDER||T_DOB||T_DOJ_EPF||T_DOJ_EPS||T_DOE_EPF||T_DOE_EPS||T_REASON_EXIT||T_PARA_CODE||T_SUB_PARA_CODE||T_SUB_PARA_CATEGORY||T_ADV_AMOUNT||T_BANK_ACC_NO||T_IFSC_CODE||T_CLAIM_SOURCE_FLAG||T_ADDRESS1||T_ADDRESS2||T_ADDRESS_CITY||T_ADDRESS_DIST||T_ADDRESS_STATE||T_ADDRESS_PIN||T_AGENCY_EMPLOYER_FLAG||T_AGENCY_NAME||T_AGENCY_ADDRESS||T_AGENCY_ADDRESS_CITY||T_AGENCY_ADDERSS_DIST||T_AGENCY_ADDRESS_STATE||T_AGENCY_ADDRESS_PIN||T_PDB_UPDATE_FLAG||T_FLAG_15GH||T_TDS_15GH||T_CANCEL_CHEQUE||T_ADV_ENCLOSURE||T_IP_ADDRESS);
  LOG_ERROR('SAVE_OCS_CLAIM_DATA IN EXCEPTION','T_UAN'||T_UAN||' SQLERRM: '||SQLERRM);
  STATUS:=1;
  OUTPUT:='EXCEPTION OTHER '||SQLERRM;
  LOG_ERROR('SAVE_OCS_CLAIM_DATA IN EXCEPTION OUTPUT','T_UAN'||T_UAN||' OUTPUT: '||OUTPUT);
END SAVE_OCS_CLAIM_DATA_LOG;

--******************************************SAVE_OCS_CRD_DATA********************BY PANKAJ KUMAR
PROCEDURE SAVE_OCS_CRD_DATA
  (
    IN_MEMBER_ID       IN VARCHAR2,
    IN_OFFICE_ID       IN NUMBER,
    IN_CLAIM_FORM_TYPE IN VARCHAR2,
    IN_TRACKING_ID     IN NUMBER,
    STATUS OUT NUMBER,
    OUTPUT OUT VARCHAR2
  )
AS
  T_EST_SL_NO      NUMBER;
  DATA_INSERT_FAIL EXCEPTION;
BEGIN
  NULL;
  STATUS      :=0;
  OUTPUT      :='';
  T_EST_SL_NO :=GET_EST_SL_NO(IN_MEMBER_ID);
  IF IN_CLAIM_FORM_TYPE = '03' THEN
    LOG_ERROR('SAVE_OCS_CRD_DATA SAVING DATA IN OCS_CRD','IN_MEMBER_ID'||IN_MEMBER_ID||' IN_TRACKING_ID: '||IN_TRACKING_ID);
  END IF;

  -- **************************************************INSERT INTO OCS_CRD TABLE***
  INSERT
  INTO OCS_CRD
    (
      TRACKING_ID,
      MEMBER_ID,
      EST_SL_NO,
      CLAIM_FORM_TYPE,
      OFFICE_ID,
      UAN,
      AADHAAR,
      RECEIPT_DATE,
      CLAIM_STATUS
    )
  SELECT IN_TRACKING_ID,
    (SELECT IN_MEMBER_ID FROM DUAL
    ),
    (SELECT T_EST_SL_NO FROM DUAL
    ),
    CLAIM_FORM_TYPE,
    OFFICE_ID,
    UAN,
    AADHAAR,
    RECEIPT_DATE,
    1
  FROM OCS_CLAIM_DATA
  WHERE TRACKING_ID=IN_TRACKING_ID;
  IF SQL%ROWCOUNT  =0 THEN
    OUTPUT        :=SQLERRM;
    RAISE DATA_INSERT_FAIL;
  END IF;
  IF IN_CLAIM_FORM_TYPE = '03' THEN
    LOG_ERROR('SAVE_OCS_CRD_DATA DATA INSERTED IN OCS_CRD','IN_MEMBER_ID'||IN_MEMBER_ID||' IN_TRACKING_ID: '||IN_TRACKING_ID);
  END IF;
   --END HERE************************** INSERT OCS CRD
  --INSERT INTO OCS CLAIM STATUS LOG
  IF IN_CLAIM_FORM_TYPE = '03' THEN
    LOG_ERROR('SAVE_OCS_CRD_DATA SAVING DATA IN OCS_CLAIM_STATUS_LOG','IN_MEMBER_ID'||IN_MEMBER_ID||' IN_TRACKING_ID: '||IN_TRACKING_ID);
  END IF;
  INSERT
  INTO OCS_CLAIM_STATUS_LOG
    (
      TRACKING_ID,
      CLAIM_STATUS,
      DATE_CLAIM_STATUS
    )
    VALUES
    (
      IN_TRACKING_ID,
      1,
      SYSDATE
    );
  IF SQL%ROWCOUNT=0 THEN
    OUTPUT      :=SQLERRM;
    RAISE DATA_INSERT_FAIL;
  END IF;
  OUTPUT:=OUTPUT||', '||SQL%ROWCOUNT||' ROW INSERTED IN OCS CLAIM STATUS LOG';
    IF IN_CLAIM_FORM_TYPE = '03' THEN
      LOG_ERROR('SAVE_OCS_CRD_DATA: DATA INSERTED IN OCS_CLAIM_STATUS_LOG','IN_MEMBER_ID'||IN_MEMBER_ID||' IN_TRACKING_ID: '||IN_TRACKING_ID);
    END IF;
  --END HERE****************** INSERT INTO OCS CLAIM STATUS LOG
EXCEPTION
WHEN DATA_INSERT_FAIL THEN
  IF IN_CLAIM_FORM_TYPE = '03' THEN
    LOG_ERROR('SAVE_OCS_CRD_DATA: DATA_INSERT_FAIL','IN_MEMBER_ID'||IN_MEMBER_ID||' IN_TRACKING_ID: '||IN_TRACKING_ID||' SQLERRM: '||SQLERRM);
  END IF;
  STATUS :=1;
WHEN OTHERS THEN
  IF IN_CLAIM_FORM_TYPE = '03' THEN
    LOG_ERROR('SAVE_OCS_CRD_DATA: EXCEPTION OTHERS','IN_MEMBER_ID'||IN_MEMBER_ID||' IN_TRACKING_ID: '||IN_TRACKING_ID||' SQLERRM: '||SQLERRM);
  END IF;
  STATUS :=1;
  OUTPUT :=SQLERRM;
END SAVE_OCS_CRD_DATA;
PROCEDURE GET_PARA_CODE_BY_EXIT_CODE
  (
    IN_EXIT_CODE IN NUMBER,
    OUT_PARA OUT VARCHAR2,
    OUT_SUB_PARA OUT VARCHAR2,
    OUT_PARA_CAT OUT VARCHAR2
  )
AS
  PARA VARCHAR2
  (
    2
  )
  ;
  SUB_PARA VARCHAR2(2);
  PARA_CAT VARCHAR2(2);
BEGIN
  --NULL;
  PARA     :='-';
  SUB_PARA :='-';
  PARA_CAT :='-';
  SELECT PARA_CODE,
    SUB_PARA_CODE,
    SUB_PARA_CATEGORY
  INTO PARA,
    SUB_PARA,
    PARA_CAT
  FROM OCS_PARA_CODE_MASTER
  WHERE EXIT_CODE=IN_EXIT_CODE;
  OUT_PARA      :=PARA;
  OUT_SUB_PARA  :=SUB_PARA;
  OUT_PARA_CAT  :=PARA_CAT;
EXCEPTION
WHEN OTHERS THEN
--  RAISE NO_DATA_FOUND;
  RAISE_APPLICATION_ERROR(-20001,'Z#Your reason of exit is invalid. Kindly get your reason of exit updated by visiting EPFO office.#Z');
END GET_PARA_CODE_BY_EXIT_CODE;


PROCEDURE GET_CLAIM_STATUS(
    IN_UAN IN NUMBER,
    CLAIM_STATUS OUT SYS_REFCURSOR,
    OUTPUT OUT NUMBER,
    OUTPUT_STATUS OUT VARCHAR2)
AS
  V_COUNT_19  NUMBER(3);
  V_COUNT_31  NUMBER(3);
  V_COUNT_10D NUMBER(3);
 
BEGIN
  OUTPUT       :=0;
  V_COUNT_19   :=0;
  V_COUNT_31   :=0;
  V_COUNT_10D  :=0;
  OUTPUT_STATUS:='';
  
  SELECT COUNT(1)
  INTO V_COUNT_19
  FROM CEN_OCS_FORM_19 COF19
  WHERE COF19.UAN = IN_UAN 
  AND COF19.CLAIM_STATUS IN ('N','P','R','S','E');
  
  SELECT COUNT(1)
  INTO V_COUNT_31
  FROM CEN_OCS_FORM_31 COF31
  WHERE COF31.UAN = IN_UAN 
  AND COF31.CLAIM_STATUS IN ('N','P','R','S','E');
  
  SELECT COUNT(1)
  INTO V_COUNT_10D
  FROM CEN_OCS_FORM_10_C COFD
  WHERE COFD.UAN = IN_UAN 
  AND COFD.CLAIM_STATUS IN ('N','P','R','S','E');
  
  IF V_COUNT_19>0 OR V_COUNT_31>0 OR V_COUNT_10D >0 THEN
    OPEN CLAIM_STATUS FOR 
    SELECT C.* --DISTINCT(C.TRACKING_ID),C.UAN,C.RECEIPT_DATE,C.CLAIM_FORM_TYPE,C.CLAIM_STATUS
     FROM
     (
         SELECT DISTINCT(COF19.TRACKING_ID),COF19.CLAIM_FORM_TYPE,COF19.RECEIPT_DATE,COF19.CLAIM_STATUS,S.DESCRIPTION AS CURRENT_STATUS,F.DESCRIPTION AS FORM_TYPE,COF19.OFFICE_ID
         FROM CEN_OCS_FORM_19 COF19, CEN_OCS_FORM_TYPE_MASTER F, CEN_OCS_CLAIM_STATUS_MASTER S  
         WHERE COF19.CLAIM_STATUS IN ('N','P','R','S','E') 
         AND COF19.UAN = IN_UAN
         AND COF19.CLAIM_FORM_TYPE = F.FORM_TYPE_CODE
         AND COF19.CLAIM_STATUS = S.CLAIM_STATUS
         UNION ALL
         SELECT  DISTINCT(COF31.TRACKING_ID),COF31.CLAIM_FORM_TYPE,COF31.RECEIPT_DATE,COF31.CLAIM_STATUS,S.DESCRIPTION AS CURRENT_STATUS,F.DESCRIPTION AS FORM_TYPE,COF31.OFFICE_ID
         FROM CEN_OCS_FORM_31 COF31, CEN_OCS_FORM_TYPE_MASTER F, CEN_OCS_CLAIM_STATUS_MASTER S   
         WHERE COF31.CLAIM_STATUS IN ('N','P','R','S','E')
         AND COF31.UAN = IN_UAN
         AND COF31.CLAIM_FORM_TYPE = F.FORM_TYPE_CODE
         AND COF31.CLAIM_STATUS = S.CLAIM_STATUS
         UNION ALL 
         SELECT  DISTINCT(COFD.TRACKING_ID),COFD.CLAIM_FORM_TYPE,COFD.RECEIPT_DATE,COFD.CLAIM_STATUS,S.DESCRIPTION AS CURRENT_STATUS,F.DESCRIPTION AS FORM_TYPE,COFD.OFFICE_ID
         FROM CEN_OCS_FORM_10_C COFD, CEN_OCS_FORM_TYPE_MASTER F, CEN_OCS_CLAIM_STATUS_MASTER S   
         WHERE COFD.CLAIM_STATUS IN ('N','P','R','S','E')
         AND COFD.UAN = IN_UAN
         AND COFD.CLAIM_FORM_TYPE = F.FORM_TYPE_CODE
         AND COFD.CLAIM_STATUS = S.CLAIM_STATUS
      )C
--     WHERE C.UAN = IN_UAN
     ORDER BY C.RECEIPT_DATE DESC;
  ELSE
      OPEN CLAIM_STATUS FOR SELECT 0 AS TRACKING_ID, '' AS CURRENT_STATUS, '' AS RECEIPT_DATE, '' AS CLAIM_FORM_TYPE, '' AS CLAIM_STATUS, '' AS FORM_TYPE FROM DUAL;
      OUTPUT        :=1;
      OUTPUT_STATUS :='RECORD NOT AVAILABLE AGAINST THIS UAN NUMBER';
  END IF;
END GET_CLAIM_STATUS;
  
  
--  SELECT COUNT(1)
--  INTO V_COUNT
--  FROM OCS_CRD
--  WHERE UAN =IN_UAN;
--  IF V_COUNT>0 THEN
--    OPEN CLAIM_STATUS FOR SELECT T.*,
--    C.FORM_TYPE,
--   NVL(C.CLAIM_ID,'NA') CLAIM_ID,
--   C.MEMBER_ID,
--  C.DESCRIPTION|| NVL2(T.REJECTION_REASON,' '||T.REJECTION_REASON,'')	--#ver3.6
--  AS
--    CURRENT_STATUS FROM
--
--    (SELECT TRACKING_ID1,
--    OFFICE_ID,				-- #ver1.1
--    CLAIM_FORM_TYPE,		-- #ver1.1
--      S1,
--      S2,
--      S3,
--      S4,
--        S5,
--        REJECTION_REASON
--    FROM
--      (SELECT TRACKING_ID AS TRACKING_ID1,
--      OFFICE_ID As OFFICE_ID,
--    CLAIM_FORM_TYPE AS CLAIM_FORM_TYPE,
--          REJECTION_REASON,	--#ver3.6
--        MAX(DECODE(CLAIM_STATUS,1,DATE_CLAIM_STATUS)) S1,
--        MAX(DECODE(CLAIM_STATUS,2,DATE_CLAIM_STATUS)) S2,
--        MAX(DECODE(CLAIM_STATUS,3,DATE_CLAIM_STATUS)) S3,
--        MAX(DECODE(CLAIM_STATUS,4,DATE_CLAIM_STATUS)) S4,
--        MAX(DECODE(CLAIM_STATUS,5,DATE_CLAIM_STATUS)) S5
--      FROM
--        (SELECT C.TRACKING_ID,
--          C.UAN,
--          L.CLAIM_STATUS,
--          C.CLAIM_STATUS AS CUR_STATUS,
--          C.OFFICE_ID AS OFFICE_ID,				-- #ver1.1
--		  C.CLAIM_FORM_TYPE AS CLAIM_FORM_TYPE,	-- #ver1.1
--          S.DESCRIPTION,
--          L.DATE_CLAIM_STATUS,
--            L.REMARKS,
--            C.REJECTION_REASON	--#ver3.6
--        FROM OCS_CRD C,
--          OCS_CLAIM_STATUS_LOG L,
--          OCS_CLAIM_STATUS_MASTER S
--        WHERE C.TRACKING_ID=L.TRACKING_ID
--        AND L.CLAIM_STATUS =S.CLAIM_STATUS
--        AND C.UAN          =IN_UAN
--        ORDER BY C.TRACKING_ID
--        )
--      GROUP BY 
--		TRACKING_ID,
--		OFFICE_ID,			-- #ver1.1
--		CLAIM_FORM_TYPE		-- #ver1.1
--		,REJECTION_REASON	--#ver3.6
--      )
--    )T,
--    (SELECT TRACKING_ID,
--      F.DESCRIPTION AS FORM_TYPE,
--      M.DESCRIPTION,
--      C.CLAIM_ID,
--      C.MEMBER_ID
--    FROM OCS_CLAIM_STATUS_MASTER M,
--      OCS_CRD C,
--      FORM_TYPE_MASTER F
--    WHERE C.CLAIM_STATUS    =M.CLAIM_STATUS
--    AND F.FORM_TYPE         =C.CLAIM_FORM_TYPE
--    ) C WHERE T.TRACKING_ID1=C.TRACKING_ID ORDER BY T.S1 DESC;
--  ELSE
--    OPEN CLAIM_STATUS FOR SELECT 0
--  AS
--    TRACKING_ID1,
--    ''
--  AS
--    S1,
--    ''
--  AS
--    S2,
--    ''
--  AS
--    S3,
--    ''
--  AS
--    S4,
--    ''
--  AS
--    S5,
--    ''
--  AS
--    FORM_TYPE,
--    ''
--  AS
--    CURRENT_STATUS,
--    ''
--  AS
--    CLAIM_FORM_TYPE,  --#ver4.17
--    0
--  AS
--    OFFICE_ID --#ver4.17
--  FROM DUAL;
--    OUTPUT        :=1;
--    OUTPUT_STATUS :='RECORD NOT AVAILABLE AGAINST THIS UAN NUMBER';
--  END IF;
--END GET_CLAIM_STATUS;

PROCEDURE CHECK_BEFORE_CLAIM_SUBMIT(
    IN_UAN             IN NUMBER,
    IN_CLAIM_FORM_TYPE IN VARCHAR2,
    OUT_LIST OUT SYS_REFCURSOR,
    OUTPUT OUT NUMBER,
    OUTPUT_STATUS OUT VARCHAR2)
AS
  NO_OF_CLAIMS NUMBER;
  CASE_NOT_FOUND EXCEPTION;
BEGIN
  NO_OF_CLAIMS:=0;
  OUTPUT      :=0;
  
  CASE IN_CLAIM_FORM_TYPE
  WHEN '01' THEN
   OPEN OUT_LIST FOR 
   SELECT
        TRACKING_ID,
        F.DESCRIPTION AS CLAIM_FORM_TYPE,
        COF.CLAIM_STATUS,
        COF.RECEIPT_DATE
   FROM
        CEN_OCS_FORM_19 COF,
        FORM_TYPE_MASTER F
   WHERE
        COF.UAN =IN_UAN AND 
        COF.CLAIM_FORM_TYPE=F.FORM_TYPE AND
        COF.CLAIM_FORM_TYPE=IN_CLAIM_FORM_TYPE AND 
        COF.CLAIM_STATUS IN ('N','P','E'); 
    IF  OUT_LIST IS NOT NULL THEN OUTPUT:=1;
    END IF; 

  WHEN '06' THEN  
   OPEN OUT_LIST FOR 
   SELECT
        TRACKING_ID,
        F.DESCRIPTION AS CLAIM_FORM_TYPE,
        COF.CLAIM_STATUS,
        COF.RECEIPT_DATE
   FROM
        CEN_OCS_FORM_31 COF,
        FORM_TYPE_MASTER F
   WHERE
        COF.UAN =IN_UAN AND 
        COF.CLAIM_FORM_TYPE=F.FORM_TYPE AND
        COF.CLAIM_FORM_TYPE=IN_CLAIM_FORM_TYPE AND 
        COF.CLAIM_STATUS IN ('N','P','E') AND
        (	--#ver2.5
          CASE --#ver4.20
    --        WHEN OCD.CLAIM_FORM_TYPE='06' AND COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2 THEN 0
            WHEN COF.CLAIM_FORM_TYPE='06' AND COF.PARA_CODE = '8' AND COF.SUB_PARA_CODE = '13' AND COF.SUB_PARA_CATEGORY = '3' THEN 1  --IF COVID-19 CLAIM IS PENDING THEN DONT ALLOW ANY PF-ADVANCE CLAIM
            WHEN COF.CLAIM_FORM_TYPE='06' AND (COF.PARA_CODE <> '8' OR COF.SUB_PARA_CODE <> '13' OR COF.SUB_PARA_CATEGORY <> '3') THEN 1 --EXECUTING THIS CASE MEANS THAT A PENDING CLAIM FOUND IS OF NON-COVID-19. AND IF OTHER THAN COVID-19 CLAIM IS GETTING FILED THEN DONT ALLOW --#ver2.6
            WHEN COF.CLAIM_FORM_TYPE='06' THEN 0  --IT IS ASSUMED THAT ONLY COVID-19 CLAIM IS ALLOWED FROM FRONT-END IN CASE OF ANY PREVIOUS PENDING CLAIM
            ELSE 1
          END = 1    
        );    
    IF  OUT_LIST IS NOT NULL THEN OUTPUT:=1;
    END IF; 

    WHEN '04' THEN  
      OPEN OUT_LIST FOR 
        SELECT
          TRACKING_ID,
          F.DESCRIPTION AS CLAIM_FORM_TYPE,
          COF.CLAIM_STATUS,
          COF.RECEIPT_DATE
        FROM
          CEN_OCS_FORM_10_C COF,
          FORM_TYPE_MASTER F
        WHERE
          COF.UAN =IN_UAN AND 
          COF.CLAIM_FORM_TYPE=F.FORM_TYPE AND
          COF.CLAIM_FORM_TYPE=IN_CLAIM_FORM_TYPE AND 
          COF.CLAIM_STATUS IN ('N','P','E');  
      IF  OUT_LIST IS NOT NULL THEN OUTPUT:=1;
      END IF; 
   ELSE RAISE CASE_NOT_FOUND;
  END CASE;
  
--  FORM_TYPE,
--  S.DESCRIPTION,
--  L.DATE_CLAIM_STATUS
--  FROM
--    OCS_CLAIM_DATA OCD,	--#ver2.5
--    OCS_CRD C,
--    OCS_CLAIM_STATUS_MASTER S,
--    FORM_TYPE_MASTER F,
--    OCS_CLAIM_STATUS_LOG L 
--  WHERE 
--    OCD.TRACKING_ID = C.TRACKING_ID AND
--    C.CLAIM_STATUS =S.CLAIM_STATUS AND 
--    C.CLAIM_FORM_TYPE=F.FORM_TYPE AND 
--    L.TRACKING_ID =C.TRACKING_ID AND 
--    L.CLAIM_STATUS =C.CLAIM_STATUS AND 
--    C.UAN =IN_UAN AND 
--    C.CLAIM_FORM_TYPE=IN_CLAIM_FORM_TYPE AND 
--    C.CLAIM_STATUS IN (0,1,2,3) AND
--    (
--      CASE --#ver2.5
--          WHEN C.CLAIM_FORM_TYPE='06' AND OCD.PARA_CODE = '8' AND OCD.SUB_PARA_CODE = '13'AND OCD.SUB_PARA_CATEGORY = '3' THEN 1
----        WHEN C.CLAIM_FORM_TYPE='06' AND COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) = 0 THEN 0 --#ver2.6  --#ver4.0
--	  WHEN C.CLAIM_FORM_TYPE='06' AND COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2  THEN 0 --#ver4.20
----        WHEN C.CLAIM_FORM_TYPE='06' THEN 0	--#ver2.6 --UNCOMMENTED FOR --#ver3.2
--        ELSE 1
--      END = 1    
--    )
--    ;
EXCEPTION
WHEN CASE_NOT_FOUND THEN
  OUTPUT       :=1;
  OUTPUT_STATUS:='FROM CHECK_BEFORE_CLAIM_SUBMIT' || SQLERRM;  
WHEN OTHERS THEN
  OUTPUT       :=1;
  OUTPUT_STATUS:=SQLERRM;
END CHECK_BEFORE_CLAIM_SUBMIT;
--******************************************ADDED AND CREATED BY PANKAJ KUMAR***************FROM HERE TO END******************************

--#ver3.8
--ADDED BY AKSHAY ON 10/06/2020 TO DISPLAY DROP-DOWN LIST OF PARALLEL EMPLOYMENTS
PROCEDURE FETCH_PARALLEL_EMPLOYMENT_DETS(
	IN_UAN IN NUMBER,
  IN_CLAIM_FORM IN NUMBER,  
--  IN_DOE_EPF_LATEST_MEMBER_ID IN DATE,
	OUT_PARALLEL_EMPLOYMNT_MEM_IDS OUT SYS_REFCURSOR
)
AS
BEGIN	
	IF IN_CLAIM_FORM = 06 THEN	--FOR PF ADVANCE CLAIM, FIND MEMBER_IDS HAVING PARALLEL EMPLOYMENT
--		IF IN_DOE_EPF_LATEST_MEMBER_ID IS NULL THEN --MEMBER IS CURRENTLY WORKING I.E. THERE MAY BE A CHANCE OF PARALLEL EMPLOYMENT
			OPEN OUT_PARALLEL_EMPLOYMNT_MEM_IDS FOR
				SELECT
					MEM.ID MEM_SYS_ID,
					MEM.MEMBER_ID MEMBER_ID,
          EST.NAME EST_NAME,
          CASE 
            WHEN EST.PF_EXEMPTED = 'Y' THEN 1 --0 = ELIGIBLE, 1 = INELIGIBLE
            WHEN MEM.DOJ_EPF IS NULL THEN 1 -- Date of joining should be available in service history --Ref email from Harsh sir dated 13/03/2020
            ELSE 0 
          END ELIGIBLE,
          CASE 
            WHEN EST.PF_EXEMPTED = 'Y' THEN 'EXEMPTED IN PF. SUBMIT CLAIM TO THE CONCERNED TRUST'
            WHEN MEM.DOJ_EPF IS NULL THEN 'DATE OF JOINING(EPF) NOT AVAILABLE'            
            ELSE 'ELIGIBLE'
          END ELIGIBILITY_MESSAGE
				FROM
					MEMBER MEM
        INNER JOIN ESTABLISHMENT EST
          ON MEM.EST_SLNO = EST.SL_NO
				WHERE
					MEM.UAN = IN_UAN 
--				AND	MEM.DOE_EPF IS NULL
--					AND MEM.DOJ_EPF IS NOT NULL -- Date of joining should be available in service history --Ref email from Harsh sir dated 13/03/2020
        ORDER BY
          MEM.ID
			;  
		ELSE  --MEMBER IS CURRENTLY UNEMPLOYED I.E. NOT A CASE OF PARALLEL EMPLOYEMNT
			OPEN OUT_PARALLEL_EMPLOYMNT_MEM_IDS FOR
				SELECT * FROM DUAL WHERE 1=2
			;
		END IF;
--	ELSE  --NO NEED OF PARALLEL EMPLOYMENT DROPDOWN LIST FOR ANY OTHER CLAIM FORM TYPE
--		OPEN OUT_PARALLEL_EMPLOYMNT_MEM_IDS FOR
--			SELECT * FROM DUAL WHERE 1=2
--		;
--	END IF;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END FETCH_PARALLEL_EMPLOYMENT_DETS;


--*************************************************CHECK_ELIGIBILITY START HERE*******
PROCEDURE CHECK_ELIGIBILITY(
    IN_UAN    IN NUMBER,
    FORM_TYPE IN NUMBER,
    DOJ_EPF   IN DATE,
    DOJ_EPS   IN DATE,
    DOE_EPF   IN DATE,
    DOE_EPS   IN DATE,
    TOTAL_SERVICE_IN_MONTHS OUT NUMBER,
    OUTPUT OUT VARCHAR2,
    OUT_OLS OUT NUMBER)
AS
  V_COUNT NUMBER;
  V_PAN   VARCHAR2(10);
  V_PAN_COUNT NUMBER;
  --Max online claim condition added by Pankaj Kumar**********************27-12-2017*******************
  V_CLAIM_COUNT  NUMBER(2);

  --ADDED BY AKSHAY ON 27/04/2019
  V_NOMINATION_COUNT NUMBER:=0;
  V_NOMINEE_PHOTO_COUNT NUMBER:=0;
  V_MEMBER_PHOTO_COUNT NUMBER:=0;
  V_PHOTO_CNT NUMBER(2):= 0;
  V_LATEST_MEMID VARCHAR2(24);
  V_DOE_NULL_COUNT NUMBER:=0;
  V_FATHER_OR_HUSBAND_NAME UAN_REPOSITORY.FATHER_OR_HUSBAND_NAME%TYPE;
  V_RELATION UAN_REPOSITORY.RELATION_WITH_MEMBER%TYPE;
  --ADDITION BY AKSHAY ON 27/04/2019 ENDED

--  V_LATEST_MEMID VARCHAR2(24);
  V_EXM VARCHAR2(2);  --ADDED BY AKSHAY ON 28/06/2019
  V_DOE_EPF_LATEST DATE:=NULL; --#ver3.8
  V_DOE_EPS DATE:=NULL; --#ver4.12
  V_ROE NUMBER; --#ver4.21
  V_CLAIM_FORM_TYPE VARCHAR2(2):='';--#ver4.29
  V_DOB VARCHAR2(10); --#ver4.29
  V_NEW_10C_COUNT NUMBER(2);
BEGIN
  OUT_OLS                :=0;
  OUTPUT                 :='';
  TOTAL_SERVICE_IN_MONTHS:=0;
  V_PAN:='';
  V_PAN_COUNT:=0;
  V_CLAIM_COUNT:=0;
  V_NEW_10C_COUNT:=0;

  --FOLLOWING CONDITION COMMENTED BY AKSHAY ON 17/07/2019 AFTER DISCUSSION WITH HARSH SIR OVER PHONE TO COUNT ONLY NON-REJECTED CLAIMS FOR ALL CLAIM TYPES
  --ADDED IF-CONDITION BY AKSHAY ON 16/04/2019 TO COUNT ONLY NON-REJECTED CLAIMS FOR ADVANCE. QUERY FOR ADVANCE IS ADDED IN CASE STATEMENT BELOW --REF:- E-MAIL BY MR. GAURAV MEENA ON 12-04-2019
--  IF FORM_TYPE=01 OR FORM_TYPE=04 THEN
--    SELECT COUNT(*) INTO V_CLAIM_COUNT FROM OCS_CLAIM_DATA WHERE CLAIM_FORM_TYPE=FORM_TYPE
--    AND UAN=IN_UAN AND PDB_UPDATE_FLAG='Y';
--  END IF;


  --ADDED BY AKSHAY ON 28/06/2019       --REF MAIL FROM HARSH SIR TO SANDESH SIR DATED 08/05/2019  --IN MAIL IT IS MENTIONED TO ALLOW ONLY 10C FOR MEMBER WITH EXEMPTED ESTABLISHMENT, BUT IT IS INFORMED OVER PHONE CALL TO ALLOW 10D AS WELL
--  IF FORM_TYPE <> 04 AND FORM_TYPE <> 03 THEN --ADDED BY AKSHAY ON 28/06/2019
--    V_LATEST_MEMID:=last_mid(IN_UAN);
--    -- CHECK WHETHER EST IS EXEMPTED OR NOT
--    SELECT DISTINCT NVL(PF_EXEMPTED,'N')||NVL(PENSION_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(V_LATEST_MEMID,0,15);
--    -- this is just for testing V_EXM := 'NN';
--
--    IF V_EXM<>'NN' THEN
--      OUTPUT:='As your establishment is exempted in PF, please submit your withdrawal case to concerned Trust.';
--      OUT_OLS:=1;
--      GOTO EXIT_PROC;
--    END IF;
--  END IF;
  --ADDITION BY AKSHAY ON 28/06/2019 ENDED

  --ADDED BY AKSHAY ON 17/07/2019 TO ALLOW CLAIM FORM ONLY IF UNEXEMPTED FOR THAT TYPE I.E. PF UNEXEMPTION & PENSION UNEXEMPTION  --REF MAIL FROM HARSH SIR DATED 16/07/2019
  V_LATEST_MEMID:=last_mid(IN_UAN);
  
  IF DOJ_EPF > SYSDATE OR DOJ_EPS > SYSDATE THEN
    OUTPUT:='Date of joining EPF/EPS is greater than current date.';
    OUT_OLS:=1;
    GOTO EXIT_PROC;
  END IF;
  
  IF DOE_EPF > SYSDATE OR DOE_EPS > SYSDATE THEN
    OUTPUT:='Date of exit EPF/EPS is greater than current date.';
    OUT_OLS:=1;
    GOTO EXIT_PROC;
  END IF; 
  
  IF DOJ_EPF > DOE_EPF OR DOJ_EPS > DOE_EPS THEN
    OUTPUT:='Date of joining EPF/EPS is greater than Date of exit EPF/EPS.';
    OUT_OLS:=1;
    GOTO EXIT_PROC;
  END IF; 
  
  
  -- IF FORM_TYPE = 01 OR FORM_TYPE = 06 THEN --#ver4.25
  IF FORM_TYPE = 01 THEN
        -- CHECK WHETHER EST IS EXEMPTED IN PF OR NOT
    SELECT DISTINCT NVL(PF_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(V_LATEST_MEMID,0,15);
    IF V_EXM<>'N' THEN
      OUTPUT:='As your establishment is exempted in PF, please submit your withdrawal case to concerned Trust.';
      OUT_OLS:=1;
      GOTO EXIT_PROC;
    END IF;
  ELSIF FORM_TYPE = 03 OR FORM_TYPE = 04 THEN
        -- CHECK WHETHER EST IS EXEMPTED IN PENSION OR NOT
    SELECT DISTINCT NVL(PENSION_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(V_LATEST_MEMID,0,15);
    IF V_EXM<>'N' THEN
      OUTPUT:='As your establishment is exempted in pension, please submit your withdrawal case to concerned Trust.';
      OUT_OLS:=1;
      GOTO EXIT_PROC;
    END IF;
  END IF;
  --ADDITION BY AKSHAY ON 17/07/2019 ENDED

  --ADDED BY AKSHAY ON 17/07/2019 AFTER DISCUSSION WITH HARSH SIR OVER PHONE TO COUNT ONLY NON-REJECTED ONLINE CLAIMS FOR ALL CLAIM TYPES
--    SELECT
--      COUNT(*)   --#ver4.19
--    INTO
--      V_CLAIM_COUNT
--    FROM
--      OCS_CLAIM_DATA OCD
--    INNER JOIN OCS_CRD OCRD
--      ON OCD.TRACKING_ID = OCRD.TRACKING_ID
--    WHERE
--      OCD.CLAIM_FORM_TYPE = FORM_TYPE
--      AND OCD.UAN = IN_UAN
--      AND OCD.PDB_UPDATE_FLAG = 'Y'
--      -- AND OCRD.CLAIM_STATUS <> 4; --COMMENTED FOR --#ver2.9
--	  AND OCRD.CLAIM_STATUS NOT IN (4,6,7,8) --#ver2.9 --#ver4.16
--      AND CASE WHEN OCRD.CLAIM_STATUS = 5 AND OCRD.CLAIM_REVISED_STATUS = 'Y' THEN 0 ELSE 1 END = 1  --#ver4.0
--;
--   -- IF V_CLAIM_COUNT>=15 THEN   --ADDED BY AKSHAY ON 17/07/2019 TO EXTEND ONLINE CLAIMS LIMIT TO 15 --REF MAIL FROM HARSH SIR TO SANDESH SIR ON 17/07/2019
--   IF V_CLAIM_COUNT>=20 THEN   --#ver3.3 --#ver4.19
--    OUTPUT :='MAXIMUM NUMBER OF ONLINE CLAIM SUBMISSION HAVE BEEN EXEED, PLEASE SUBMIT CLAIM THROUGH PHYSICAL MODE';
--    OUT_OLS:=1;
--    GOTO EXIT_PROC;
--   END IF;
   --ADDITION BY AKSHAY ON 17/07/2019 ENDED


  CASE
    --******************************FORM 19**************************************************
  WHEN FORM_TYPE=01 THEN
    CASE
    --****************************Max number of Online Claim******
--    WHEN V_CLAIM_COUNT>=5 THEN  --COMMENTED BY AKSHAY ON 17/07/2019
--    WHEN V_CLAIM_COUNT>=15 THEN   --ADDED BY AKSHAY ON 17/07/2019 TO EXTEND ONLINE CLAIMS LIMIT TO 15 --REF MAIL FROM HARSH SIR TO SANDESH SIR ON 17/07/2019
--    OUTPUT :='MAXIMUM NUMBER OF ONLINE CLAIM SUBMISSION HAVE BEEN EXEED, PLEASE SUBMIT CLAIM THROUGH PHYSICAL MODE';
--    OUT_OLS:=1;
    WHEN DOJ_EPF IS NOT NULL AND DOE_EPF IS NOT NULL THEN
      --COMMENTED AFTER THE CLARIFICATION RECEIVED FROM VCS OVER CALL DATED 19/02/2019. CLARIFICATION: IF MEMBER'S AGE IS 58 OR MORE THEN ALLOW TO FILE THE CLAIM IRRESPECTIVE OF REASON_OF_LEAVING
--      IF MONTHS_BETWEEN(SYSDATE,DOE_EPF)>2 OR (IN_EXIT_REASON_CODE = 3 AND 58 <= GET_MEMBER_AGE(IN_UAN)) THEN                 --Ver. 1.4
--      IF MONTHS_BETWEEN(SYSDATE,DOE_EPF)>2 OR 58 <= GET_MEMBER_AGE(IN_UAN) THEN --COMMENTED ON 10/01/2020 TO CHANGE AGE TO 55 --#ver1.2
      SELECT REASON_OF_LEAVING INTO V_ROE FROM MEMBER WHERE MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22); --#ver4.21
      IF MONTHS_BETWEEN(SYSDATE,DOE_EPF)>2 OR 55 <= GET_MEMBER_AGE(IN_UAN) OR V_ROE = 4 THEN --ADDED ON 10/01/2020 TO CHANGE AGE TO 55 --#ver1.2

        SELECT TRUNC(MONTHS_BETWEEN(DOE_EPF,DOJ_EPF))
        INTO TOTAL_SERVICE_IN_MONTHS
        FROM DUAL;
    --***************************TDS DEDUCTION MESSAGE*******************09-08-2017***********

--#ver1.7
--     SELECT COUNT(PAN) INTO V_PAN_COUNT FROM UAN_REPOSITORY WHERE UAN=IN_UAN AND PAN_DEMO_VERIFICATION_STAT='S';
--    IF V_PAN_COUNT=1 THEN
--    SELECT PAN INTO V_PAN FROM UAN_REPOSITORY WHERE UAN=IN_UAN AND PAN_DEMO_VERIFICATION_STAT='S';
--    END IF;
  --ADDED ON 19/02/2020 --#ver1.7
    BEGIN
--      V_MK_PAN := PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(IN_UAN,2);
--      SELECT UR.PAN INTO V_PAN FROM UAN_REPOSITORY UR WHERE UR.UAN=IN_UAN AND UR.PAN = TRIM(V_MK_PAN);
      SELECT UR.PAN INTO V_PAN FROM UAN_REPOSITORY UR WHERE UR.UAN=IN_UAN;
    EXCEPTION 
      WHEN OTHERS THEN
        V_PAN := NULL;
    END;
    --ADDITION ON 18/02/2020 ENDS HERE
    CASE  WHEN ROUND(TOTAL_SERVICE_IN_MONTHS/12)<5 AND V_PAN IS NOT NULL AND LENGTH(V_PAN)=10 THEN
    OUTPUT:='Eligible for PF withdrawal';
    WHEN ROUND(TOTAL_SERVICE_IN_MONTHS/12)>=5 THEN
    OUTPUT:='Eligible for PF withdrawal';
    ELSE
    OUTPUT:='Member opted to submit the online claim without seeding PAN.';
    END CASE;
    --*****************END HERE**********TDS DEDUCTION MESSAGE*******************09-08-2017***********
    ELSE
      --COMMENTED AFTER THE CLARIFICATION RECEIVED FROM VCS OVER CALL DATED 19/02/2019. CLARIFICATION: IF MEMBER'S AGE IS 58 OR MORE THEN ALLOW TO FILE THE CLAIM IRRESPECTIVE OF REASON_OF_LEAVING
        /*
        IF IN_EXIT_REASON_CODE = 3 THEN   --Ver. 1.4
          OUTPUT :='DATE OF LEAVING IS LESS THAN 2 MONTHS FROM TODAY OR AGE SHOULD BE 58 YEARS OR MORE';
        ELSE
          OUTPUT :='DATE OF LEAVING IS LESS THAN 2 MONTHS FROM TODAY';
        END IF;
        */
--        OUTPUT :='DATE OF LEAVING IS LESS THAN 2 MONTHS FROM TODAY OR AGE SHOULD BE 58 YEARS OR MORE'; --COMMENTED ON 10/01/2020 TO CHANGE AGE TO 55 --#ver1.2
        OUTPUT :='DATE OF LEAVING IS LESS THAN 2 MONTHS FROM TODAY OR AGE SHOULD BE 55 YEARS OR MORE'; --ADDED ON 10/01/2020 TO CHANGE AGE TO 55 --#ver1.2
        OUT_OLS:=1;
      END IF;
    ELSE
      OUTPUT :='DATE OF JOIN OR DATE OF LEAVING NOT AVAILABLE';
      OUT_OLS:=1;
    END CASE;
    --******************************FORM 10C**************************************************
  --ADDED BY AKSHAY ON 26/04/2019 FOR 10D
  WHEN FORM_TYPE=03 THEN
    --ESIGNED NOMINATION MUST BE PRESENT
--    SELECT COUNT(1) INTO V_NOMINATION_COUNT FROM MEMBER_NOMINATION_DETAILS WHERE UAN= IN_UAN AND STATUS = 'E';
    V_NOMINATION_COUNT :=CEN_OCS_UTILITY.GET_NOMINATION_COUNT(IN_UAN); --#ver4.32
--    V_NOMINATION_COUNT:=0;  --ADDED FOR TESTING
    IF V_NOMINATION_COUNT = 0 THEN
      OUTPUT :='NOMINATION DETAILS NOT AVAILABLE';
      OUT_OLS:=1;
    ELSE
      --VALIDATE NOMINEE PHOTO
      SELECT
        COUNT(1)
      INTO
        V_NOMINEE_PHOTO_COUNT
      FROM
        MEM_NOMINATION_FAMILY_DETAILS
      WHERE
        NOMINATION_ID = (SELECT MAX(NOMINATION_ID)FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS = 'E')
        AND PHOTOGRAPH IS NULL
        AND NOMINATION_TYPE IN ('B','S');

      IF V_NOMINEE_PHOTO_COUNT <> 0 THEN
        OUTPUT :='NOMINEE PHOTOGRAPHS NOT AVAILABLE';
        OUT_OLS:=1;
      END IF;
    END IF;

    --VALIDATE MEMBER PHOTO



--1.0 Members Phto validation
        SELECT
                COUNT(1)
        INTO
                V_PHOTO_CNT
        FROM
                UP_ALT.MEMBER_PROFILE_PHOTO
        WHERE
                UAN = IN_UAN;

        IF V_PHOTO_CNT = 0 THEN
    IF OUTPUT IS NULL THEN
          OUTPUT :='E-NOMINATION WITH PHOTOGRAPH IS NOT AVAILABLE IN SYSTEM, CANNOT PROCEED.';
        ELSE
          OUTPUT := OUTPUT || ' E-NOMINATION WITH PHOTOGRAPH IS NOT AVAILABLE IN SYSTEM, CANNOT PROCEED.';
        END IF;
        OUT_OLS:=1;
        END IF;

    --  #ver4.39 Added OCS_UTILITY.VERIFY_DOJ_AT58_10D in CHECK_ELIGIBILITY procedure to allow member for filing claim at age of 58 yrs having multiple memberid without checking DOJ_EPS and DOE_EPS.
     IF  OUTPUT IS NULL THEN
        SELECT TO_CHAR(DOB,'dd-MM-yyyy') INTO V_DOB FROM UAN_REPOSITORY WHERE UAN = IN_UAN;
        CEN_OCS_UTILITY.VERIFY_DOJ_AT58_10D(IN_UAN,V_DOB,OUT_OLS,OUTPUT); --#ver4.29
        IF (OUT_OLS = '58' OR OUT_OLS = '5058' OR OUT_OLS = '57') THEN 
            OUT_OLS := 0;
            OUTPUT  := '';
     ELSE       

    --CALCULATE AGE AND CHECK WHETHER DOE_EPS IS AVAILABLE AGAINST ALL THE MEMBER IDS LINKED WITH THIS UAN IF AGE IS LESS THAN 58YRS
    IF  GET_MEMBER_AGE(IN_UAN) < 58 THEN
      SELECT
        COUNT(1)
      INTO
        V_DOE_NULL_COUNT
      FROM
        MEMBER
      WHERE
        UAN = IN_UAN
        AND DOE_EPS IS NULL;

      IF V_DOE_NULL_COUNT > 0 THEN
        IF OUTPUT IS NULL THEN
          OUTPUT :='DATE OF LEAVING EPS NOT AVAILABLE AGAINST ALL THE LINKED MEMBER ID.';
        ELSE
          OUTPUT := OUTPUT || ' DATE OF LEAVING EPS NOT AVAILABLE AGAINST ALL THE LINKED MEMBER ID.';
        END IF;
        OUT_OLS:=1;
      END IF;
    END IF;

    --DOJ_EPS FOR LATEST MEMBER_ID SHOULD BE PRESENT
    IF DOJ_EPS IS NULL THEN
      IF OUTPUT IS NULL THEN
        OUTPUT :='DATE OF JOINING EPS NOT AVAILABLE.';
      ELSE
        OUTPUT := OUTPUT || ' DATE OF JOINING EPS NOT AVAILABLE.';
      END IF;
      OUT_OLS:=1;
    END IF;

    --FATHER_HUSBAND_NAME AND RELATION SHOULD BE PRESENT
    SELECT
      FATHER_OR_HUSBAND_NAME,
      RELATION_WITH_MEMBER
    INTO
      V_FATHER_OR_HUSBAND_NAME,
      V_RELATION
    FROM
      UAN_REPOSITORY
    WHERE
      UAN = IN_UAN;

    IF  V_FATHER_OR_HUSBAND_NAME IS NULL THEN
      IF OUTPUT IS NULL THEN
        OUTPUT :='FATHER OR HUSBAND NAME NOT AVAILABLE.';
      ELSE
        OUTPUT := OUTPUT || ' FATHER OR HUSBAND NAME NOT AVAILABLE.';
      END IF;
      OUT_OLS:=1;
    END IF;

    IF  V_RELATION IS NULL THEN
      IF OUTPUT IS NULL THEN
        OUTPUT :='RELATION WITH RESPECT TO FATHER OR HUSBAND NAME NOT AVAILABLE.';
      ELSE
        OUTPUT := OUTPUT || ' RELATION WITH RESPECT TO FATHER OR HUSBAND NAME NOT AVAILABLE.';
      END IF;
      OUT_OLS:=1;
    END IF;
    END IF;
  END IF;

  WHEN FORM_TYPE=04 THEN
    CASE
     --****************************Max number of Online Claim******
--    WHEN V_CLAIM_COUNT>=5 THEN  --COMMENTED BY AKSHAY ON 17/07/2019
--    WHEN V_CLAIM_COUNT>=15 THEN   --ADDED BY AKSHAY ON 17/07/2019 TO EXTEND ONLINE CLAIMS LIMIT TO 15 --REF MAIL FROM HARSH SIR TO SANDESH SIR ON 17/07/2019
--
--    OUTPUT :='MAXIMUM NUMBER OF ONLINE CLAIM SUBMISSION HAVE BEEN EXEED, PLEASE SUBMIT CLAIM THROUGH PHYSICAL MODE';
--    OUT_OLS:=1;
    WHEN DOJ_EPS                          IS NOT NULL AND DOE_EPS IS NOT NULL THEN
--	SELECT ADD_MONTHS(DOB, 696) INTO V_DOE_EPS FROM UAN_REPOSITORY WHERE UAN=IN_UAN;
--	IF V_DOE_EPS IS NOT NULL AND DOE_EPS < V_DOE_EPS THEN --#ver4.12
--		V_DOE_EPS := DOE_EPS;
--	END IF;

  	-- #ver4.37
--    SELECT
--          COUNT(1) 
--       INTO
--          V_COUNT
--        FROM
--          OCS_CLAIM_DATA OCD
--        INNER JOIN OCS_CRD OCRD
--          ON OCD.TRACKING_ID = OCRD.TRACKING_ID
--        WHERE
--          OCD.UAN = IN_UAN AND
--          OCD.MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22) AND
--          OCD.CLAIM_FORM_TYPE = '04' AND
--          OCRD.CLAIM_STATUS = 5 AND
--          OCRD.CLAIM_REVISED_STATUS IS NULL AND
--          NVL(OCD.FORM_10C_APPLICATION_TYPE,'WB') = 'WB';
	
	    -- Yash Patidar Edits Here validate_10c
        SELECT
          COUNT(1) 
        INTO 
          V_NEW_10C_COUNT
        FROM 
          UNIFIED_PORTAL.CEN_OCS_FORM_10_C
        WHERE
          UAN = IN_UAN
          AND MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22)
          AND CLAIM_FORM_TYPE = '04'
          AND CLAIM_STATUS IN ('N','P','E');
     IF(V_NEW_10C_COUNT > 0) THEN
          OUTPUT :='PENSION WITHDRAWAL BENEFIT CLAIM IS ALREADY SETTLED.';
          OUT_OLS:=1;
--     ELSIF(V_NEW_10C_COUNT > 0) then
--	      OUTPUT :='PENSION WITHDRAWAL BENEFIT CLAIM IS ALREADY SETTLED.';
--		  OUT_OLS:=1;
     ELSE        --#ver4.37  
	SELECT REASON_OF_LEAVING INTO V_ROE FROM MEMBER WHERE MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22); --#ver4.23
	TOTAL_SERVICE_IN_MONTHS := CEN_OCS_UTILITY.FORM_10C_SERVICE_CALC(IN_UAN); --#ver4.24
        --IF MONTHS_BETWEEN(SYSDATE,DOE_EPS)   >2 AND MONTHS_BETWEEN(DOE_EPS,DOJ_EPS)>=6 THEN   --COMMENTED ON 12/06/2019
--      IF (MONTHS_BETWEEN(SYSDATE,DOE_EPS)   >2 OR 58 <= GET_MEMBER_AGE(IN_UAN))AND MONTHS_BETWEEN(DOE_EPS,DOJ_EPS)>=6 THEN              --AS DISCUSSED WITH MS. SMITA SONI OVER PHONE CALL, THERE SHOULD NOT BE A 2 MONTHS WAITING PERIOD FOR FORM-10C IF MEMBER'S AGE IS 58 OR MORE.  --ADDED GET_MEMBER_AGE CONDITION ON 12/06/2019 --COMMENTED ON 10/01/2020 TO CHANGE AGE TO 55 --#ver1.2
--      IF (MONTHS_BETWEEN(SYSDATE,DOE_EPS)   >2 OR 55 <= GET_MEMBER_AGE(IN_UAN))AND MONTHS_BETWEEN(NVL(V_DOE_EPS, DOE_EPS),DOJ_EPS)>=6 OR V_ROE = 4 THEN  --ADDED ON 10/01/2020 TO CHANGE AGE FROM 58 TO 55 --REF EMAIL FROM SMITA SONI TO SANDESH SIR DATED 09/01/2020
	IF (MONTHS_BETWEEN(SYSDATE,DOE_EPS) > 2 OR 55 <= GET_MEMBER_AGE(IN_UAN) OR V_ROE = 4) THEN  --New Service Calculation --#ver4.24
        IF TOTAL_SERVICE_IN_MONTHS >= 6 AND TOTAL_SERVICE_IN_MONTHS < 114 THEN --#ver4.24
--        IF MONTHS_BETWEEN(NVL(V_DOE_EPS, DOE_EPS),DOJ_EPS) < 114 THEN
          OUTPUT :='Eligible for PENSION withdrawal';
--          SELECT TRUNC(MONTHS_BETWEEN(NVL(V_DOE_EPS, DOE_EPS),DOJ_EPS))
--          INTO TOTAL_SERVICE_IN_MONTHS
--          FROM DUAL;
        ELSE
          OUTPUT :='TOTAL SERVICE IS GREATER THAN OR EQUAL TO 9.5 YEAR OR SERVICE LENGTH IS LESS THAN 6 MONTHS';
          OUT_OLS:=1;
        END IF;
      ELSE
        OUTPUT :='DATE OF LEAVING IS LESS THAN 2 MONTHS FROM TODAY OR TOTAL SERVICE IS LESS THAN 6 MONTHS';
        OUT_OLS:=1;
      END IF;   --#ver4.37
      END IF;
    ELSE
      OUTPUT :='DATE OF LEAVING EPS OR DATE OF JOINING EPS IS NOT AVAILABLE';
      OUT_OLS:=1;
    END CASE;
  WHEN FORM_TYPE=44 THEN  --#ver4.29

          --ESIGNED NOMINATION MUST BE PRESENT
--          SELECT COUNT(1) INTO V_NOMINATION_COUNT FROM MEMBER_NOMINATION_DETAILS WHERE UAN= IN_UAN AND STATUS = 'E';
            V_NOMINATION_COUNT :=CEN_OCS_UTILITY.GET_NOMINATION_COUNT(IN_UAN); --#ver4.32
      --    V_NOMINATION_COUNT:=0;  --ADDED FOR TESTING
          IF V_NOMINATION_COUNT = 0 THEN
            OUTPUT :='NOMINATION DETAILS NOT AVAILABLE';
            OUT_OLS:=1;
          ELSE
            OUTPUT :='';
            OUT_OLS:=0;
          END IF;
    --******************************FORM 31**************************************************
  WHEN FORM_TYPE=06 THEN
    --ADDED BY AKSHAY ON 16/04/2019 TO COUNT ONLY NON-REJECTED CLAIMS --REF:- E-MAIL BY MR. GAURAV MEENA ON 12-04-2019
--    SELECT
--      COUNT(*)
--    INTO
--      V_CLAIM_COUNT
--    FROM
--      OCS_CLAIM_DATA OCD
--    INNER JOIN OCS_CRD OCRD
--      ON OCD.TRACKING_ID = OCRD.TRACKING_ID
--    WHERE
--      OCD.CLAIM_FORM_TYPE = FORM_TYPE
--      AND OCD.UAN = IN_UAN
--      AND OCD.PDB_UPDATE_FLAG = 'Y'
--      AND OCRD.CLAIM_STATUS <> 4;
    --ADDITION BY AKSHAY ON 16/04/2019 ENDED

	--#ver3.8
    SELECT DOE_EPF INTO V_DOE_EPF_LATEST FROM MEMBER WHERE MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22); --ADDED FOR FINAL SUBMIT AFTER MEMBER ID SELECTION LAUNCHED FOR FORM-31. --UNABLE TO PASS DOE_EPF OF LATEST MEMBER ID FROM FINAL SUBMIT
    CASE
     --****************************Max number of Online Claim******
--    WHEN V_CLAIM_COUNT>=5 THEN  --COMMENTED BY AKSHAY ON 17/07/2019
--    WHEN V_CLAIM_COUNT>=15 THEN   --ADDED BY AKSHAY ON 17/07/2019 TO EXTEND ONLINE CLAIMS LIMIT TO 15 --REF MAIL FROM HARSH SIR TO SANDESH SIR ON 17/07/2019
--
--    OUTPUT :='MAXIMUM NUMBER OF ONLINE CLAIM SUBMISSION HAVE BEEN EXEED, PLEASE SUBMIT CLAIM THROUGH PHYSICAL MODE';
--    OUT_OLS:=1;
--    WHEN DOJ_EPF                        IS NOT NULL AND DOE_EPF IS NULL THEN    --COMMENTED BY AKSHAY ON 20/09/2019 TO ADD 68HH IN PURPOSE FOR PF ADVANCE
--  WHEN DOJ_EPF                        IS NOT NULL THEN  --ADDED BY AKSHAY ON 20/09/2019 TO ADD 68HH IN PURPOSE FOR PF ADVANCE
--    WHEN DOJ_EPF IS NOT NULL AND DOE_EPF IS NULL THEN  --ADDED ON 25/09/2019 --TO CALCULATE TOTAL SERVICE FROM MIN(DOJ_EPF) TO SYSDATE IN CASE THE DOE_EPF IS NULL --COMMENTED ON 10/06/2020
    WHEN DOJ_EPF IS NOT NULL AND V_DOE_EPF_LATEST IS NULL THEN  --ADDED ON 10/06/2019 --#ver3.8
     IF MONTHS_BETWEEN(SYSDATE,DOJ_EPF)>=0 THEN
        OUTPUT                          :='Eligible for advance';
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE,DOJ_EPF))
        INTO TOTAL_SERVICE_IN_MONTHS
        FROM DUAL;
      ELSE
        OUTPUT :='TOTAL SERVICE IS LESS THAN 5 YEAR';
        OUT_OLS:=1;
      END IF;
--    WHEN DOJ_EPF IS NOT NULL AND DOE_EPF IS NOT NULL THEN  --ADDED ON 25/09/2019 --TO CALCULATE TOTAL SERVICE FROM MIN(DOJ_EPF) TO MAX(DOE_EPF) IN CASE THE DOE_EPF IS NOT NULL --COMMENTED ON 10/06/2020
    WHEN DOJ_EPF IS NOT NULL AND V_DOE_EPF_LATEST IS NOT NULL THEN  --ADDED ON 10/06/2019 --#ver3.8
--      IF MONTHS_BETWEEN(DOE_EPF,DOJ_EPF)>=0 THEN --COMMENTED ON 10/06/2019
      IF MONTHS_BETWEEN(V_DOE_EPF_LATEST,DOJ_EPF)>=0 THEN --ADDED ON 10/06/2019 --#ver3.8
        OUTPUT                          :='Eligible for advance';
--        SELECT TRUNC(MONTHS_BETWEEN(DOE_EPF,DOJ_EPF)) --COMMENTED ON 10/06/2019
        SELECT TRUNC(MONTHS_BETWEEN(V_DOE_EPF_LATEST,DOJ_EPF)) --ADDED ON 10/06/2019 --#ver3.8
        INTO TOTAL_SERVICE_IN_MONTHS
        FROM DUAL;
      ELSE
        OUTPUT :='TOTAL SERVICE IS LESS THAN 5 YEAR';
        OUT_OLS:=1;
      END IF;
    ELSE
      OUTPUT :='NOT ELIGIBLE FOR ADVANCE';
      OUT_OLS:=1;
    END CASE;
  END CASE;
  <<EXIT_PROC>>
  NULL;
END CHECK_ELIGIBILITY;

--*************************************************************END CHECK_ELIGIBILITY***********************************************************
--***************************************************************************GET_SCHEME_PARA PROCEDURE START HERE *************************
PROCEDURE GET_SCHEME_PARA(
    IN_UAN    IN NUMBER,
    DOJ_EPF   IN DATE,
    DOJ_EPS   IN DATE,
    DOE_EPF   IN DATE,
    DOE_EPS   IN DATE,
    FORM_TYPE IN NUMBER,
    OUT_OLS OUT NUMBER,
    OUTPUT OUT SYS_REFCURSOR,
    OUTPUT_STATUS OUT VARCHAR2)

AS
  TOTAL_SERVICE_IN_MONTHS NUMBER;
  IN_OUTPUT               VARCHAR2(4000);       --Ver. 1.4  --Changed by Akshay --varchar2(100) changed to varchar2(4000)
  V_DATE_OF_BIRTH         DATE;
  --******************MULTIPLE MEMBER ID**
    V_LATEST_MEMID VARCHAR2(24);
    V_DOJ_EPF      DATE;
    V_DOJ_EPS      DATE;  --#ver4.29
    V_DOE_EPS      DATE;  --#ver4.29
    V_PENDING_CLAIM_COUNT NUMBER(2):=0; --#ver2.5
     V_MEMBERSHIP NUMBER(3):=0;   --#ver4.8
     V_NOMINATION_COUNT NUMBER(2):=0;
BEGIN
  OUT_OLS                :=0;
  OUTPUT_STATUS          :='';
  TOTAL_SERVICE_IN_MONTHS:=0;
  IN_OUTPUT              :='';
  --******************MULTIPLE MEMBER ID**
  V_LATEST_MEMID:=last_mid(IN_UAN);

 CASE
    --***************************************FORM 19 START HERE*****************
  WHEN FORM_TYPE    =01 THEN
--    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, DOJ_EPF, DOJ_EPS, DOE_EPF, DOE_EPS, V_MEMBER_EXIT_REASON_CODE, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);     --Ver. 1.4
    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, DOJ_EPF, DOJ_EPS, DOE_EPF, DOE_EPS, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);                              --Ver. 1.4
    IF OUT_OLS      =0 THEN
      OUTPUT_STATUS:=IN_OUTPUT;
      OPEN OUTPUT FOR SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      'NA'
    AS
      MAX_EE_PERCENT,
      'NA'
    AS
      MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      'NA'
    AS
      NO_OF_MONTHS,
      'NA'
    AS
      MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT 0   AS ELIGIBLE,
        IN_OUTPUT AS ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=01
      )SPM_FINAL WHERE PARA_CC IN ('1217-','1221-','1223-','1224-','1225-','1222-','1229-','1232-','1234-');
     -- OUTPUT_STATUS:='ELIGIBLE FOR ONLINE CLAIM';
    ELSE
      OPEN OUTPUT FOR SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      'NA'
    AS
      MAX_EE_PERCENT,
      'NA'
    AS
      MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      'NA'
    AS
      NO_OF_MONTHS,
      'NA'
    AS
      MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT 1   AS ELIGIBLE,
        IN_OUTPUT AS ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=01
      )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','914-','1015-','6516-','6517-');
      OUT_OLS      :=1;
      OUTPUT_STATUS:=IN_OUTPUT;
    END IF;
    --***************************************FORM 19 END HERE*****************
    --***************************************FORM 10D START HERE*****************
  WHEN FORM_TYPE    =03 THEN
    CHECK_ELIGIBILITY(IN_UAN,FORM_TYPE,DOJ_EPF,DOJ_EPS,DOE_EPF,DOE_EPS,TOTAL_SERVICE_IN_MONTHS,IN_OUTPUT,OUT_OLS);
    OUTPUT_STATUS:=IN_OUTPUT;
--    IF OUT_OLS      =0 THEN

      OPEN OUTPUT FOR SELECT SPM_FINAL.PARA_CODE,
        SPM_FINAL.SUB_PARA_CODE,
        SPM_FINAL.SUB_PARA_CATEGORY,
        SPM_FINAL.PARA_DESCRIPTION,
        'NA'
      AS
        MAX_EE_PERCENT,
        'NA'
      AS
        MAX_ER_PERCENT,
        SPM_FINAL.PARA_DETAILS,
        'NA'
      AS
        NO_OF_MONTHS,
        'NA'
      AS
        MAX_NUMBER,
        SPM_FINAL.ELIGIBLE,
        SPM_FINAL.ELIGIBILITY_MESSAGE FROM
        (SELECT 1   AS ELIGIBLE,
          IN_OUTPUT AS ELIGIBILITY_MESSAGE,
          SPM.PARA_CODE
          ||SUB_PARA_CODE
          ||SUB_PARA_CATEGORY PARA_CC,
          SPM.*
        FROM SCHEME_PARA_MASTER SPM
        WHERE FORM_TYPE=01
        )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','914-','1015-','6516-','6517-');
--     ELSE
--
--     END IF;
  WHEN FORM_TYPE    =04 THEN
  --Replaced DOJ_EPF to DOJ_EPS**************on 22-Feb-2018*********by Pankaj Kumar********
    SELECT MIN(DOJ_EPS) INTO V_DOJ_EPF FROM MEMBER WHERE UAN=IN_UAN AND DOJ_EPS IS NOT NULL AND EST_SLNO <> 0; --#ver4.14
--    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, DOJ_EPF, V_DOJ_EPF, DOE_EPF, DOE_EPS, V_MEMBER_EXIT_REASON_CODE, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);   --Ver. 1.4
    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, DOJ_EPF, V_DOJ_EPF, DOE_EPF, DOE_EPS, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);            --Ver. 1.4
    IF OUT_OLS      =0 THEN
      OUTPUT_STATUS:=IN_OUTPUT;
      OPEN OUTPUT FOR SELECT 0
    AS
      ELIGIBLE,
      IN_OUTPUT
    AS
      ELIGIBILITY_MESSAGE FROM DUAL;
    ELSE
      OPEN OUTPUT FOR SELECT 1
    AS
      ELIGIBLE,
      IN_OUTPUT
    AS
      ELIGIBILITY_MESSAGE FROM DUAL;
      OUT_OLS      :=1;
      OUTPUT_STATUS:=IN_OUTPUT;
    END IF;
    --***************************************FORM 10C END HERE*****************
    --***************************************FORM 10CSC START HERE***************** --#ver4.29
    WHEN FORM_TYPE    = 44 THEN
    SELECT DOJ_EPS,DOE_EPS INTO V_DOJ_EPS, V_DOE_EPS FROM MEMBER WHERE MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22);
    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, DOJ_EPF, V_DOJ_EPS, DOE_EPF, V_DOE_EPS, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);            --Ver. 1.4
    IF OUT_OLS      =0 THEN
      OUTPUT_STATUS:=IN_OUTPUT;
      OPEN OUTPUT FOR SELECT 0
    AS
      ELIGIBLE,
      IN_OUTPUT
    AS
      ELIGIBILITY_MESSAGE FROM DUAL;
    ELSE
      OPEN OUTPUT FOR SELECT 1
    AS
      ELIGIBLE,
      IN_OUTPUT
    AS
      ELIGIBILITY_MESSAGE FROM DUAL;
      OUT_OLS      :=1;
      OUTPUT_STATUS:=IN_OUTPUT;
    END IF;
    --***************************************FORM 10CSC END HERE*****************
    --***************************************FORM 31 START HERE*****************
  WHEN FORM_TYPE    =06 THEN
  -- FOLLOWING FUNCTION CALL FOR CALCULATING MEMBERSHIP IN month ADDED ON 02/09/2020   --#ver4.8
   V_MEMBERSHIP:= FETCH_MEMBERSHIP(IN_UAN);    
    SELECT MIN(DOJ_EPF) INTO V_DOJ_EPF FROM MEMBER WHERE UAN=IN_UAN AND DOJ_EPF IS NOT NULL AND EST_SLNO <> 0; --#ver4.14
--    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, V_DOJ_EPF, DOJ_EPS, DOE_EPF, DOE_EPS, V_MEMBER_EXIT_REASON_CODE, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);   --Ver. 1.4
    CHECK_ELIGIBILITY(IN_UAN, FORM_TYPE, V_DOJ_EPF, DOJ_EPS, DOE_EPF, DOE_EPS, TOTAL_SERVICE_IN_MONTHS, IN_OUTPUT, OUT_OLS);            --Ver. 1.4
    IF OUT_OLS      >0 THEN--NOT eligible condition
      OUT_OLS      :=1;
      OUTPUT_STATUS:=IN_OUTPUT;
      OPEN OUTPUT FOR SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
          AND SPM.SERVICE_MONTHS IS NOT NULL
          THEN 1
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
          AND SPM.SERVICE_MONTHS IS NOT NULL
          THEN IN_OUTPUT
          ELSE 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','914-','1015-','6516-','6517-');
    END IF;

      IF OUT_OLS      =0 THEN
--COMMENTED ON 25/09/2019 TO DISPLAY ALL PARA FOR EXITED MEMBER		--REF MAIL FROM SMITA SONI TO SANDESH SIR ON 23/09/2019
--        IF DOE_EPF IS NOT NULL THEN
--          OUTPUT_STATUS:=IN_OUTPUT;
--          OPEN OUTPUT FOR
--          --ADDED BY AKSHAY ON 20/09/2019 TO ADD 68HH IN PURPOSE OF ADVANCE
--          SELECT SPM_FINAL.PARA_CODE,
--          SPM_FINAL.SUB_PARA_CODE,
--          SPM_FINAL.SUB_PARA_CATEGORY,
--          SPM_FINAL.PARA_DESCRIPTION,
--          SPM_FINAL.MAX_EE_PERCENT,
--          SPM_FINAL.MAX_ER_PERCENT,
--          SPM_FINAL.PARA_DETAILS,
--          SPM_FINAL.NO_OF_MONTHS,
--          SPM_FINAL.MAX_NUMBER,
--          SPM_FINAL.ELIGIBLE,
--          SPM_FINAL.ELIGIBILITY_MESSAGE FROM
--          (SELECT
--            CASE
--              WHEN DOE_EPF IS NOT NULL AND MONTHS_BETWEEN (SYSDATE, DOE_EPF) > 1  and GET_68HH_CLAIMS_THR_LAST_ESTAB(IN_UAN,FORM_TYPE) = 0 --ONLY ONE CLAIM FOR THIS ESTABLISHMENT   --PENDING
--              THEN 0
--              ELSE 1
--            END ELIGIBLE,
--            CASE
--              WHEN DOE_EPF IS NULL
--                THEN 'DATE OF EXIT SHOULD BE AVAILABLE IN THE LAST EMPLOYMENT'
--              WHEN MONTHS_BETWEEN (SYSDATE, DOE_EPF) <= 1
--                THEN 'DIFFERENCE BETWEEN DATE OF CLAIM AND DATE OF EXIT SHOULD BE MORE THAN ONE MONTH'
--              WHEN GET_68HH_CLAIMS_THR_LAST_ESTAB(IN_UAN,FORM_TYPE) > 0   --ONLY ONE CLAIM FOR THIS ESTABLISHMENT   --PENDING
--                THEN 'Only one claim is allowed against one establishment'
--              ELSE 'PRECONDITIONS FULFILLED'
--            END ELIGIBILITY_MESSAGE,
--            SPM.PARA_CODE
--            ||SUB_PARA_CODE
--            ||SUB_PARA_CATEGORY PARA_CC,
--            SPM.*
--          FROM SCHEME_PARA_MASTER SPM
--          WHERE FORM_TYPE=06
--          )SPM_FINAL WHERE PARA_CC IN ('411-')
--          ;
--        ELSE
          OUTPUT_STATUS:=IN_OUTPUT;

      --#ver2.5  
      --DECIDE WHETHER TO ALLOW ALL THE SCHEME PARAS OR ONLY COVID-19
      --IF NON-COVID-19 CLAIM IS PENDING THEN ALLOW ONLY COVID-19 PARA
      --IF COVID-19 CLAIM IS PENDING THEN DO NOT ALLOW TO FILE ADVANCE CLAIM
      --IF NO CLAIM IS PENDING THEN ALLOW ALL THE SCHEME PARAS
      SELECT 
        COUNT(1)
      INTO
        V_PENDING_CLAIM_COUNT
      FROM
        CEN_OCS_FORM_31 COF31
--        OCS_CLAIM_DATA OCD,
--        OCS_CRD C--,
--        OCS_CLAIM_STATUS_MASTER S,
--        FORM_TYPE_MASTER F,
--        OCS_CLAIM_STATUS_LOG L 
      WHERE 
--        OCD.TRACKING_ID = C.TRACKING_ID AND
--        C.CLAIM_STATUS =S.CLAIM_STATUS AND 
--        C.CLAIM_FORM_TYPE=F.FORM_TYPE AND 
--        L.TRACKING_ID =C.TRACKING_ID AND 
--        L.CLAIM_STATUS =C.CLAIM_STATUS AND 
        COF31.UAN =IN_UAN AND 
        COF31.CLAIM_FORM_TYPE='06' AND 
        COF31.CLAIM_STATUS IN ('N','P','E')
        ;

--        SELECT COUNT(1) INTO V_NOMINATION_COUNT FROM MEMBER_NOMINATION_DETAILS WHERE UAN= IN_UAN AND STATUS = 'E';
        -- V_NOMINATION_COUNT :=OCS_UTILITY.GET_NOMINATION_COUNT(IN_UAN); --#ver4.32
       V_NOMINATION_COUNT := 1;  --ADDED FOR BYPASS NOMINATION CHECK --#ver4.33
      IF V_PENDING_CLAIM_COUNT > 0 THEN
        --NON-COVID-19 CLAIM IS PENDING
        --ALLOW ONLY COVID-19, OTHER PARAS WILL BE DISPLAYED AS DISABLED
        OPEN OUTPUT FOR 
        SELECT 
          SPM_FINAL.PARA_CODE,
          SPM_FINAL.SUB_PARA_CODE,
          SPM_FINAL.SUB_PARA_CATEGORY,
          SPM_FINAL.PARA_DESCRIPTION,
          SPM_FINAL.MAX_EE_PERCENT,
          SPM_FINAL.MAX_ER_PERCENT,
          SPM_FINAL.PARA_DETAILS,
          SPM_FINAL.NO_OF_MONTHS,
          SPM_FINAL.MAX_NUMBER,
          SPM_FINAL.ELIGIBLE,
          SPM_FINAL.ELIGIBILITY_MESSAGE FROM
          (SELECT
          CASE
			WHEN V_NOMINATION_COUNT=0 --ver#4.32
             THEN 1
--            WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) = 0
            WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2 --#ver4.20
              THEN 0
            ELSE 1
          END ELIGIBLE,
          CASE
			 WHEN (V_NOMINATION_COUNT = 0) --ver#4.32
               THEN 'NOMINATION DETAILS NOT AVAILABLE' 
--            WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) > 0 
            WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) >= 2  --#ver4.20
--              THEN 'Only one advance is admissible under this paragraph'   --#ver4.20
              THEN 'Only two advances are admissible under this paragraph'   --#ver4.0
--		THEN 'One PF Advance(Form-31) claim is already pending.'	--#ver3.2
          ELSE 
            'SERVICE OK'
          END ELIGIBILITY_MESSAGE,
          SPM.PARA_CODE
          ||SUB_PARA_CODE
          ||SUB_PARA_CATEGORY PARA_CC,
          SPM.*
          FROM SCHEME_PARA_MASTER SPM
          WHERE FORM_TYPE=06
          )SPM_FINAL WHERE PARA_CC IN ('8133')
          --ADDITION ON 29/03/2020 ENDED
          union all
          SELECT SPM_FINAL.PARA_CODE,
          SPM_FINAL.SUB_PARA_CODE,
          SPM_FINAL.SUB_PARA_CATEGORY,
          SPM_FINAL.PARA_DESCRIPTION,
          SPM_FINAL.MAX_EE_PERCENT,
          SPM_FINAL.MAX_ER_PERCENT,
          SPM_FINAL.PARA_DETAILS,
          SPM_FINAL.NO_OF_MONTHS,
          SPM_FINAL.MAX_NUMBER,
          SPM_FINAL.ELIGIBLE,
          SPM_FINAL.ELIGIBILITY_MESSAGE FROM
          (SELECT
            1 ELIGIBLE,
            'One PF Advance(Form-31) claim is already pending.' ELIGIBILITY_MESSAGE,
            SPM.PARA_CODE
            ||SUB_PARA_CODE
            ||SUB_PARA_CATEGORY PARA_CC,
            SPM.*
          FROM SCHEME_PARA_MASTER SPM
          WHERE FORM_TYPE=06
          )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','1015-','914-','6516-','411-')
          ;
        --ADDED ON 17/12/2021  IF NOMINATION IS NOT AVAILABLE - DONT ALLOW CLAIM EXCEPT ILLNESS
      ELSIF V_NOMINATION_COUNT=0 THEN
        OPEN OUTPUT FOR     
        SELECT 
			SPM_FINAL.PARA_CODE,
			SPM_FINAL.SUB_PARA_CODE,
			SPM_FINAL.SUB_PARA_CATEGORY,
			SPM_FINAL.PARA_DESCRIPTION,
			SPM_FINAL.MAX_EE_PERCENT,
			SPM_FINAL.MAX_ER_PERCENT,
			SPM_FINAL.PARA_DETAILS,
			SPM_FINAL.NO_OF_MONTHS,
			SPM_FINAL.MAX_NUMBER,
			SPM_FINAL.ELIGIBLE,
			SPM_FINAL.ELIGIBILITY_MESSAGE FROM
			(SELECT
                1 AS ELIGIBLE,
				'NOMINATION DETAILS NOT AVAILABLE' AS ELIGIBILITY_MESSAGE,
			SPM.PARA_CODE
			||SUB_PARA_CODE
			||SUB_PARA_CATEGORY PARA_CC,
			SPM.*
			FROM SCHEME_PARA_MASTER SPM
			WHERE FORM_TYPE=06
            )SPM_FINAL WHERE PARA_CC NOT IN ('511-')
            UNION ALL 
		SELECT 
			SPM_FINAL.PARA_CODE,
			SPM_FINAL.SUB_PARA_CODE,
			SPM_FINAL.SUB_PARA_CATEGORY,
			SPM_FINAL.PARA_DESCRIPTION,
			SPM_FINAL.MAX_EE_PERCENT,
			SPM_FINAL.MAX_ER_PERCENT,
			SPM_FINAL.PARA_DETAILS,
			SPM_FINAL.NO_OF_MONTHS,
			SPM_FINAL.MAX_NUMBER,
			SPM_FINAL.ELIGIBLE,
			SPM_FINAL.ELIGIBILITY_MESSAGE FROM
			(SELECT
			CASE
          WHEN (SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
          OR SPM.SERVICE_MONTHS  IS NULL) AND COUNT_ILLNESS_ADVNCE_IN_30DAYS(IN_UAN) = 0
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (SPM.SERVICE_MONTHS>TOTAL_SERVICE_IN_MONTHS)
            THEN 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
          WHEN (COUNT_ILLNESS_ADVNCE_IN_30DAYS(IN_UAN) > 0) 
            THEN 'CLAIM APPROVED WITHIN ONE MONTH'  
          ELSE 
            'SERVICE OK'
        END ELIGIBILITY_MESSAGE,
			SPM.PARA_CODE
			||SUB_PARA_CODE
			||SUB_PARA_CATEGORY PARA_CC,
			SPM.*
			FROM SCHEME_PARA_MASTER SPM
			WHERE FORM_TYPE=06
			)SPM_FINAL WHERE PARA_CC IN ('511-');


		ELSE


        --NO CLAIM IS PENDING ALLOW ALL THE PARAS
      --*************************DATE OF BIRTH******CHANGED HAS BEEN MADE IN BELLOW CODE TO HANDLE MULTIPLE MEM ID********************
		SELECT DOB INTO V_DATE_OF_BIRTH FROM UAN_REPOSITORY WHERE UAN=IN_UAN;--14-DEC-2017
		OPEN OUTPUT FOR
		  --ADDED ON 29/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR COVID-19 CORONAVIRUS REASON	--#ver2.0      
		SELECT 
			SPM_FINAL.PARA_CODE,
			SPM_FINAL.SUB_PARA_CODE,
			SPM_FINAL.SUB_PARA_CATEGORY,
			SPM_FINAL.PARA_DESCRIPTION,
			SPM_FINAL.MAX_EE_PERCENT,
			SPM_FINAL.MAX_ER_PERCENT,
			SPM_FINAL.PARA_DETAILS,
			SPM_FINAL.NO_OF_MONTHS,
			SPM_FINAL.MAX_NUMBER,
			SPM_FINAL.ELIGIBLE,
			SPM_FINAL.ELIGIBILITY_MESSAGE FROM
			(SELECT
			CASE
--				WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) = 0
                WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2 --#ver4.20
					THEN 0
				ELSE 1
			END ELIGIBLE,
			CASE
--				WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) > 0 
                WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) >= 2 --#ver4.20
					THEN 'Only two advances are admissible under this paragraph'   --#ver4.0
--					THEN 'One PF Advance(Form-31) claim is already pending.'  --#ver3.2
			ELSE 
				'SERVICE OK'
			END ELIGIBILITY_MESSAGE,
			SPM.PARA_CODE
			||SUB_PARA_CODE
			||SUB_PARA_CATEGORY PARA_CC,
			SPM.*
			FROM SCHEME_PARA_MASTER SPM
			WHERE FORM_TYPE=06
			)SPM_FINAL WHERE PARA_CC IN ('8133')
			--ADDITION ON 29/03/2020 ENDED
		UNION ALL
        SELECT 
			SPM_FINAL.PARA_CODE,
          SPM_FINAL.SUB_PARA_CODE,
          SPM_FINAL.SUB_PARA_CATEGORY,
          SPM_FINAL.PARA_DESCRIPTION,
          SPM_FINAL.MAX_EE_PERCENT,
          SPM_FINAL.MAX_ER_PERCENT,
          SPM_FINAL.PARA_DETAILS,
          SPM_FINAL.NO_OF_MONTHS,
          SPM_FINAL.MAX_NUMBER,
          SPM_FINAL.ELIGIBLE,
          SPM_FINAL.ELIGIBILITY_MESSAGE FROM
          (SELECT
            CASE
              WHEN SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
              OR SPM.SERVICE_MONTHS  IS NULL
              THEN 0
              ELSE 1
            END ELIGIBLE,
            CASE
              WHEN SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
              OR SPM.SERVICE_MONTHS  IS NULL
              THEN 'SERVICE OK'
              ELSE 'TOTAL SERVICE IS LESS THAN '
                ||SPM.SERVICE_MONTHS
                ||' MONTHS'
            END ELIGIBILITY_MESSAGE,
            SPM.PARA_CODE
            ||SUB_PARA_CODE
            ||SUB_PARA_CATEGORY PARA_CC,
            SPM.*
          FROM SCHEME_PARA_MASTER SPM
          WHERE FORM_TYPE=06
--      )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','914-','1015-')
--      )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','1015-')	--#ver4.0
  --    )SPM_FINAL WHERE PARA_CC IN ('24-','48-','612M','612E','813-','1015-')
        )SPM_FINAL WHERE PARA_CC IN ('48-','813-')  --revised filters for 24-,612M,612E,1015- BY SHIWANI  --#ver4.8
     UNION ALL --ADDED ON 29/03/2020 TO ALLOW ONLY ONE ADVANCE CLAIM FOR ILLNESS IN 30 DAYS    	--#ver4.0 
		SELECT 
			SPM_FINAL.PARA_CODE,
			SPM_FINAL.SUB_PARA_CODE,
			SPM_FINAL.SUB_PARA_CATEGORY,
			SPM_FINAL.PARA_DESCRIPTION,
			SPM_FINAL.MAX_EE_PERCENT,
			SPM_FINAL.MAX_ER_PERCENT,
			SPM_FINAL.PARA_DETAILS,
			SPM_FINAL.NO_OF_MONTHS,
			SPM_FINAL.MAX_NUMBER,
			SPM_FINAL.ELIGIBLE,
			SPM_FINAL.ELIGIBILITY_MESSAGE FROM
			(SELECT
			CASE
          WHEN (SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
          OR SPM.SERVICE_MONTHS  IS NULL) AND COUNT_ILLNESS_ADVNCE_IN_30DAYS(IN_UAN) = 0
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (SPM.SERVICE_MONTHS>TOTAL_SERVICE_IN_MONTHS)
            THEN 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
          WHEN (COUNT_ILLNESS_ADVNCE_IN_30DAYS(IN_UAN) > 0) 
            THEN 'CLAIM APPROVED WITHIN ONE MONTH'  
          ELSE 
            'SERVICE OK'
        END ELIGIBILITY_MESSAGE,
			SPM.PARA_CODE
			||SUB_PARA_CODE
			||SUB_PARA_CATEGORY PARA_CC,
			SPM.*
			FROM SCHEME_PARA_MASTER SPM
			WHERE FORM_TYPE=06
			)SPM_FINAL WHERE PARA_CC IN ('511-')
      --ADDED ON 02/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR POWER CUT REASON --#ver1.8
      UNION ALL
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          /*FOLLOWING COMMENTED ON 02/09/2020 TO APPLY NEW FILTER i.e. Date of exit should not be there
          (SPM.SERVICE_MONTHS<=TOTAL_SERVICE_IN_MONTHS
          OR SPM.SERVICE_MONTHS  IS NULL) */
          DOE_EPF IS NULL
          AND COUNT_CLAIM_FOR_POWERCUT(IN_UAN) = 0
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN 
           DOE_EPF IS NOT NULL
           THEN 'Employee with current employment can opt for this paragraph'
           /*FOLLOWING COMMENTED ON 02/09/2020 TO APPLY NEW FILTER i.e. Date of exit should not be there
          (SPM.SERVICE_MONTHS>TOTAL_SERVICE_IN_MONTHS)
            THEN 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
            */
          WHEN (COUNT_CLAIM_FOR_POWERCUT(IN_UAN) > 0) 
            THEN 'Only one advance is admissible under this paragraph'  
          ELSE 
            'SERVICE OK'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('914-')
      --ADDITION ON 02/03/2020 ENDED
      /*--ADDED ON 29/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR COVID-19 CORONAVIRUS REASON	--#ver1.9
      UNION ALL
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) = 0
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) > 0 
            THEN 'Only one advance is admissible under this paragraph'  
          ELSE 
            'SERVICE OK'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('8133')
      --ADDITION ON 29/03/2020 ENDED*/
          UNION ALL
          SELECT SPM_FINAL.PARA_CODE,
          SPM_FINAL.SUB_PARA_CODE,
          SPM_FINAL.SUB_PARA_CATEGORY,
          SPM_FINAL.PARA_DESCRIPTION,
          SPM_FINAL.MAX_EE_PERCENT,
          SPM_FINAL.MAX_ER_PERCENT,
          SPM_FINAL.PARA_DETAILS,
          SPM_FINAL.NO_OF_MONTHS,
          SPM_FINAL.MAX_NUMBER,
          SPM_FINAL.ELIGIBLE,
          SPM_FINAL.ELIGIBILITY_MESSAGE FROM
          (SELECT
            CASE
              WHEN TRUNC (MONTHS_BETWEEN (SYSDATE, V_DATE_OF_BIRTH) / 12)>=55
              THEN 0
              ELSE 1
            END ELIGIBLE,
            CASE
              WHEN TRUNC (MONTHS_BETWEEN (SYSDATE, V_DATE_OF_BIRTH) / 12)>=55
              THEN 'SERVICE OK FOR 90%WITHDRAWL'
              ELSE 'AGE IS  '
                ||TRUNC (MONTHS_BETWEEN (SYSDATE, V_DATE_OF_BIRTH) / 12)
                ||'YEARS ONLY,NOT ELIGIBLE'
            END ELIGIBILITY_MESSAGE,
            SPM.PARA_CODE
            ||SUB_PARA_CODE
            ||SUB_PARA_CATEGORY PARA_CC,
            SPM.*
          FROM SCHEME_PARA_MASTER SPM
          WHERE FORM_TYPE=06
          )SPM_FINAL WHERE PARA_CC IN ('6516-')

          UNION ALL   --ADDED BY AKSHAY ON 17/09/2019 TO ADD 68HH IN PURPOSE OF ADVANCE
          SELECT SPM_FINAL.PARA_CODE,
          SPM_FINAL.SUB_PARA_CODE,
          SPM_FINAL.SUB_PARA_CATEGORY,
          SPM_FINAL.PARA_DESCRIPTION,
          SPM_FINAL.MAX_EE_PERCENT,
          SPM_FINAL.MAX_ER_PERCENT,
          SPM_FINAL.PARA_DETAILS,
          SPM_FINAL.NO_OF_MONTHS,
          SPM_FINAL.MAX_NUMBER,
          SPM_FINAL.ELIGIBLE,
          SPM_FINAL.ELIGIBILITY_MESSAGE FROM
          (SELECT
            CASE
              WHEN DOE_EPF IS NOT NULL AND MONTHS_BETWEEN (SYSDATE, DOE_EPF) > 1  and GET_68HH_CLAIMS_THR_LAST_ESTAB(IN_UAN,FORM_TYPE) = 0 --ONLY ONE CLAIM FOR THIS ESTABLISHMENT   --PENDING
              THEN 0
              ELSE 1
            END ELIGIBLE,
            CASE
              WHEN DOE_EPF IS NULL
                THEN 'DATE OF EXIT SHOULD BE AVAILABLE IN THE LAST EMPLOYMENT'
              WHEN MONTHS_BETWEEN (SYSDATE, DOE_EPF) <= 1
                THEN 'DIFFERENCE BETWEEN DATE OF CLAIM AND DATE OF EXIT SHOULD BE MORE THAN ONE MONTH'
              WHEN GET_68HH_CLAIMS_THR_LAST_ESTAB(IN_UAN,FORM_TYPE) > 0   --ONLY ONE CLAIM FOR THIS ESTABLISHMENT   --PENDING
                THEN 'Only one claim is allowed against one establishment'
              ELSE 'PRECONDITIONS FULFILLED'
            END ELIGIBILITY_MESSAGE,
            SPM.PARA_CODE
            ||SUB_PARA_CODE
            ||SUB_PARA_CATEGORY PARA_CC,
            SPM.*
          FROM SCHEME_PARA_MASTER SPM
          WHERE FORM_TYPE=06
          )SPM_FINAL WHERE PARA_CC IN ('411-')
          /* COMMENTED FOR TEMP               --#ver4.8
 UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED  PARA 68B(1)(a),PARA 68B(1)(b),PARA 68B(1)(c),PARA 68BB,PARA 68BC,PARA 68BD  ADVANCE
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          V_MEMBERSHIP > SPM.SERVICE_MONTHS AND 
          SPM.MAX_NUMBER > GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN V_MEMBERSHIP <= SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN SPM.MAX_NUMBER <= GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'||V_MEMBERSHIP            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('37-','38-','39-')  */

         UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68K ADVANCE   --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND 
          3 > GET_CLAIM_COUNT_FOR_68K(IN_UAN)
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN 3 <= GET_CLAIM_COUNT_FOR_68K(IN_UAN)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('612E','612M')

       UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED 68N ADVANCE        --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN SPM.MAX_NUMBER > GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  and
          1 > COUNT_PARA68N_ADVNCE_IN_3YEARS(IN_UAN) 
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN  
        SPM.MAX_NUMBER <= GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)   
        THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
        when 1 <= COUNT_PARA68N_ADVNCE_IN_3YEARS(IN_UAN)
           THEN 'SECOND CLAIM WILL BE ALLOWED ONLY AFTER THREE YEARS OF FIRST CLAIM'          -- #ver4.11
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('1015-') 

      UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68B(1)(a),PARA 68B(1)(b) ADVANCE           --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND 
          SPM.MAX_NUMBER > nvl(COUNT_PARA68B1_CLAIMS(IN_UAN, null),0) 
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN SPM.MAX_NUMBER <= COUNT_PARA68B1_CLAIMS(IN_UAN, null)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('23-','25-','27-') 

       UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68B(1)(c) ADVANCE  --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND 
          SPM.MAX_NUMBER > nvl(COUNT_PARA68B1_CLAIMS(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY),0) 
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN SPM.MAX_NUMBER <= COUNT_PARA68B1_CLAIMS(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM 2 NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('24-') 

      UNION ALL   --ADDED BY SHIWANI ON 05/10/2020 FOR REVISED PARA 68B(7) ADVANCE   --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND 
          SPM.MAX_NUMBER >= GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  and   --ver4.10
          1 > nvl(COUNT_PARA68B7_ADVNCE(IN_UAN),0) 
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
          WHEN SPM.MAX_NUMBER <=  GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY) 
          then 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          WHEN 1 <= COUNT_PARA68B7_ADVNCE(IN_UAN)  
            THEN 'SECOND CLAIM WILL BE ALLOWED ONLY AFTER TEN YEARS OF FIRST CLAIM'
          ELSE 'PRECONDITIONS FULFILLED'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
      )SPM_FINAL WHERE PARA_CC IN ('26-') 
      ;
      END IF;--#ver2.5

END IF;
  END CASE;
  --***************************************FORM 31 START HERE*****************
END GET_SCHEME_PARA;
--****************************************************************GET_SERVICE_HISTORY_DISPLAY****************************
PROCEDURE GET_SERVICE_HISTORY_DISPLAY(
    IN_UAN IN NUMBER,
    OUT_SERVICE OUT SYS_REFCURSOR)
AS
  V_COUNT NUMBER;
  --HANDLE MULTIPLE MEMBER ID CASE*************************V_LATEST_MEMID
  V_LATEST_MEMID  VARCHAR2(24);
BEGIN
V_LATEST_MEMID:='';
  --SELECT COUNT(1) INTO V_COUNT FROM MEMBER WHERE UAN =IN_UAN;
  --IF V_COUNT >0 THEN
  --*************************CHANGED HAS BEEN MADE IN BELLOW LINE TO HANDLE MULTIPLE MEM ID*******************IF NOT DISPLAY ALL MEMBER ID CLIENT SIDE****
 V_LATEST_MEMID:=last_mid(IN_UAN); --Handled multiple member id cases alert message
  OPEN OUT_SERVICE FOR SELECT M.MEMBER_ID,
  M.STATUS,
  TO_CHAR(M.DOJ_EPF,'dd-mm-yyyy')
AS
  DOJ_EPF,
  TO_CHAR(M.DOJ_EPS,'dd-mm-yyyy')
AS
  DOJ_EPS,
  TO_CHAR(M.DOE_EPF,'dd-mm-yyyy')
AS
  DOE_EPF,
  TO_CHAR(M.DOE_EPS,'dd-mm-yyyy')
AS
  DOE_EPS,
  NVL(M.REASON_OF_LEAVING,'') LEAVE_REASON_CODE,
  NVL(MER.REASON,' ') LEAVE_REASON,
  NVL(MER.REASON_CODE,'') LEAVE_REASON_CHAR_CODE ,
--  NVL(PAN_DEMO_VERIFICATION_STAT,'') PAN_VERIFICATION_STATUS,	--#ver1.6
  CASE	--#ver1.6
--    WHEN PAN = PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(IN_UAN,2,'N') THEN 'S'
    WHEN TRIM(PAN) IS NOT NULL THEN 'S'   --#ver1.7
    ELSE 'D'
  END PAN_VERIFICATION_STATUS,
  (SELECT DISTINCT NVL(PF_EXEMPTED,'N')||NVL(PENSION_EXEMPTED,'N') FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(V_LATEST_MEMID,0,15)) AS PF_EXEMPTED
  FROM 
    MEMBER M 
  INNER JOIN UAN_REPOSITORY UR
    ON UR.UAN = M.UAN
  LEFT JOIN MEMBER_EXIT_REASON MER
    ON M.REASON_OF_LEAVING = MER.ID
  WHERE
    M.UAN=IN_UAN AND M.MEMBER_ID=SUBSTR(V_LATEST_MEMID,0,22);--14-DEC-2017
  --END IF;
  --NULL;
END GET_SERVICE_HISTORY_DISPLAY;
--****************************************************************END GET_SERVICE_HISTORY_DISPLAY****************************
--**************************************************************SAVE_CLAIM_DATA************

--FROM 06/12/2019, ONLY UMANG APP CLAIMS WILL GO THROUGH THIS PROCEDURE AND CLAIMS RECEIVED THROUGH UNIFIED_PORTAL WILL GO THROUGH SAVE_CLAIM_DATA_FOR_UP
PROCEDURE SAVE_CLAIM_DATA(
    IN_CLAIM_TYPE          IN OCS_CLAIM_DATA.CLAIM_FORM_TYPE%TYPE,
    IN_UAN                 IN NUMBER,
    IN_DOE_EPF             IN OCS_CLAIM_DATA.DOE_EPF%TYPE,
    IN_DOE_EPS             IN OCS_CLAIM_DATA.DOE_EPS%TYPE,
    T_REASON_EXIT          IN OCS_CLAIM_DATA.REASON_EXIT%TYPE,
    T_PARA_CODE            IN OCS_CLAIM_DATA.PARA_CODE%TYPE,
    T_SUB_PARA_CODE        IN OCS_CLAIM_DATA.SUB_PARA_CODE%TYPE ,
    T_SUB_PARA_CATEGORY    IN OCS_CLAIM_DATA.SUB_PARA_CATEGORY%TYPE ,
    T_ADV_AMOUNT           IN OCS_CLAIM_DATA.ADV_AMOUNT%TYPE,
    T_CLAIM_SOURCE_FLAG    IN OCS_CLAIM_DATA.CLAIM_SOURCE_FLAG%TYPE ,
    T_ADDRESS1             IN OCS_CLAIM_DATA.ADDRESS1%TYPE ,
    T_ADDRESS2             IN OCS_CLAIM_DATA.ADDRESS2%TYPE ,
    T_ADDRESS_CITY         IN OCS_CLAIM_DATA.ADDRESS_CITY%TYPE ,
    T_ADDRESS_DIST         IN OCS_CLAIM_DATA.ADDRESS_DIST%TYPE ,
    T_ADDRESS_STATE        IN OCS_CLAIM_DATA.ADDRESS_STATE%TYPE ,
    T_ADDRESS_PIN          IN OCS_CLAIM_DATA.ADDRESS_PIN%TYPE ,
    T_AGENCY_EMPLOYER_FLAG IN OCS_CLAIM_DATA.AGENCY_EMPLOYER_FLAG%TYPE ,
    T_AGENCY_NAME          IN OCS_CLAIM_DATA.AGENCY_NAME%TYPE ,
    T_AGENCY_ADDRESS       IN OCS_CLAIM_DATA.AGENCY_ADDRESS%TYPE ,
    T_AGENCY_ADDRESS_CITY  IN OCS_CLAIM_DATA.AGENCY_ADDRESS_CITY%TYPE ,
    T_AGENCY_ADDERSS_DIST  IN OCS_CLAIM_DATA.AGENCY_ADDERSS_DIST%TYPE ,
    T_AGENCY_ADDRESS_STATE IN OCS_CLAIM_DATA.AGENCY_ADDRESS_STATE%TYPE ,
    T_AGENCY_ADDRESS_PIN   IN OCS_CLAIM_DATA.AGENCY_ADDRESS_PIN%TYPE ,
    T_FLAG_15GH            IN OCS_CLAIM_DATA.FLAG_15GH%TYPE ,
    T_PDF_15GH             IN CEN_OCS_FORM_19.PDF_15GH%TYPE,
    T_TDS_15GH             IN OCS_CLAIM_DATA.TDS_15GH%TYPE ,
    T_CANCEL_CHEQUE        IN OCS_CLAIM_DATA.CANCEL_CHEQUE%TYPE ,
    T_ADV_ENCLOSURE        IN OCS_CLAIM_DATA.ADV_ENCLOSURE%TYPE ,
    T_IP_ADDRESS           IN OCS_CLAIM_DATA.IP_ADDRESS%TYPE ,
    OUT_MOBILE_NUMBER OUT OCS_CLAIM_DATA.MOBILE%TYPE,
    OUT_MEMBER_NAME OUT OCS_CLAIM_DATA.MEMBER_NAME%TYPE,
    OUT_LEAVE_REASON OUT VARCHAR2,
    OUT_FS_NAME OUT OCS_CLAIM_DATA.FATHER_SPOUSE_NAME%TYPE,
    OUT_DOJ_EPF OUT VARCHAR2,
    OUT_DOJ_EPS OUT VARCHAR2,
    OUT_DOE_EPF OUT VARCHAR2,
    OUT_DOE_EPS OUT VARCHAR2,
    OUT_DOB OUT VARCHAR2,
    OUT_PANCARD OUT VARCHAR2,
    OUT_AADHAAR OUT OCS_CLAIM_DATA.AADHAAR%TYPE,
    OUT_BANK_ACC_NO OUT OCS_CLAIM_DATA.BANK_ACC_NO%TYPE,
    OUT_BANK_IFSC OUT OCS_CLAIM_DATA.IFSC_CODE%TYPE,
    OUT_BANK_DETAILS OUT VARCHAR2,
    OUT_MEMBER_ID OUT OCS_CLAIM_DATA.MEMBER_ID%TYPE,
    OUT_OFFICE_ID         OUT NUMBER,
    OUT_RECEIPT_DATE OUT OCS_CLAIM_DATA.RECEIPT_DATE%TYPE,
    OUT_STATUS OUT NUMBER,
    OUT_TRACKING_ID OUT  NUMBER,
    OUT_MESSAGE OUT VARCHAR2,
    OUT_MARITAL_STATUS OUT VARCHAR2,	 --#ver4.6
    OUT_ESTABLISHMENT_NAME OUT VARCHAR2,	 --#ver4.6
    IN_MEMBER_ID IN VARCHAR2 DEFAULT '-1', --#ver4.6
    IN_APPLICATION_TYPE IN VARCHAR2 DEFAULT NULL, --#ver4.6
    --ADDED BY AKSHAY FOR 10D --ADDED AS OPTIONAL IN-PARAMETERS FOR UMANG --ALWAYS KEEP THESE PARAMETERS AS LAST PARAMETERS OF PROCEDURE
        IN_CLAIM_BY                      IN OCS_CLAIM_DATA.CLAIM_BY%TYPE        DEFAULT NULL,
        IN_PENSION_TYPE                  IN OCS_CLAIM_DATA.PENSION_TYPE%TYPE    DEFAULT NULL,
        IN_OPTED_REDUCED_PENSION IN OCS_CLAIM_DATA.OPTED_REDUCED_PENSION%TYPE   DEFAULT NULL,
        IN_OPTED_DATE                    IN VARCHAR2    DEFAULT NULL,
        IN_PPO_DETAILS                   IN OCS_CLAIM_DATA.PPO_DETAILS%TYPE     DEFAULT NULL,
        IN_SCHEME_CERTIFICATE    IN OCS_CLAIM_DATA.SCHEME_CERTIFICATE%TYPE      DEFAULT NULL,
        IN_DEFERRED_PENSION      IN OCS_CLAIM_DATA.DEFERRED_PENSION%TYPE        DEFAULT NULL,
        IN_DEFERRED_PENSION_AGE  IN OCS_CLAIM_DATA.DEFERRED_PENSION_AGE%TYPE    DEFAULT NULL,
        IN_DEFERRED_PENSION_CONT IN OCS_CLAIM_DATA.DEFERRED_PENSION_CONT%TYPE   DEFAULT NULL,
        IN_BANK_ACCOUNT_NUMBER   IN VARCHAR2    DEFAULT NULL,
        IN_BANK_IFSC                     IN VARCHAR2    DEFAULT NULL,
	IN_BANK_ID 			 	 IN NUMBER	DEFAULT NULL,
    IN_CANCEL_CHEQUE_PATH IN VARCHAR2	DEFAULT NULL    --ADDED BY AKSHAY ON 09/08/2019 TO STORE PHYSICAL LOCATION OF UPLOADED CANCELLED CHEQUE
    --ADDITION BY AKSHAY FOR 10D ENDED --ADDED AS OPTIONAL IN-PARAMETERS FOR UMANG --ALWAYS KEEP THESE PARAMETERS AS LAST PARAMETERS OF PROCEDURE
----- IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH STARTS HERE ADDED ON 18/09/2020
     , IN_3RDPARTY_NAME     IN VARCHAR2 	DEFAULT NULL ,
      IN_3RDPARTY_BANK_ACCNO IN VARCHAR2	DEFAULT NULL ,
      IN_3RDPARTY_BANK_IFSC  IN VARCHAR2	DEFAULT NULL ,
      IN_AUTH_LETTER_FILE_PATH IN VARCHAR2	DEFAULT NULL 
      ------ IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH ENDS HERE
      
    )
AS
  V_OFFICE_ID   NUMBER(3,0);
  V_TRACKING_ID NUMBER(18,0);
  --MEMBER DETAILS VARIABLE***********************************************
  OUT_MEMBER_DETAILS            SYS_REFCURSOR;
  V_MEMBER_UAN                  NUMBER(12);
  V_MEMBER_NAME                 OCS_CLAIM_DATA.FATHER_SPOUSE_NAME%TYPE;
  V_MEMBER_FATHER_SPOUSE_NAME   UAN_REPOSITORY.FATHER_OR_HUSBAND_NAME%TYPE;
  V_MEMBER_RELATION_WITH_MEMBER UAN_REPOSITORY.RELATION_WITH_MEMBER%TYPE;
  V_MEMBER_PAN                  VARCHAR(50);
  V_MEMBER_AADHAAR              UAN_REPOSITORY.AADHAAR%TYPE;
  V_MEMBER_MOBILE_NUMBER        UAN_REPOSITORY.MOBILE_NUMBER%TYPE;
  V_MEMBER_EMAIL_ID             UAN_REPOSITORY.EMAIL_ID%TYPE;
  V_MEMBER_GENDER               UAN_REPOSITORY.GENDER%TYPE;
  V_MEMBER_DOB                  UAN_REPOSITORY.DOB%TYPE;
  V_LEAVE_REASON_CODE           OCS_CLAIM_DATA.REASON_EXIT%TYPE;
  V_LEAVE_REASON                VARCHAR2(128); --#ver3.9
  V_OUT_PARA                    OCS_CLAIM_DATA.PARA_CODE%TYPE;
  V_OUT_SUB_PARA                OCS_CLAIM_DATA.SUB_PARA_CODE%TYPE;
  V_OUT_SUB_PARA_CAT            OCS_CLAIM_DATA.SUB_PARA_CATEGORY%TYPE;
  V1_MEMBER_PAN                  VARCHAR2(10);
  --KYC VARIABLE**********************************************************
  V_BANK_AC_NO        VARCHAR2(20);
  V_IFSC              VARCHAR2(11);
  -- V_BANK_BRANCH       VARCHAR2(100);	--COMMENTED FOR #ver3.9
  V_BANK_BRANCH       VARCHAR2(256);	--#ver3.9
  --SERVICE DETAILS VARIABLE**********************************************
  V_STATUS      MEMBER.STATUS%TYPE;
  V_DOJ_EPF     MEMBER.DOJ_EPF%TYPE;
  V_DOJ_EPS     MEMBER.DOJ_EPS%TYPE;
  V_DOE_EPF     MEMBER.DOE_EPF%TYPE;
  V_DOE_EPS     MEMBER.DOE_EPS%TYPE;
  V_MEMBER_ID   MEMBER.MEMBER_ID%TYPE;
  --********************INSERT ON OCS_CLAIM_DATA*****
  INSERT_STATUS         NUMBER;
--  INSERT_OUTPUT         VARCHAR2(100);
  INSERT_OUTPUT         VARCHAR2(4000);   --CHANGED ON 20/06/2019
  --SAVE_OCRD_DATA*******************************VARIABLE****************
  V_OCRD_STATUS NUMBER(1,0);
--  V_OCRD_OUTPUT VARCHAR2(100);
  V_OCRD_OUTPUT VARCHAR2(4000);   --CHANGED ON 20/06/2019

  --CLAM SUBMISSION ELIGIBILITY VARIABLE****************
  V_PENDING_CLAIM           NUMBER(1,0);
  V_TOTAL_SERVICE_IN_MONTHS NUMBER(3,0);
--  V_CSE_OUTPUT              VARCHAR2(100);
  V_CSE_OUTPUT VARCHAR2(4000);   --CHANGED ON 20/06/2019
  V_CSE_OUT_OLS             NUMBER(1,0);
  --USER DEFINE EXCEPTION*************************************************
  KYC_EXCEPTION                  EXCEPTION;
  OFFICE_ID_OR_TEMP_ID_NOT_FOUND EXCEPTION;
  DATA_INSERT_FAIL               EXCEPTION;
  CLAIM_PENDING                  EXCEPTION;
  NOT_ELIGIBLE                   EXCEPTION;
  FORM_10C_NOT_ALLOWED           EXCEPTION; --#ver4.6
  INVALID_68M_ADV_AMT			 EXCEPTION; --#ver4.8
  INVALID_IFSC      			 EXCEPTION; --#ver4.18
  INVALID_UAN         			 EXCEPTION; --#ver4.28
  BANK_ACCNO_AADHAAR_MISMATCH    EXCEPTION; --#ver4.31
  VMODULE   VARCHAR(200);
  --MULTIPLE SERVICE ALERT MESSAGE*************************BY PANAKAJ KUMAR*************22-DEC-2017
  V_SERVICE_COUNT                NUMBER(2);

  V_ERROR_MESSAGE VARCHAR2(4000); --ADDED BY AKSHAY ON 10/04/2019
  --ADDED BY AKSHAY ON 11/04/2019
  V_MASKED_BANK_AC_NO        VARCHAR2(20);
  V_MASKED_MEMBER_PAN                  VARCHAR(50);
  V_MASKED_MEMBER_AADHAAR              VARCHAR2(15);
  V_MASKED_MEMBER_MOBILE_NUMBER        UAN_REPOSITORY.MOBILE_NUMBER%TYPE;
  --ADDITION BY AKSHAY ON 11/04/2019 ENDED
  V_LEAVE_REASON_CHAR VARCHAR2(1 BYTE):='';
  V_NOMINATION_ID NUMBER;
  V_MARITAL_STATUS VARCHAR2(2):='';
  V_MEMBER_PHOTOGRAPH BLOB;
  V_NOMINATION_SAVED VARCHAR2(120) := '';
  --ADDED BY AKSHAY ON 11/07/2019 TO VALIDATE TOTAL SERVICE USING MIN(DOJ) BUT STORE LATEST DOJ IN TABLE  --REF. MAIL FROM SMITA SONI TO SANDESH SIR FOR CASE DATED 05/07/2019
  V_DOJ_EPF_TO_VALIDATE DATE;
        V_DOJ_EPS_TO_VALIDATE DATE;
  V_LATEST_MEMID  VARCHAR2(24); --#ver4.6
  V_APPLICATION_TYPE  VARCHAR2(2); --#ver4.6
  v_PARA68M_MAX_AMOUNT NUMBER;
  V_ENCR_BANK_ACC_NO VARCHAR2(500); --#ver4.13
  V_BANK_VER_REF_CODE NUMBER(28,0); --#ver4.13
  V_IFSC_COUNT NUMBER(3);  --#ver4.18
  V_EXM VARCHAR2(2); --#ver4.26
  V_DEACTIVATED_UAN_COUNT NUMBER(1); --#ver4.28

  -- Yash Patidar Edits HERE  UMANG PORTAL
  V_BANK_NAME		VARCHAR(128);
  V_OFFICE_NAME		VARCHAR(128);
  V_ADDRESS_OF_OFFICE VARCHAR(256);
  V_PINCODE_OF_OFFICE NUMBER(6);
  V_NOMINATION_FAMILY_ID NUMBER(12);
  V_NOMINEE_NAME VARCHAR(85);
  V_NOMINEE_DOB	DATE;
  V_NOMINEE_GENDER CHAR(1);
  V_NOMINEE_AADHAAR NUMBER(16);
  V_NOMINEE_RELATION CHAR(1);
  V_NOMINEE_RELATION_OTHER VARCHAR(32);
  V_NOMINEE_ADDRESS VARCHAR(1024);
  V_IS_MINOR_NOMINEE CHAR(1);
  V_IS_LUNATIC CHAR(1);
  V_NOM_SHARE_IN_PERCENT NUMBER(5,2);
  V_GUARDIAN_NAME VARCHAR2(85);
  V_GUARDIAN_RELATION VARCHAR2(15);
  V_GUARDIAN_ADDRESS VARCHAR2(1024);
  V_NOM_ADDRESS1 VARCHAR2(35);
  V_NOM_ADDRESS2 VARCHAR2(35);
  V_NOM_CITY	VARCHAR2(50);
  V_NOM_DISTRICT	VARCHAR2(50);
  V_NOM_STATE	VARCHAR2(50);
  V_NOM_DISTRICT_ID NUMBER(4,0);
  V_NOM_STATE_ID NUMBER(2,0);
  V_NOM_PIN NUMBER(6,0);
  V_IS_WIDTHRAWAL_BENFIT_REQ CHAR(1);
  V_IS_WIDTHRAWAL_BENFIT_TAKEN CHAR(1);

BEGIN
IF IN_CLAIM_TYPE = '03' THEN
  LOG_ERROR('SAVE_CLAIM_DATA: IN_PARAMETERS',
    'IN_UAN:'||IN_UAN||'#~#'||
    'IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||'#~#'||
    'IN_DOE_EPF:'||TO_CHAR(IN_DOE_EPF)||'#~#'||
    'IN_DOE_EPS:'||TO_CHAR(IN_DOE_EPS)||'#~#'||
    'T_REASON_EXIT:'||T_REASON_EXIT||'#~#'||
    'T_PARA_CODE:'||T_PARA_CODE||'#~#'||
    'T_SUB_PARA_CODE:'||T_SUB_PARA_CODE||'#~#'||
    'T_SUB_PARA_CATEGORY:'||T_SUB_PARA_CATEGORY||'#~#'||
    'T_ADV_AMOUNT:'||T_ADV_AMOUNT||'#~#'||
    'T_CLAIM_SOURCE_FLAG:'||T_CLAIM_SOURCE_FLAG||'#~#'||
    'T_ADDRESS1:'||T_ADDRESS1||'#~#'||
    'T_ADDRESS2:'||T_ADDRESS2||'#~#'||
    'T_ADDRESS_CITY:'||T_ADDRESS_CITY||'#~#'||
    'T_ADDRESS_DIST:'||T_ADDRESS_DIST||'#~#'||
    'T_ADDRESS_STATE:'||T_ADDRESS_STATE||'#~#'||
    'T_ADDRESS_PIN:'||T_ADDRESS_PIN||'#~#'||
    'T_AGENCY_EMPLOYER_FLAG:'||T_AGENCY_EMPLOYER_FLAG||'#~#'||
    'T_AGENCY_NAME:'||T_AGENCY_NAME||'#~#'||
    'T_AGENCY_ADDRESS:'||T_AGENCY_ADDRESS||'#~#'||
    'T_AGENCY_ADDRESS_CITY:'||T_AGENCY_ADDRESS_CITY||'#~#'||
    'T_AGENCY_ADDERSS_DIST:'||T_AGENCY_ADDERSS_DIST||'#~#'||
    'T_AGENCY_ADDRESS_STATE:'||T_AGENCY_ADDRESS_STATE||'#~#'||
    'T_AGENCY_ADDRESS_PIN:'||T_AGENCY_ADDRESS_PIN||'#~#'||
    'T_FLAG_15GH:'||T_FLAG_15GH||'#~#'||
    'T_TDS_15GH:'||T_TDS_15GH||'#~#'
    ||
    'T_CANCEL_CHEQUE:'||
     CASE WHEN T_CANCEL_CHEQUE IS NULL THEN 'AVAILABLE' ELSE 'NOT AVAILBLE' END ||'#~#'
    ||
    'T_ADV_ENCLOSURE:'||T_ADV_ENCLOSURE||'#~#'||
    'T_IP_ADDRESS:'||T_IP_ADDRESS||'#~#'||
    'IN_CLAIM_BY:'||IN_CLAIM_BY||'#~#'||
    'IN_PENSION_TYPE:'||IN_PENSION_TYPE||'#~#'||
    'IN_OPTED_REDUCED_PENSION:'||IN_OPTED_REDUCED_PENSION||'#~#'||
    'IN_OPTED_DATE:'||IN_OPTED_DATE||'#~#'||
    'IN_PPO_DETAILS:'||IN_PPO_DETAILS||'#~#'||
    'IN_SCHEME_CERTIFICATE:'||IN_SCHEME_CERTIFICATE||'#~#'||
    'IN_DEFERRED_PENSION:'||IN_DEFERRED_PENSION||'#~#'||
    'IN_DEFERRED_PENSION_AGE:'||IN_DEFERRED_PENSION_AGE||'#~#'||
    'IN_DEFERRED_PENSION_CONT:'||IN_DEFERRED_PENSION_CONT||'#~#'||
    'IN_BANK_ACCOUNT_NUMBER:'||IN_BANK_ACCOUNT_NUMBER||'#~#'||
    'IN_BANK_IFSC:'||IN_BANK_IFSC||'#~#'||
    'IN_BANK_ID:'||IN_BANK_ID
    );
END IF;

  --PARA CODE VALUE SET*****************
  V_OUT_PARA:=T_PARA_CODE;
  V_OUT_SUB_PARA:=T_SUB_PARA_CODE;
  V_OUT_SUB_PARA_CAT:=T_SUB_PARA_CATEGORY;
  --OUT DATA FOR PDF********************INITIALIZE TO EMPTY**************
  OUT_MOBILE_NUMBER:=0;
  OUT_MEMBER_NAME  :='';
  OUT_LEAVE_REASON :='';
  OUT_FS_NAME      :='';
  OUT_DOJ_EPF      :='';
  OUT_DOJ_EPS      :='';
  OUT_DOE_EPF      :='';
  OUT_DOE_EPS      :='';
  OUT_DOB          :='';
  OUT_PANCARD      :='';
  OUT_AADHAAR      :=0;
  OUT_BANK_ACC_NO  :='';
  OUT_BANK_IFSC    :='';
  OUT_BANK_DETAILS :='';
  OUT_MEMBER_ID    :='';
  OUT_OFFICE_ID    :=0;
  V1_MEMBER_PAN:='';
  v_PARA68M_MAX_AMOUNT :=0;
  --OUT DATA STATUS AND OTHER VARIABLE INITIALIZED**************************
  OUT_STATUS           :=0;
  OUT_MESSAGE          :='';
  V_OFFICE_ID          :=0;
  INSERT_STATUS        :=0;
  INSERT_OUTPUT        :='';
  OUT_TRACKING_ID      :=0;
  V_PENDING_CLAIM      :=0;
  V_ENCR_BANK_ACC_NO   :='';   --#ver4.13
  V_BANK_VER_REF_CODE  :='';   --#ver4.13
  V_IFSC_COUNT         :=0;    --#ver4.18
  V_DEACTIVATED_UAN_COUNT :=0; --#ver4.28
  --*********************************************************************CHECK PENDING CLAIM************************************BY UAN*****************************
 --***************BELLOW CODE FOR TRAC LOG****************
 VMODULE:='OCS_NEW_PACKAGE.SAVE_CLAIM_DATA';
 --*******************************
 LOG_ERROR('INSIDE SAVE_CLAIM_DATA : ','BY YASH');
 
  SELECT 
    COUNT(1) INTO V_DEACTIVATED_UAN_COUNT
  FROM 
    MEMBER_USERS 
  WHERE
    UAN=IN_UAN
    AND ACCOUNT_STATUS='D';

  IF V_DEACTIVATED_UAN_COUNT > 0 THEN
    LOG_ERROR(VMODULE,'UAN IS DEACTIVATED , '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE INVALID_UAN;
  END IF;

  SELECT COUNT(1)
  INTO V_PENDING_CLAIM
  FROM OCS_CRD OCRD
  INNER JOIN OCS_CLAIM_DATA OCD	--#ver2.5
    ON OCD.TRACKING_ID = OCRD.TRACKING_ID
  WHERE OCRD.CLAIM_STATUS IN(0,1,2,3)
  AND OCRD.UAN             =IN_UAN AND OCRD.CLAIM_FORM_TYPE=IN_CLAIM_TYPE 
  AND (	--#ver2.5
      CASE --#ver4.20
        WHEN OCD.CLAIM_FORM_TYPE='06' AND OCD.PARA_CODE = '8' AND OCD.SUB_PARA_CODE = '13' AND OCD.SUB_PARA_CATEGORY = '3' THEN 1  --IF COVID-19 CLAIM IS PENDING THEN DONT ALLOW ANY PF-ADVANCE CLAIM
        WHEN OCD.CLAIM_FORM_TYPE='06' AND (T_PARA_CODE <> '8' OR T_SUB_PARA_CODE <> '13' OR T_SUB_PARA_CATEGORY <> '3') THEN 1 --EXECUTING THIS CASE MEANS THAT A PENDING CLAIM FOUND IS OF NON-COVID-19. AND IF OTHER THAN COVID-19 CLAIM IS GETTING FILED THEN DONT ALLOW --#ver2.6
        WHEN OCD.CLAIM_FORM_TYPE='06' THEN 0  --IT IS ASSUMED THAT ONLY COVID-19 CLAIM IS ALLOWED FROM FRONT-END IN CASE OF ANY PREVIOUS PENDING CLAIM
        ELSE 1
      END = 1    
    )
  ;
  IF V_PENDING_CLAIM  >0 THEN
  LOG_ERROR(VMODULE,'YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS, '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE CLAIM_PENDING;
  END IF;
  
  CHECK_ANY_PENDING_KYC(IN_UAN,V_ERROR_MESSAGE);
  IF V_ERROR_MESSAGE IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20001,'Z#'||V_ERROR_MESSAGE||'#Z');
  END IF;
  --*********************************************************************CALL PROCEDURE*****************************************GET_MEMBER_ID**********************
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA FETCHING MEMBER DATA','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
  END IF;
  IF IN_CLAIM_TYPE = '04' AND IN_APPLICATION_TYPE IS NULL THEN --#ver4.6
    OUT_STATUS := 1;
    OUT_MESSAGE := 'Form-10C application type not provided. Kindly contact to your administrator.';
    GOTO EXIT_PROC;
  END IF;     

  --IF MEMBER_ID PROVIDED, CHECK WHETHER LATEST OR NOT --#ver4.6
  IF IN_MEMBER_ID <> '-1' THEN
    V_LATEST_MEMID:=last_mid(IN_UAN);
    IF IN_CLAIM_TYPE <> '04' OR IN_APPLICATION_TYPE <> 'SC' THEN
      IF IN_MEMBER_ID <> SUBSTR(V_LATEST_MEMID,0,22) THEN
        OUT_STATUS := 1;
        OUT_MESSAGE := 'Please file claim against most recent service.';
        GOTO EXIT_PROC;
      END IF;
    END IF;    
  ELSE
    --MEMBER ID NOT PROVIDED
    IF (IN_CLAIM_TYPE = '04' AND IN_APPLICATION_TYPE = 'SC') OR IN_CLAIM_TYPE = '06' THEN
      OUT_STATUS := 1;
      OUT_MESSAGE := 'Member ID must be provided. Kindly contact to your administrator.';
      GOTO EXIT_PROC;
    END IF;
  END IF;

  IF IN_CLAIM_TYPE = '04' AND IN_APPLICATION_TYPE = 'SC' THEN --#ver4.6
    GET_MEMBER_DATA(IN_UAN, IN_MEMBER_ID, OUT_MEMBER_DETAILS, OUT_MESSAGE, OUT_STATUS);
    IF OUT_STATUS = 1 THEN
      RAISE FORM_10C_NOT_ALLOWED;
    END IF;
  ELSE
  GET_MEMBER_DATA_ALL(IN_UAN,OUT_MEMBER_DETAILS,OUT_MESSAGE,OUT_STATUS);
  END IF;
  FETCH OUT_MEMBER_DETAILS INTO
          V_BANK_AC_NO,
V_MASKED_BANK_AC_NO,  --ADDED BY AKSHAY ON 11/04/2019
          V_IFSC,
          V_BANK_BRANCH,
          V_MEMBER_NAME,
          V_MEMBER_GENDER,
          V_MEMBER_FATHER_SPOUSE_NAME,
          V_MEMBER_RELATION_WITH_MEMBER,
          V_MEMBER_DOB,
          V_MEMBER_MOBILE_NUMBER,
V_MASKED_MEMBER_MOBILE_NUMBER,  --ADDED BY AKSHAY ON 11/04/2019
          V_MEMBER_AADHAAR,
V_MASKED_MEMBER_AADHAAR,  --ADDED BY AKSHAY ON 11/04/2019
          V_MEMBER_PAN,
V_MASKED_MEMBER_PAN,  --ADDED BY AKSHAY ON 11/04/2019
          V_MEMBER_ID,
          V_STATUS,
          V_MEMBER_EMAIL_ID,
          V_DOJ_EPF,
          V_DOJ_EPS,
          V_DOE_EPF,
          V_DOE_EPS,
          V_LEAVE_REASON_CODE,
          V_LEAVE_REASON,
          V_LEAVE_REASON_CHAR,
          V_SERVICE_COUNT,
          V_ENCR_BANK_ACC_NO, --#ver4.13
          V_BANK_VER_REF_CODE;  --#ver4.13

  CLOSE OUT_MEMBER_DETAILS;

  --Bank Account no & AADHAAR check with previous claim data
  --OCS_UTILITY.CHK_BANK_ACC_NO_OCS(V_BANK_AC_NO, IN_UAN, OUT_STATUS);
  CEN_OCS_UTILITY.CHK_BANK_ACC_NO_OCS(V_BANK_AC_NO, V_IFSC, IN_UAN, OUT_STATUS); --#ver4.37
  IF OUT_STATUS = 1 THEN
      RAISE BANK_ACCNO_AADHAAR_MISMATCH;
  END IF;
--***********IN CASE OF DATE OF EXIT EFP OR EPS INPUT BY MEMBER
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: MEMBER DATA FETCHED',
        'IN_UAN:'||IN_UAN||'#~#'||
        'V_BANK_AC_NO:'||V_BANK_AC_NO||'#~#'||
        'V_MASKED_BANK_AC_NO:'||V_MASKED_BANK_AC_NO||'#~#'||
        'V_IFSC:'||V_IFSC||'#~#'||
        'V_BANK_BRANCH:'||V_BANK_BRANCH||'#~#'||
        'V_MEMBER_NAME:'||V_MEMBER_NAME||'#~#'||
        'V_MEMBER_GENDER:'||V_MEMBER_GENDER||'#~#'||
        'V_MEMBER_FATHER_SPOUSE_NAME:'||V_MEMBER_FATHER_SPOUSE_NAME||'#~#'||
        'V_MEMBER_RELATION_WITH_MEMBER:'||V_MEMBER_RELATION_WITH_MEMBER||'#~#'||
        'V_MEMBER_DOB:'||TO_CHAR(V_MEMBER_DOB)||'#~#'||
        'V_MEMBER_MOBILE_NUMBER:'||V_MEMBER_MOBILE_NUMBER||'#~#'||
        'V_MASKED_MEMBER_MOBILE_NUMBER:'||V_MASKED_MEMBER_MOBILE_NUMBER||'#~#'||
        'V_MEMBER_AADHAAR:'||V_MEMBER_AADHAAR||'#~#'||
        'V_MASKED_MEMBER_AADHAAR:'||V_MASKED_MEMBER_AADHAAR||'#~#'||
        'V_MEMBER_PAN:'||V_MEMBER_PAN||'#~#'||
        'V_MASKED_MEMBER_PAN:'||V_MASKED_MEMBER_PAN||'#~#'||
        'V_MEMBER_ID:'||V_MEMBER_ID||'#~#'||
        'V_STATUS:'||V_STATUS||'#~#'||
        'V_MEMBER_EMAIL_ID:'||V_MEMBER_EMAIL_ID||'#~#'||
        'V_DOJ_EPF:'||TO_CHAR(V_DOJ_EPF)||'#~#'||
        'V_DOJ_EPS:'||TO_CHAR(V_DOJ_EPS)||'#~#'||
        'V_DOE_EPF:'||TO_CHAR(V_DOE_EPF)||'#~#'||
        'V_DOE_EPS:'||TO_CHAR(V_DOE_EPS)||'#~#'||
        'V_LEAVE_REASON_CODE:'||V_LEAVE_REASON_CODE||'#~#'||
        'V_LEAVE_REASON:'||V_LEAVE_REASON||'#~#'||
        'V_LEAVE_REASON_CHAR:'||V_LEAVE_REASON_CHAR||'#~#'||
        'V_SERVICE_COUNT:'||V_SERVICE_COUNT
        );
  END IF;

  CASE WHEN (IN_CLAIM_TYPE='01') AND (V_DOE_EPF IS NULL) THEN
    V_DOE_EPF     :=IN_DOE_EPF;
    V_LEAVE_REASON_CODE:=T_REASON_EXIT;
    WHEN (IN_CLAIM_TYPE='04') AND (V_DOE_EPS IS NULL) THEN
    V_DOE_EPS     :=IN_DOE_EPS;
    V_LEAVE_REASON_CODE:=T_REASON_EXIT;
    ELSE
  IF IN_CLAIM_TYPE='01' THEN
   DBMS_OUTPUT.PUT_LINE('I AM CALLED === '||V_LEAVE_REASON_CODE);
  GET_PARA_CODE_BY_EXIT_CODE(V_LEAVE_REASON_CODE,V_OUT_PARA,V_OUT_SUB_PARA,V_OUT_SUB_PARA_CAT);
  END IF;
  END CASE;

  IF V_OUT_PARA IS NULL OR V_OUT_SUB_PARA IS NULL OR V_OUT_SUB_PARA_CAT IS NULL THEN --#ver4.3
	RAISE_APPLICATION_ERROR(-20001, 'Z#PARA DETAILS NOT FOUND. PLEASE TRY AFTER SOME TIME.#Z');
  END IF;

  --Ver. 1.3
--  IF IN_CLAIM_TYPE = '04' THEN
--    SELECT MIN(DOJ_EPS) INTO V_DOJ_EPS FROM MEMBER WHERE UAN = IN_UAN;
--  ELSIF IN_CLAIM_TYPE = '06' THEN
--    SELECT MIN(DOJ_EPF) INTO V_DOJ_EPF FROM MEMBER WHERE UAN = IN_UAN;
--  END IF;
--
----*******************************************************************CHECK CLAIM SUBMISSION ELIGIBILITY***********************************************************************
----  CHECK_ELIGIBILITY(IN_UAN, IN_CLAIM_TYPE, V_DOJ_EPF, V_DOJ_EPS, V_DOE_EPF, V_DOE_EPS, TO_NUMBER(V_LEAVE_REASON_CODE), V_TOTAL_SERVICE_IN_MONTHS, V_CSE_OUTPUT, V_CSE_OUT_OLS);        --Ver. 1.4
--  IF IN_CLAIM_TYPE = '03' THEN
--    LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY STARTED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
--  END IF;
--  CHECK_ELIGIBILITY(IN_UAN, IN_CLAIM_TYPE, V_DOJ_EPF, V_DOJ_EPS, V_DOE_EPF, V_DOE_EPS, V_TOTAL_SERVICE_IN_MONTHS, V_CSE_OUTPUT, V_CSE_OUT_OLS);             --Ver. 1.4
--  IF IN_CLAIM_TYPE = '03' THEN
--    LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY FINISHED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_CSE_OUT_OLS:'||V_CSE_OUT_OLS||' V_CSE_OUTPUT:'||V_CSE_OUTPUT);
--  END IF;


  --ADDED BY AKSHAY ON 11/07/2019 TO VALIDATE TOTAL SERVICE USING MIN(DOJ) BUT STORE LATEST DOJ IN TABLE  --REF. MAIL FROM SMITA SONI TO SANDESH SIR FOR CASE DATED 05/07/2019
        IF IN_CLAIM_TYPE = '04' THEN
                SELECT MIN(DOJ_EPS) INTO V_DOJ_EPS_TO_VALIDATE FROM MEMBER WHERE UAN = IN_UAN AND EST_SLNO <> 0;  --#ver4.14
		IF IN_APPLICATION_TYPE = 'SC' THEN --#ver4.6
		  --CHECK ELIGIBILITY
		  CHECK_ELIGIBILITY(IN_UAN,'44',V_DOJ_EPF,V_DOJ_EPS_TO_VALIDATE,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);                
		ELSE
                --CHECK ELIGIBILITY
                CHECK_ELIGIBILITY(IN_UAN,IN_CLAIM_TYPE,V_DOJ_EPF,V_DOJ_EPS_TO_VALIDATE,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);
		END IF;
	--

    --#ver4.6
    VALIDATE_FORM_10C(IN_UAN,IN_MEMBER_ID,IN_CLAIM_TYPE,IN_APPLICATION_TYPE,V_CSE_OUTPUT);

	DBMS_OUTPUT.PUT_LINE('V_CSE_OUT_OLS: '||V_CSE_OUT_OLS);
	DBMS_OUTPUT.PUT_LINE('V_CSE_OUTPUT: '||V_CSE_OUTPUT);

    IF V_CSE_OUTPUT IS NOT NULL THEN --#ver4.6
      RAISE NOT_ELIGIBLE;
    END IF;

    IF IN_APPLICATION_TYPE = 'SC' THEN --#ver4.6
      SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS ='E';
      SELECT MARITAL_STATUS INTO V_MARITAL_STATUS FROM UAN_REPOSITORY WHERE UAN = IN_UAN;
    END IF;
        ELSIF IN_CLAIM_TYPE = '06' THEN
                SELECT MIN(DOJ_EPF) INTO V_DOJ_EPF_TO_VALIDATE FROM MEMBER WHERE UAN = IN_UAN AND EST_SLNO <> 0;   --#ver4.14
                --CHECK ELIGIBILITY
                CHECK_ELIGIBILITY(IN_UAN,IN_CLAIM_TYPE,V_DOJ_EPF_TO_VALIDATE,V_DOJ_EPS,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);

				VALIDATE_SCHEME_PARA(IN_UAN,T_PARA_CODE,T_SUB_PARA_CODE,T_SUB_PARA_CATEGORY,V_TOTAL_SERVICE_IN_MONTHS,V_DOE_EPF,V_CSE_OUTPUT);
				IF V_CSE_OUTPUT IS NOT NULL THEN
					RAISE NOT_ELIGIBLE;
				END IF;

                SELECT DISTINCT NVL(PF_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(IN_MEMBER_ID,0,15); --#ver4.26
                IF V_EXM <> 'N' THEN
                  OUT_STATUS:=1;
                  OUT_MESSAGE:='As your establishment is exempted in PF, please submit your withdrawal case to concerned Trust.';
                  GOTO EXIT_PROC;
                END IF;
        ELSE
                IF IN_CLAIM_TYPE = '03' THEN
                        LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY STARTED','IN_UAN: '||IN_UAN||' IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||' Ip-Address '||T_IP_ADDRESS);
                END IF;

		--CHECK ELIGIBILITY
                CHECK_ELIGIBILITY(IN_UAN,IN_CLAIM_TYPE,V_DOJ_EPF,V_DOJ_EPS,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);

                IF IN_CLAIM_TYPE = '03' THEN
                        LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY FINISHED','IN_UAN: '||IN_UAN||' IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||' Ip-Address '||T_IP_ADDRESS||' V_CSE_OUT_OLS:'||V_CSE_OUT_OLS||' V_CSE_OUTPUT:'||V_CSE_OUTPUT);
                END IF;
        END IF;
  --ADDITION BY AKSHAY ON 11/07/2019 ENDED
  IF V_CSE_OUT_OLS > 0 THEN
   ------CAPTURE ERROR lOG***************************
   LOG_ERROR(VMODULE,V_CSE_OUTPUT||', '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE NOT_ELIGIBLE;
  END IF;

  IF IN_CLAIM_TYPE = '03' THEN
LOG_ERROR('SAVE_CLAIM_DATA COLLECTING REQUIRED DATA','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS ='E';
    SELECT MARITAL_STATUS INTO V_MARITAL_STATUS FROM UAN_REPOSITORY WHERE UAN = IN_UAN;
    SELECT PHOTOGRAPH INTO V_MEMBER_PHOTOGRAPH FROM UP_ALT.MEMBER_PROFILE_PHOTO WHERE UAN = IN_UAN ORDER BY UPLOADED_TIME DESC FETCH FIRST ROW ONLY;
    V_BANK_AC_NO:= IN_BANK_ACCOUNT_NUMBER;
    V_IFSC :=IN_BANK_IFSC;
LOG_ERROR('SAVE_CLAIM_DATA REQUIRED DATA COLLECTED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_NOMINATION_ID:'||V_NOMINATION_ID||' V_BANK_AC_NO:'||V_BANK_AC_NO||' V_IFSC:'||V_IFSC||' V_MARITAL_STATUS:'||V_MARITAL_STATUS);
--    RAISE_APPLICATION_ERROR(-20001,'ERROR GENERATING CLAIM PDF.');
  END IF;

 --********************************************************************CALL PROCEDURE******************************************GET_OFFICE_ID BY MEMBER_ID***********************
  V_OFFICE_ID    :=GET_OFFICE_ID(V_MEMBER_ID);
  -- V_TRACKING_ID  :=GEN_TRACKING_ID(V_OFFICE_ID,IN_CLAIM_TYPE);
  V_TRACKING_ID  :=GEN_TRACKING_ID_UAN(IN_UAN,IN_CLAIM_TYPE);
  OUT_TRACKING_ID:=V_TRACKING_ID;
  LOG_ERROR('SAVE_CLAIM_DATA OFFICE_ID, TRACKING_ID COLLECTED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_OFFICE_ID:'||V_OFFICE_ID||' V_TRACKING_ID:'||V_TRACKING_ID);
  IF V_OFFICE_ID  =0 OR V_TRACKING_ID=0 THEN
  ------CAPTURE ERROR lOG***************************
   LOG_ERROR(VMODULE,'Office Id or Tracking Id Generation Failed'||', '||IN_UAN||' Ip-Address  '||T_IP_ADDRESS);
    RAISE OFFICE_ID_OR_TEMP_ID_NOT_FOUND;
  END IF;
  --***********
  DBMS_OUTPUT.PUT_LINE('DOE EPF== '||V_DOE_EPF||' DOE EPS== '||V_DOE_EPS);

  --********************************************************************CALL PROCEDURE*****************************************INSERT VALUE IN OCS_CLAIM_DATA_TEMP***************
  OUT_RECEIPT_DATE:=SYSDATE;
  LOG_ERROR('SAVE_CLAIM_DATA V_MEMBER_PAN','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_MEMBER_PAN:'||V_MEMBER_PAN);
  --******************************************PAN NUMBER HANDLING**********************21-JUL-2017*************BY PANKAJ KUMAR
  IF LENGTH(V_MEMBER_PAN)=10 THEN
  V1_MEMBER_PAN:=V_MEMBER_PAN;
  END IF;
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: CALLING SAVE_OCS_CLAIM_DATA',
    'V_OFFICE_ID:'||V_OFFICE_ID||'#~#'||
    'V_TRACKING_ID:'||V_TRACKING_ID||'#~#'||
    'IN_UAN:'||IN_UAN||'#~#'||
    'V_MEMBER_ID:'||V_MEMBER_ID||'#~#'||
    'V_MEMBER_NAME:'||V_MEMBER_NAME||'#~#'||
    'V_MEMBER_FATHER_SPOUSE_NAME:'||V_MEMBER_FATHER_SPOUSE_NAME||'#~#'||
    'IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||'#~#'||
    'OUT_RECEIPT_DATE:'||to_char(OUT_RECEIPT_DATE)||'#~#' ||
    'SUBSTR(V_MEMBER_ID):'||V_MEMBER_ID||'#~#'||
    'V_MEMBER_RELATION_WITH_MEMBER:'||V_MEMBER_RELATION_WITH_MEMBER||'#~#'||
    'V1_MEMBER_PAN:'||V1_MEMBER_PAN||'#~#'||
    'V_MEMBER_AADHAAR:'||V_MEMBER_AADHAAR||'#~#'||
    'V_MEMBER_MOBILE_NUMBER:'||V_MEMBER_MOBILE_NUMBER||'#~#'||
    'V_MEMBER_EMAIL_ID:'||V_MEMBER_EMAIL_ID||'#~#'||
    'V_MEMBER_GENDER:'||V_MEMBER_GENDER||'#~#'||
    'V_MEMBER_DOB:'||TO_CHAR(V_MEMBER_DOB)||'#~#'||
    'V_DOJ_EPF:'||TO_CHAR(V_DOJ_EPF)||'#~#'||
    'V_DOJ_EPS:'||TO_CHAR(V_DOJ_EPS)||'#~#'||
    'V_DOE_EPF:'||TO_CHAR(V_DOE_EPF)||'#~#'||
    'V_DOE_EPS:'||TO_CHAR(V_DOE_EPS)||'#~#'||
    'V_LEAVE_REASON_CODE:'||V_LEAVE_REASON_CODE||'#~#'||
    'V_OUT_PARA:'||V_OUT_PARA||'#~#'||
    'V_OUT_SUB_PARA:'||V_OUT_SUB_PARA||'#~#'||
    'V_OUT_SUB_PARA_CAT:'||V_OUT_SUB_PARA_CAT||'#~#'||
    'T_ADV_AMOUNT:'||T_ADV_AMOUNT||'#~#'||
    'V_BANK_AC_NO:'||V_BANK_AC_NO||'#~#'||
    'V_IFSC:'||V_IFSC||'#~#'||
    'T_CLAIM_SOURCE_FLAG:'||T_CLAIM_SOURCE_FLAG||'#~#'||
    'T_ADDRESS1:'||T_ADDRESS1||'#~#'||
    'T_ADDRESS2:'||T_ADDRESS2||'#~#'||
    'T_ADDRESS_CITY:'||T_ADDRESS_CITY||'#~#'||
    'T_ADDRESS_DIST:'||T_ADDRESS_DIST||'#~#'||
    'T_ADDRESS_STATE:'||T_ADDRESS_STATE||'#~#'||
    'T_ADDRESS_PIN:'||T_ADDRESS_PIN||'#~#'||
    'T_AGENCY_EMPLOYER_FLAG:'||T_AGENCY_EMPLOYER_FLAG||'#~#'||
    'T_AGENCY_NAME:'||T_AGENCY_NAME||'#~#'||
    'T_AGENCY_ADDRESS:'||T_AGENCY_ADDRESS||'#~#'||
    'T_AGENCY_ADDRESS_CITY:'||T_AGENCY_ADDRESS_CITY||'#~#'||
    'T_AGENCY_ADDERSS_DIST:'||T_AGENCY_ADDERSS_DIST||'#~#'||
    'T_AGENCY_ADDRESS_STATE:'||T_AGENCY_ADDRESS_STATE||'#~#'||
    'T_AGENCY_ADDRESS_PIN:'||T_AGENCY_ADDRESS_PIN||'#~#'||
    'T_FLAG_15GH:'||T_FLAG_15GH||'#~#'||
    'T_TDS_15GH:'||T_TDS_15GH||'#~#'||
    'T_CANCEL_CHEQUE:'|| CASE WHEN T_CANCEL_CHEQUE IS NULL THEN 'AVAILABLE' ELSE 'NOT AVAILBLE' END ||'#~#'||
    'T_ADV_ENCLOSURE:'||T_ADV_ENCLOSURE||'#~#'||
    'T_IP_ADDRESS:'||T_IP_ADDRESS||'#~#'||
    'IN_CLAIM_BY:'||IN_CLAIM_BY||'#~#'||
    'IN_PENSION_TYPE:'||IN_PENSION_TYPE||'#~#'||
    'IN_OPTED_REDUCED_PENSION:'||IN_OPTED_REDUCED_PENSION||'#~#'||
    'IN_OPTED_DATE:'||IN_OPTED_DATE||'#~#'||
    'IN_PPO_DETAILS:'||IN_PPO_DETAILS||'#~#'||
    'IN_SCHEME_CERTIFICATE:'||IN_SCHEME_CERTIFICATE||'#~#'||
    'IN_DEFERRED_PENSION:'||IN_DEFERRED_PENSION||'#~#'||
    'IN_DEFERRED_PENSION_AGE:'||IN_DEFERRED_PENSION_AGE||'#~#'||
    'IN_DEFERRED_PENSION_CONT:'||IN_DEFERRED_PENSION_CONT||'#~#'||
    'V_MARITAL_STATUS:'||V_MARITAL_STATUS||'#~#'||
    'V_NOMINATION_ID:'||V_NOMINATION_ID||'#~#'||
    'IN_BANK_ID:'||IN_BANK_ID||'#~#'||
    'IN_CANCEL_CHEQUE_PATH: '||IN_CANCEL_CHEQUE_PATH
    );
  END IF;
  CASE WHEN IN_CLAIM_TYPE ='04'THEN V_APPLICATION_TYPE := IN_APPLICATION_TYPE; ELSE V_APPLICATION_TYPE :=''; END CASE;	--#ver4.6

  IF IN_CLAIM_TYPE = '06' AND T_PARA_CODE = '9' AND T_SUB_PARA_CODE = '14' and T_SUB_PARA_CATEGORY = '-' THEN 
  GET_PARA68M_MAX_AMOUNT(v_PARA68M_MAX_AMOUNT);
	IF TO_NUMBER(T_ADV_AMOUNT) > TO_NUMBER(v_PARA68M_MAX_AMOUNT)  THEN
		RAISE INVALID_68M_ADV_AMT;
	END IF;
  END IF;

  -- Yash Patidar Edits HERE UMANG PORTAL

  IF IN_CLAIM_TYPE = '04' THEN 
    BEGIN
      SELECT
        MNFD.NOMINATION_FAMILY_ID,
        MNFD.NOMINEE_NAME,
        MNFD.NOMINEE_DOB,
        MNFD.NOMINEE_GENDER,
        MNFD.NOMINEE_AADHAAR,
        MNFD.NOMINEE_RELATION,
        MNFD.NOMINEE_RELATION_OTHER,
        MNFD.NOMINEE_ADDRESS,
        MNFD.IS_MINOR_NOMINEE,
        MNFD.IS_LUNATIC ,
        MNFD.EPF_PERCENTAGE,
        MNFD.GUARDIAN_NAME,
        MNFD.GUARDIAN_RELATION,
        MNFD.GUARDIAN_ADDRESS,
        MNFD.ADDRESS_LINE1,
        MNFD.ADDRESS_LINE2,
        MNFD.ADDRESS_CITY,
        MNFD.ADDRESS_DISTRICT,
        MNFD.ADDRESS_STATE,
        MNFD.ADDRESS_DISTRICT_ID,
        MNFD.ADDRESS_STATE_ID,
        MNFD.ADDRESS_PIN_CODE
      INTO
        V_NOMINATION_FAMILY_ID,
        V_NOMINEE_NAME,
        V_NOMINEE_DOB,
        V_NOMINEE_GENDER,
        V_NOMINEE_AADHAAR,
        V_NOMINEE_RELATION,
        V_NOMINEE_RELATION_OTHER,
        V_NOMINEE_ADDRESS,
        V_IS_MINOR_NOMINEE,
        V_IS_LUNATIC,
        V_NOM_SHARE_IN_PERCENT,
        V_GUARDIAN_NAME,
        V_GUARDIAN_RELATION,
        V_GUARDIAN_ADDRESS,
        V_NOM_ADDRESS1,
        V_NOM_ADDRESS2,
        V_NOM_CITY,
        V_NOM_DISTRICT,
        V_NOM_STATE,
        V_NOM_DISTRICT_ID,
        V_NOM_STATE_ID,
        V_NOM_PIN
      FROM
        MEMBER_NOMINATION_DETAILS MND
      INNER JOIN MEM_NOMINATION_FAMILY_DETAILS MNFD
      ON MND.NOMINATION_ID = MNFD.NOMINATION_ID
      WHERE
        MND.NOMINATION_ID = V_NOMINATION_ID AND
        STATUS = 'E' 
      ORDER BY MNFD.LAST_UPDATED_ON DESC
      FETCH FIRST 1 ROW ONLY;
      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_CSE_OUTPUT := V_CSE_OUTPUT ||'. ERROR OCCURED WHILE FETCHING NOMINEE DETAILS' || '. CANNOT PROCEED';
                RAISE NOT_ELIGIBLE;
    END;
	
	  BEGIN
      SELECT
        OT.DESCRIPTION,
        OFI.ADDRESS_LINE1|| ' ' || OFI.ADDRESS_LINE2|| ' ' ||OFI.ADDRESS_LINE3|| ' ' ||OFI.CITY,
        OFI.PIN
      INTO
        V_OFFICE_NAME,
        V_ADDRESS_OF_OFFICE,
        V_PINCODE_OF_OFFICE
      FROM 
        OFFICE OFI
      INNER JOIN OFFICE_TYPE OT
      ON OFI.OFFICE_TYPE_ID = OT.ID
      WHERE
        OFI.ID = V_OFFICE_ID;
      
      EXCEPTION	
        WHEN NO_DATA_FOUND THEN
          V_CSE_OUTPUT := V_CSE_OUTPUT || '. ERROR OCCURED WHILE FETCHING OFFICE DETAILS' || '. CANNOT PROCEED';
          RAISE NOT_ELIGIBLE;
    END;
    
    BEGIN
      
      SELECT 
        NAME
      INTO
        V_BANK_NAME
      FROM
        BANK
      WHERE
        ID = IN_BANK_ID;
        
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_CSE_OUTPUT := V_CSE_OUTPUT || '. ERROR OCCURED WHILE FETCHING BANK NAME' || '. CANNOT PROCEED';
          RAISE NOT_ELIGIBLE;
    END;
    
      V_IS_WIDTHRAWAL_BENFIT_REQ := 'Y';
      V_IS_WIDTHRAWAL_BENFIT_TAKEN := 'N';
    END IF;


  --Check for IFSC obsolete #ver4.18
  SELECT COUNT(*) INTO V_IFSC_COUNT FROM BANK_IFSC WHERE IFSC_CODE=TRIM(UPPER(V_IFSC)) AND NVL(OBSOLETE,'Y') = 'N';  --#ver4.38
  IF V_IFSC_COUNT=0 THEN
    RAISE INVALID_IFSC;
  END IF; 
  SAVE_OCS_CLAIM_DATA(
      V_OFFICE_ID ,
      V_TRACKING_ID ,
      IN_UAN ,
      V_MEMBER_ID ,
      V_MEMBER_NAME ,
      V_MEMBER_FATHER_SPOUSE_NAME ,
      IN_CLAIM_TYPE ,
      OUT_RECEIPT_DATE ,
      SUBSTR(V_MEMBER_ID,0,15) ,
      V_MEMBER_RELATION_WITH_MEMBER ,
      V1_MEMBER_PAN ,
      V_MEMBER_AADHAAR ,
      V_MEMBER_MOBILE_NUMBER ,
      V_MEMBER_EMAIL_ID ,
      V_MEMBER_GENDER ,
      V_MEMBER_DOB,
      V_DOJ_EPF,
      V_DOJ_EPS,
      V_DOE_EPF,
      V_DOE_EPS,
      V_LEAVE_REASON_CODE,
      V_OUT_PARA ,
      V_OUT_SUB_PARA ,
      V_OUT_SUB_PARA_CAT ,
      T_ADV_AMOUNT ,
      V_BANK_AC_NO ,
      V_IFSC ,
      T_CLAIM_SOURCE_FLAG ,
      T_ADDRESS1 ,
      T_ADDRESS2 ,
      T_ADDRESS_CITY ,
      T_ADDRESS_DIST ,
      T_ADDRESS_STATE ,
      T_ADDRESS_PIN ,
      T_AGENCY_EMPLOYER_FLAG ,
      T_AGENCY_NAME ,
      T_AGENCY_ADDRESS ,
      T_AGENCY_ADDRESS_CITY ,
      T_AGENCY_ADDERSS_DIST ,
      T_AGENCY_ADDRESS_STATE ,
      T_AGENCY_ADDRESS_PIN ,
      T_FLAG_15GH ,
      T_PDF_15GH,
      T_TDS_15GH ,
--  T_CANCEL_CHEQUE ,
      T_ADV_ENCLOSURE ,
      T_IP_ADDRESS ,
  --ADDED BY AKSHAY FOR 10D
      IN_CLAIM_BY,
      IN_PENSION_TYPE,
      IN_OPTED_REDUCED_PENSION,
      IN_OPTED_DATE,
      IN_PPO_DETAILS,
      IN_SCHEME_CERTIFICATE,
      IN_DEFERRED_PENSION,
      IN_DEFERRED_PENSION_AGE,
      IN_DEFERRED_PENSION_CONT,
      V_MARITAL_STATUS,
      V_NOMINATION_ID,
      IN_BANK_ID,
      V_MEMBER_PHOTOGRAPH,
      --ADDITION BY AKSHAY FOR 10D ENDED
--      IN_CANCEL_CHEQUE_PATH,
      V_APPLICATION_TYPE, --#ver4.6
      '',  --#ver4.21
      NULL, --#ver4.22
      NULL, --#ver4.22
      IN_3RDPARTY_NAME     ,
      IN_3RDPARTY_BANK_ACCNO ,
      IN_3RDPARTY_BANK_IFSC  ,
      IN_AUTH_LETTER_FILE_PATH ,
	-- Yash Patidar Edits HERE UMANG PORTAL
      V_BANK_NAME,
      V_BANK_BRANCH,
      V_NOMINATION_FAMILY_ID,
      V_NOMINEE_NAME,
      V_NOMINEE_DOB,
      V_NOMINEE_GENDER,
      V_NOMINEE_AADHAAR,
      V_NOMINEE_RELATION,
      V_NOMINEE_RELATION_OTHER,
      V_NOMINEE_ADDRESS,
      V_IS_MINOR_NOMINEE,
      V_IS_LUNATIC,
      V_NOM_SHARE_IN_PERCENT,
      V_GUARDIAN_NAME,
      V_GUARDIAN_RELATION,
      V_GUARDIAN_ADDRESS,
      V_NOM_ADDRESS1,
      V_NOM_ADDRESS2,
      V_NOM_CITY,
      V_NOM_DISTRICT,
      V_NOM_STATE,
      V_NOM_DISTRICT_ID,
      V_NOM_STATE_ID,
      V_NOM_PIN,	  
      V_OFFICE_NAME,
      V_ADDRESS_OF_OFFICE,
      V_PINCODE_OF_OFFICE,
      V_IS_WIDTHRAWAL_BENFIT_REQ,
      V_IS_WIDTHRAWAL_BENFIT_TAKEN,
      INSERT_STATUS ,
      INSERT_OUTPUT );
      
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CLAIM_DATA FINISHED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' INSERT_STATUS: '||INSERT_STATUS||' INSERT_OUTPUT: '||INSERT_OUTPUT);
  END IF;

  IF INSERT_STATUS>0 THEN
  ------CAPTURE ERROR lOG***************************
    LOG_ERROR(VMODULE,'INSERT FAILED SAVE_OCS_CLAIM_DATA'||', '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
    RAISE DATA_INSERT_FAIL;
  END IF;  
  IF IN_CLAIM_TYPE = '03' THEN
  LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CRD_DATA CALLED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
  END IF;
-- SAVE_OCS_CRD_DATA(V_MEMBER_ID,V_OFFICE_ID,IN_CLAIM_TYPE,V_TRACKING_ID,V_OCRD_STATUS,V_OCRD_OUTPUT);
-- IF IN_CLAIM_TYPE = '03' THEN
--  LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CRD_DATA FINISHED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' V_OCRD_STATUS:'||V_OCRD_STATUS||' V_OCRD_OUTPUT:'||V_OCRD_OUTPUT);
--  END IF;
--  IF V_OCRD_STATUS=1 THEN
--    INSERT_OUTPUT:=V_OCRD_OUTPUT;
--    ------CAPTURE ERROR lOG***************************
--    LOG_ERROR('SAVE_OCS_CRD_DATA',V_OCRD_OUTPUT||', '||V_MEMBER_ID||' Ip-Address  '||T_IP_ADDRESS);
--    RAISE DATA_INSERT_FAIL;
--  END IF;

  --ADDED ON 15/05/2019 FOR 10D
  IF IN_CLAIM_TYPE='03' THEN
  LOG_ERROR('SAVE_CLAIM_DATA: CALLING PKG_EMP_PENSION_CLAIM.INSERT_OCS_FAMILY_NOMINATION','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
    PKG_EMP_PENSION_CLAIM.INSERT_OCS_FAMILY_NOMINATION(V_TRACKING_ID,V_NOMINATION_ID,'M',V_NOMINATION_SAVED);
    LOG_ERROR('SAVE_CLAIM_DATA: FINISHED PKG_EMP_PENSION_CLAIM.INSERT_OCS_FAMILY_NOMINATION','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' V_NOMINATION_SAVED:'||V_NOMINATION_SAVED);
    IF V_NOMINATION_SAVED <> 'SUCCESS' THEN
      INSERT_OUTPUT := V_NOMINATION_SAVED;
      LOG_ERROR('INSERT_OCS_FAMILY_NOMINATION','INSERT FAILED: '||INSERT_OUTPUT||', '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
      RAISE DATA_INSERT_FAIL;
    END IF;
  END IF;
  --ADDITION ON 15/05/2019 ENDED

  COMMIT;
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: CHANGES COMMITTED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
  END IF;
  OUT_MOBILE_NUMBER:=V_MEMBER_MOBILE_NUMBER;
  OUT_MEMBER_NAME  :=V_MEMBER_NAME;
  IF IN_CLAIM_TYPE='01' OR IN_CLAIM_TYPE='04' THEN
  SELECT REASON
  INTO OUT_LEAVE_REASON
  FROM MEMBER_EXIT_REASON
  -- WHERE ID        =V_LEAVE_REASON_CODE;
  WHERE ID        =DECODE(V_LEAVE_REASON_CODE,'7',10,'8',11,'9',12,V_LEAVE_REASON_CODE);	--#ver4.2
  END IF;

  OUT_FS_NAME    :=V_MEMBER_FATHER_SPOUSE_NAME;
  OUT_DOJ_EPF    :=TO_CHAR(V_DOJ_EPF,'dd-Mon-yyyy');
  OUT_DOJ_EPS    :=TO_CHAR(V_DOJ_EPS,'dd-Mon-yyyy');
  OUT_DOE_EPF    :=TO_CHAR(V_DOE_EPF,'dd-Mon-yyyy');
  OUT_DOE_EPS    :=TO_CHAR(V_DOE_EPS,'dd-Mon-yyyy');
  OUT_DOB        :=TO_CHAR(V_MEMBER_DOB,'dd-Mon-yyyy');
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: DATA GATHERED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' OUT_FS_NAME:'||OUT_FS_NAME||' OUT_DOJ_EPF:'||OUT_DOJ_EPF||' OUT_DOJ_EPS:'||OUT_DOJ_EPS||' OUT_DOE_EPF'||OUT_DOE_EPF||' OUT_DOE_EPS:'||OUT_DOE_EPS||' OUT_DOB:'||OUT_DOB);
  END IF;
  IF IN_CLAIM_TYPE='01' THEN
  CASE WHEN ROUND(V_TOTAL_SERVICE_IN_MONTHS/12)<5 AND V_MEMBER_PAN IS NOT NULL AND LENGTH(V_MEMBER_PAN)=10 THEN
  OUT_PANCARD    :=V_MEMBER_PAN;
  WHEN ROUND(V_TOTAL_SERVICE_IN_MONTHS/12)>=5 THEN
  OUT_PANCARD    :=NVL(V_MEMBER_PAN,'NA');
  ELSE
  OUT_PANCARD    :='PAN NOT AVAILABLE ( '||V_CSE_OUTPUT||')';
  END CASE;
  ELSE
  OUT_PANCARD    :=NVL(V_MEMBER_PAN,'NA');
  END IF;


  OUT_AADHAAR    :=V_MEMBER_AADHAAR;
  OUT_BANK_ACC_NO:=TRIM(V_BANK_AC_NO);
  OUT_BANK_IFSC  :=V_IFSC;
  OUT_OFFICE_ID  :=V_OFFICE_ID;
   IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: DATA GATHERED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' OUT_AADHAAR:'||OUT_AADHAAR||' OUT_BANK_ACC_NO:'||OUT_BANK_ACC_NO||' OUT_BANK_IFSC:'||OUT_BANK_IFSC||' OUT_OFFICE_ID:'||OUT_OFFICE_ID);
  END IF;
  IF IN_CLAIM_TYPE <> '03' THEN
    SELECT NVL((B.NAME
      ||','
      ||BI.BRANCH),'NA')
    INTO OUT_BANK_DETAILS
    FROM BANK_IFSC BI
    LEFT JOIN BANK B
    ON B.ID           =BI.BANK_ID
    WHERE BI.IFSC_CODE=V_IFSC;
  END IF;

  OUT_MEMBER_ID    :=V_MEMBER_ID;

 IF IN_CLAIM_TYPE = '04' AND IN_APPLICATION_TYPE = 'SC' THEN	--#ver4.6
	--FETCH ESTABLISHMENT NAME
	SELECT NAME INTO OUT_ESTABLISHMENT_NAME FROM ESTABLISHMENT WHERE EST_ID = SUBSTR(V_MEMBER_ID,0,15);
	--FETCH MARITAL STATUS
	CASE
		WHEN V_MARITAL_STATUS = 'M' THEN OUT_MARITAL_STATUS:='Married';
		WHEN V_MARITAL_STATUS = 'U' THEN OUT_MARITAL_STATUS:='Unmarried';
		WHEN V_MARITAL_STATUS = 'W' THEN OUT_MARITAL_STATUS:='Widow/Widower';
		WHEN V_MARITAL_STATUS = 'D' THEN OUT_MARITAL_STATUS:='Divorcee';
		ELSE OUT_MARITAL_STATUS:= 'Not Provided';
	END CASE;	
  ELSE
	OUT_ESTABLISHMENT_NAME:='';
	OUT_MARITAL_STATUS:='';
  END IF;
   IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: PROCEDURE FINISHED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
  END IF;
  <<EXIT_PROC>> --#ver4.6
  NULL;
EXCEPTION
WHEN NO_DATA_FOUND THEN
OUT_STATUS:=1;
OUT_MESSAGE:='DATA NOT FOUND EXCEPTION: '||SQLERRM;
WHEN OFFICE_ID_OR_TEMP_ID_NOT_FOUND THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='OFFICE ID NOT FOUND OR FAILED TO GENERATE TRACKING ID';

WHEN DATA_INSERT_FAIL THEN
  ROLLBACK;
  OUT_STATUS :=1;
  OUT_MESSAGE:='INSERT EXCEPTION: '||INSERT_OUTPUT;

WHEN CLAIM_PENDING THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS';

WHEN NOT_ELIGIBLE THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='ELIGIBLITY EXCEPTION: '||V_CSE_OUTPUT;

WHEN INVALID_CURSOR THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='DATA NOT AVAILABLE AGAINST THIS UAN,PLEASE ENTER VALID UAN';

WHEN FORM_10C_NOT_ALLOWED THEN --#ver4.6
  OUT_STATUS :=1;
  OUT_MESSAGE:='ERROR: '||OUT_MESSAGE;

WHEN INVALID_68M_ADV_AMT THEN --#ver4.8
  OUT_STATUS :=1;
  OUT_MESSAGE:='INVALID ADVANCE AMOUNT.MAXIMUM LIMIT EXCEEDED';

WHEN INVALID_IFSC THEN --#ver4.18
  OUT_STATUS :=1;
  OUT_MESSAGE:='Available IFSC ('||V_IFSC||') is invalid. Please update valid IFSC with latest Bank Account Number in KYC details through your employer/Unified Portal.';

WHEN INVALID_UAN THEN --#ver4.28
  OUT_STATUS :=1;
  OUT_MESSAGE:='UAN IS DEACTIVATED. CAN NOT PROCEED.';

WHEN BANK_ACCNO_AADHAAR_MISMATCH THEN
    OUT_STATUS :=1;
    OUT_MESSAGE:='Bank account is already linked against another UAN with another AADHAAR, so cannot be allowed.';

WHEN OTHERS THEN    --ADDED BY AKSHAY ON 10/04/2019
  IF SQLCODE = -20001 THEN
    OUT_STATUS :=1;
    LOG_ERROR(VMODULE,'EXCEPTION.SQLCODE = -20001, '||IN_UAN||' Error: '||SQLERRM);
    V_ERROR_MESSAGE := SQLERRM;
    OUT_MESSAGE:=substr(V_ERROR_MESSAGE,instr(V_ERROR_MESSAGE,'Z#')+2,instr(V_ERROR_MESSAGE,'#Z')-(instr(V_ERROR_MESSAGE,'Z#')+2));
--    OUT_MESSAGE:=SQLERRM;
  ELSE
    LOG_ERROR(VMODULE,'EXCEPTION.OTHERS, '||IN_UAN||' Error: '||SQLERRM);
    OUT_STATUS :=1;
    OUT_MESSAGE:= 'Unexpected error while saving the claim. Please try after some time.';
        RAISE_APPLICATION_ERROR(-20001,SQLERRM);
 END IF;

END SAVE_CLAIM_DATA;
--****************************GET SERVICE HISTORY BY MEMBER ID************CREATED BY PANKAJ KUMAR************************DATED 17-03-2017**********************************************
PROCEDURE GET_SERVICE_HISTORY_BY_MEMID(
    IN_MEMBER_ID IN MEMBER.MEMBER_ID%TYPE,
    OUT_SERVICE OUT SYS_REFCURSOR)
AS
  V_COUNT NUMBER;
BEGIN
  OPEN OUT_SERVICE FOR SELECT M.STATUS,
  TO_CHAR(M.DOJ_EPF,'dd-mm-yyyy')
AS
  DOJ_EPF,
  TO_CHAR(M.DOJ_EPS,'dd-mm-yyyy')
AS
  DOJ_EPS,
  TO_CHAR(M.DOE_EPF,'dd-mm-yyyy')
AS
  DOE_EPF,
  TO_CHAR(M.DOE_EPS,'dd-mm-yyyy')
AS
  DOE_EPS FROM MEMBER M WHERE M.MEMBER_ID=IN_MEMBER_ID AND M.EST_SLNO <> 0 ORDER BY M.MEMBER_ID;  --#ver4.14
END GET_SERVICE_HISTORY_BY_MEMID;
--*********************************************************GET MEMBER ID**********************************************************************************CREATED BY PANKAJ KUMAR*****************
PROCEDURE GET_MEMBERID(
    IN_UAN IN MEMBER.UAN%TYPE,
    OUT_MEMBER_ID OUT VARCHAR2)
AS
BEGIN
  OUT_MEMBER_ID:='';
  SELECT UR.MEMBER_ID INTO OUT_MEMBER_ID FROM MEMBER UR WHERE UR.UAN = IN_UAN AND UR.EST_SLNO <> 0;  --#ver4.14
END GET_MEMBERID;
--*********************************************************GET OCS DETAILS FROM OCS_CLAIM_DATA FOR PDF****************************************************CREATED BY PANKAJ KUMAR*****************DATED 17-03-2017*****
PROCEDURE GET_REP_INFO_BY_UAN(
    IN_UAN IN UAN_REPOSITORY.UAN%TYPE,
    OUT_LIST OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE)
AS
BEGIN
  OPEN OUT_LIST FOR SELECT UR.UAN,
  SAL.NAME||' '||UR.NAME
AS
  NAME,
  UR.FATHER_OR_HUSBAND_NAME,
  UR.RELATION_WITH_MEMBER,
  UR.PAN,
  UR.AADHAAR,
  UR.MOBILE_NUMBER,
  UR.EMAIL_ID,
  UR.GENDER,
  UR.DOB FROM UAN_REPOSITORY UR LEFT OUTER JOIN SALUTATION SAL ON UR.SALUTATION = SAL.ID LEFT OUTER JOIN QUALIFICATION QUAL ON UR.QUALIFICATION_ID = QUAL.ID WHERE UR.UAN = IN_UAN;
END GET_REP_INFO_BY_UAN;
--**********************************************GET EXIT REASON****************************
PROCEDURE GET_MEMBER_EXIT_REASON(
    EXIT_REASON OUT SYS_REFCURSOR)
AS
BEGIN
  NULL;
  OPEN EXIT_REASON FOR SELECT MER.ID
AS
  REASON_CODE,
  MER.REASON ,
  OPCM.PARA_CODE,
  OPCM.SUB_PARA_CODE,
  OPCM.SUB_PARA_CATEGORY FROM MEMBER_EXIT_REASON MER LEFT JOIN OCS_PARA_CODE_MASTER OPCM ON OPCM.EXIT_CODE =MER.ID WHERE MER.ID NOT IN(2) AND OPCM.ACTIVE IN ('Y');
END GET_MEMBER_EXIT_REASON;


--*************************************************GET ALL MEMBER ID*********************STEP-2*****************
PROCEDURE GET_MEMBER_DATA_ALL(
    IN_UAN IN NUMBER,
    OUT_MEMBER_DATA OUT SYS_REFCURSOR,
    OUT_MESSAGE OUT VARCHAR2,
    OUT_STATUS OUT NUMBER)
AS
  V_COUNT NUMBER;
  V_MEM_ID VARCHAR2(22) ;
  V_IN_PDB VARCHAR2(1);
  V_EXM VARCHAR2(2);
  V_PDB NUMBER;
  ---
  VV_DOJ_EPF DATE;
  VV_DOJ_EPS DATE;
  VV_DOE_EPF DATE;
  VV_DOE_EPS DATE;
  VV_ROE NUMBER;
  ---HANDLE MULTIPLE MEMBER ID**************************************************
  V_LATEST_MEMID VARCHAR2(24);
BEGIN
  V_COUNT    :=0;
  OUT_MESSAGE:='';
  OUT_STATUS :=0;
  V_MEM_ID:='';
  V_IN_PDB:='Y';
  V_EXM:='NN';
  V_PDB:=0;
  --HANDLE MULTIPLE MEMBER ID**********************************************
  V_LATEST_MEMID:='';
  --DBMS_OUTPUT.PUT_LINE(in_uan);
  V_LATEST_MEMID:=last_mid(IN_UAN);
  SELECT COUNT(UAN) INTO V_COUNT FROM MEMBER WHERE UAN=IN_UAN AND EST_SLNO <> 0;--14-DEC-2017  --#ver4.14


  --- CHANGED HAS BEEM MADE IN BELLOW CODE TO HANDLE MULTIPLE MEMBER ID*************************************************************************************
   SELECT MEMBER_ID,DOJ_EPF,DOJ_EPS,DOE_EPF,DOE_EPS,REASON_OF_LEAVING  INTO V_MEM_ID,VV_DOJ_EPF,VV_DOJ_EPS,VV_DOE_EPF,VV_DOE_EPS,VV_ROE FROM MEMBER WHERE UAN=IN_UAN AND MEMBER_ID=SUBSTR(V_LATEST_MEMID,0,22);
    --- CHECK OFFICE IS IN PDB OR NOT
    SELECT COUNT(OFFICE_ID) INTO V_PDB FROM OCS_NO_PDB WHERE OFFICE_CODE=SUBSTR(V_MEM_ID,0,5);
      --DBMS_OUTPUT.PUT_LINE(v_pdb);
    IF V_PDB>0 THEN
     V_IN_PDB:='N';
      OUT_MESSAGE:='Your service details are in the process of being migrated to Central Portal. Please try again in a weeks time.';
      OUT_STATUS:=1;
      --DBMS_OUTPUT.PUT_LINE(out_message);
    END IF;
    --- CHECK OFFICE IS IN PDB OR NOT

--FOLLOWING CHECK COMMENTED ON 28/06/2019 AND MOVED TO CHECK_ELIGIBILITY
--     IF OUT_STATUS=0 THEN
--
--        --- CHECK WHETHER EST IS EXEMPTED OR NOT
--        SELECT DISTINCT NVL(PF_EXEMPTED,'N')||NVL(PENSION_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(V_MEM_ID,0,15);
--
--        IF V_EXM<>'NN' THEN
--          OUT_MESSAGE:='As your establishment is exempted in PF, please submit your withdrawal case to concerned Trust.';
--          OUT_STATUS:=1;
--        END IF;
--
--     END IF;

    IF OUT_STATUS=0 THEN
      ---VALIDATION FOR EXIT REASON CHECK---STARTS
      IF VV_DOJ_EPF IS NOT NULL AND VV_DOJ_EPS IS NOT NULL AND VV_DOE_EPF IS NOT NULL AND VV_DOE_EPS IS NOT NULL AND VV_ROE IS NULL
      THEN
      OUT_MESSAGE:='Reason of Leaving is not available. Please get the same updated through your employer.';
      OUT_STATUS:=1;
      END IF;
      ---VALIDATION FOR EXIT REASON CHECK---ENDS--

    END IF;

    IF OUT_STATUS=0 THEN
      ---VALIDATION FOR NULL DOJ AND DOE.---STARTS
      IF VV_DOJ_EPF IS  NULL AND VV_DOJ_EPS IS  NULL
      THEN
      OUT_MESSAGE:='Date of Joining is not available. Please get the same updated through your employer.';
      OUT_STATUS:=1;
      END IF;
      ---VALIDATION FOR NULL DOJ AND DOE........ENDS
    END IF;

    --IF V_IN_PDB='Y' AND V_EXM='NN' THEN
    -- CHANGED HAS BEEN MADE IN BELLOW CODE TO HANDLE MULTIPLE MEMBER ID************************************************************
      OPEN OUT_MEMBER_DATA FOR SELECT
      --TRIM(UR.BANK_ACC_NO) BANK_ACC_NO,               --COMMENTED ON 14/06/2019
--      TRIM(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^0-9]', '')) BANK_ACC_NO, --ADDED ON 14/06/2019 TO OMIT EVERYTHING EXCEPT DIGITS  --ISSUE REPORTED ON WHATSAPP ON 12/06/2019 TP AKSHAY BY MS. SMITA SONI --COMMENTED FOR #ver4.0
      TRIM(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^A-Za-z0-9]', '')) BANK_ACC_NO, --#ver4.0 --Guided by Harsh sir over phone call
      --COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(TRIM(UR.BANK_ACC_NO))) MASKED_BANK_ACC_NO,      --ADDED BY AKSHAY ON 11/04/2019
--      COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^0-9]', ''))) MASKED_BANK_ACC_NO,      --ADDED BY AKSHAY ON 14/06/2019
      COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^A-Za-z0-9]', ''))) MASKED_BANK_ACC_NO,      --#ver4.0    
      TRIM(UPPER(GET_LATEST_IFSC(UR.BANK_IFSC))) AS BANK_IFSC, --UR.BANK_IFSC,  --#ver4.16     --#ver4.38
      B.NAME||','||B_IFSC.BRANCH AS BANK_DETAILS,
      --SAL.NAME||' '||
      UR.NAME AS NAME,
      UR.GENDER,
      UR.FATHER_OR_HUSBAND_NAME,
      UR.RELATION_WITH_MEMBER AS FATHER_OR_HUSBAND,
      TO_CHAR(UR.DOB,'DD-MON-YYYY') AS DOB,
      UR.MOBILE_NUMBER,
      COMMON_KYC_MASK.MASK_MOBILE_NUMBER(UR.MOBILE_NUMBER) AS MASKED_MOBILE_NUMBER,         --ADDED BY AKSHAY ON 11/04/2019
      UR.AADHAAR,
      COMMON_KYC_MASK.MASKED_AADHAAR(TO_CHAR(UR.AADHAAR)) AS MASKED_AADHAAR,            --ADDED BY AKSHAY ON 11/04/2019
      CASE 
        WHEN TRIM(UR.PAN) IS NOT NULL THEN
--          CASE 
--            WHEN UR.PAN_DEMO_VERIFICATION_STAT='S' THEN
--              UR.PAN 
--            ELSE
--              UR.PAN||' (PAN NOT VERIFIED)' 
--          END
          TRIM(UPPER(UR.PAN))  --#ver1.7
      ELSE 
        'N.A.' 
      END PAN,                                              -- Ver. 1.2 [ELSE '' END PAN changed to ELSE 'N.A.' END PAN] N.A.= Not Available
--      CASE WHEN UR.PAN IS NOT NULL THEN
      CASE 
--        WHEN UR.PAN IS NOT NULL AND PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UR.UAN,2) = UR.PAN THEN  --ADDED BY AKSHAY ON 17/05/2019
        WHEN TRIM(UR.PAN) IS NOT NULL THEN  --ADDED BY AKSHAY ON 17/05/2019
--          CASE 
--            WHEN PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UR.UAN,2) = UR.PAN THEN
--              COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN))) 
--            ELSE
--              COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN)))||' (PAN NOT DIGITALLY SIGNED BY EMPLOYER)' 
--            END
          COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN))) --#ver1.7
--      ELSE '' END PAN,
        ELSE 
          'NA' 
      END MASKED_PAN,               --ADDED BY AKSHAY ON 11/04/2019
      MEM.MEMBER_ID,
      MEM.STATUS,
      UR.EMAIL_ID,
      TO_CHAR(MEM.DOJ_EPF,'DD-MON-YYYY') AS DOJ_EPF,
      TO_CHAR(MEM.DOJ_EPS,'DD-MON-YYYY') AS DOJ_EPS,
      TO_CHAR(MEM.DOE_EPF,'DD-MON-YYYY') AS DOE_EPF,
      TO_CHAR(MEM.DOE_EPS,'DD-MON-YYYY') AS DOE_EPS,
      -- MEM.REASON_OF_LEAVING AS LEAVE_REASON_CODE,
      DECODE(MEM.REASON_OF_LEAVING,10,7,11,8,12,9,MEM.REASON_OF_LEAVING) AS LEAVE_REASON_CODE,	--#ver4.2
      MER.REASON AS LEAVE_REASON,
      MER.REASON_CODE AS LEAVE_REASON_CHAR_CODE, --ADDED FOR 10D ON 07/05/2019
      V_COUNT AS V_COUNT,--ADDED TO HANDLE MULTIPLE MEMBER ID MESSAGE ON CLIENT SIDE 14-DEC-2017
      UR.ENCR_DOCUMENT_NO, --#ver4.13
      CASE
        WHEN (UR.BANK_VER_REF_CODE IS NOT NULL) AND (NVL(UR.BANK_ONLINE_VERIFICATION_STAT,'Y') <> 'N') THEN
            UR.BANK_VER_REF_CODE
        ELSE
            NULL
      END BANK_VER_REF_CODE --#ver4.17
      FROM UAN_REPOSITORY UR
      --LEFT JOIN SALUTATION SAL ON SAL.ID=UR.SALUTATION
      LEFT JOIN BANK_IFSC B_IFSC ON B_IFSC.IFSC_CODE=GET_LATEST_IFSC(UR.BANK_IFSC)
      LEFT JOIN BANK B ON B.ID=B_IFSC.BANK_ID
      LEFT JOIN MEMBER MEM ON MEM.UAN=UR.UAN
      LEFT JOIN MEMBER_EXIT_REASON MER ON MER.ID=MEM.REASON_OF_LEAVING WHERE UR.UAN=IN_UAN AND MEM.MEMBER_ID=SUBSTR(V_LATEST_MEMID,0,22);

EXCEPTION
WHEN OTHERS THEN
LOG_ERROR('OCS_NEW_PACKAGE.GET_MEMBER_DATA_ALL',SUBSTR(V_LATEST_MEMID,0,22)||','||IN_UAN||','||OUT_MESSAGE);
  OUT_MESSAGE:='DATA NOT FOUND';
  OUT_STATUS :=1;
END GET_MEMBER_DATA_ALL;
--#ver3.8
--ADDED FOR PARALLEL EMPLOYMENT
  PROCEDURE GET_MEMBER_DATA_FOR_PF_ADVANCE(
    IN_UAN IN NUMBER,
    IN_MEMBER_SYS_ID IN NUMBER,
    OUT_MEMBER_DETAILS OUT SYS_REFCURSOR,
    OUT_MESSAGE OUT VARCHAR2,
    OUT_STATUS OUT NUMBER)
  AS
    V_COUNT NUMBER;
    V_CLAIM_COUNT NUMBER;
    V_MEM_ID VARCHAR2(22) ;
    V_IN_PDB VARCHAR2(1);
    V_EXM VARCHAR2(2);
    V_PDB NUMBER;
    ---
    VV_DOJ_EPF DATE;
    VV_DOJ_EPS DATE;
    VV_DOE_EPF DATE;
    VV_DOE_EPS DATE;
    VV_ROE NUMBER;
  BEGIN
    V_COUNT    :=0;
    OUT_MESSAGE:='';
    OUT_STATUS :=0;
    V_MEM_ID:='';
--    V_IN_PDB:='Y';
    V_EXM:='NN';
    V_PDB:=0;
    --HANDLE MULTIPLE MEMBER ID**********************************************
    --DBMS_OUTPUT.PUT_LINE(in_uan);
    SELECT COUNT(UAN) INTO V_COUNT FROM MEMBER WHERE UAN=IN_UAN AND EST_SLNO <> 0;--14-DEC-2017 --#ver4.14


    --- CHANGED HAS BEEM MADE IN BELLOW CODE TO HANDLE MULTIPLE MEMBER ID*************************************************************************************
    SELECT MEMBER_ID,DOJ_EPF,DOJ_EPS,DOE_EPF,DOE_EPS,REASON_OF_LEAVING  INTO V_MEM_ID,VV_DOJ_EPF,VV_DOJ_EPS,VV_DOE_EPF,VV_DOE_EPS,VV_ROE FROM MEMBER WHERE ID = IN_MEMBER_SYS_ID AND EST_SLNO <> 0;     --#ver4.14
      --- CHECK OFFICE IS IN PDB OR NOT
      SELECT COUNT(OFFICE_ID) INTO V_PDB FROM OCS_NO_PDB WHERE OFFICE_CODE=SUBSTR(V_MEM_ID,0,5);
        --DBMS_OUTPUT.PUT_LINE(v_pdb);
      IF V_PDB>0 THEN
--       V_IN_PDB:='N';
        OUT_MESSAGE:='Your service details for '||V_MEM_ID||' are in the process of being migrated to Central Portal. Please try again in a weeks time.';
        OUT_STATUS:=1;
        --DBMS_OUTPUT.PUT_LINE(out_message);
      END IF;
      --- CHECK OFFICE IS IN PDB OR NOT


  --FOLLOWING CHECK COMMENTED ON 28/06/2019 AND MOVED TO CHECK_ELIGIBILITY
      IF OUT_STATUS=0 THEN  
        --- CHECK WHETHER EST IS EXEMPTED OR NOT
        SELECT DISTINCT NVL(PF_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(V_MEM_ID,0,15);
        IF V_EXM<>'N' THEN
          OUT_MESSAGE:='As your establishment is exempted in PF, please submit your withdrawal case to concerned Trust.';
          OUT_STATUS:=1;
        END IF;  
      END IF;

      IF OUT_STATUS=0 THEN
        ---VALIDATION FOR EXIT REASON CHECK---STARTS
        IF VV_DOJ_EPF IS NOT NULL AND VV_DOJ_EPS IS NOT NULL AND VV_DOE_EPF IS NOT NULL AND VV_DOE_EPS IS NOT NULL AND VV_ROE IS NULL
        THEN
        OUT_MESSAGE:='Reason of Leaving is not available. Please get the same updated through your employer.';
        OUT_STATUS:=1;
        END IF;
        ---VALIDATION FOR EXIT REASON CHECK---ENDS--

      END IF;

      IF OUT_STATUS=0 THEN
        ---VALIDATION FOR NULL DOJ AND DOE.---STARTS
        IF VV_DOJ_EPF IS  NULL AND VV_DOJ_EPS IS  NULL
        THEN
        OUT_MESSAGE:='Date of Joining is not available. Please get the same updated through your employer.';
        OUT_STATUS:=1;
        END IF;
        ---VALIDATION FOR NULL DOJ AND DOE........ENDS
      END IF;

      IF OUT_STATUS = 0 THEN
        --CHECK APPROVED PF FINAL SETTELEMENT CLAIM IS AVAILABLE OR NOT
        V_CLAIM_COUNT := 0;
        SELECT
          COUNT(1)
        INTO
          V_CLAIM_COUNT
        FROM
          CEN_OCS_FORM_19 COF19
--          OCS_CLAIM_DATA OCD
--        INNER JOIN OCS_CRD OCRD
--          ON OCD.TRACKING_ID = OCRD.TRACKING_ID
        WHERE
          COF19.UAN = IN_UAN AND
          COF19.MEMBER_ID = V_MEM_ID AND
          COF19.CLAIM_STATUS = 'S' AND --5=CLAIM SETTELED
--          OCRD.CLAIM_REVISED_STATUS IS NULL AND -- CLAIM_REVISED_STATUS IS NOT UPDATED BY FO --#ver4.29
          COF19.CLAIM_FORM_TYPE = '01'  --01=PF FINAL SETTLEMENT CLAIM (FORM-19)
        ;

        IF V_CLAIM_COUNT <> 0 THEN
          OUT_STATUS:=1;
          OUT_MESSAGE:='APPROVED PF FINAL SETTLEMENT CLAIM(FORM-19) IS AVAILABLE IN THE SYSTEM.';
          GOTO EXIT_PROC;
        ELSE
          --CHECK APPROVED TRANSFER CLAIM IS FILED OR NOT
          SELECT
            COUNT(1)
          INTO
            V_CLAIM_COUNT
          FROM
            CEN_OCS_OTCP COO
          INNER JOIN OTCP_CLAIM_FO_ACTION OCFA ON
            OCFA.UAN = COO.UAN AND OCFA.CLAIM_ID = COO.CLAIM_ID
          WHERE
            COO.UAN = IN_UAN AND
            COO.PREVIOUS_EST_PF_ACC_NO=V_MEM_ID AND
--            OCD.EMPLOYER_ACTION_STATUS = 'A' AND
            OCFA.FO_STATUS = 3 AND
            OCFA.RMO_STATUS='N';

          IF V_CLAIM_COUNT <> 0 THEN
            OUT_STATUS:=1;
            OUT_MESSAGE:='APPROVED PF TRANSFER CLAIM IS AVAILABLE IN THE SYSTEM.';
            GOTO EXIT_PROC;
          END IF;                  
        END IF;

      END IF;
      --IF V_IN_PDB='Y' AND V_EXM='NN' THEN
      -- CHANGED HAS BEEN MADE IN BELLOW CODE TO HANDLE MULTIPLE MEMBER ID************************************************************
        OPEN OUT_MEMBER_DETAILS FOR SELECT
        --TRIM(UR.BANK_ACC_NO) BANK_ACC_NO,               --COMMENTED ON 14/06/2019
--        TRIM(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^0-9]', '')) BANK_ACC_NO, --ADDED ON 14/06/2019 TO OMIT EVERYTHING EXCEPT DIGITS  --ISSUE REPORTED ON WHATSAPP TO AKSHAY ON 12/06/2019  BY MS. SMITA SONI --Commented for #ver4.0
        TRIM(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^A-Za-z0-9]', '')) BANK_ACC_NO, --#ver4.0 --Guided by Harsh sir over phone
        --COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(TRIM(UR.BANK_ACC_NO))) MASKED_BANK_ACC_NO,      --ADDED BY AKSHAY ON 11/04/2019
--        COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^0-9]', ''))) MASKED_BANK_ACC_NO,      --ADDED BY AKSHAY ON 14/06/2019
        COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^A-Za-z0-9]', ''))) MASKED_BANK_ACC_NO,      --#ver4.0
        UPPER(GET_LATEST_IFSC(UR.BANK_IFSC)) AS BANK_IFSC, --UR.BANK_IFSC, --#ver4.16   #ver4.38
        B.NAME||','||B_IFSC.BRANCH AS BANK_DETAILS,
        --SAL.NAME||' '||
        UR.NAME AS NAME,
        UR.GENDER,
        UR.FATHER_OR_HUSBAND_NAME,
        UR.RELATION_WITH_MEMBER AS FATHER_OR_HUSBAND,
        TO_CHAR(UR.DOB,'DD-MON-YYYY') AS DOB,
        UR.MOBILE_NUMBER,
        COMMON_KYC_MASK.MASK_MOBILE_NUMBER(UR.MOBILE_NUMBER) AS MASKED_MOBILE_NUMBER,         --ADDED BY AKSHAY ON 11/04/2019
        UR.AADHAAR,
        COMMON_KYC_MASK.MASKED_AADHAAR(TO_CHAR(UR.AADHAAR)) AS MASKED_AADHAAR,            --ADDED BY AKSHAY ON 11/04/2019
        CASE 
        WHEN TRIM(UR.PAN) IS NOT NULL THEN
--          CASE 
--            WHEN UR.PAN_DEMO_VERIFICATION_STAT='S' THEN
--              UR.PAN 
--            ELSE
--              UR.PAN||' (PAN NOT VERIFIED)' 
--          END
          TRIM(UPPER(UR.PAN))  --#ver1.7
      ELSE 
        'N.A.' 
      END PAN,                                              -- Ver. 1.2 [ELSE '' END PAN changed to ELSE 'N.A.' END PAN] N.A.= Not Available
--      CASE WHEN UR.PAN IS NOT NULL THEN
      CASE 
--        WHEN UR.PAN IS NOT NULL AND PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UR.UAN,2) = UR.PAN THEN  --ADDED BY AKSHAY ON 17/05/2019
        WHEN TRIM(UR.PAN) IS NOT NULL THEN  --ADDED BY AKSHAY ON 17/05/2019
--          CASE 
--            WHEN PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UR.UAN,2) = UR.PAN THEN
--              COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN))) 
--            ELSE
--              COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN)))||' (PAN NOT DIGITALLY SIGNED BY EMPLOYER)' 
--            END
          COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN))) --#ver1.7
--      ELSE '' END PAN,
        ELSE 
          'NA' 
      END MASKED_PAN,               --ADDED BY AKSHAY ON 11/04/2019
        MEM.MEMBER_ID,
        MEM.STATUS,
        UR.EMAIL_ID,
        TO_CHAR(MEM.DOJ_EPF,'DD-MON-YYYY') AS DOJ_EPF,
        TO_CHAR(MEM.DOJ_EPS,'DD-MON-YYYY') AS DOJ_EPS,
        TO_CHAR(MEM.DOE_EPF,'DD-MON-YYYY') AS DOE_EPF,
        TO_CHAR(MEM.DOE_EPS,'DD-MON-YYYY') AS DOE_EPS,
        -- MEM.REASON_OF_LEAVING AS LEAVE_REASON_CODE,
        DECODE(MEM.REASON_OF_LEAVING,10,7,11,8,12,9,MEM.REASON_OF_LEAVING) AS LEAVE_REASON_CODE,	--#ver4.2
        MER.REASON AS LEAVE_REASON,
        MER.REASON_CODE AS LEAVE_REASON_CHAR_CODE, --ADDED FOR 10D ON 07/05/2019
        V_COUNT AS V_COUNT,--ADDED TO HANDLE MULTIPLE MEMBER ID MESSAGE ON CLIENT SIDE 14-DEC-2017
        UR.ENCR_DOCUMENT_NO, --#ver4.13
        CASE
        WHEN (UR.BANK_VER_REF_CODE IS NOT NULL) AND (NVL(UR.BANK_ONLINE_VERIFICATION_STAT,'Y') <> 'N') THEN
            UR.BANK_VER_REF_CODE
        ELSE
            NULL
        END BANK_VER_REF_CODE  --#ver4.17
        FROM UAN_REPOSITORY UR
        --LEFT JOIN SALUTATION SAL ON SAL.ID=UR.SALUTATION
        LEFT JOIN BANK_IFSC B_IFSC ON B_IFSC.IFSC_CODE=GET_LATEST_IFSC(UR.BANK_IFSC)
        LEFT JOIN BANK B ON B.ID=B_IFSC.BANK_ID
        LEFT JOIN MEMBER MEM ON MEM.UAN=UR.UAN
        LEFT JOIN MEMBER_EXIT_REASON MER ON MER.ID=MEM.REASON_OF_LEAVING 
      WHERE 
        MEM.ID = IN_MEMBER_SYS_ID  AND MEM.EST_SLNO <> 0     --#ver4.14
      ;
    <<EXIT_PROC>>
    NULL;
  EXCEPTION
  WHEN OTHERS THEN
  LOG_ERROR('OCS_NEW_PACKAGE.GET_MEMBER_DATA_FOR_PF_ADVANCE','IN_MEMBER_SYS_ID: '||IN_MEMBER_SYS_ID||','||IN_UAN||','||OUT_MESSAGE);
    OUT_MESSAGE:='DATA NOT FOUND';
    OUT_STATUS :=1;
  END GET_MEMBER_DATA_FOR_PF_ADVANCE;
--ADDITION FOR PARALLEL EMPLOYEMNT ENDS HERE  
PROCEDURE GET_AADHAAR_FOR_EKYC(IN_UAN IN NUMBER,OUT_AADHAAR OUT VARCHAR2)
AS
BEGIN
OUT_AADHAAR:=0;
SELECT AADHAAR INTO OUT_AADHAAR FROM UAN_REPOSITORY WHERE UAN = IN_UAN;

END GET_AADHAAR_FOR_EKYC;
PROCEDURE UPDATE_AADHAAR_EKYC(
        IN_TRACKING_ID       IN OCS_UIDAI_RESPONSE.TRACKING_ID%TYPE,
        IN_AADHAAR           IN OCS_UIDAI_RESPONSE.AADHAAR%TYPE,
        IN_PID               IN varchar2,
        IN_RESPONSE_CODE     IN OCS_UIDAI_RESPONSE.RESPONSE_CODE%TYPE,
        IN_NAME              IN OCS_UIDAI_RESPONSE.NAME%TYPE,
        IN_DOB               IN varchar2,
        IN_EMAIL             IN OCS_UIDAI_RESPONSE.EMAIL%TYPE,
        IN_GENDER            IN OCS_UIDAI_RESPONSE.GENDER%TYPE,
        IN_PHONE             IN OCS_UIDAI_RESPONSE.CO_SO%TYPE,
        IN_DISTRICT          IN OCS_UIDAI_RESPONSE.DISTRICT%TYPE,
        --IN_HOUSE_NUMBER      IN OCS_UIDAI_RESPONSE.HOUSE_NUMBER%TYPE,
        IN_LAND_MARK         IN OCS_UIDAI_RESPONSE.LAND_MARK%TYPE,
        IN_LOCALITY          IN OCS_UIDAI_RESPONSE.LOCALITY%TYPE,
        IN_VILL_TOWN_CITY    IN OCS_UIDAI_RESPONSE.VILL_TOWN_CITY%TYPE,
        IN_STREET            IN OCS_UIDAI_RESPONSE.STREET%TYPE,
        IN_POST_OFFICE       IN OCS_UIDAI_RESPONSE.POST_OFFICE%TYPE,
        IN_SUB_DISTRICT      IN OCS_UIDAI_RESPONSE.SUB_DISTRICT%TYPE,
        IN_STATE             IN OCS_UIDAI_RESPONSE.STATE%TYPE,
        OUT_STATUS           OUT NUMBER,
        OUT_MESSAGE          OUT VARCHAR2
)
AS
INSERT_FAILED  EXCEPTION;
VMODULE  VARCHAR(200);
V_FORM_TYPE VARCHAR2(2 BYTE);
BEGIN
    OUT_STATUS:=0;
    OUT_MESSAGE:='';
    V_FORM_TYPE:='';
        
    SELECT COF19.CLAIM_FORM_TYPE INTO V_FORM_TYPE FROM CEN_OCS_FORM_19 COF19 WHERE COF19.TRACKING_ID=IN_TRACKING_ID; 
    SELECT COF31.CLAIM_FORM_TYPE INTO V_FORM_TYPE FROM CEN_OCS_FORM_31 COF31 WHERE COF31.TRACKING_ID=IN_TRACKING_ID;   
    SELECT CLAIM_FORM_TYPE INTO V_FORM_TYPE FROM CEN_OCS_FORM_10_C WHERE TRACKING_ID = IN_TRACKING_ID;
VMODULE:='OCS_NEW_PACKAGE.UPDATE_AADHAAR_EKYC';
CASE V_FORM_TYPE
    WHEN '01' THEN
    INSERT INTO CEN_OCS_FORM_19_UIDAI_RESPONSE
    (
      TRACKING_ID,
      AADHAAR,
      PID,
      RESPONSE_CODE,
      NAME,
      DOB,
      EMAIL,
      GENDER,
      PHONE,
      DISTRICT,
      HOUSE_NUMBER,
      LAND_MARK,
      LOCALITY,
      VILL_TOWN_CITY,
      STREET,
      POST_OFFICE,
      SUB_DISTRICT,
      STATE
    )
    VALUES
    (
      IN_TRACKING_ID,
      IN_AADHAAR,
      IN_PID,
      IN_RESPONSE_CODE,
      IN_NAME,
      to_date(IN_DOB,'DD-MM-YYYY'),
      IN_EMAIL,
      SUBSTR(IN_GENDER,0,1),
      IN_PHONE,
      IN_DISTRICT,
      'NA',--need add
      IN_LAND_MARK,
      IN_LOCALITY,
      IN_VILL_TOWN_CITY,
      IN_STREET,
      IN_POST_OFFICE,
      IN_SUB_DISTRICT,
      IN_STATE
);
IF SQL%ROWCOUNT =1 THEN
OUT_STATUS:=0;
OUT_MESSAGE:=SQL%ROWCOUNT||' ROW INSERTED SUCCESSFULLY.';
UPDATE CEN_OCS_FORM_19 COF19 SET COF19.EKYC_STATUS='Y' WHERE COF19.TRACKING_ID=IN_TRACKING_ID;
IF SQL%ROWCOUNT =1 THEN
OUT_MESSAGE:=OUT_MESSAGE||' , '||SQL%ROWCOUNT||' ROW UPDATED SUCCESSFULLY.';
COMMIT;
END IF;
END IF;
 

 WHEN '06' THEN
    INSERT INTO CEN_OCS_FORM_31_UIDAI_RESPONSE
    (
      TRACKING_ID,
      AADHAAR,
      PID,
      RESPONSE_CODE,
      NAME,
      DOB,
      EMAIL,
      GENDER,
      PHONE,
      DISTRICT,
      HOUSE_NUMBER,
      LAND_MARK,
      LOCALITY,
      VILL_TOWN_CITY,
      STREET,
      POST_OFFICE,
      SUB_DISTRICT,
      STATE
    )
    VALUES
    (
      IN_TRACKING_ID,
      IN_AADHAAR,
      IN_PID,
      IN_RESPONSE_CODE,
      IN_NAME,
      to_date(IN_DOB,'DD-MM-YYYY'),
      IN_EMAIL,
      SUBSTR(IN_GENDER,0,1),
      IN_PHONE,
      IN_DISTRICT,
      'NA',--need add
      IN_LAND_MARK,
      IN_LOCALITY,
      IN_VILL_TOWN_CITY,
      IN_STREET,
      IN_POST_OFFICE,
      IN_SUB_DISTRICT,
      IN_STATE
);
IF SQL%ROWCOUNT =1 THEN
OUT_STATUS:=0;
OUT_MESSAGE:=SQL%ROWCOUNT||' ROW INSERTED SUCCESSFULLY.';
 UPDATE CEN_OCS_FORM_31 COF31 SET COF31.EKYC_STATUS='Y' WHERE COF31.TRACKING_ID=IN_TRACKING_ID;
IF SQL%ROWCOUNT =1 THEN
OUT_MESSAGE:=OUT_MESSAGE||' , '||SQL%ROWCOUNT||' ROW UPDATED SUCCESSFULLY.';
COMMIT;
END IF;
END IF;

	WHEN '04' THEN
		INSERT INTO CEN_OCS_FORM_10C_UIDAI_RESP
		(
		  TRACKING_ID,
		  AADHAAR,
		  PID,
		  RESPONSE_CODE,
		  NAME,
		  DOB,
		  EMAIL,
		  GENDER,
		  PHONE,
		  DISTRICT,
		  HOUSE_NUMBER,
		  LAND_MARK,
		  LOCALITY,
		  VILL_TOWN_CITY,
		  STREET,
		  POST_OFFICE,
		  SUB_DISTRICT,
		  STATE
		)
		VALUES
		(
		  IN_TRACKING_ID,
		  IN_AADHAAR,
		  IN_PID,
		  IN_RESPONSE_CODE,
		  IN_NAME,
		  to_date(IN_DOB,'DD-MM-YYYY'),
		  IN_EMAIL,
		  SUBSTR(IN_GENDER,0,1),
		  IN_PHONE,
		  IN_DISTRICT,
		  'NA',--need add
		  IN_LAND_MARK,
		  IN_LOCALITY,
		  IN_VILL_TOWN_CITY,
		  IN_STREET,
		  IN_POST_OFFICE,
		  IN_SUB_DISTRICT,
		  IN_STATE
		);

	IF SQL%ROWCOUNT =1 THEN
		OUT_STATUS:=0;
		OUT_MESSAGE:=SQL%ROWCOUNT||' ROW INSERTED SUCCESSFULLY.';
		UPDATE CEN_OCS_FORM_10_C COFD SET COFD.EKYC_STATUS='Y' WHERE COFD.TRACKING_ID=IN_TRACKING_ID;
		IF SQL%ROWCOUNT =1 THEN
			OUT_MESSAGE:=OUT_MESSAGE||' , '||SQL%ROWCOUNT||' ROW UPDATED SUCCESSFULLY.';
			COMMIT;
		END IF;
	END IF;

END CASE; 
EXCEPTION WHEN OTHERS THEN
LOG_ERROR(VMODULE,IN_TRACKING_ID||','||IN_AADHAAR||','||IN_PID||','||IN_RESPONSE_CODE||','||IN_NAME||','||IN_DOB||','||IN_EMAIL||','||IN_GENDER||','||IN_PHONE||','||IN_DISTRICT||','||IN_LAND_MARK||','||IN_LOCALITY||','||IN_VILL_TOWN_CITY||','||IN_STREET||','||IN_POST_OFFICE||','||IN_SUB_DISTRICT||','||IN_STATE);
ROLLBACK;
/*************************EKYC UPDATION FAILED EXCEPTION***************BY PANKAJ KUMAR***************05-SEPT-2017*****/
DELETE FROM OCS_CRD WHERE TRACKING_ID=IN_TRACKING_ID;
DELETE FROM OCS_CLAIM_STATUS_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
DELETE OCS_NOMINATION_FAMILY_DET WHERE TRACKING_ID=IN_TRACKING_ID;
DELETE FROM OCS_CLAIM_DATA WHERE TRACKING_ID=IN_TRACKING_ID;
 CASE V_FORM_TYPE
    WHEN '01' THEN
      DELETE CEN_OCS_FORM_19_LOG WHERE TRACKING_ID=IN_TRACKING_ID; 
      DELETE CEN_OCS_FORM_19 WHERE TRACKING_ID=IN_TRACKING_ID;  
    WHEN '06' THEN
      DELETE CEN_OCS_FORM_31_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
      DELETE CEN_OCS_FORM_31 WHERE TRACKING_ID=IN_TRACKING_ID;
    WHEN '04' THEN 
      DELETE CEN_OCS_FORM_10_C_LOG WHERE TRACKING_ID = IN_TRACKING_ID;
      DELETE CEN_OCS_FORM_10_C WHERE TRACKING_ID = iN_TRACKING_ID; 
 END CASE;   
OUT_STATUS:=1;
OUT_MESSAGE:='FAILED: '||SQLERRM;
END UPDATE_AADHAAR_EKYC;

--******************************************STEP 1***********************CHECK OCS ELIGIBILITY**************************

PROCEDURE GET_OCS_ELIGIBILITY(
        IN_UAN IN NUMBER,
        OUT_IS_ELIGIBLE OUT VARCHAR2
)
AS
        V_AADHAAR UAN_REPOSITORY.AADHAAR%TYPE:=NULL;
        V_AADHAAR_DEMO_VERIF_STAT UAN_REPOSITORY.AADHAAR_DEMO_VERIFICATION_STAT%TYPE:=NULL;
        V_AADHAAR_BIO_VERIF_STAT UAN_REPOSITORY.AADHAAR_BIO_VERIFICATION_STAT%TYPE:=NULL;
        V_AADHAAR_OTP_VERIF_STAT UAN_REPOSITORY.AADHAAR_OTP_VERIFICATION_STAT%TYPE:=NULL;
        V_BANK_ACC_NO UAN_REPOSITORY.BANK_ACC_NO%TYPE:=NULL;
        V_BANK_IFSC UAN_REPOSITORY.BANK_IFSC%TYPE:=NULL;
        --******************************TO HANDLE MEMBER BANK ACCOUNT*******BY PANKAJ KUMAR*********03-NOV-2017
        V_COUNT NUMBER(1);
        --*****************************HANDLE FATHER_SPOUSE_NAME*****************20-DEC-17*************
        V_FATHER_OR_HUSBAND_NAME UAN_REPOSITORY.FATHER_OR_HUSBAND_NAME%TYPE:=NULL;
        V_NAME UAN_REPOSITORY.NAME%TYPE:=NULL;
        V_GENDER UAN_REPOSITORY.GENDER%TYPE:=NULL;
        V_IFSC_COUNT NUMBER(1);
        V_DOB DATE;                     --Ver 1.4
        V_PENDING_KYC_ERR VARCHAR2(4000);
        V_BANK_VER_REF_CODE NUMBER(28,0);  --#ver4.17
        V_BANK_ONLINE_VER_STATUS VARCHAR2(1);  --#ver4.17
BEGIN
		--#ver3.4
		SELECT COUNT(1) INTO V_COUNT FROM MEMBER_USERS WHERE UAN = IN_UAN;
        IF V_COUNT = 0 THEN
          RAISE_APPLICATION_ERROR(-20001,'Z#UAN is not activated. Please activate it through unified portal.#Z');
        END IF;

        SELECT AADHAAR,
        AADHAAR_DEMO_VERIFICATION_STAT,
        AADHAAR_OTP_VERIFICATION_STAT,
        AADHAAR_BIO_VERIFICATION_STAT,
        TRIM(BANK_ACC_NO) BANK_ACC_NO,
        GET_LATEST_IFSC(BANK_IFSC),
        FATHER_OR_HUSBAND_NAME,
        TRIM(NAME),	--#ver3.4
        DOB,                             --Ver 1.4
        GENDER,		--#ver3.4
        BANK_VER_REF_CODE, --#ver4.17
        BANK_ONLINE_VERIFICATION_STAT --#ver4.17
        INTO V_AADHAAR,
        V_AADHAAR_DEMO_VERIF_STAT,
        V_AADHAAR_OTP_VERIF_STAT,
        V_AADHAAR_BIO_VERIF_STAT,
        V_BANK_ACC_NO,
        V_BANK_IFSC,
        V_FATHER_OR_HUSBAND_NAME,
        V_NAME,
        V_DOB,                            --Ver 1.4
        V_GENDER,
        V_BANK_VER_REF_CODE,
        V_BANK_ONLINE_VER_STATUS
        FROM UAN_REPOSITORY WHERE UAN = IN_UAN;
     --*******************************************HANDLED IFSC CASE PROBLEM ACCORDING TO IFSC MASTER TABLE*******
--        SELECT COUNT(*) INTO V_IFSC_COUNT FROM BANK_IFSC WHERE IFSC_CODE=V_BANK_IFSC;
        --Enabled as per discussion with Sandesh & Kiran Sir #ver4.18
         SELECT COUNT(*) INTO V_IFSC_COUNT FROM BANK_IFSC WHERE IFSC_CODE=TRIM(UPPER(V_BANK_IFSC)) AND NVL(OBSOLETE,'Y') = 'N'; --#ver2.4	--COMMENTED WHILE #ver2.5    --#ver4.38

     --******************************TO HANDLE MEMBER BANK ACCOUNT*******BY PANKAJ KUMAR*********03-NOV-2017
--        V_COUNT:=0;
--        SELECT COUNT(*)
--        INTO
--        V_COUNT
--        FROM MEMBER_KYC MEMKYC
--        WHERE MEMKYC.DOCUMENT_TYPE_ID=1
--        AND MEMKYC.ID=(SELECT MAX(MK.ID) FROM MEMBER_KYC MK WHERE MK.UAN=IN_UAN AND MK.DOCUMENT_TYPE_ID=1)
--        AND TRIM(MEMKYC.DOCUMENT_NO)=TRIM(V_BANK_ACC_NO)
--        AND MEMKYC.IFSC=V_BANK_IFSC
--        AND MEMKYC.UAN=IN_UAN;
       --******************************END HERE TO HANDLE MEMBER BANK ACCOUNT*******BY PANKAJ KUMAR*********03-NOV-2017
        IF V_BANK_VER_REF_CODE IS NOT NULL AND V_BANK_ONLINE_VER_STATUS = 'N' THEN
                 RAISE_APPLICATION_ERROR(-20001,'Z#Invalid Bank Account Number.('||(PKG_MEMBER_KYC_BY_MEM.GET_LATEST_KYC_REMARK(IN_UAN,V_BANK_ACC_NO))||') Kindly update your bank account details through self mode.[DB]#Z');  --Bank kyc specific error message change on dated 20-09-2022
        ELSIF V_AADHAAR IS NULL THEN
                 RAISE_APPLICATION_ERROR(-20001,'Z#Please update your AADHAAR.#Z');
        ELSIF V_AADHAAR IS NOT NULL AND ((V_AADHAAR_DEMO_VERIF_STAT IS NULL OR V_AADHAAR_DEMO_VERIF_STAT <> 'S') AND (V_AADHAAR_OTP_VERIF_STAT IS NULL OR V_AADHAAR_OTP_VERIF_STAT<>'S') AND (V_AADHAAR_BIO_VERIF_STAT IS NULL OR V_AADHAAR_BIO_VERIF_STAT<>'S')) THEN
--                RAISE_APPLICATION_ERROR(-20001,'Z#AADHAAR is not authenticated from UIDAI. Please authenticate your AADHAAR by visiting nearest EPFO office.#Z');
                RAISE_APPLICATION_ERROR(-20001,'Z#AADHAAR is not authenticated from UIDAI. Please seed your AADHAAR KYC.#Z');
--        ELSIF to_char(PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(IN_UAN,3)) <> to_char(V_AADHAAR) THEN  --ADDED BY AKSHAY
        ELSIF to_char(PKG_LATEST_KYC.GET_AADHAAR_BY_UAN(IN_UAN,'Y')) <> to_char(V_AADHAAR) THEN  --ADDED BY AKSHAY
            RAISE_APPLICATION_ERROR(-20001,'Z#Please update your latest authenticated AADHAAR through your employer/Unified Portal.#Z');
--        ELSIF V_COUNT=0 OR V_BANK_ACC_NO IS NULL OR V_BANK_IFSC IS NULL   THEN
        ELSIF  V_BANK_ACC_NO IS NULL OR V_BANK_IFSC IS NULL OR PKG_LATEST_KYC.GET_DSC_BANK(IN_UAN, V_BANK_ACC_NO) = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,'Z#Please update your latest Bank account no. and valid IFSC details through your employer/Unified Portal.#Z');
        ELSIF IS_BANK_ACCOUNT_NUMBER_BLOCKED(V_BANK_ACC_NO) = 1 THEN   -- ELSIF ADDED BY AKSHAY ON 03/09/2019
          RAISE_APPLICATION_ERROR(-20001,'Z#Bank account number is blocked for claim processing. Kindly contact to EPFO Office.#Z');
        ELSIF V_IFSC_COUNT=0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Z#Available IFSC ('||V_BANK_IFSC||') is invalid. Please update valid IFSC with latest Bank Account Number in KYC details through your employer/Unified Portal.#Z');
--		RAISE_APPLICATION_ERROR(-20001,'Z#The IFSC code seeded against your bank account number is no more valid. Cannot proceed.#Z');--#ver2.4 --COMMENTED WHILE #ver2.5
	   --**********************SYSDATE HANDLE*************************
       ELSIF SYSDATE<TO_DATE('01-MAY-2017','DD-MON-YYYY') THEN
                RAISE_APPLICATION_ERROR(-20001,'Z#Some Problem Arise On Server, Please Try Again Later.#Z');
      --******************************FATHER NAME NULL************************THEN
      ELSIF V_FATHER_OR_HUSBAND_NAME IS NULL THEN
--      RAISE_APPLICATION_ERROR(-20001,'Z#Please update your  FATHER OR HUSBAND NAME in member details through your Employer/Unified portal#Z');
      RAISE_APPLICATION_ERROR(-20001,'Z#Please provide missing FATHER OR HUSBAND NAME in member details through your Employer/Unified portal#Z');       --MESSAGE CHANGED BY AKSHAY ON 14/01/2019 ON DEMAND OF HARSH SIR (MAIL DATED 11/01/2019) --MESSAGE WAS CONVEYED OVER PHONE
      ELSIF V_DOB IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Z#Please provide missing DATE OF BIRTH in member details through your Employer/Unified portal#Z');      --Ver 1.4
      ELSE
          --ADDED BY AKSHAY ON 07/06/2019
          CHECK_ANY_PENDING_KYC(IN_UAN,V_PENDING_KYC_ERR);
          IF V_PENDING_KYC_ERR IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001,'Z#'||V_PENDING_KYC_ERR||'#Z');
          END IF;
          --ADDITION BY AKSHAY ON 07/06/2019 ENDED

          --#ver3.4
--          CHECK_BANK_ACC_MAP_TO_OTHR_UAN(IN_UAN,V_AADHAAR,V_NAME,V_DOB,V_GENDER,V_BANK_ACC_NO);
          CHECK_BANK_ACC_MAP_TO_OTHR_UAN(IN_UAN,V_AADHAAR,V_NAME,V_DOB,V_GENDER,V_BANK_ACC_NO, V_BANK_IFSC); --#ver4.0
          OUT_IS_ELIGIBLE := 'Y';
       END IF;
END GET_OCS_ELIGIBILITY;

--*****************************Function developed By Ajay Agrawal(AD-IS)***********integrated by Pankaj Kumar**********to handle muliple member id case
FUNCTION LAST_MID(
    IN_MID IN VARCHAR2 )
  RETURN VARCHAR2
AS
BEGIN
  DECLARE
    cnt NUMBER:=0;
    mid VARCHAR2(22);
  BEGIN
    SELECT COUNT(*) INTO cnt FROM unified_portal.member WHERE uan=IN_MID and EST_SLNO <> 0;     --#ver4.14
    IF cnt=1 THEN
      SELECT member_id INTO mid FROM unified_portal.member WHERE uan=IN_MID and EST_SLNO <> 0;    --#ver4.14
    ELSE
      SELECT member_id
      INTO mid
      FROM
        (SELECT member_id
        FROM unified_portal.member
        WHERE uan              =IN_MID
        --AND PREVIOUS_EMPLOYMENT='Y'   --COMMENTED THE CONDITION ON 13/03/2019 AS PER GUIDELINES BY HARSH SIR TO SANDESH SIR
        AND ( doj_epf          =
          (SELECT MAX(DOJ_EPF) FROM unified_portal.MEMBER WHERE UAN=IN_MID and EST_SLNO <> 0  --#ver4.14
          )
        OR LAST_UPDATE_TIME=
          (SELECT MAX(LAST_UPDATE_TIME)
          FROM unified_portal.MEMBER
          WHERE uan    =IN_MID
          AND DOJ_EPF IS NULL
          AND EST_SLNO <> 0  --#ver4.14
          ) )
        ORDER BY id DESC
        )
      WHERE rownum=1;
    END IF;
    RETURN mid||cnt;
  END;
END LAST_MID;
--*********************************************LOGGER***********************TRACK FAILED CASES*****added by pankaj kumar******23-Nov-2017
PROCEDURE LOG_ERROR(
      TITLE_IN IN UP_ALT.OCS_ERROR_LOG2.TITLE%TYPE,
      INFO_IN  IN UP_ALT.OCS_ERROR_LOG2.INFO%TYPE)
  AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT
    INTO UP_ALT.OCS_ERROR_LOG2
      (
        TITLE,
        INFO,
        CREATED_BY,
        CALLSTACK,
        ERRORSTACK,
        ERRORBACKTRACE
      )
      VALUES
      (
        TITLE_IN,
        INFO_IN,
        USER,
        DBMS_UTILITY.FORMAT_CALL_STACK,
        DBMS_UTILITY.FORMAT_ERROR_STACK,
        DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
      );
    COMMIT;
  END LOG_ERROR;
  PROCEDURE GET_UAN_DETAILS(
    IN_UAN IN VARCHAR2,
    OUT_UAN_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
  )
  AS
  BEGIN
    OPEN OUT_UAN_DETAILS FOR
      SELECT
        NAME,
        TO_CHAR(DOB,'DD-MM-YYYY') AS DOB,
        NVL(GENDER,'') AS GENDER,
        FATHER_OR_HUSBAND_NAME,
        TRIM(BANK_ACC_NO) AS BANK_ACC_NO,
        AADHAAR AS AADHAAR,
        CASE    --COPIED FROM GET_MEMBER_DATA_ALL --BECAUSE THIS DATA IS BEING COMPARED WITH OUTPUT OF GET_MEMBER_DATA_ALL
--          WHEN PAN IS NOT NULL THEN
          WHEN PAN IS NOT NULL AND PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UAN,2) = PAN THEN  --ADDED BY AKSHAY ON 17/05/2019
            CASE
              WHEN PAN_DEMO_VERIFICATION_STAT='S' THEN PAN
              ELSE PAN||' (PAN NOT VERIFIED)'
            END
        ELSE 'N.A.' END PAN,    -- Ver. 1.2 [ELSE '' END PAN changed to ELSE 'N.A.' END PAN] N.A.= Not Available
        MOBILE_NUMBER
      FROM
        UAN_REPOSITORY
      WHERE
        UAN = IN_UAN;
  END GET_UAN_DETAILS;

  PROCEDURE GET_UAN_MEMBER_DETAILS(
    IN_UAN IN VARCHAR2,
    OUT_UAN_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
  )
  AS
  BEGIN
    OPEN OUT_UAN_DETAILS FOR
      SELECT
        NAME,
        TO_CHAR(DOB,'DD-MON-YYYY') AS DOB,
        NVL(GENDER,'') AS GENDER,
        FATHER_OR_HUSBAND_NAME,
        TRIM(BANK_ACC_NO) AS BANK_ACC_NO,
        AADHAAR AS AADHAAR,
        CASE    --COPIED FROM GET_MEMBER_DATA_ALL --BECAUSE THIS DATA IS BEING COMPARED WITH OUTPUT OF GET_MEMBER_DATA_ALL
--          WHEN PAN IS NOT NULL THEN
          WHEN PAN IS NOT NULL AND PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UAN,2) = PAN THEN  --ADDED BY AKSHAY ON 17/05/2019
            CASE
              WHEN PAN_DEMO_VERIFICATION_STAT='S' THEN PAN
              ELSE PAN||' (PAN NOT VERIFIED)'
            END
        ELSE 'N.A.' END PAN,    -- Ver. 1.2 [ELSE '' END PAN changed to ELSE 'N.A.' END PAN]  N.A.= Not Available
        MOBILE_NUMBER
      FROM
        UAN_REPOSITORY
      WHERE
        UAN = IN_UAN;
  END GET_UAN_MEMBER_DETAILS;

        --ADDED BY AKSHAY TO PREVENT THE NON-EKYC OR PDF GENERATION FAILURE CLAIMS ON 14/01/2019
        PROCEDURE DELETE_OCS_CLAIM_DATA(
                IN_TRACKING_ID IN NUMBER,
                IN_UAN IN NUMBER,
                IN_FORM_TYPE IN VARCHAR2
        )
        AS
                V_ERROR_MSG VARCHAR2(4000 BYTE):='';
                V_TRACKING_ID NUMBER(18);
        BEGIN
          LOG_ERROR('DELETE_OCS_CLAIM_DATA','RECEIVED PARAMETERS: IN_TRACKING_ID:'||IN_TRACKING_ID||' IN_UAN:'||IN_UAN||' IN_FORM_TYPE:'||IN_FORM_TYPE);
          IF IN_TRACKING_ID IS NOT NULL THEN
            LOG_ERROR('DELETE_OCS_CLAIM_DATA','INSIDE IF FOR TRACKING_ID:'||IN_TRACKING_ID);
--            DELETE OCS_CRD WHERE TRACKING_ID=IN_TRACKING_ID;
--            DELETE OCS_CLAIM_STATUS_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
--            DELETE OCS_UIDAI_RESPONSE WHERE TRACKING_ID=IN_TRACKING_ID;
--            DELETE OCS_NOMINATION_FAMILY_DET WHERE TRACKING_ID=IN_TRACKING_ID;
--            DELETE OCS_VERIFICATION_LOG_DETAILS WHERE TRACKING_ID=IN_TRACKING_ID;	--#ver3.5
--            DELETE OCS_VERIFICATION_LOG_SUMMARY WHERE TRACKING_ID=IN_TRACKING_ID;	--#ver3.5
--            DELETE OCS_CLAIM_DATA WHERE TRACKING_ID=IN_TRACKING_ID;
            CASE IN_FORM_TYPE
              WHEN '01' THEN
                DELETE CEN_OCS_FORM_19_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
                DELETE CEN_OCS_FORM_19 WHERE TRACKING_ID=IN_TRACKING_ID;  
              WHEN '06' THEN
                DELETE CEN_OCS_FORM_31_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
                DELETE CEN_OCS_FORM_31 WHERE TRACKING_ID=IN_TRACKING_ID;
              WHEN '04' THEN 
                DELETE CEN_OCS_FORM_10_C_LOG WHERE TRACKING_ID = IN_TRACKING_ID;
                DELETE CEN_OCS_FORM_10_C WHERE TRACKING_ID = IN_TRACKING_ID;
              WHEN '44' THEN
                DELETE CEN_OCS_FORM_10_C_LOG WHERE TRACKING_ID = IN_TRACKING_ID;
                DELETE CEN_OCS_FORM_10_C WHERE TRACKING_ID = IN_TRACKING_ID;
            END CASE;   
              LOG_ERROR('DELETE_OCS_CLAIM_DATA','DELETED CLAIM DATA FOR RECEIVED TRACKING_ID: '||V_TRACKING_ID||' SQL%ROWCOUNT: '||SQL%ROWCOUNT);
            COMMIT;

          ELSE
            LOG_ERROR('DELETE_OCS_CLAIM_DATA','INSIDE ELSE FOR UAN:'||IN_UAN||' TRACKING_ID:'||IN_TRACKING_ID);
            CASE IN_FORM_TYPE
              WHEN '01' THEN
                SELECT
                  COF19.TRACKING_ID
                INTO
                  V_TRACKING_ID
                FROM
                  CEN_OCS_FORM_19 COF19
                WHERE
                  COF19.UAN = IN_UAN AND
                  COF19.CLAIM_FORM_TYPE = IN_FORM_TYPE AND
                  COF19.CLAIM_SOURCE_FLAG = 'EE' AND
                  COF19.CLAIM_STATUS = 'N';
            --  AND OCD.EKYC_STATUS = 'N'   --COMMENTED AS EKYC MIGHT HAVE UPDATED SUCCESSFULLY BUT AN ERROR OCCURED IN PDF GENERATION
              WHEN '06' THEN
                SELECT
                  COF31.TRACKING_ID
                INTO
                  V_TRACKING_ID
                FROM
                  CEN_OCS_FORM_31 COF31
                WHERE
                  COF31.UAN = IN_UAN AND
                  COF31.CLAIM_FORM_TYPE = IN_FORM_TYPE AND
                  COF31.CLAIM_SOURCE_FLAG = 'EE' AND
                  COF31.CLAIM_STATUS = 'N';
                  
               WHEN '04' THEN
                    SELECT
                      COF10C.TRACKING_ID
                    INTO
                      V_TRACKING_ID
                    FROM
                      CEN_OCS_FORM_10_C COF10C
                    WHERE
                      COF10C.UAN = IN_UAN AND
                      COF10C.CLAIM_FORM_TYPE = IN_FORM_TYPE AND
                      COF10C.CLAIM_SOURCE_FLAG = 'EE' AND
                      COF10C.CLAIM_STATUS = 'N';
               
               WHEN '44' THEN
                    SELECT
                      COF10C.TRACKING_ID
                    INTO
                      V_TRACKING_ID
                    FROM
                      CEN_OCS_FORM_10_C COF10C
                    WHERE
                      COF10C.UAN = IN_UAN AND
                      COF10C.CLAIM_FORM_TYPE = IN_FORM_TYPE AND
                      COF10C.CLAIM_SOURCE_FLAG = 'EE' AND
                      COF10C.CLAIM_STATUS = 'N';
               
               END CASE;   
            LOG_ERROR('DELETE_OCS_CLAIM_DATA','FOUND TRACKING_ID'||V_TRACKING_ID);
--            DELETE OCS_CRD WHERE TRACKING_ID=V_TRACKING_ID;
--            DELETE OCS_CLAIM_STATUS_LOG WHERE TRACKING_ID=V_TRACKING_ID;
--            DELETE OCS_UIDAI_RESPONSE WHERE TRACKING_ID=V_TRACKING_ID;
--            DELETE OCS_NOMINATION_FAMILY_DET WHERE TRACKING_ID=V_TRACKING_ID;
--            DELETE OCS_VERIFICATION_LOG_DETAILS WHERE TRACKING_ID=V_TRACKING_ID;	--#ver3.5
--            DELETE OCS_VERIFICATION_LOG_SUMMARY WHERE TRACKING_ID=V_TRACKING_ID;	--#ver3.5
--            DELETE OCS_CLAIM_DATA WHERE TRACKING_ID=V_TRACKING_ID;
             CASE IN_FORM_TYPE
               WHEN '01' THEN
                 DELETE CEN_OCS_FORM_19_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
                 DELETE CEN_OCS_FORM_19 WHERE TRACKING_ID=IN_TRACKING_ID; 
               WHEN '06' THEN
                 DELETE CEN_OCS_FORM_31_LOG WHERE TRACKING_ID=IN_TRACKING_ID;
                 DELETE CEN_OCS_FORM_31 WHERE TRACKING_ID=IN_TRACKING_ID;
               WHEN '04' THEN 
                 DELETE CEN_OCS_FORM_10_C_LOG WHERE TRACKING_ID = IN_TRACKING_ID;
                 DELETE CEN_OCS_FORM_10_C WHERE TRACKING_ID = IN_TRACKING_ID;
               WHEN '44' THEN 
                 DELETE CEN_OCS_FORM_10_C_LOG WHERE TRACKING_ID = IN_TRACKING_ID;
                 DELETE CEN_OCS_FORM_10_C WHERE TRACKING_ID = IN_TRACKING_ID;
             END CASE;   
              LOG_ERROR('DELETE_OCS_CLAIM_DATA','DELETED CLAIM DATA FOR DERIVED TRACKING_ID: '||V_TRACKING_ID||' SQL%ROWCOUNT: '||SQL%ROWCOUNT);
          COMMIT;
          END IF;
          
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              LOG_ERROR('DELETE_OCS_CLAIM_DATA','TRACKING_ID NOT FOUND FOR UAN: '||IN_UAN||' CLAIM_FORM_TYPE: '||IN_FORM_TYPE);
            WHEN OTHERS THEN
              ROLLBACK;
              V_ERROR_MSG:=SQLERRM;
              LOG_ERROR('DELETE_OCS_CLAIM_DATA',IN_TRACKING_ID||', '||V_ERROR_MSG);
              RAISE_APPLICATION_ERROR(-20002,'UNABLE TO DELETE CLAIM DATA: '||SQLERRM);
        END DELETE_OCS_CLAIM_DATA;

  --ADDED BY AKSHAY TO CHECK WHETHER A NON-EKYC CLAIM IS PRESENT FOR PERTICULAR UAN
PROCEDURE CHECK_NON_EKYC_CLAIM(
        IN_UAN IN NUMBER,
        OUT_NON_EKYC_COUNT OUT NUMBER
)
AS
BEGIN
        SELECT
                COUNT(OCD.TRACKING_ID)
        INTO
                OUT_NON_EKYC_COUNT
        FROM
                OCS_CLAIM_DATA OCD
        INNER JOIN
                (
                        SELECT
                                TRACKING_ID,
                                CLAIM_STATUS
                        FROM
                        (
                                SELECT
                                        TRACKING_ID,
                                        MAX(CLAIM_STATUS)CLAIM_STATUS
                                FROM
                                        OCS_CLAIM_STATUS_LOG
                                GROUP BY
                                        TRACKING_ID
                        )
                        WHERE
                                CLAIM_STATUS=1
                )PC
                ON OCD.TRACKING_ID      =PC.TRACKING_ID
        WHERE
                OCD.UAN = IN_UAN
                AND
                (
                        (
                                OCD.EKYC_STATUS='N'
                                AND OCD.CLAIM_SOURCE_FLAG='EE'
                        )
                        OR (
                                OCD.IFSC_CODE NOT IN (SELECT IFSC_CODE FROM BANK_IFSC)
                        )
                )
                AND OCD.PDB_UPDATE_FLAG ='N';

END CHECK_NON_EKYC_CLAIM;


PROCEDURE DELETE_NON_EKYC_CLAIM(
        IN_UAN IN NUMBER,
        OUT_MESSAGE OUT VARCHAR2
)AS
        V_COUNT NUMBER :=0;
  CURSOR NON_EKCY_CLAIMS_CUR(IN_UAN_CUR NUMBER)
        IS
                SELECT
                        OCD.TRACKING_ID TRACKING_ID
                FROM
                        OCS_CLAIM_DATA OCD
                INNER JOIN
                        (
                                SELECT
                                        TRACKING_ID,
                                        CLAIM_STATUS
                                FROM
                                (
                                        SELECT
                                                TRACKING_ID,
                                                MAX(CLAIM_STATUS)CLAIM_STATUS
                                        FROM
                                                OCS_CLAIM_STATUS_LOG
                                        GROUP BY
                                                TRACKING_ID
                                )
                                WHERE
                                        CLAIM_STATUS=1
                        )PC
                        ON OCD.TRACKING_ID      =PC.TRACKING_ID
                WHERE
                        OCD.UAN = IN_UAN_CUR
                        AND
                        (
                                (
                                        OCD.EKYC_STATUS='N'
                                        AND OCD.CLAIM_SOURCE_FLAG='EE'
                                )
                                OR (
                                        OCD.IFSC_CODE NOT IN (SELECT IFSC_CODE FROM BANK_IFSC)
                                )
                        )
                        AND OCD.PDB_UPDATE_FLAG ='N';
BEGIN

        FOR V_REC IN NON_EKCY_CLAIMS_CUR(IN_UAN)
        LOOP
                V_COUNT := 0;
--                INSERT INTO OCS_UIDAI_RESPONSE_REJ_LOG (
--                SELECT OUR.*, SYSTIMESTAMP AS REJCTION_TIMESTAMP FROM OCS_UIDAI_RESPONSE OUR WHERE TRACKING_ID=V_REC.TRACKING_ID);

                INSERT INTO OCS_CLAIM_STATUS_REJ_LOG (
                SELECT OCSL.*, SYSTIMESTAMP AS REJCTION_TIMESTAMP FROM OCS_CLAIM_STATUS_LOG OCSL WHERE TRACKING_ID=V_REC.TRACKING_ID);

                INSERT INTO OCS_CRD_REJ_LOG (
                SELECT OC.*, SYSTIMESTAMP AS REJCTION_TIMESTAMP FROM OCS_CRD OC WHERE TRACKING_ID=V_REC.TRACKING_ID);

--                INSERT INTO OCS_CLAIM_DATA_REJ_LOG (
--                SELECT OCD.*, SYSTIMESTAMP AS REJCTION_TIMESTAMP FROM OCS_CLAIM_DATA OCD WHERE TRACKING_ID=V_REC.TRACKING_ID);

--                INSERT INTO OCS_CLAIM_DATA_REJ_LOG (
--                      SELECT
--                        OFFICE_ID,
--                        TRACKING_ID,
--                        UAN,
--                        MEMBER_ID,
--                        MEMBER_NAME,
--                        FATHER_SPOUSE_NAME,
--                        CLAIM_FORM_TYPE,
--                        RECEIPT_DATE,
--                        ESTABLISHMENT_ID,
--                        FLAG_FS,
--                        PAN,
--                        AADHAAR,
--                        MOBILE,
--                        EMAIL_ID,
--                        GENDER,
--                        DOB,
--                        DOJ_EPF,
--                        DOJ_EPS,
--                        DOE_EPF,
--                        DOE_EPS,
--                        REASON_EXIT,
--                        PARA_CODE,
--                        SUB_PARA_CODE,
--                        SUB_PARA_CATEGORY,
--                        ADV_AMOUNT,
--                        BANK_ACC_NO,
--                        IFSC_CODE,
--                        CLAIM_SOURCE_FLAG,
--                        ADDRESS1,
--                        ADDRESS2,
--                        ADDRESS_CITY,
--                        ADDRESS_DIST,
--                        ADDRESS_STATE,
--                        ADDRESS_PIN,
--                        AGENCY_EMPLOYER_FLAG,
--                        AGENCY_NAME,
--                        AGENCY_ADDRESS,
--                        AGENCY_ADDRESS_CITY,
--                        AGENCY_ADDERSS_DIST,
--                        AGENCY_ADDRESS_STATE,
--                        AGENCY_ADDRESS_PIN,
--                        PDB_UPDATE_FLAG,
--                        FLAG_15GH,
--                        TDS_15GH,
--                        CANCEL_CHEQUE,
--                        ADV_ENCLOSURE,
--                        IP_ADDRESS,
--                        EKYC_STATUS,
--                                                SYSTIMESTAMP AS REJECTION_TIMESTAMP,
--                        MARITAL_STATUS,
--                        CLAIM_BY,
--                        PENSION_TYPE,
--                        OPTED_REDUCED_PENSION,
--                        OPTED_DATE,
--                        PPO_DETAILS,
--                        SCHEME_CERTIFICATE,
--                        DEFERRED_PENSION,
--                        DEFERRED_PENSION_AGE,
--                        DEFERRED_PENSION_CONT,
--                        NOMINATION_ID,
--                        BANK_ID,
--                        MEMBER_PHOTOGRAPH,
--                        CANCEL_CHEQUE_PATH,
--                        KYC_PDF,
--                        AADHAAR_VERIFICATION_STATUS,--#ver2.9
--                        KYC_PDF_EXISTS,	--#ver2.9
--                        FORM_10C_APPLICATION_TYPE, --#ver4.6
--                        WITHDRAWAL_REASON_CODE, --#ver4.21
--                        AADHAAR_CONSENT_STATUS, --#ver4.22
--                        AADHAAR_CONSENT_REF_ID --#ver4.22
--                      FROM
--                        OCS_CLAIM_DATA OCD
--                      WHERE
--                        TRACKING_ID=V_REC.TRACKING_ID
--                      );

                DELETE OCS_UIDAI_RESPONSE WHERE TRACKING_ID=V_REC.TRACKING_ID;

                DELETE OCS_CLAIM_STATUS_LOG WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;

                DELETE OCS_CRD WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;
                DELETE OCS_NOMINATION_FAMILY_DET WHERE TRACKING_ID=V_REC.TRACKING_ID;
                DELETE OCS_VERIFICATION_LOG_DETAILS WHERE TRACKING_ID=V_REC.TRACKING_ID;	--#ver3.5
                DELETE OCS_VERIFICATION_LOG_SUMMARY WHERE TRACKING_ID=V_REC.TRACKING_ID;	--#ver3.5

                DELETE OCS_CLAIM_DATA WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;

                IF V_COUNT = 3 THEN
                        COMMIT;
                ELSE
                        ROLLBACK;
                END IF;
        END LOOP;

        IF V_COUNT = 3 THEN
                OUT_MESSAGE := '0#~#Pending claim(s) deleted successfully.';
        ELSE
                OUT_MESSAGE := '1#~#Failed to delete pending claim(s).';
        END IF;
EXCEPTION
                WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END DELETE_NON_EKYC_CLAIM;


  PROCEDURE GET_NOMINATION_DETAILS_FOR_OCS(
                IN_UAN IN NUMBER,
                OUT_NOMINATION_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
        )
        AS
        BEGIN
           
               OPEN OUT_NOMINATION_DETAILS FOR
                        SELECT
                                MND.UAN,
                                MND.AADHAAR,
                                MND.NOMINATION_ID,
                                UR.NAME,
                                TO_CHAR(UR.DOB,'DD/MM/YYYY') AS DOB,
                                '' AS UID_TOKEN,  --ADDED ON 19/03/2019
                                DECODE(MND.GENDER,'M','MALE','F','FEMALE','T','TRANSGENDER','NOT PROVIDED') AS GENDER_STR,
                                UR.FATHER_OR_HUSBAND_NAME,
                                UR.MARITAL_STATUS,
                                UPPER(REPLACE(GET_MARITAL_STATUS_STR(UR.MARITAL_STATUS),'Not Provided',NULL))   AS MARITAL_STATUS_STR,
                                TO_CHAR(MND.DOJ_EPF_AS_ON_NOMINATION_DATE,'DD/MM/YYYY') DOJ_EPF,
                                TO_CHAR(MND.DOJ_EPS_AS_ON_NOMINATION_DATE,'DD/MM/YYYY') DOJ_EPS,
                                '--' AS DOJ_FPS,
                                MND.GENDER,
                                MND.PERMANENT_ADDRESS,
                                MND.CURRENT_ADDRESS,
                                MND.HAVING_FAMILY,
                                TO_CHAR(MND.NOMINATION_ENTRY_TIME,'DD-MON-YYYY HH24:MI') AS NOMINATION_ENTRY_TIME,
                                MND.STATUS,
                                MNFD.NOMINATION_FAMILY_ID,
                                MNFD.IS_FAMILY_MEMBER,
                                CASE
                                  WHEN MNFD.NOMINATION_TYPE = 'B' THEN 'S'
                                  ELSE MNFD.NOMINATION_TYPE
                                END AS NOMINATION_TYPE,     --F = EPF, S = EPS, B = BOTH, N = NOT A NOMINE (JUST A FAMILY MEMBER)
                                MNFD.EPF_PERCENTAGE,  -- NEED TO CONFIRM   --Eg. 99.99%   --NEED TO VALIDATE FOR 100.00  I.E. (5,2)
                                MNFD.NOMINEE_NAME,
                                TO_CHAR(MNFD.NOMINEE_DOB,'DD/MM/YYYY') AS NOMINEE_DOB,
                                MNFD.NOMINEE_RELATION,
                                CASE
--                                        WHEN MNFD.NOMINEE_RELATION IS NULL THEN  --#ver4.36
--                                                ''
                                        WHEN MND.HAVING_FAMILY = 'N' AND MNFD.NOMINEE_RELATION IS NULL THEN --#ver4.29
                                                MNFD.NOMINEE_RELATION_OTHER
                                        WHEN MND.HAVING_FAMILY = 'Y' AND MNFD.NOMINATION_TYPE = 'S' AND MNFD.NOMINEE_RELATION IS NULL THEN --#ver4.36
                                                MNFD.NOMINEE_RELATION_OTHER
                                        ELSE
                                                PKG_MEMBER_NOMINATION.GET_RELATION_STR(UR.GENDER,MNFD.NOMINEE_RELATION) --#ver4.36
                                END AS RELATION_STR,
                                MNFD.NOMINEE_RELATION_OTHER,
                                MNFD.NOMINEE_ADDRESS,
                                                                --NEW PARAMETERS ADDED ON 01/03/2018 ON CLONE DB
                                                --        MNFD.NOMINEE_GENDER,
                                                                DECODE(MNFD.NOMINEE_GENDER,'M','MALE','F','FEMALE','T','TRANSGENDER','NOT PROVIDED') AS NOMINEE_GENDER,
                                                                MNFD.NOMINEE_AADHAAR,
                                                                NVL2(MNFD.NOMINEE_AADHAAR,COMMON_KYC_MASK.MASKED_AADHAAR(MNFD.NOMINEE_AADHAAR),'') AS MASKED_NOMINEE_AADHAAR,                            --ADDED BY AKSHAY ON 15/04/2019
                                                                MNFD.NOMINEE_AADHAAR_STATUS,
                                                                MNFD.NOMINEE_AADHAAR_REFERENCE_NO,
                                MNFD.IS_MINOR_NOMINEE,  -- Y = YES, N = NO
                                MNFD.GUARDIAN_NAME,
                                MNFD.GUARDIAN_RELATION,
                                MNFD.GUARDIAN_ADDRESS,
                                -- MNFD.UID_TOKEN AS FAMILY_MEM_UID_TOKEN,  --ADDED BY AKSHAY ON 26/03/2019
                                -- MNFD.UIDAI_RESPONSE_TRANS_ID AS FAMILY_MEM_UIDAI_RESP_TRANS_ID, --ADDED BY AKSHAY ON 26/03/2019
                                MPP.PHOTOGRAPH AS MEM_PHOTO,
                                MNFD.PHOTOGRAPH AS NOMINEE_PHOTO
                        FROM
                                MEMBER_NOMINATION_DETAILS MND
                        INNER JOIN MEM_NOMINATION_FAMILY_DETAILS MNFD
                                ON MND.NOMINATION_ID = MNFD.NOMINATION_ID
                        INNER JOIN UAN_REPOSITORY UR
                          ON UR.UAN = MND.UAN
                        LEFT OUTER JOIN UP_ALT.MEMBER_PROFILE_PHOTO MPP ON
                          MPP.UAN = UR.UAN
                        WHERE
                                MND.NOMINATION_ID = (SELECT MAX(NOMINATION_ID) FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS = 'E');
            
           
        END GET_NOMINATION_DETAILS_FOR_OCS;




PROCEDURE GET_NOMINEE_DETAILS_FOR_OCS
(
    IN_TRACKING_ID IN OCS_CLAIM_DATA.TRACKING_ID%TYPE,
    OUT_NOMINATION_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)
AS
    BEGIN
    OPEN OUT_NOMINATION_DETAILS FOR
       SELECT
          MND.UAN,
          MND.AADHAAR,
          MND.NOMINATION_ID,
          UR.NAME,
          TO_CHAR(UR.DOB,'DD/MM/YYYY') AS DOB,
--          '' AS UID_TOKEN,  --ADDED ON 19/03/2019
          DECODE(MND.GENDER,'M','MALE','F','FEMALE','T','TRANSGENDER','NOT PROVIDED') AS GENDER_STR,
          UR.FATHER_OR_HUSBAND_NAME,
          UR.MARITAL_STATUS,
          UPPER(REPLACE(GET_MARITAL_STATUS_STR(UR.MARITAL_STATUS),'Not Provided',NULL))   AS MARITAL_STATUS_STR,
          TO_CHAR(MND.DOJ_EPF_AS_ON_NOMINATION_DATE,'DD/MM/YYYY') DOJ_EPF,
          TO_CHAR(MND.DOJ_EPS_AS_ON_NOMINATION_DATE,'DD/MM/YYYY') DOJ_EPS,
          '--' AS DOJ_FPS,
          MND.GENDER,
          MND.PERMANENT_ADDRESS,
          MND.CURRENT_ADDRESS,
          MND.HAVING_FAMILY,
          TO_CHAR(MND.NOMINATION_ENTRY_TIME,'DD-MON-YYYY HH24:MI') AS NOMINATION_ENTRY_TIME,
          MND.STATUS,
          MNFD.NOMINATION_FAMILY_ID,
          MNFD.IS_FAMILY_MEMBER,
          MNFD.NOMINATION_TYPE,     --F = EPF, S = EPS, B = BOTH, N = NOT A NOMINE (JUST A FAMILY MEMBER)
          MNFD.EPF_PERCENTAGE,  -- NEED TO CONFIRM   --Eg. 99.99%   --NEED TO VALIDATE FOR 100.00  I.E. (5,2)
          MNFD.NOMINEE_NAME,
          TO_CHAR(MNFD.NOMINEE_DOB,'DD/MM/YYYY') AS NOMINEE_DOB,
          MNFD.NOMINEE_RELATION,
          CASE
             WHEN MND.HAVING_FAMILY = 'N' AND MNFD.NOMINEE_RELATION IS NULL THEN --#ver4.29
               MNFD.NOMINEE_RELATION_OTHER
             WHEN MND.HAVING_FAMILY = 'Y' AND MNFD.NOMINATION_TYPE = 'S' AND MNFD.NOMINEE_RELATION IS NULL THEN --#ver4.36
               MNFD.NOMINEE_RELATION_OTHER
             ELSE
               PKG_MEMBER_NOMINATION.GET_RELATION_STR(UR.GENDER,MNFD.NOMINEE_RELATION) --#ver4.36
            END AS RELATION_STR,
          MNFD.NOMINEE_RELATION_OTHER,
          MNFD.NOMINEE_ADDRESS,

                        --NEW PARAMETERS ADDED ON 01/03/2018 ON CLONE DB
          MNFD.NOMINEE_GENDER,
          MNFD.NOMINEE_AADHAAR,
          NVL2(MNFD.NOMINEE_AADHAAR,COMMON_KYC_MASK.MASKED_AADHAAR(MNFD.NOMINEE_AADHAAR),'') AS MASKED_NOMINEE_AADHAAR,   --ADDED BY AKSHAY ON 15/04/2019
          MNFD.NOMINEE_AADHAAR_STATUS,
          MNFD.NOMINEE_AADHAAR_REFERENCE_NO,
          MNFD.IS_MINOR_NOMINEE,  -- Y = YES, N = NO
          MNFD.GUARDIAN_NAME,
          MNFD.GUARDIAN_RELATION,
          MNFD.GUARDIAN_ADDRESS,
          -- MNFD.UID_TOKEN AS FAMILY_MEM_UID_TOKEN,  --ADDED BY AKSHAY ON 26/03/2019
          -- MNFD.UIDAI_RESPONSE_TRANS_ID AS FAMILY_MEM_UIDAI_RESP_TRANS_ID, --ADDED BY AKSHAY ON 26/03/2019
          MPP.PHOTOGRAPH AS MEM_PHOTO,
          MNFD.PHOTOGRAPH AS NOMINEE_PHOTO
        FROM
          MEMBER_NOMINATION_DETAILS MND
        INNER JOIN
          MEM_NOMINATION_FAMILY_DETAILS MNFD
        ON
          MND.NOMINATION_ID = MNFD.NOMINATION_ID
        INNER JOIN
          CEN_OCS_FORM_10_C OCD
        ON
          OCD.NOMINATION_ID = MND.NOMINATION_ID
        INNER JOIN
          UAN_REPOSITORY UR
        ON
          UR.UAN = MND.UAN
        LEFT OUTER JOIN
          UP_ALT.MEMBER_PROFILE_PHOTO MPP
        ON
          MPP.UAN = UR.UAN
        WHERE
            OCD.TRACKING_ID = IN_TRACKING_ID AND
            MNFD.NOMINATION_TYPE IN ('S', 'B');

    END GET_NOMINEE_DETAILS_FOR_OCS;

PROCEDURE GET_OCS_CLAIM_DATA_FOR_PDF
(
    IN_TRACKING_ID IN OCS_CLAIM_DATA.TRACKING_ID%TYPE,
    OUT_OCS_CLAIM_DATA OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE,
    OUT_NOMINATION_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
)
AS
        V_BANK_DETAILS VARCHAR2(128);
        V_IFSC VARCHAR2(30);
    BEGIN

        OPEN OUT_OCS_CLAIM_DATA FOR
    SELECT
      OCD.UAN AS UAN,
      OCD.BANK_ID,
                        MEMBER_NAME,
                        MOBILE,
                        TO_CHAR(OCD.DOB, 'DD-MM-YYYY')  AS DOB,
                        FATHER_SPOUSE_NAME,
                        TO_CHAR(DOJ_EPF, 'DD-MM-YYYY')  AS DOJ_EPF,
                        TO_CHAR(DOJ_EPS, 'DD-MM-YYYY')  AS DOJ_EPS,
                        TO_CHAR(DOE_EPF, 'DD-MM-YYYY')  AS DOE_EPF,
                        TO_CHAR(DOE_EPS, 'DD-MM-YYYY')  AS DOE_EPS,
                        OCD.PAN,
                        OCD.AADHAAR,
      (CASE
        WHEN OCD.GENDER = 'M' THEN 'Male'
        WHEN OCD.GENDER = 'F' THEN 'Female'
        END) as GENDER
      ,
      EST.NAME    AS        ESTABLISHMENT_ID,
      (OCD.ADDRESS1 || ',' || OCD.ADDRESS2 || ',' || OCD.ADDRESS_CITY || ' - ' ||OCD.ADDRESS_PIN) AS MEMBER_ADDRESS,
			OCD.BANK_ACC_NO   AS BANK_ACC_NO,
			OCD.IFSC_CODE     AS IFSC_CODE,
			(CASE
				WHEN OCD.CLAIM_BY = 'M' THEN 'Member'
				ELSE 'Employer'
				END) as CLAIM_BY,
      (CASE
				WHEN OCD.MARITAL_STATUS = 'M' THEN 'Married'
				WHEN OCD.MARITAL_STATUS = 'U' THEN 'Unmarried'
        WHEN OCD.MARITAL_STATUS = 'W' THEN 'Widow/Widower'
        WHEN OCD.MARITAL_STATUS = 'D' THEN 'Divorcee'
                                END)
        as MARITAL_STATUS,

      (CASE
        WHEN OCD.PENSION_TYPE = 'D' THEN 'Disablement'
        WHEN OCD.PENSION_TYPE = 'S' THEN 'Superannuation'
        END) AS PENSION_TYPE,
        (CASE
        WHEN OCD.OPTED_REDUCED_PENSION = 'Y' THEN 'Yes'
        WHEN OCD.OPTED_REDUCED_PENSION = 'N' THEN 'No'
        END) AS OPTED_REDUCED_PENSION,
                        TO_CHAR(OPTED_DATE, 'DD-MM-YYYY')       AS OPTED_DATE,
                        PPO_DETAILS,
                        SCHEME_CERTIFICATE,
                        DEFERRED_PENSION,
                        DEFERRED_PENSION_AGE,
                        DEFERRED_PENSION_CONT,
                        OCD.NOMINATION_ID,
                        OCD.OFFICE_ID,
      OCD.CANCEL_CHEQUE AS CANCEL_CHEQUE,
                        OCD.BANK_ACC_NO         AS BANK_ACC_NO,
                        MEMBER_ID,
                        TRACKING_ID,
                        TO_CHAR(RECEIPT_DATE, 'DD-MM-YYYY')     AS RECEIPT_DATE,
      MPP.PHOTOGRAPH              AS MEM_PHOTO,
      MER.REASON                  AS EXIT_REASON,
--        (SELECT DISTINCT BANK_NAME FROM UNIFIED_PORTAL.BANK_MASTER SBM WHERE  SBM.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) AND SBM.UP_BANK_ID = OCD.BANK_ID AND SBM.IS_FOR_10D='Y') AS BANK_NAME,
      (
        SELECT
          DISTINCT B.NAME
        FROM
          UNIFIED_PORTAL.BANK_IFSC BI
        INNER JOIN BANK B
          ON B.ID = BI.BANK_ID
        WHERE
          BI.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) AND
          BI.BANK_ID = OCD.BANK_ID AND
          BI.IS_FOR_10D = 'Y' AND
          NVL(BI.OBSOLETE,'N') = 'N'
      ) AS BANK_NAME,
      -- SBM.BANK_NAME                         AS BANK_NAME,
--      BM.BRANCH_NAME                        AS BANK_BRANCH,
      BM.BRANCH                        AS BANK_BRANCH,
--      BM.BRANCH_ADDR                        AS BANK_ADDRESS
      ST.NAME                        AS BANK_ADDRESS
                FROM
                        OCS_CLAIM_DATA OCD
    INNER JOIN
      MEMBER_NOMINATION_DETAILS MND
    ON
      MND.NOMINATION_ID = OCD.NOMINATION_ID
    INNER JOIN
          UAN_REPOSITORY UR
        ON
          UR.UAN = MND.UAN
        LEFT OUTER JOIN
          UP_ALT.MEMBER_PROFILE_PHOTO MPP
        ON
          MPP.UAN = UR.UAN
   -- INNER JOIN
        LEFT JOIN
      MEMBER_EXIT_REASON MER
    ON
      MER.ID = OCD.REASON_EXIT
--    INNER JOIN BANK_MASTER SBM ON
--              SBM.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) AND SBM.UP_BANK_ID = OCD.BANK_ID AND SBM.IS_FOR_10D='Y'
--    INNER JOIN UNIFIED_PORTAL.BANK_MASTER BM ON
--              BM.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) AND BM.IFSC_CODE = OCD.IFSC_CODE

--    INNER JOIN BANK_IFSC SBM ON       --#ver1.4
--      SBM.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) AND SBM.BANK_ID = OCD.BANK_ID AND SBM.IS_FOR_10D='Y'--#ver1.4
    INNER JOIN UNIFIED_PORTAL.BANK_IFSC BM ON
      /*BM.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) AND*/ BM.IFSC_CODE = OCD.IFSC_CODE AND BM.BANK_ID = OCD.BANK_ID AND BM.IS_FOR_10D='Y' --#ver1.4
    INNER JOIN STATE ST
      ON ST.ID = BM.STATE_ID
        INNER JOIN
                ESTABLISHMENT EST
        ON
                EST.EST_ID = OCD.ESTABLISHMENT_ID
                WHERE
                        TRACKING_ID = IN_TRACKING_ID
--      AND BM.SLIP_TYPE = '600'
--      AND BM.RECORD_STATUS = '0'
      AND	
      ( (	--ADDED ON 06/02/2020	--#ver1.4
            CASE
            WHEN TO_NUMBER(OCD.ADDRESS_STATE) = 36 THEN		--1 = STATE_ID OF ANDHRA PRADESH, 36 = STATE_ID OF TELANGANA
              (CASE WHEN BM.STATE_ID in(1,36) THEN 1 ELSE 0 END)
            ELSE
              (CASE WHEN BM.STATE_ID = TO_NUMBER(OCD.ADDRESS_STATE) THEN 1 ELSE 0 END)
            END )=1) 

      AND NVL(BM.OBSOLETE,'N') = 'N'
      ;

                BEGIN
                        GET_NOMINEE_DETAILS_FOR_OCS(IN_TRACKING_ID, OUT_NOMINATION_DETAILS);
                END;
END GET_OCS_CLAIM_DATA_FOR_PDF;

  --ADDED BY AKSHAY FOR FORM-15G/H UPLOAD IN FORM-19
  PROCEDURE GET_PAN_VERIFICATION_STATUS(
    IN_UAN IN NUMBER,
    OUT_STATUS OUT VARCHAR2
  )
  AS
    V_UR_PAN VARCHAR2(10);
    V_MK_PAN VARCHAR2(40);
  BEGIN
--    SELECT --#ver1.5
--      NVL(PAN_DEMO_VERIFICATION_STAT,'N') PAN_DEMO_VERIFICATION_STAT
--    INTO
--      OUT_STATUS
--    FROM
--      UAN_REPOSITORY UR
--    WHERE
--      UR.UAN = IN_UAN;    

   --#ver1.5
  --ADDED ON 12/02/2020 TO CHECK DIGITALLY SIGNED PAN INSTEAD OF PAN VERIFICATION STATUS  --WHATSAPP BY SMITA SONI TO AKSHAY ON 11/02/2020    
--    SELECT
--      PAN
--    INTO
--      V_UR_PAN
--    FROM
--      UAN_REPOSITORY UR
--    WHERE
--      UR.UAN = IN_UAN;
--      
--    V_MK_PAN := PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(IN_UAN,2,'N');  
--    LOG_ERROR('GET_PAN_VERIFICATION_STATUS V_MK_PAN','IN_UAN: '||IN_UAN||' V_UR_PAN: '||V_UR_PAN||' V_MK_PAN: '||V_MK_PAN);
--    IF V_UR_PAN = TRIM(V_MK_PAN) THEN
--      OUT_STATUS := 'S';
--    ELSE
--      OUT_STATUS := 'D';
--    END IF;  
--ADDITION ON 12/02/2020 ENDS HERE

--ADDED ON 19/02/2020 --#ver1.7
SELECT
      NVL2(TRIM(PAN),'S','D')
    INTO
      OUT_STATUS
    FROM
      UAN_REPOSITORY UR
    WHERE
      UR.UAN = IN_UAN;

  EXCEPTION
    WHEN OTHERS THEN
--      LOG_ERROR('GET_PAN_VERIFICATION_STATUS','IN_UAN: '||IN_UAN||' V_UR_PAN: '||V_UR_PAN||' V_MK_PAN: '||V_MK_PAN||' ERROR:'||SQLERRM);
      LOG_ERROR('GET_PAN_VERIFICATION_STATUS','IN_UAN: '||IN_UAN||' OUT_STATUS: '||OUT_STATUS||' ERROR:'||SQLERRM);
      OUT_STATUS := 'D';          
  END GET_PAN_VERIFICATION_STATUS;

  PROCEDURE GET_DATA_FOR_10D_SERVICE(
    IN_UAN IN NUMBER,
    IN_MEMBER_ID IN VARCHAR2,
    OUT_MARITAL_STATUS OUT VARCHAR2,
    OUT_OFFICE_ID OUT NUMBER
  )
  AS
  BEGIN
    OUT_OFFICE_ID := GET_OFFICE_ID(IN_MEMBER_ID);
    SELECT
      MARITAL_STATUS
    INTO
      OUT_MARITAL_STATUS
    FROM
      UAN_REPOSITORY
    WHERE
      UAN = IN_UAN;
--  EXCEPTION
--    WHEN OTHERS THEN
--      RAISE_APPLICATION_ERROR(-20001,'1#~#ERROR WHILE FETCHING DETAILS FOR SERVICE VALIDATION.');
  END GET_DATA_FOR_10D_SERVICE;
    PROCEDURE GET_TRACKING_ID_AND_OFFICE_ID(
      IN_UAN IN NUMBER,
      IN_CLAIM_TYPE IN VARCHAR2,
      IN_MEMBER_SYS_ID IN NUMBER,
      OUT_TRACKING_ID OUT NUMBER,
      OUT_OFFICE_ID OUT NUMBER
    )AS
      V_MEMBER_ID VARCHAR2(25):='';
    BEGIN
      IF IN_CLAIM_TYPE = '06' AND IN_MEMBER_SYS_ID IS NOT NULL THEN
        SELECT MEMBER_ID INTO V_MEMBER_ID FROM MEMBER WHERE ID = IN_MEMBER_SYS_ID AND EST_SLNO <> 0;   --#ver4.14
      ELSE
        V_MEMBER_ID := last_mid(IN_UAN);
      END IF;

      OUT_OFFICE_ID := GET_OFFICE_ID(SUBSTR(V_MEMBER_ID,0,22));
      OUT_TRACKING_ID  := GEN_TRACKING_ID_UAN(IN_UAN,IN_CLAIM_TYPE);
    END GET_TRACKING_ID_AND_OFFICE_ID;
  --ADDED BY AKSHAY ON 04/12/2019 FOR EKYC STATUS ISSUE
   PROCEDURE SUBMIT_OCS_CLAIM(
      ----------IN-PARAMETERS OF SAVE_CLAIM_DATA STARTS HERE
      IN_CLAIM_TYPE          IN CEN_OCS_FORM_19.CLAIM_FORM_TYPE%TYPE,
      IN_UAN                 IN NUMBER,
      IN_DOE_EPF             IN CEN_OCS_FORM_19.DOE_EPF%TYPE,
      IN_DOE_EPS             IN CEN_OCS_FORM_19.DOE_EPS%TYPE,
      T_REASON_EXIT          IN CEN_OCS_FORM_19.REASON_EXIT%TYPE,
      T_PARA_CODE            IN CEN_OCS_FORM_19.PARA_CODE%TYPE,
      T_SUB_PARA_CODE        IN CEN_OCS_FORM_19.SUB_PARA_CODE%TYPE ,
      T_SUB_PARA_CATEGORY    IN CEN_OCS_FORM_19.SUB_PARA_CATEGORY%TYPE ,
      T_ADV_AMOUNT           IN CEN_OCS_FORM_31.ADV_AMOUNT%TYPE,
      T_CLAIM_SOURCE_FLAG    IN CEN_OCS_FORM_19.CLAIM_SOURCE_FLAG%TYPE ,
      T_ADDRESS1             IN CEN_OCS_FORM_19.ADDRESS1%TYPE ,
      T_ADDRESS2             IN CEN_OCS_FORM_19.ADDRESS2%TYPE ,
      T_ADDRESS_CITY         IN CEN_OCS_FORM_19.ADDRESS_CITY%TYPE ,
      T_ADDRESS_DIST         IN CEN_OCS_FORM_19.ADDRESS_DIST%TYPE ,
      T_ADDRESS_STATE        IN CEN_OCS_FORM_19.ADDRESS_STATE%TYPE ,
      T_ADDRESS_PIN          IN CEN_OCS_FORM_19.ADDRESS_PIN%TYPE ,
      T_AGENCY_EMPLOYER_FLAG IN CEN_OCS_FORM_31.AGENCY_EMPLOYER_FLAG%TYPE ,
      T_AGENCY_NAME          IN CEN_OCS_FORM_31.AGENCY_NAME%TYPE ,
      T_AGENCY_ADDRESS       IN CEN_OCS_FORM_31.AGENCY_ADDRESS%TYPE ,
      T_AGENCY_ADDRESS_CITY  IN CEN_OCS_FORM_31.AGENCY_ADDRESS_CITY%TYPE ,
      T_AGENCY_ADDERSS_DIST  IN CEN_OCS_FORM_31.AGENCY_ADDERSS_DIST%TYPE ,
      T_AGENCY_ADDRESS_STATE IN CEN_OCS_FORM_31.AGENCY_ADDRESS_STATE%TYPE ,
      T_AGENCY_ADDRESS_PIN   IN CEN_OCS_FORM_31.AGENCY_ADDRESS_PIN%TYPE ,
      T_FLAG_15GH            IN CEN_OCS_FORM_19.FLAG_15GH%TYPE,
      T_PDF_15GH             IN CEN_OCS_FORM_19.PDF_15GH%TYPE,
      T_TDS_15GH             IN CEN_OCS_FORM_19.TDS_15GH%TYPE,
--      T_CANCEL_CHEQUE        IN CEN_OCS_FORM_19.CANCEL_CHEQUE%TYPE,
      T_ADV_ENCLOSURE        IN CEN_OCS_FORM_31.ADV_ENCLOSURE%TYPE,
      T_IP_ADDRESS           IN CEN_OCS_FORM_19.IP_ADDRESS%TYPE,
      --ADDED BY AKSHAY FOR 10D
      IN_CLAIM_BY        IN CEN_OCS_FORM_19.CLAIM_BY%TYPE,
      IN_PENSION_TYPE      IN CEN_OCS_FORM_10D.PENSION_TYPE%TYPE,
      IN_OPTED_REDUCED_PENSION IN CHAR,
      IN_OPTED_DATE        IN VARCHAR2,
      IN_PPO_DETAILS       IN VARCHAR2,
      IN_SCHEME_CERTIFICATE    IN VARCHAR2,
      IN_DEFERRED_PENSION    IN CHAR,
      IN_DEFERRED_PENSION_AGE  IN NUMBER,
      IN_DEFERRED_PENSION_CONT IN VARCHAR2,
      IN_BANK_ACCOUNT_NUMBER   IN VARCHAR2,
      IN_BANK_IFSC       IN VARCHAR2,
      IN_BANK_ID         IN NUMBER,
      --ADDITION BY AKSHAY FOR 10D ENDED
--      IN_CANCEL_CHEQUE_PATH IN VARCHAR2,	    --ADDED BY AKSHAY ON 09/08/2019 TO STORE PHYSICAL LOCATION OF UPLOADED CANCELLED CHEQUE
      IN_MEMBER_SYS_ID IN NUMBER, --#ber3.8
      IN_AADHAAR_FOR_DEMO_VERIFY IN VARCHAR2,	--#ver3.4
      IN_AADHAAR_DEMO_VERIFY_STATUS IN VARCHAR2,	--#ver3.4
      IN_AADHAAR_DEMO_VERIFY_CODE IN VARCHAR2,	--#ver3.4
      IN_APPLICATION_TYPE IN VARCHAR2, --ADDED ON 24/11/2021  --#ver4.29
      IN_WITHDRAWAL_REASON IN VARCHAR2, --ADDED ON 28/09/2020  --#ver4.21
      IN_AADHAAR_CONSENT_STATUS IN CHAR, --#ver4.22
      IN_AADHAAR_CONSENT_REF_ID IN NUMBER, --#ver4.22
      ----------IN-PARAMETERS OF SAVE_CLAIM_DATA ENDS HERE
      ----------IN-PARAMETERS OF UPDATE_AADHAAR_EKYC STARTS HERE
      IN_TRACKING_ID       IN OCS_UIDAI_RESPONSE.TRACKING_ID%TYPE,
      IN_AADHAAR           IN OCS_UIDAI_RESPONSE.AADHAAR%TYPE,
      IN_PID               IN varchar2,
      IN_RESPONSE_CODE     IN OCS_UIDAI_RESPONSE.RESPONSE_CODE%TYPE,
      IN_NAME              IN OCS_UIDAI_RESPONSE.NAME%TYPE,
      IN_DOB               IN varchar2,
      IN_EMAIL             IN OCS_UIDAI_RESPONSE.EMAIL%TYPE,
      IN_GENDER            IN OCS_UIDAI_RESPONSE.GENDER%TYPE,
      IN_PHONE             IN OCS_UIDAI_RESPONSE.CO_SO%TYPE,
      IN_DISTRICT          IN OCS_UIDAI_RESPONSE.DISTRICT%TYPE,
      --IN_HOUSE_NUMBER      IN OCS_UIDAI_RESPONSE.HOUSE_NUMBER%TYPE,
      IN_LAND_MARK         IN OCS_UIDAI_RESPONSE.LAND_MARK%TYPE,
      IN_LOCALITY          IN OCS_UIDAI_RESPONSE.LOCALITY%TYPE,
      IN_VILL_TOWN_CITY    IN OCS_UIDAI_RESPONSE.VILL_TOWN_CITY%TYPE,
      IN_STREET            IN OCS_UIDAI_RESPONSE.STREET%TYPE,
      IN_POST_OFFICE       IN OCS_UIDAI_RESPONSE.POST_OFFICE%TYPE,
      IN_SUB_DISTRICT      IN OCS_UIDAI_RESPONSE.SUB_DISTRICT%TYPE,
      IN_STATE             IN OCS_UIDAI_RESPONSE.STATE%TYPE,
      ----------IN-PARAMETERS OF UPDATE_AADHAAR_EKYC ENDS HERE
      ----- IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH STARTS HERE ADDED ON 18/09/2020
      IN_3RDPARTY_NAME     IN VARCHAR2  DEFAULT NULL,
      IN_3RDPARTY_BANK_ACCNO IN VARCHAR2 DEFAULT NULL,
      IN_3RDPARTY_BANK_IFSC  IN VARCHAR2 DEFAULT NULL,
      IN_AUTH_LETTER_FILE_PATH IN VARCHAR2 DEFAULT NULL,
      ------ IN PARAMS TO ADD 3RD PARTY BANK DETAILS AND AUTH LETTER PATH ENDS HERE

      ----------OUT-PARAMETERS OF SAVE_CLAIM_DATA STARTS HERE
      OUT_MOBILE_NUMBER OUT CEN_OCS_FORM_19.MOBILE%TYPE,
      OUT_MEMBER_NAME OUT CEN_OCS_FORM_19.MEMBER_NAME%TYPE,
      OUT_LEAVE_REASON OUT VARCHAR2,
      OUT_FS_NAME OUT CEN_OCS_FORM_19.FATHER_SPOUSE_NAME%TYPE,
      OUT_DOJ_EPF OUT VARCHAR2,
      OUT_DOJ_EPS OUT VARCHAR2,
      OUT_DOE_EPF OUT VARCHAR2,
      OUT_DOE_EPS OUT VARCHAR2,
      OUT_DOB OUT VARCHAR2,
      OUT_PANCARD OUT VARCHAR2,
      OUT_AADHAAR OUT CEN_OCS_FORM_19.AADHAAR%TYPE,
      OUT_BANK_ACC_NO OUT CEN_OCS_FORM_19.BANK_ACC_NO%TYPE,
      OUT_BANK_IFSC OUT CEN_OCS_FORM_19.IFSC_CODE%TYPE,
      OUT_BANK_DETAILS OUT VARCHAR2,
      OUT_MEMBER_ID OUT CEN_OCS_FORM_19.MEMBER_ID%TYPE,
      OUT_OFFICE_ID         OUT NUMBER,
      OUT_RECEIPT_DATE OUT CEN_OCS_FORM_19.RECEIPT_DATE%TYPE,
      OUT_STATUS OUT NUMBER,    --REQUIRED FOR UPDATE_AADHAAR_EKYC ALSO
      OUT_TRACKING_ID OUT  NUMBER,
      OUT_MESSAGE OUT VARCHAR2	--REQUIRED FOR UPDATE_AADHAAR_EKYC ALSO
      ----------OUT-PARAMETERS OF SAVE_CLAIM_DATA ENDS HERE
  )AS
  BEGIN
    LOG_ERROR('INSIDE SAVE_CLAIM_DATA :', 'BY YASH');
    SAVE_CLAIM_DATA_FOR_UP(
      IN_CLAIM_TYPE,
      IN_UAN,
      IN_DOE_EPF,
      IN_DOE_EPS,
      T_REASON_EXIT,
      T_PARA_CODE,
      T_SUB_PARA_CODE,
      T_SUB_PARA_CATEGORY,
      T_ADV_AMOUNT,
      T_CLAIM_SOURCE_FLAG,
      T_ADDRESS1,
      T_ADDRESS2,
      T_ADDRESS_CITY,
      T_ADDRESS_DIST,
      T_ADDRESS_STATE,
      T_ADDRESS_PIN,
      T_AGENCY_EMPLOYER_FLAG,
      T_AGENCY_NAME,
      T_AGENCY_ADDRESS,
      T_AGENCY_ADDRESS_CITY,
      T_AGENCY_ADDERSS_DIST,
      T_AGENCY_ADDRESS_STATE,
      T_AGENCY_ADDRESS_PIN,
      T_FLAG_15GH,
      T_PDF_15GH,
      T_TDS_15GH,
--      T_CANCEL_CHEQUE,
      T_ADV_ENCLOSURE,
      T_IP_ADDRESS,
      IN_AADHAAR_FOR_DEMO_VERIFY,	--#ver3.4
      IN_AADHAAR_DEMO_VERIFY_STATUS,	--#ver3.4
      IN_AADHAAR_DEMO_VERIFY_CODE,	--#ver3.4
      IN_APPLICATION_TYPE, --ADDED ON 24/11/2021 --#ver4.29
      IN_WITHDRAWAL_REASON, --ADDED ON 28/09/2020  --#ver4.21
      IN_AADHAAR_CONSENT_STATUS, --#ver4.22
      IN_AADHAAR_CONSENT_REF_ID, --#ver4.22
      OUT_MOBILE_NUMBER,
      OUT_MEMBER_NAME,
      OUT_LEAVE_REASON,
      OUT_FS_NAME,
      OUT_DOJ_EPF,
      OUT_DOJ_EPS,
      OUT_DOE_EPF,
      OUT_DOE_EPS,
      OUT_DOB,
      OUT_PANCARD,
      OUT_AADHAAR,
      OUT_BANK_ACC_NO,
      OUT_BANK_IFSC,
      OUT_BANK_DETAILS,
      OUT_MEMBER_ID,
      OUT_OFFICE_ID,
      OUT_RECEIPT_DATE,
      OUT_STATUS,
      OUT_TRACKING_ID,
      OUT_MESSAGE,
      --ADDED BY AKSHAY FOR 10D
      IN_CLAIM_BY,
      IN_PENSION_TYPE,
      IN_OPTED_REDUCED_PENSION,
      IN_OPTED_DATE,
      IN_PPO_DETAILS,
      IN_SCHEME_CERTIFICATE,
      IN_DEFERRED_PENSION,
      IN_DEFERRED_PENSION_AGE,
      IN_DEFERRED_PENSION_CONT,
      IN_BANK_ACCOUNT_NUMBER,
      IN_BANK_IFSC,
      IN_BANK_ID,
      --ADDITION BY AKSHAY FOR 10D ENDED
--      IN_CANCEL_CHEQUE_PATH,
      IN_MEMBER_SYS_ID,
      IN_3RDPARTY_NAME     ,
      IN_3RDPARTY_BANK_ACCNO ,
      IN_3RDPARTY_BANK_IFSC  ,
      IN_AUTH_LETTER_FILE_PATH 
    );

--    CHECK OUT_STATUS AND OUT_MESSAGE
    IF OUT_STATUS = 1 THEN
      ROLLBACK;
    ELSIF OUT_STATUS = 0 THEN
    CASE IN_CLAIM_TYPE
    WHEN '01' THEN
      INSERT INTO CEN_OCS_FORM_19_UIDAI_RESPONSE(
        TRACKING_ID,
        AADHAAR,
        PID,
        RESPONSE_CODE,
        NAME,
        DOB,
        EMAIL,
        GENDER,
        PHONE,
        DISTRICT,
        HOUSE_NUMBER,
        LAND_MARK,
        LOCALITY,
        VILL_TOWN_CITY,
        STREET,
        POST_OFFICE,
        SUB_DISTRICT,
        STATE
      ) VALUES
      (
        OUT_TRACKING_ID,
        IN_AADHAAR,
        IN_PID,
        IN_RESPONSE_CODE,
        IN_NAME,
        TO_DATE(IN_DOB,'DD-MM-YYYY'),
        IN_EMAIL,
        SUBSTR(IN_GENDER,0,1),
        IN_PHONE,
        IN_DISTRICT  ,
        'NA',--need add
        IN_LAND_MARK,
        IN_LOCALITY,
        IN_VILL_TOWN_CITY,
        IN_STREET,
        IN_POST_OFFICE,
        IN_SUB_DISTRICT,
        IN_STATE
      );
    IF SQL%ROWCOUNT =1 THEN
      OUT_STATUS:=0;
      OUT_MESSAGE:=SQL%ROWCOUNT||' ROW INSERTED SUCCESSFULLY.';
       UPDATE CEN_OCS_FORM_19 COF19 SET COF19.EKYC_STATUS='Y' WHERE COF19.TRACKING_ID=OUT_TRACKING_ID;
        IF SQL%ROWCOUNT =1 THEN
        OUT_MESSAGE:=OUT_MESSAGE||' , '||SQL%ROWCOUNT||' ROW UPDATED SUCCESSFULLY.';
       COMMIT;
       END IF;
--        IF SQL%ROWCOUNT <> 1 THEN
       ELSE
        RAISE_APPLICATION_ERROR(-20001,'1#~#DE-01: Unable to log request. Please try after some time.#~#e-KYC data not saved. But insert statement executed successfully.');
--        END IF;
        COMMIT;
    END IF;   
   
      
    WHEN '06' THEN
     INSERT INTO CEN_OCS_FORM_31_UIDAI_RESPONSE(
        TRACKING_ID,
        AADHAAR,
        PID,
        RESPONSE_CODE,
        NAME,
        DOB,
        EMAIL,
        GENDER,
        PHONE,
        DISTRICT,
        HOUSE_NUMBER,
        LAND_MARK,
        LOCALITY,
        VILL_TOWN_CITY,
        STREET,
        POST_OFFICE,
        SUB_DISTRICT,
        STATE
      ) VALUES
      (
        OUT_TRACKING_ID,
        IN_AADHAAR,
        IN_PID,
        IN_RESPONSE_CODE,
        IN_NAME,
        TO_DATE(IN_DOB,'DD-MM-YYYY'),
        IN_EMAIL,
        SUBSTR(IN_GENDER,0,1),
        IN_PHONE,
        IN_DISTRICT  ,
        'NA',--need add
        IN_LAND_MARK,
        IN_LOCALITY,
        IN_VILL_TOWN_CITY,
        IN_STREET,
        IN_POST_OFFICE,
        IN_SUB_DISTRICT,
        IN_STATE
      );
    IF SQL%ROWCOUNT =1 THEN
      OUT_STATUS:=0;
      OUT_MESSAGE:=SQL%ROWCOUNT||' ROW INSERTED SUCCESSFULLY.';
       UPDATE CEN_OCS_FORM_31 COF31 SET COF31.EKYC_STATUS='Y' WHERE COF31.TRACKING_ID=OUT_TRACKING_ID;
        IF SQL%ROWCOUNT =1 THEN
        OUT_MESSAGE:=OUT_MESSAGE||' , '||SQL%ROWCOUNT||' ROW UPDATED SUCCESSFULLY.';
       COMMIT;
       END IF;
--      IF SQL%ROWCOUNT <> 1 THEN
       ELSE
        RAISE_APPLICATION_ERROR(-20001,'1#~#DE-01: Unable to log request. Please try after some time.#~#e-KYC data not saved. But insert statement executed successfully.');
--      END IF;
      COMMIT;
	 END IF; 
     
	WHEN '04' THEN
      INSERT INTO CEN_OCS_FORM_10C_UIDAI_RESP(
        TRACKING_ID,
        AADHAAR,
        PID,
        RESPONSE_CODE,
        NAME,
        DOB,
        EMAIL,
        GENDER,
        PHONE,
        DISTRICT,
        HOUSE_NUMBER,
        LAND_MARK,
        LOCALITY,
        VILL_TOWN_CITY,
        STREET,
        POST_OFFICE,
        SUB_DISTRICT,
        STATE
      ) VALUES
      (
        OUT_TRACKING_ID,
        IN_AADHAAR,
        IN_PID,
        IN_RESPONSE_CODE,
        IN_NAME,
        TO_DATE(IN_DOB,'DD-MM-YYYY'),
        IN_EMAIL,
        SUBSTR(IN_GENDER,0,1),
        IN_PHONE,
        IN_DISTRICT  ,
        'NA',--need add
        IN_LAND_MARK,
        IN_LOCALITY,
        IN_VILL_TOWN_CITY,
        IN_STREET,
        IN_POST_OFFICE,
        IN_SUB_DISTRICT,
        IN_STATE
      );
      
      IF SQL%ROWCOUNT =1 THEN
        OUT_STATUS:=0;
        OUT_MESSAGE:=SQL%ROWCOUNT||' ROW INSERTED SUCCESSFULLY.';
        UPDATE CEN_OCS_FORM_10_C COFD SET COFD.EKYC_STATUS='Y' WHERE COFD.TRACKING_ID=OUT_TRACKING_ID;
        IF SQL%ROWCOUNT =1 THEN
          OUT_MESSAGE:=OUT_MESSAGE||' , '||SQL%ROWCOUNT||' ROW UPDATED SUCCESSFULLY.';
          COMMIT;
        END IF;
      ELSE 
        RAISE_APPLICATION_ERROR(-20001,'1#~#DE-01: Unable to log request. Please try after some time.#~#e-KYC data not saved. But insert statement executed successfully.');
        COMMIT;
      END IF;   
--    IF SQL%ROWCOUNT <> 1 THEN
--        RAISE_APPLICATION_ERROR(-20001,'1#~#DE-01: Unable to log request. Please try after some time.#~#e-KYC data not saved. But insert statement executed successfully.');
--    END IF;
--    COMMIT;
	
    END CASE;
  ELSE
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20001,'1#~#Technical error at server. Please try after some time.#~#Invalid OUT_STATUS returned from SAVE_CLAIM_DATA. OUT_STATUS: '||OUT_STATUS);  
  END IF;   
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      LOG_ERROR('SUBMIT_OCS_CLAIM','UAN: '||IN_UAN||' Error: '||SQLERRM);
      RAISE;
  END SUBMIT_OCS_CLAIM;

  --NEW PROCEDURE ADDED BY AKSHAY ON 06/12/2019 FOR UNIFIED_PORTAL CLAIMS
  PROCEDURE SAVE_CLAIM_DATA_FOR_UP(
    IN_CLAIM_TYPE          IN CEN_OCS_FORM_19.CLAIM_FORM_TYPE%TYPE,
    IN_UAN                 IN NUMBER,
    IN_DOE_EPF             IN CEN_OCS_FORM_19.DOE_EPF%TYPE,
    IN_DOE_EPS             IN CEN_OCS_FORM_19.DOE_EPS%TYPE,
    T_REASON_EXIT          IN CEN_OCS_FORM_19.REASON_EXIT%TYPE,
    T_PARA_CODE            IN CEN_OCS_FORM_19.PARA_CODE%TYPE,
    T_SUB_PARA_CODE        IN CEN_OCS_FORM_19.SUB_PARA_CODE%TYPE ,
    T_SUB_PARA_CATEGORY    IN CEN_OCS_FORM_19.SUB_PARA_CATEGORY%TYPE ,
    T_ADV_AMOUNT           IN CEN_OCS_FORM_31.ADV_AMOUNT%TYPE,
    T_CLAIM_SOURCE_FLAG    IN CEN_OCS_FORM_19.CLAIM_SOURCE_FLAG%TYPE ,
    T_ADDRESS1             IN CEN_OCS_FORM_19.ADDRESS1%TYPE ,
    T_ADDRESS2             IN CEN_OCS_FORM_19.ADDRESS2%TYPE ,
    T_ADDRESS_CITY         IN CEN_OCS_FORM_19.ADDRESS_CITY%TYPE ,
    T_ADDRESS_DIST         IN CEN_OCS_FORM_19.ADDRESS_DIST%TYPE ,
    T_ADDRESS_STATE        IN CEN_OCS_FORM_19.ADDRESS_STATE%TYPE ,
    T_ADDRESS_PIN          IN CEN_OCS_FORM_19.ADDRESS_PIN%TYPE ,
    T_AGENCY_EMPLOYER_FLAG IN CEN_OCS_FORM_31.AGENCY_EMPLOYER_FLAG%TYPE ,
    T_AGENCY_NAME          IN CEN_OCS_FORM_31.AGENCY_NAME%TYPE ,
    T_AGENCY_ADDRESS       IN CEN_OCS_FORM_31.AGENCY_ADDRESS%TYPE ,
    T_AGENCY_ADDRESS_CITY  IN CEN_OCS_FORM_31.AGENCY_ADDRESS_CITY%TYPE ,
    T_AGENCY_ADDERSS_DIST  IN CEN_OCS_FORM_31.AGENCY_ADDERSS_DIST%TYPE ,
    T_AGENCY_ADDRESS_STATE IN CEN_OCS_FORM_31.AGENCY_ADDRESS_STATE%TYPE ,
    T_AGENCY_ADDRESS_PIN   IN CEN_OCS_FORM_31.AGENCY_ADDRESS_PIN%TYPE ,
    T_FLAG_15GH            IN CEN_OCS_FORM_19.FLAG_15GH%TYPE ,
    T_PDF_15GH             IN CEN_OCS_FORM_19.PDF_15GH%TYPE,
    T_TDS_15GH             IN CEN_OCS_FORM_19.TDS_15GH%TYPE ,
--    T_CANCEL_CHEQUE        IN CEN_OCS_FORM_19.CANCEL_CHEQUE%TYPE ,
    T_ADV_ENCLOSURE        IN CEN_OCS_FORM_31.ADV_ENCLOSURE%TYPE ,
    T_IP_ADDRESS           IN CEN_OCS_FORM_19.IP_ADDRESS%TYPE ,
    IN_AADHAAR_FOR_DEMO_VERIFY IN VARCHAR2,	--#ver3.4
    IN_AADHAAR_DEMO_VERIFY_STATUS IN VARCHAR2,	--#ver3.4
    IN_AADHAAR_DEMO_VERIFY_CODE IN VARCHAR2,	--#ver3.4   
    IN_APPLICATION_TYPE IN VARCHAR2, --ADDED ON 24/11/2021  --#ver4.29
    IN_WITHDRAWAL_REASON IN VARCHAR2, --ADDED ON 28/09/2020    --#ver4.21
    IN_AADHAAR_CONSENT_STATUS IN CHAR, --#ver4.22
    IN_AADHAAR_CONSENT_REF_ID IN NUMBER, --#ver4.22
    OUT_MOBILE_NUMBER OUT CEN_OCS_FORM_19.MOBILE%TYPE,
    OUT_MEMBER_NAME OUT CEN_OCS_FORM_19.MEMBER_NAME%TYPE,
    OUT_LEAVE_REASON OUT VARCHAR2,
    OUT_FS_NAME OUT CEN_OCS_FORM_19.FATHER_SPOUSE_NAME%TYPE,
    OUT_DOJ_EPF OUT VARCHAR2,
    OUT_DOJ_EPS OUT VARCHAR2,
    OUT_DOE_EPF OUT VARCHAR2,
    OUT_DOE_EPS OUT VARCHAR2,
    OUT_DOB OUT VARCHAR2,
    OUT_PANCARD OUT VARCHAR2,
    OUT_AADHAAR OUT CEN_OCS_FORM_19.AADHAAR%TYPE,
    OUT_BANK_ACC_NO OUT CEN_OCS_FORM_19.BANK_ACC_NO%TYPE,
    OUT_BANK_IFSC OUT CEN_OCS_FORM_19.IFSC_CODE%TYPE,
    OUT_BANK_DETAILS OUT VARCHAR2,
    OUT_MEMBER_ID OUT CEN_OCS_FORM_19.MEMBER_ID%TYPE,
    OUT_OFFICE_ID         OUT NUMBER,
    OUT_RECEIPT_DATE OUT CEN_OCS_FORM_19.RECEIPT_DATE%TYPE,
    OUT_STATUS OUT NUMBER,
    OUT_TRACKING_ID OUT  NUMBER,
    OUT_MESSAGE OUT VARCHAR2,
    --ADDED BY AKSHAY FOR 10D --ADDED AS OPTIONAL IN-PARAMETERS FOR UMANG --ALWAYS KEEP THESE PARAMETERS AS LAST PARAMETERS OF PROCEDURE
    IN_CLAIM_BY                      IN CEN_OCS_FORM_19.CLAIM_BY%TYPE        DEFAULT NULL,
    IN_PENSION_TYPE                  IN CEN_OCS_FORM_10D.PENSION_TYPE%TYPE    DEFAULT NULL,
    IN_OPTED_REDUCED_PENSION IN NUMBER,
    IN_OPTED_DATE                    IN VARCHAR2    DEFAULT NULL,
    IN_PPO_DETAILS                   IN VARCHAR2,
    IN_SCHEME_CERTIFICATE    IN VARCHAR2,
    IN_DEFERRED_PENSION      IN CHAR,
    IN_DEFERRED_PENSION_AGE  IN NUMBER,
    IN_DEFERRED_PENSION_CONT IN VARCHAR2,
    IN_BANK_ACCOUNT_NUMBER   IN VARCHAR2    DEFAULT NULL,
    IN_BANK_IFSC                     IN VARCHAR2    DEFAULT NULL,
    IN_BANK_ID         IN NUMBER  DEFAULT NULL,
--    IN_CANCEL_CHEQUE_PATH IN VARCHAR2 DEFAULT NULL    --ADDED BY AKSHAY ON 09/08/2019 TO STORE PHYSICAL LOCATION OF UPLOADED CANCELLED CHEQUE
    --ADDITION BY AKSHAY FOR 10D ENDED --ADDED AS OPTIONAL IN-PARAMETERS FOR UMANG --ALWAYS KEEP THESE PARAMETERS AS LAST PARAMETERS OF PROCEDURE
    IN_MEMBER_SYS_ID IN NUMBER DEFAULT NULL,--#ver3.8
    IN_3RDPARTY_NAME     IN VARCHAR2  DEFAULT NULL,
    IN_3RDPARTY_BANK_ACCNO IN VARCHAR2  DEFAULT NULL,
    IN_3RDPARTY_BANK_IFSC  IN VARCHAR2  DEFAULT NULL,
    IN_AUTH_LETTER_FILE_PATH IN VARCHAR2  DEFAULT NULL
    )
AS
  V_OFFICE_ID   NUMBER(3,0);
  V_TRACKING_ID NUMBER(18,0);
  --MEMBER DETAILS VARIABLE***********************************************
  OUT_MEMBER_DETAILS            SYS_REFCURSOR;
  V_MEMBER_UAN                  NUMBER(12);
  V_MEMBER_NAME                 OCS_CLAIM_DATA.FATHER_SPOUSE_NAME%TYPE;
  V_MEMBER_FATHER_SPOUSE_NAME   UAN_REPOSITORY.FATHER_OR_HUSBAND_NAME%TYPE;
  V_MEMBER_RELATION_WITH_MEMBER UAN_REPOSITORY.RELATION_WITH_MEMBER%TYPE;
  V_MEMBER_PAN                  VARCHAR(50);
  V_MEMBER_AADHAAR              UAN_REPOSITORY.AADHAAR%TYPE;
  V_MEMBER_MOBILE_NUMBER        UAN_REPOSITORY.MOBILE_NUMBER%TYPE;
  V_MEMBER_EMAIL_ID             UAN_REPOSITORY.EMAIL_ID%TYPE;
  V_MEMBER_GENDER               UAN_REPOSITORY.GENDER%TYPE;
  V_MEMBER_DOB                  UAN_REPOSITORY.DOB%TYPE;
  V_LEAVE_REASON_CODE           OCS_CLAIM_DATA.REASON_EXIT%TYPE;
  V_LEAVE_REASON                VARCHAR2(128);	--#ver1.5
  V_OUT_PARA                    OCS_CLAIM_DATA.PARA_CODE%TYPE;
  V_OUT_SUB_PARA                OCS_CLAIM_DATA.SUB_PARA_CODE%TYPE;
  V_OUT_SUB_PARA_CAT            OCS_CLAIM_DATA.SUB_PARA_CATEGORY%TYPE;
  V1_MEMBER_PAN                  VARCHAR2(10);
  --KYC VARIABLE**********************************************************
  V_BANK_AC_NO        VARCHAR2(20);
  V_IFSC              VARCHAR2(11);
  -- V_BANK_BRANCH       VARCHAR2(100);	--COMMENTED FOR #ver3.9
  V_BANK_BRANCH       VARCHAR2(256);	--#ver3.9
  --SERVICE DETAILS VARIABLE**********************************************
  V_STATUS      MEMBER.STATUS%TYPE;
  V_DOJ_EPF     MEMBER.DOJ_EPF%TYPE;
  V_DOJ_EPS     MEMBER.DOJ_EPS%TYPE;
  V_DOE_EPF     MEMBER.DOE_EPF%TYPE;
  V_DOE_EPS     MEMBER.DOE_EPS%TYPE;
  V_MEMBER_ID   MEMBER.MEMBER_ID%TYPE;
  --********************INSERT ON OCS_CLAIM_DATA*****
  INSERT_STATUS         NUMBER;
--  INSERT_OUTPUT         VARCHAR2(100);
  INSERT_OUTPUT         VARCHAR2(4000);   --CHANGED ON 20/06/2019
  --SAVE_OCRD_DATA*******************************VARIABLE****************
--  V_OCRD_STATUS NUMBER(1,0);
--  V_OCRD_OUTPUT VARCHAR2(100);
  V_OCRD_OUTPUT VARCHAR2(4000);   --CHANGED ON 20/06/2019

  --CLAM SUBMISSION ELIGIBILITY VARIABLE****************
  V_PENDING_CLAIM           NUMBER(1,0);
  V_TOTAL_SERVICE_IN_MONTHS NUMBER(3,0);
--  V_CSE_OUTPUT              VARCHAR2(100);
  V_CSE_OUTPUT VARCHAR2(4000);   --CHANGED ON 20/06/2019
  V_CSE_OUT_OLS             NUMBER(1,0);
  --USER DEFINE EXCEPTION*************************************************
  KYC_EXCEPTION                  EXCEPTION;
  OFFICE_ID_OR_TEMP_ID_NOT_FOUND EXCEPTION;
  DATA_INSERT_FAIL               EXCEPTION;
  CLAIM_PENDING                  EXCEPTION;
  NOT_ELIGIBLE                   EXCEPTION;
  PF_ADVANCE_NOT_ALLOWED         EXCEPTION; --#ver3.8
  FORM_10C_NOT_ALLOWED           EXCEPTION; --#ver4.29
  INVALID_68M_ADV_AMT			 EXCEPTION; --#ver4.10
  INVALID_IFSC      			 EXCEPTION; --#ver4.18
  INVALID_UAN         			 EXCEPTION; --#ver4.30
  VMODULE   VARCHAR(200);
  --MULTIPLE SERVICE ALERT MESSAGE*************************BY PANAKAJ KUMAR*************22-DEC-2017
  V_SERVICE_COUNT                NUMBER(2);

  V_ERROR_MESSAGE VARCHAR2(4000); --ADDED BY AKSHAY ON 10/04/2019
  --ADDED BY AKSHAY ON 11/04/2019
  V_MASKED_BANK_AC_NO        VARCHAR2(20);
  V_MASKED_MEMBER_PAN                  VARCHAR(50);
  V_MASKED_MEMBER_AADHAAR              VARCHAR2(15);
  V_MASKED_MEMBER_MOBILE_NUMBER        UAN_REPOSITORY.MOBILE_NUMBER%TYPE;
  --ADDITION BY AKSHAY ON 11/04/2019 ENDED
  V_LEAVE_REASON_CHAR VARCHAR2(1 BYTE):='';
  V_NOMINATION_ID NUMBER;
  V_MARITAL_STATUS VARCHAR2(2):='';
  V_MEMBER_PHOTOGRAPH BLOB;
  V_NOMINATION_SAVED VARCHAR2(120) := '';
  --ADDED BY AKSHAY ON 11/07/2019 TO VALIDATE TOTAL SERVICE USING MIN(DOJ) BUT STORE LATEST DOJ IN TABLE  --REF. MAIL FROM SMITA SONI TO SANDESH SIR FOR CASE DATED 05/07/2019
  V_DOJ_EPF_TO_VALIDATE DATE;
  V_DOJ_EPS_TO_VALIDATE DATE;
  V_PARA68M_MAX_AMOUNT NUMBER;  --#ver4.10
  V_ENCR_BANK_ACC_NO VARCHAR2(500); --#ver4.13
  V_BANK_VER_REF_CODE NUMBER(28,0);  --#ver4.13
  V_IFSC_COUNT NUMBER(3);  --#ver4.18
  V_WITHDRAWAL_REASON VARCHAR2(1):=''; --#ver4.21
  V_DEACTIVATED_UAN_COUNT NUMBER(1); --#ver4.30
  
  -- Yash Patidar Edits HERE  UNIFIED_PORTAL
  V_BANK_NAME		VARCHAR(128);
  V_OFFICE_NAME		VARCHAR(128);
  V_ADDRESS_OF_OFFICE VARCHAR(256);
  V_PINCODE_OF_OFFICE NUMBER(6);
  V_NOMINATION_FAMILY_ID NUMBER(12);
  V_NOMINEE_NAME VARCHAR(85);
  V_NOMINEE_DOB	DATE;
  V_NOMINEE_GENDER CHAR(1);
  V_NOMINEE_AADHAAR NUMBER(16);
  V_NOMINEE_RELATION CHAR(1);
  V_NOMINEE_RELATION_OTHER VARCHAR(32);
  V_NOMINEE_ADDRESS VARCHAR(1024);
  V_IS_MINOR_NOMINEE CHAR(1);
  V_IS_LUNATIC CHAR(1);
  V_NOM_SHARE_IN_PERCENT NUMBER(5,2);
  V_GUARDIAN_NAME VARCHAR2(85);
  V_GUARDIAN_RELATION VARCHAR2(15);
  V_GUARDIAN_ADDRESS VARCHAR2(1024);
  V_NOM_ADDRESS1 VARCHAR2(35);
  V_NOM_ADDRESS2 VARCHAR2(35);
  V_NOM_CITY	VARCHAR2(50);
  V_NOM_DISTRICT	VARCHAR2(50);
  V_NOM_STATE	VARCHAR2(50);
  V_NOM_DISTRICT_ID NUMBER(4,0);
  V_NOM_STATE_ID NUMBER(2,0);
  V_NOM_PIN NUMBER(6,0);
  V_IS_WIDTHRAWAL_BENFIT_REQ CHAR(1);
  V_IS_WIDTHRAWAL_BENFIT_TAKEN CHAR(1);
BEGIN

LOG_ERROR('INSIDE SAVE_CLAIM_DATA_FOR_UP','BY YASH');
IF IN_CLAIM_TYPE = '03' THEN
  LOG_ERROR('SAVE_CLAIM_DATA: IN_PARAMETERS',
    'IN_UAN:'||IN_UAN||'#~#'||
    'IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||'#~#'||
    'IN_DOE_EPF:'||TO_CHAR(IN_DOE_EPF)||'#~#'||
    'IN_DOE_EPS:'||TO_CHAR(IN_DOE_EPS)||'#~#'||
    'T_REASON_EXIT:'||T_REASON_EXIT||'#~#'||
    'T_PARA_CODE:'||T_PARA_CODE||'#~#'||
    'T_SUB_PARA_CODE:'||T_SUB_PARA_CODE||'#~#'||
    'T_SUB_PARA_CATEGORY:'||T_SUB_PARA_CATEGORY||'#~#'||
    'T_ADV_AMOUNT:'||T_ADV_AMOUNT||'#~#'||
    'T_CLAIM_SOURCE_FLAG:'||T_CLAIM_SOURCE_FLAG||'#~#'||
    'T_ADDRESS1:'||T_ADDRESS1||'#~#'||
    'T_ADDRESS2:'||T_ADDRESS2||'#~#'||
    'T_ADDRESS_CITY:'||T_ADDRESS_CITY||'#~#'||
    'T_ADDRESS_DIST:'||T_ADDRESS_DIST||'#~#'||
    'T_ADDRESS_STATE:'||T_ADDRESS_STATE||'#~#'||
    'T_ADDRESS_PIN:'||T_ADDRESS_PIN||'#~#'||
    'T_AGENCY_EMPLOYER_FLAG:'||T_AGENCY_EMPLOYER_FLAG||'#~#'||
    'T_AGENCY_NAME:'||T_AGENCY_NAME||'#~#'||
    'T_AGENCY_ADDRESS:'||T_AGENCY_ADDRESS||'#~#'||
    'T_AGENCY_ADDRESS_CITY:'||T_AGENCY_ADDRESS_CITY||'#~#'||
    'T_AGENCY_ADDERSS_DIST:'||T_AGENCY_ADDERSS_DIST||'#~#'||
    'T_AGENCY_ADDRESS_STATE:'||T_AGENCY_ADDRESS_STATE||'#~#'||
    'T_AGENCY_ADDRESS_PIN:'||T_AGENCY_ADDRESS_PIN||'#~#'||
    'T_FLAG_15GH:'||T_FLAG_15GH||'#~#'||
    'T_TDS_15GH:'||T_TDS_15GH||'#~#'||
--    'T_CANCEL_CHEQUE:'||
--     CASE WHEN T_CANCEL_CHEQUE IS NULL THEN 'AVAILABLE' ELSE 'NOT AVAILBLE' END ||'#~#'
--    ||
    'T_ADV_ENCLOSURE:'||T_ADV_ENCLOSURE||'#~#'||
    'T_IP_ADDRESS:'||T_IP_ADDRESS||'#~#'||
    'IN_CLAIM_BY:'||IN_CLAIM_BY||'#~#'||
    'IN_PENSION_TYPE:'||IN_PENSION_TYPE||'#~#'||
    'IN_OPTED_REDUCED_PENSION:'||IN_OPTED_REDUCED_PENSION||'#~#'||
    'IN_OPTED_DATE:'||IN_OPTED_DATE||'#~#'||
    'IN_PPO_DETAILS:'||IN_PPO_DETAILS||'#~#'||
    'IN_SCHEME_CERTIFICATE:'||IN_SCHEME_CERTIFICATE||'#~#'||
    'IN_DEFERRED_PENSION:'||IN_DEFERRED_PENSION||'#~#'||
    'IN_DEFERRED_PENSION_AGE:'||IN_DEFERRED_PENSION_AGE||'#~#'||
    'IN_DEFERRED_PENSION_CONT:'||IN_DEFERRED_PENSION_CONT||'#~#'||
    'IN_BANK_ACCOUNT_NUMBER:'||IN_BANK_ACCOUNT_NUMBER||'#~#'||
    'IN_BANK_IFSC:'||IN_BANK_IFSC||'#~#'||
    'IN_BANK_ID:'||IN_BANK_ID
    );
END IF;

  --PARA CODE VALUE SET*****************
  V_OUT_PARA:=T_PARA_CODE;
  V_OUT_SUB_PARA:=T_SUB_PARA_CODE;
  V_OUT_SUB_PARA_CAT:=T_SUB_PARA_CATEGORY;
  --OUT DATA FOR PDF********************INITIALIZE TO EMPTY**************
  OUT_MOBILE_NUMBER:=0;
  OUT_MEMBER_NAME  :='';
  OUT_LEAVE_REASON :='';
  OUT_FS_NAME      :='';
  OUT_DOJ_EPF      :='';
  OUT_DOJ_EPS      :='';
  OUT_DOE_EPF      :='';
  OUT_DOE_EPS      :='';
  OUT_DOB          :='';
  OUT_PANCARD      :='';
  OUT_AADHAAR      :=0;
  OUT_BANK_ACC_NO  :='';
  OUT_BANK_IFSC    :='';
  OUT_BANK_DETAILS :='';
  OUT_MEMBER_ID    :='';
  OUT_OFFICE_ID    :=0;
  V1_MEMBER_PAN:='';
  --OUT DATA STATUS AND OTHER VARIABLE INITIALIZED**************************
  OUT_STATUS           :=0;
  OUT_MESSAGE          :='';
  V_OFFICE_ID          :=0;
  INSERT_STATUS        :=0;
  INSERT_OUTPUT        :='';
  OUT_TRACKING_ID      :=0;
  V_PENDING_CLAIM      :=0;
  V_PARA68M_MAX_AMOUNT :=0;    --#ver4.10
  V_ENCR_BANK_ACC_NO   :='';   --#ver4.13
  V_BANK_VER_REF_CODE  :='';   --#ver4.13
  V_IFSC_COUNT         :=0;    --#ver4.18
  V_DEACTIVATED_UAN_COUNT :=0; --#ver4.30
  --*********************************************************************CHECK PENDING CLAIM************************************BY UAN*****************************
 --***************BELLOW CODE FOR TRAC LOG****************
 VMODULE:='OCS_NEW_PACKAGE.SAVE_CLAIM_DATA';
 --*******************************
  SELECT 
    COUNT(1) INTO V_DEACTIVATED_UAN_COUNT
  FROM 
    MEMBER_USERS 
  WHERE
    UAN=IN_UAN
    AND ACCOUNT_STATUS='D';

  IF V_DEACTIVATED_UAN_COUNT > 0 THEN --#ver4.30
    LOG_ERROR(VMODULE,'UAN IS DEACTIVATED , '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE INVALID_UAN;
  END IF;

--  SELECT COUNT(1)
--  INTO V_PENDING_CLAIM
--  FROM OCS_CRD OCRD
--  INNER JOIN OCS_CLAIM_DATA OCD	--#ver2.5
--    ON OCD.TRACKING_ID = OCRD.TRACKING_ID
--  WHERE OCRD.CLAIM_STATUS IN(0,1,2,3)
--  AND OCRD.UAN             =IN_UAN AND OCRD.CLAIM_FORM_TYPE=IN_CLAIM_TYPE 
--  AND (	--#ver2.5
--      CASE --#ver4.20
----        WHEN OCD.CLAIM_FORM_TYPE='06' AND COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2 THEN 0
--        WHEN OCD.CLAIM_FORM_TYPE='06' AND OCD.PARA_CODE = '8' AND OCD.SUB_PARA_CODE = '13' AND OCD.SUB_PARA_CATEGORY = '3' THEN 1  --IF COVID-19 CLAIM IS PENDING THEN DONT ALLOW ANY PF-ADVANCE CLAIM
--        WHEN OCD.CLAIM_FORM_TYPE='06' AND (T_PARA_CODE <> '8' OR T_SUB_PARA_CODE <> '13' OR T_SUB_PARA_CATEGORY <> '3') THEN 1 --EXECUTING THIS CASE MEANS THAT A PENDING CLAIM FOUND IS OF NON-COVID-19. AND IF OTHER THAN COVID-19 CLAIM IS GETTING FILED THEN DONT ALLOW --#ver2.6
--        WHEN OCD.CLAIM_FORM_TYPE='06' THEN 0  --IT IS ASSUMED THAT ONLY COVID-19 CLAIM IS ALLOWED FROM FRONT-END IN CASE OF ANY PREVIOUS PENDING CLAIM
--        ELSE 1
--      END = 1    
--    )
--  ;
--  IF V_PENDING_CLAIM  >0 THEN
--  LOG_ERROR(VMODULE,'YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS, '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
--    RAISE CLAIM_PENDING;
--  END IF;
CASE IN_CLAIM_TYPE 
WHEN '01' THEN
 SELECT COUNT(1)
  INTO V_PENDING_CLAIM
  FROM CEN_OCS_FORM_19 COF
  WHERE COF.CLAIM_STATUS IN('N','P','E')
  AND COF.UAN=IN_UAN AND COF.CLAIM_FORM_TYPE=IN_CLAIM_TYPE;
 IF V_PENDING_CLAIM  >0 THEN
  LOG_ERROR(VMODULE,'YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS, '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE CLAIM_PENDING;
  END IF; 
WHEN '06' THEN
 SELECT COUNT(1)
  INTO V_PENDING_CLAIM
  FROM CEN_OCS_FORM_31 COF
  WHERE COF.CLAIM_STATUS IN('N','P','E')
  AND COF.UAN=IN_UAN AND COF.CLAIM_FORM_TYPE=IN_CLAIM_TYPE
  AND (	--#ver2.5
      CASE --#ver4.20
--        WHEN OCD.CLAIM_FORM_TYPE='06' AND COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2 THEN 0
        WHEN COF.CLAIM_FORM_TYPE='06' AND COF.PARA_CODE = '8' AND COF.SUB_PARA_CODE = '13' AND COF.SUB_PARA_CATEGORY = '3' THEN 1  --IF COVID-19 CLAIM IS PENDING THEN DONT ALLOW ANY PF-ADVANCE CLAIM
        WHEN COF.CLAIM_FORM_TYPE='06' AND (T_PARA_CODE <> '8' OR T_SUB_PARA_CODE <> '13' OR T_SUB_PARA_CATEGORY <> '3') THEN 1 --EXECUTING THIS CASE MEANS THAT A PENDING CLAIM FOUND IS OF NON-COVID-19. AND IF OTHER THAN COVID-19 CLAIM IS GETTING FILED THEN DONT ALLOW --#ver2.6
        WHEN COF.CLAIM_FORM_TYPE='06' THEN 0  --IT IS ASSUMED THAT ONLY COVID-19 CLAIM IS ALLOWED FROM FRONT-END IN CASE OF ANY PREVIOUS PENDING CLAIM
        ELSE 1
      END = 1    
    );
  IF V_PENDING_CLAIM  >0 THEN
  LOG_ERROR(VMODULE,'YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS, '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE CLAIM_PENDING;
  END IF;
  
  WHEN '04' THEN
   SELECT COUNT(1)
    INTO V_PENDING_CLAIM
    FROM CEN_OCS_FORM_10_C COF
    WHERE COF.CLAIM_STATUS IN('N','P','E')
    AND COF.UAN=IN_UAN AND COF.CLAIM_FORM_TYPE=IN_CLAIM_TYPE;
    
   IF V_PENDING_CLAIM  >0 THEN
      LOG_ERROR(VMODULE,'YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS, '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
      RAISE CLAIM_PENDING;
    END IF; 
  
ELSE RAISE CASE_NOT_FOUND;
END CASE;


  --*********************************************************************CALL PROCEDURE*****************************************GET_MEMBER_ID**********************
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA FETCHING MEMBER DATA','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
  END IF;

  --#ver3.8
  IF IN_CLAIM_TYPE = '06' /*AND IN_MEMBER_SYS_ID IS NOT NULL*/ THEN   --AND CONDITION ADDED TEMPORARILY
   
    GET_MEMBER_DATA_FOR_PF_ADVANCE(IN_UAN, IN_MEMBER_SYS_ID, OUT_MEMBER_DETAILS, OUT_MESSAGE, OUT_STATUS);
    IF OUT_STATUS = 1 THEN
      RAISE PF_ADVANCE_NOT_ALLOWED;
    END IF;
  --#ver4.29
  ELSIF IN_CLAIM_TYPE = '04' AND IN_APPLICATION_TYPE = 'SC' THEN
    SELECT MEMBER_ID INTO V_MEMBER_ID FROM MEMBER WHERE ID = IN_MEMBER_SYS_ID AND EST_SLNO <> 0;
    GET_MEMBER_DATA(IN_UAN, V_MEMBER_ID, OUT_MEMBER_DETAILS, OUT_MESSAGE, OUT_STATUS);
    IF OUT_STATUS = 1 THEN
      RAISE FORM_10C_NOT_ALLOWED;
    END IF;
  ELSE
    GET_MEMBER_DATA_ALL(IN_UAN,OUT_MEMBER_DETAILS,OUT_MESSAGE,OUT_STATUS);
  END IF;

  FETCH OUT_MEMBER_DETAILS INTO
          V_BANK_AC_NO,
          V_MASKED_BANK_AC_NO,  --ADDED BY AKSHAY ON 11/04/2019
          V_IFSC,
          V_BANK_BRANCH,
          V_MEMBER_NAME,
          V_MEMBER_GENDER,
          V_MEMBER_FATHER_SPOUSE_NAME,
          V_MEMBER_RELATION_WITH_MEMBER,
          V_MEMBER_DOB,
          V_MEMBER_MOBILE_NUMBER,
          V_MASKED_MEMBER_MOBILE_NUMBER,  --ADDED BY AKSHAY ON 11/04/2019
          V_MEMBER_AADHAAR,
          V_MASKED_MEMBER_AADHAAR,  --ADDED BY AKSHAY ON 11/04/2019
          V_MEMBER_PAN,
          V_MASKED_MEMBER_PAN,  --ADDED BY AKSHAY ON 11/04/2019
          V_MEMBER_ID,
          V_STATUS,
          V_MEMBER_EMAIL_ID,
          V_DOJ_EPF,
          V_DOJ_EPS,
          V_DOE_EPF,
          V_DOE_EPS,
          V_LEAVE_REASON_CODE,
          V_LEAVE_REASON,
          V_LEAVE_REASON_CHAR,
          V_SERVICE_COUNT,
          V_ENCR_BANK_ACC_NO,  --#ver4.13
          V_BANK_VER_REF_CODE; --#ver4.13

  CLOSE OUT_MEMBER_DETAILS;
--***********IN CASE OF DATE OF EXIT EFP OR EPS INPUT BY MEMBER
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: MEMBER DATA FETCHED',
        'IN_UAN:'||IN_UAN||'#~#'||
        'V_BANK_AC_NO:'||V_BANK_AC_NO||'#~#'||
        'V_MASKED_BANK_AC_NO:'||V_MASKED_BANK_AC_NO||'#~#'||
        'V_IFSC:'||V_IFSC||'#~#'||
        'V_BANK_BRANCH:'||V_BANK_BRANCH||'#~#'||
        'V_MEMBER_NAME:'||V_MEMBER_NAME||'#~#'||
        'V_MEMBER_GENDER:'||V_MEMBER_GENDER||'#~#'||
        'V_MEMBER_FATHER_SPOUSE_NAME:'||V_MEMBER_FATHER_SPOUSE_NAME||'#~#'||
        'V_MEMBER_RELATION_WITH_MEMBER:'||V_MEMBER_RELATION_WITH_MEMBER||'#~#'||
        'V_MEMBER_DOB:'||TO_CHAR(V_MEMBER_DOB)||'#~#'||
        'V_MEMBER_MOBILE_NUMBER:'||V_MEMBER_MOBILE_NUMBER||'#~#'||
        'V_MASKED_MEMBER_MOBILE_NUMBER:'||V_MASKED_MEMBER_MOBILE_NUMBER||'#~#'||
        'V_MEMBER_AADHAAR:'||V_MEMBER_AADHAAR||'#~#'||
        'V_MASKED_MEMBER_AADHAAR:'||V_MASKED_MEMBER_AADHAAR||'#~#'||
        'V_MEMBER_PAN:'||V_MEMBER_PAN||'#~#'||
        'V_MASKED_MEMBER_PAN:'||V_MASKED_MEMBER_PAN||'#~#'||
        'V_MEMBER_ID:'||V_MEMBER_ID||'#~#'||
        'V_STATUS:'||V_STATUS||'#~#'||
        'V_MEMBER_EMAIL_ID:'||V_MEMBER_EMAIL_ID||'#~#'||
        'V_DOJ_EPF:'||TO_CHAR(V_DOJ_EPF)||'#~#'||
        'V_DOJ_EPS:'||TO_CHAR(V_DOJ_EPS)||'#~#'||
        'V_DOE_EPF:'||TO_CHAR(V_DOE_EPF)||'#~#'||
        'V_DOE_EPS:'||TO_CHAR(V_DOE_EPS)||'#~#'||
        'V_LEAVE_REASON_CODE:'||V_LEAVE_REASON_CODE||'#~#'||
        'V_LEAVE_REASON:'||V_LEAVE_REASON||'#~#'||
        'V_LEAVE_REASON_CHAR:'||V_LEAVE_REASON_CHAR||'#~#'||
        'V_SERVICE_COUNT:'||V_SERVICE_COUNT
        );
  END IF;

  CASE WHEN (IN_CLAIM_TYPE='01') AND (V_DOE_EPF IS NULL) THEN
    V_DOE_EPF     :=IN_DOE_EPF;
    V_LEAVE_REASON_CODE:=T_REASON_EXIT;
    WHEN (IN_CLAIM_TYPE='04') AND (V_DOE_EPS IS NULL) THEN
    V_DOE_EPS     :=IN_DOE_EPS;
    V_LEAVE_REASON_CODE:=T_REASON_EXIT;
    ELSE
  IF IN_CLAIM_TYPE='01' THEN
   DBMS_OUTPUT.PUT_LINE('I AM CALLED === '||V_LEAVE_REASON_CODE);
  GET_PARA_CODE_BY_EXIT_CODE(V_LEAVE_REASON_CODE,V_OUT_PARA,V_OUT_SUB_PARA,V_OUT_SUB_PARA_CAT);
  END IF;
  END CASE;

	IF V_OUT_PARA IS NULL OR V_OUT_SUB_PARA IS NULL OR V_OUT_SUB_PARA_CAT IS NULL THEN --#ver4.3
		RAISE_APPLICATION_ERROR(-20001, 'Z#PARA DETAILS NOT FOUND. PLEASE TRY AFTER SOME TIME.#Z');
	END IF;
  --Ver. 1.3
--  IF IN_CLAIM_TYPE = '04' THEN
--    SELECT MIN(DOJ_EPS) INTO V_DOJ_EPS FROM MEMBER WHERE UAN = IN_UAN;
--  ELSIF IN_CLAIM_TYPE = '06' THEN
--    SELECT MIN(DOJ_EPF) INTO V_DOJ_EPF FROM MEMBER WHERE UAN = IN_UAN;
--  END IF;
--
----*******************************************************************CHECK CLAIM SUBMISSION ELIGIBILITY***********************************************************************
----  CHECK_ELIGIBILITY(IN_UAN, IN_CLAIM_TYPE, V_DOJ_EPF, V_DOJ_EPS, V_DOE_EPF, V_DOE_EPS, TO_NUMBER(V_LEAVE_REASON_CODE), V_TOTAL_SERVICE_IN_MONTHS, V_CSE_OUTPUT, V_CSE_OUT_OLS);        --Ver. 1.4
--  IF IN_CLAIM_TYPE = '03' THEN
--    LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY STARTED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
--  END IF;
--  CHECK_ELIGIBILITY(IN_UAN, IN_CLAIM_TYPE, V_DOJ_EPF, V_DOJ_EPS, V_DOE_EPF, V_DOE_EPS, V_TOTAL_SERVICE_IN_MONTHS, V_CSE_OUTPUT, V_CSE_OUT_OLS);             --Ver. 1.4
--  IF IN_CLAIM_TYPE = '03' THEN
--    LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY FINISHED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_CSE_OUT_OLS:'||V_CSE_OUT_OLS||' V_CSE_OUTPUT:'||V_CSE_OUTPUT);
--  END IF;


  --ADDED BY AKSHAY ON 11/07/2019 TO VALIDATE TOTAL SERVICE USING MIN(DOJ) BUT STORE LATEST DOJ IN TABLE  --REF. MAIL FROM SMITA SONI TO SANDESH SIR FOR CASE DATED 05/07/2019
        IF IN_CLAIM_TYPE = '04' THEN
             --   SELECT MIN(DOJ_EPS) INTO V_DOJ_EPS_TO_VALIDATE FROM MEMBER WHERE UAN = IN_UAN AND EST_SLNO <> 0;  --#ver4.14
                --CHECK ELIGIBILITY
             --   CHECK_ELIGIBILITY(IN_UAN,IN_CLAIM_TYPE,V_DOJ_EPF,V_DOJ_EPS_TO_VALIDATE,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);

                --#ver4.23 FOR FORM-19/10C, IF VALIDATION FOR 2 MONTHS WAITING PERIOD IS FAILED THEN CHECK IF IN_WITHDRAWAL_REASON IS PROVIDED
                  -- IF IN_CLAIM_TYPE = '04' THEN
                  -- IF V_CSE_OUT_OLS > 0 THEN
		VALIDATE_FORM_10C(IN_UAN,V_MEMBER_ID,IN_CLAIM_TYPE,IN_APPLICATION_TYPE,V_CSE_OUTPUT); --#ver4.29
                IF V_CSE_OUTPUT IS NOT NULL THEN
		-- #ver4.23 FOR FORM-19/10C, IF VALIDATION FOR 2 MONTHS WAITING PERIOD IS FAILED THEN CHECK IF IN_WITHDRAWAL_REASON IS PROVIDED
                    IF INSTR(V_CSE_OUTPUT,'2 MONTHS') > 0 THEN                      
                        IF IN_WITHDRAWAL_REASON IS NOT NULL THEN  --#ver4.23
                            BEGIN
                                SELECT REASON_CODE INTO V_WITHDRAWAL_REASON FROM OCS_WITHDRAWAL_REASONS WHERE REASON_CODE = IN_WITHDRAWAL_REASON AND FORM_TYPE = IN_CLAIM_TYPE;
                                V_CSE_OUT_OLS := 0; --ALLOW TO SAVE FORM-10C
                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_CSE_OUTPUT := V_CSE_OUTPUT || '. CANNOT PROCEED';
                                RAISE NOT_ELIGIBLE;
                            END;
                        ELSE
                                V_CSE_OUTPUT :=V_CSE_OUTPUT|| '_1';  --#ver4.35
                            RAISE NOT_ELIGIBLE;
                        END IF;
                        ELSE 
                        V_CSE_OUTPUT :=V_CSE_OUTPUT|| '_2';  --#ver4.35
				RAISE NOT_ELIGIBLE;
                    END IF;
                  END IF;                  
                IF IN_APPLICATION_TYPE = 'SC' THEN
                  SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS ='E';
                  SELECT MARITAL_STATUS INTO V_MARITAL_STATUS FROM UAN_REPOSITORY WHERE UAN = IN_UAN;
                END IF;

        ELSIF IN_CLAIM_TYPE = '06' THEN
                SELECT MIN(DOJ_EPF) INTO V_DOJ_EPF_TO_VALIDATE FROM MEMBER WHERE UAN = IN_UAN AND EST_SLNO <> 0;   --#ver4.14
                --CHECK ELIGIBILITY
                CHECK_ELIGIBILITY(IN_UAN,IN_CLAIM_TYPE,V_DOJ_EPF_TO_VALIDATE,V_DOJ_EPS,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);

		--#ver2.6
                VALIDATE_SCHEME_PARA(IN_UAN,T_PARA_CODE,T_SUB_PARA_CODE,T_SUB_PARA_CATEGORY,V_TOTAL_SERVICE_IN_MONTHS,V_DOE_EPF,V_CSE_OUTPUT);
                IF V_CSE_OUTPUT IS NOT NULL THEN
                  RAISE NOT_ELIGIBLE;
                END IF;
        ELSE
                IF IN_CLAIM_TYPE = '03' THEN
                        LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY STARTED','IN_UAN: '||IN_UAN||' IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||' Ip-Address '||T_IP_ADDRESS);
                END IF;
                --CHECK ELIGIBILITY
                CHECK_ELIGIBILITY(IN_UAN,IN_CLAIM_TYPE,V_DOJ_EPF,V_DOJ_EPS,V_DOE_EPF,V_DOE_EPS,V_TOTAL_SERVICE_IN_MONTHS,V_CSE_OUTPUT,V_CSE_OUT_OLS);

                --#ver4.21 FOR FORM-19, IF VALIDATION FOR 2 MONTHS WAITING PERIOD IS FAILED THEN CHECK IF IN_FORM_19_WITHDRAWAL_REASON IS PROVIDED
                IF IN_CLAIM_TYPE = '01' THEN
                  IF V_CSE_OUT_OLS > 0 THEN
                    IF INSTR(V_CSE_OUTPUT,'2 MONTHS') > 0 THEN
                        IF IN_WITHDRAWAL_REASON IS NOT NULL THEN  --#ver4.21
                            BEGIN
                                SELECT REASON_CODE INTO V_WITHDRAWAL_REASON FROM OCS_WITHDRAWAL_REASONS WHERE REASON_CODE = IN_WITHDRAWAL_REASON AND FORM_TYPE = IN_CLAIM_TYPE;
                                V_CSE_OUT_OLS := 0; --ALLOW TO SAVE FORM-19
                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                V_CSE_OUTPUT := V_CSE_OUTPUT || '. CANNOT PROCEED';
                                RAISE NOT_ELIGIBLE;
                            END;
                        ELSE
                            RAISE NOT_ELIGIBLE;
                        END IF;
                    END IF;
                  END IF;                  
                END IF;

                IF IN_CLAIM_TYPE = '03' THEN
                        LOG_ERROR('SAVE_CLAIM_DATA CHECK_ELIGIBILITY FINISHED','IN_UAN: '||IN_UAN||' IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||' Ip-Address '||T_IP_ADDRESS||' V_CSE_OUT_OLS:'||V_CSE_OUT_OLS||' V_CSE_OUTPUT:'||V_CSE_OUTPUT);
                END IF;
        END IF;
  --ADDITION BY AKSHAY ON 11/07/2019 ENDED
  IF V_CSE_OUT_OLS > 0 THEN
   ------CAPTURE ERROR lOG***************************
   LOG_ERROR(VMODULE,V_CSE_OUTPUT||', '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    RAISE NOT_ELIGIBLE;
  END IF;

  IF IN_CLAIM_TYPE = '03' THEN
LOG_ERROR('SAVE_CLAIM_DATA COLLECTING REQUIRED DATA','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS);
    SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS ='E';
    SELECT MARITAL_STATUS INTO V_MARITAL_STATUS FROM UAN_REPOSITORY WHERE UAN = IN_UAN;
    SELECT PHOTOGRAPH INTO V_MEMBER_PHOTOGRAPH FROM UP_ALT.MEMBER_PROFILE_PHOTO WHERE UAN = IN_UAN ORDER BY UPLOADED_TIME DESC FETCH FIRST ROW ONLY;
    V_BANK_AC_NO:= IN_BANK_ACCOUNT_NUMBER;
    V_IFSC :=IN_BANK_IFSC;
LOG_ERROR('SAVE_CLAIM_DATA REQUIRED DATA COLLECTED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_NOMINATION_ID:'||V_NOMINATION_ID||' V_BANK_AC_NO:'||V_BANK_AC_NO||' V_IFSC:'||V_IFSC||' V_MARITAL_STATUS:'||V_MARITAL_STATUS);
--    RAISE_APPLICATION_ERROR(-20001,'ERROR GENERATING CLAIM PDF.');
  END IF;

 --********************************************************************CALL PROCEDURE******************************************GET_OFFICE_ID BY MEMBER_ID***********************
  V_OFFICE_ID    :=GET_OFFICE_ID(V_MEMBER_ID);
  -- V_TRACKING_ID  :=GEN_TRACKING_ID(V_OFFICE_ID,IN_CLAIM_TYPE);
  V_TRACKING_ID  :=GEN_TRACKING_ID_UAN(IN_UAN,IN_CLAIM_TYPE);
  OUT_TRACKING_ID:=V_TRACKING_ID;
  LOG_ERROR('SAVE_CLAIM_DATA OFFICE_ID, TRACKING_ID COLLECTED','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_OFFICE_ID:'||V_OFFICE_ID||' V_TRACKING_ID:'||V_TRACKING_ID);
  IF V_OFFICE_ID  =0 OR V_TRACKING_ID=0 THEN
  ------CAPTURE ERROR lOG***************************
   LOG_ERROR(VMODULE,'Office Id or Tracking Id Generation Failed'||', '||IN_UAN||' Ip-Address  '||T_IP_ADDRESS);
    RAISE OFFICE_ID_OR_TEMP_ID_NOT_FOUND;
  END IF;
  --***********
  DBMS_OUTPUT.PUT_LINE('DOE EPF== '||V_DOE_EPF||' DOE EPS== '||V_DOE_EPS);

  --********************************************************************CALL PROCEDURE*****************************************INSERT VALUE IN OCS_CLAIM_DATA_TEMP***************
  OUT_RECEIPT_DATE:=SYSDATE;
  LOG_ERROR('SAVE_CLAIM_DATA V_MEMBER_PAN','IN_UAN: '||IN_UAN||' Ip-Address '||T_IP_ADDRESS||' V_MEMBER_PAN:'||V_MEMBER_PAN);
  --******************************************PAN NUMBER HANDLING**********************21-JUL-2017*************BY PANKAJ KUMAR
  IF LENGTH(V_MEMBER_PAN)=10 THEN
  V1_MEMBER_PAN:=V_MEMBER_PAN;
  END IF;
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: CALLING SAVE_OCS_CLAIM_DATA',
    'V_OFFICE_ID:'||V_OFFICE_ID||'#~#'||
    'V_TRACKING_ID:'||V_TRACKING_ID||'#~#'||
    'IN_UAN:'||IN_UAN||'#~#'||
    'V_MEMBER_ID:'||V_MEMBER_ID||'#~#'||
    'V_MEMBER_NAME:'||V_MEMBER_NAME||'#~#'||
    'V_MEMBER_FATHER_SPOUSE_NAME:'||V_MEMBER_FATHER_SPOUSE_NAME||'#~#'||
    'IN_CLAIM_TYPE:'||IN_CLAIM_TYPE||'#~#'||
    'OUT_RECEIPT_DATE:'||to_char(OUT_RECEIPT_DATE)||'#~#' ||
    'SUBSTR(V_MEMBER_ID):'||V_MEMBER_ID||'#~#'||
    'V_MEMBER_RELATION_WITH_MEMBER:'||V_MEMBER_RELATION_WITH_MEMBER||'#~#'||
    'V1_MEMBER_PAN:'||V1_MEMBER_PAN||'#~#'||
    'V_MEMBER_AADHAAR:'||V_MEMBER_AADHAAR||'#~#'||
    'V_MEMBER_MOBILE_NUMBER:'||V_MEMBER_MOBILE_NUMBER||'#~#'||
    'V_MEMBER_EMAIL_ID:'||V_MEMBER_EMAIL_ID||'#~#'||
    'V_MEMBER_GENDER:'||V_MEMBER_GENDER||'#~#'||
    'V_MEMBER_DOB:'||TO_CHAR(V_MEMBER_DOB)||'#~#'||
    'V_DOJ_EPF:'||TO_CHAR(V_DOJ_EPF)||'#~#'||
    'V_DOJ_EPS:'||TO_CHAR(V_DOJ_EPS)||'#~#'||
    'V_DOE_EPF:'||TO_CHAR(V_DOE_EPF)||'#~#'||
    'V_DOE_EPS:'||TO_CHAR(V_DOE_EPS)||'#~#'||
    'V_LEAVE_REASON_CODE:'||V_LEAVE_REASON_CODE||'#~#'||
    'V_OUT_PARA:'||V_OUT_PARA||'#~#'||
    'V_OUT_SUB_PARA:'||V_OUT_SUB_PARA||'#~#'||
    'V_OUT_SUB_PARA_CAT:'||V_OUT_SUB_PARA_CAT||'#~#'||
    'T_ADV_AMOUNT:'||T_ADV_AMOUNT||'#~#'||
    'V_BANK_AC_NO:'||V_BANK_AC_NO||'#~#'||
    'V_IFSC:'||V_IFSC||'#~#'||
    'T_CLAIM_SOURCE_FLAG:'||T_CLAIM_SOURCE_FLAG||'#~#'||
    'T_ADDRESS1:'||T_ADDRESS1||'#~#'||
    'T_ADDRESS2:'||T_ADDRESS2||'#~#'||
    'T_ADDRESS_CITY:'||T_ADDRESS_CITY||'#~#'||
    'T_ADDRESS_DIST:'||T_ADDRESS_DIST||'#~#'||
    'T_ADDRESS_STATE:'||T_ADDRESS_STATE||'#~#'||
    'T_ADDRESS_PIN:'||T_ADDRESS_PIN||'#~#'||
    'T_AGENCY_EMPLOYER_FLAG:'||T_AGENCY_EMPLOYER_FLAG||'#~#'||
    'T_AGENCY_NAME:'||T_AGENCY_NAME||'#~#'||
    'T_AGENCY_ADDRESS:'||T_AGENCY_ADDRESS||'#~#'||
    'T_AGENCY_ADDRESS_CITY:'||T_AGENCY_ADDRESS_CITY||'#~#'||
    'T_AGENCY_ADDERSS_DIST:'||T_AGENCY_ADDERSS_DIST||'#~#'||
    'T_AGENCY_ADDRESS_STATE:'||T_AGENCY_ADDRESS_STATE||'#~#'||
    'T_AGENCY_ADDRESS_PIN:'||T_AGENCY_ADDRESS_PIN||'#~#'||
    'T_FLAG_15GH:'||T_FLAG_15GH||'#~#'||
    'T_TDS_15GH:'||T_TDS_15GH||'#~#'||
--    'T_CANCEL_CHEQUE:'|| CASE WHEN T_CANCEL_CHEQUE IS NULL THEN 'AVAILABLE' ELSE 'NOT AVAILBLE' END ||'#~#'||
    'T_ADV_ENCLOSURE:'||T_ADV_ENCLOSURE||'#~#'||
    'T_IP_ADDRESS:'||T_IP_ADDRESS||'#~#'||
    'IN_CLAIM_BY:'||IN_CLAIM_BY||'#~#'||
    'IN_PENSION_TYPE:'||IN_PENSION_TYPE||'#~#'||
    'IN_OPTED_REDUCED_PENSION:'||IN_OPTED_REDUCED_PENSION||'#~#'||
    'IN_OPTED_DATE:'||IN_OPTED_DATE||'#~#'||
    'IN_PPO_DETAILS:'||IN_PPO_DETAILS||'#~#'||
    'IN_SCHEME_CERTIFICATE:'||IN_SCHEME_CERTIFICATE||'#~#'||
    'IN_DEFERRED_PENSION:'||IN_DEFERRED_PENSION||'#~#'||
    'IN_DEFERRED_PENSION_AGE:'||IN_DEFERRED_PENSION_AGE||'#~#'||
    'IN_DEFERRED_PENSION_CONT:'||IN_DEFERRED_PENSION_CONT||'#~#'||
    'V_MARITAL_STATUS:'||V_MARITAL_STATUS||'#~#'||
    'V_NOMINATION_ID:'||V_NOMINATION_ID||'#~#'||
--    'IN_BANK_ID:'||IN_BANK_ID||'#~#'||
    'IN_BANK_ID:'||IN_BANK_ID
--    'IN_CANCEL_CHEQUE_PATH: '||IN_CANCEL_CHEQUE_PATH
    );
  END IF;

   IF IN_CLAIM_TYPE = '06' AND T_PARA_CODE = '9' AND T_SUB_PARA_CODE = '14' and T_SUB_PARA_CATEGORY = '-' THEN  --#ver4.10
  GET_PARA68M_MAX_AMOUNT(V_PARA68M_MAX_AMOUNT);
	IF TO_NUMBER(T_ADV_AMOUNT) > TO_NUMBER(V_PARA68M_MAX_AMOUNT)  THEN
		RAISE INVALID_68M_ADV_AMT;
	END IF;
  END IF;

-- Yash Patidar Edits HERE UNIFIED_PORTAL
  IF IN_CLAIM_TYPE = '04' THEN 
    SELECT MAX(NOMINATION_ID) INTO V_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS ='E';
    LOG_ERROR('SAVE_CLAIM_DATA: FETCHING NOMINEE DETAILS', 'DETAILS : ' || V_NOMINATION_ID);
    BEGIN
      SELECT
        MNFD.NOMINATION_FAMILY_ID,
        MNFD.NOMINEE_NAME,
        MNFD.NOMINEE_DOB,
        MNFD.NOMINEE_GENDER,
        MNFD.NOMINEE_AADHAAR,
        MNFD.NOMINEE_RELATION,
        MNFD.NOMINEE_RELATION_OTHER,
        MNFD.NOMINEE_ADDRESS,
        MNFD.IS_MINOR_NOMINEE,
        MNFD.IS_LUNATIC ,
        MNFD.EPF_PERCENTAGE,
        MNFD.GUARDIAN_NAME,
        MNFD.GUARDIAN_RELATION,
        MNFD.GUARDIAN_ADDRESS,
        MNFD.ADDRESS_LINE1,
        MNFD.ADDRESS_LINE2,
        MNFD.ADDRESS_CITY,
        MNFD.ADDRESS_DISTRICT,
        MNFD.ADDRESS_STATE,
        MNFD.ADDRESS_DISTRICT_ID,
        MNFD.ADDRESS_STATE_ID,
        MNFD.ADDRESS_PIN_CODE
      INTO
        V_NOMINATION_FAMILY_ID,
        V_NOMINEE_NAME,
        V_NOMINEE_DOB,
        V_NOMINEE_GENDER,
        V_NOMINEE_AADHAAR,
        V_NOMINEE_RELATION,
        V_NOMINEE_RELATION_OTHER,
        V_NOMINEE_ADDRESS,
        V_IS_MINOR_NOMINEE,
        V_IS_LUNATIC,
        V_NOM_SHARE_IN_PERCENT,
        V_GUARDIAN_NAME,
        V_GUARDIAN_RELATION,
        V_GUARDIAN_ADDRESS,
        V_NOM_ADDRESS1,
        V_NOM_ADDRESS2,
        V_NOM_CITY,
        V_NOM_DISTRICT,
        V_NOM_STATE,
        V_NOM_DISTRICT_ID,
        V_NOM_STATE_ID,
        V_NOM_PIN
      FROM
        MEMBER_NOMINATION_DETAILS MND
      INNER JOIN MEM_NOMINATION_FAMILY_DETAILS MNFD
      ON MND.NOMINATION_ID = MNFD.NOMINATION_ID
      WHERE
        MND.NOMINATION_ID = V_NOMINATION_ID AND
        MND.UAN = IN_UAN AND
        STATUS = 'E' 
      ORDER BY MNFD.LAST_UPDATED_ON DESC
      FETCH FIRST 1 ROW ONLY;
     
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_CSE_OUTPUT := V_CSE_OUTPUT ||'. ERROR OCCURED WHILE FETCHING NOMINEE DETAILS' || '. CANNOT PROCEED';
                RAISE NOT_ELIGIBLE;
    END;
	
    LOG_ERROR('SAVE_CLAIM_DATA: FETCHING OFFICE DETAILS', 'DETAILS : ' || V_OFFICE_ID || '#~# APPLICATION TYPE  : '|| IN_APPLICATION_TYPE || 'CLAIM_FORM_TYPE : '|| IN_CLAIM_TYPE);
	  BEGIN
      SELECT
        OT.DESCRIPTION,
        OFI.ADDRESS_LINE1|| ' ' || OFI.ADDRESS_LINE2|| ' ' ||OFI.ADDRESS_LINE3|| ' ' ||OFI.CITY,
        OFI.PIN
      INTO
        V_OFFICE_NAME,
        V_ADDRESS_OF_OFFICE,
        V_PINCODE_OF_OFFICE
      FROM 
        OFFICE OFI
      INNER JOIN OFFICE_TYPE OT
      ON OFI.OFFICE_TYPE_ID = OT.ID
      WHERE
        OFI.ID = V_OFFICE_ID;
      
      EXCEPTION	
        WHEN NO_DATA_FOUND THEN
          V_CSE_OUTPUT := V_CSE_OUTPUT || '. ERROR OCCURED WHILE FETCHING OFFICE DETAILS' || '. CANNOT PROCEED';
          RAISE NOT_ELIGIBLE;
    END;
    
      V_IS_WIDTHRAWAL_BENFIT_REQ := 'Y';
      V_IS_WIDTHRAWAL_BENFIT_TAKEN := 'N';
    END IF;


  --Check for IFSC obsolete #ver4.18
  SELECT COUNT(*) INTO V_IFSC_COUNT FROM BANK_IFSC WHERE IFSC_CODE=TRIM(UPPER(V_IFSC)) AND NVL(OBSOLETE,'Y') = 'N';     --#ver4.38
  IF V_IFSC_COUNT=0 THEN
    RAISE INVALID_IFSC;
  END IF;   
    SAVE_OCS_CLAIM_DATA(
      V_OFFICE_ID ,
      V_TRACKING_ID ,
      IN_UAN ,
      V_MEMBER_ID ,
      V_MEMBER_NAME ,
      V_MEMBER_FATHER_SPOUSE_NAME ,
      IN_CLAIM_TYPE ,
      OUT_RECEIPT_DATE ,
      SUBSTR(V_MEMBER_ID,0,15) ,
      V_MEMBER_RELATION_WITH_MEMBER ,
      V1_MEMBER_PAN ,
      V_MEMBER_AADHAAR ,
      V_MEMBER_MOBILE_NUMBER ,
      V_MEMBER_EMAIL_ID ,
      V_MEMBER_GENDER ,
      V_MEMBER_DOB,
      V_DOJ_EPF,
      V_DOJ_EPS,
      V_DOE_EPF,
      V_DOE_EPS,
      V_LEAVE_REASON_CODE,
      V_OUT_PARA ,
      V_OUT_SUB_PARA ,
      V_OUT_SUB_PARA_CAT ,
      T_ADV_AMOUNT ,
      V_BANK_AC_NO ,
      V_IFSC ,
      T_CLAIM_SOURCE_FLAG ,
      T_ADDRESS1 ,
      T_ADDRESS2 ,
      T_ADDRESS_CITY ,
      T_ADDRESS_DIST ,
      T_ADDRESS_STATE ,
      T_ADDRESS_PIN ,
      T_AGENCY_EMPLOYER_FLAG ,
      T_AGENCY_NAME ,
      T_AGENCY_ADDRESS ,
      T_AGENCY_ADDRESS_CITY ,
      T_AGENCY_ADDERSS_DIST ,
      T_AGENCY_ADDRESS_STATE ,
      T_AGENCY_ADDRESS_PIN ,
      T_FLAG_15GH ,
      T_PDF_15GH ,
      T_TDS_15GH ,
    --  T_CANCEL_CHEQUE ,
      T_ADV_ENCLOSURE ,
      T_IP_ADDRESS ,
  --ADDED BY AKSHAY FOR 10D
      IN_CLAIM_BY,
      IN_PENSION_TYPE,
      IN_OPTED_REDUCED_PENSION,
      IN_OPTED_DATE,
      IN_PPO_DETAILS,
      IN_SCHEME_CERTIFICATE,
      IN_DEFERRED_PENSION,
      IN_DEFERRED_PENSION_AGE,
      IN_DEFERRED_PENSION_CONT,
      V_MARITAL_STATUS,
      V_NOMINATION_ID,
      IN_BANK_ID,
      V_MEMBER_PHOTOGRAPH,
      --ADDITION BY AKSHAY FOR 10D ENDED
--      IN_CANCEL_CHEQUE_PATH,
      --NULL, --#ver4.6
      IN_APPLICATION_TYPE,--#ver4.29
      V_WITHDRAWAL_REASON,  --#ver4.21
      IN_AADHAAR_CONSENT_STATUS, --#ver4.22
      IN_AADHAAR_CONSENT_REF_ID, --#ver4.22
      IN_3RDPARTY_NAME     ,
      IN_3RDPARTY_BANK_ACCNO ,
      IN_3RDPARTY_BANK_IFSC  ,
      IN_AUTH_LETTER_FILE_PATH ,
	-- Yash Patidar Edits HERE UNIFIED_PORTAL
      V_BANK_NAME,
      V_BANK_BRANCH,
      V_NOMINATION_FAMILY_ID,
      V_NOMINEE_NAME,
      V_NOMINEE_DOB,
      V_NOMINEE_GENDER,
      V_NOMINEE_AADHAAR,
      V_NOMINEE_RELATION,
      V_NOMINEE_RELATION_OTHER,
      V_NOMINEE_ADDRESS,
      V_IS_MINOR_NOMINEE,
      V_IS_LUNATIC,
      V_NOM_SHARE_IN_PERCENT,
      V_GUARDIAN_NAME,
      V_GUARDIAN_RELATION,
      V_GUARDIAN_ADDRESS,
      V_NOM_ADDRESS1,
      V_NOM_ADDRESS2,
      V_NOM_CITY,
      V_NOM_DISTRICT,
      V_NOM_STATE,
      V_NOM_DISTRICT_ID,
      V_NOM_STATE_ID,
      V_NOM_PIN,	  
      V_OFFICE_NAME,
      V_ADDRESS_OF_OFFICE,
      V_PINCODE_OF_OFFICE,
      V_IS_WIDTHRAWAL_BENFIT_REQ,
      V_IS_WIDTHRAWAL_BENFIT_TAKEN,
      INSERT_STATUS ,
      INSERT_OUTPUT );
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CLAIM_DATA FINISHED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' INSERT_STATUS: '||INSERT_STATUS||' INSERT_OUTPUT: '||INSERT_OUTPUT);
  END IF;
  
  IF IN_CLAIM_TYPE = '04' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CLAIM_DATA FINISHED FOR 10C','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' INSERT_STATUS: '||INSERT_STATUS||' INSERT_OUTPUT: '||INSERT_OUTPUT);
  END IF;

  IF INSERT_STATUS>0 THEN
  ------CAPTURE ERROR lOG***************************
    LOG_ERROR(VMODULE,'INSERT FAILED SAVE_OCS_CLAIM_DATA'||', '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
    RAISE DATA_INSERT_FAIL;
  END IF;
  IF INSERT_STATUS=0 THEN
    SAVE_OCS_CLAIM_DATA_LOG(
          V_OFFICE_ID ,
          V_TRACKING_ID ,
          IN_UAN ,
          V_MEMBER_ID ,
          V_MEMBER_NAME ,
          V_MEMBER_FATHER_SPOUSE_NAME ,
          IN_CLAIM_TYPE ,
          OUT_RECEIPT_DATE ,
          SUBSTR(V_MEMBER_ID,0,15) ,
          V_MEMBER_RELATION_WITH_MEMBER ,
          V1_MEMBER_PAN ,
          V_MEMBER_AADHAAR ,
          V_MEMBER_MOBILE_NUMBER ,
          V_MEMBER_EMAIL_ID ,
          V_MEMBER_GENDER ,
          V_MEMBER_DOB,
          V_DOJ_EPF,
          V_DOJ_EPS,
          V_DOE_EPF,
          V_DOE_EPS,
          V_LEAVE_REASON_CODE,
          V_OUT_PARA ,
          V_OUT_SUB_PARA ,
          V_OUT_SUB_PARA_CAT ,
          T_ADV_AMOUNT ,
          V_BANK_AC_NO ,
          V_IFSC ,
          T_CLAIM_SOURCE_FLAG ,
          T_ADDRESS1 ,
          T_ADDRESS2 ,
          T_ADDRESS_CITY ,
          T_ADDRESS_DIST ,
          T_ADDRESS_STATE ,
          T_ADDRESS_PIN ,
          T_AGENCY_EMPLOYER_FLAG ,
          T_AGENCY_NAME ,
          T_AGENCY_ADDRESS ,
          T_AGENCY_ADDRESS_CITY ,
          T_AGENCY_ADDERSS_DIST ,
          T_AGENCY_ADDRESS_STATE ,
          T_AGENCY_ADDRESS_PIN ,
          T_FLAG_15GH ,
          T_PDF_15GH ,
          T_TDS_15GH ,
        --  T_CANCEL_CHEQUE ,
          T_ADV_ENCLOSURE ,
          T_IP_ADDRESS ,
          --ADDED BY AKSHAY FOR 10D
          IN_CLAIM_BY,
          IN_PENSION_TYPE,
          IN_OPTED_REDUCED_PENSION,
          IN_OPTED_DATE,
          IN_PPO_DETAILS,
          IN_SCHEME_CERTIFICATE,
          IN_DEFERRED_PENSION,
          IN_DEFERRED_PENSION_AGE,
          IN_DEFERRED_PENSION_CONT,
          V_MARITAL_STATUS,
          V_NOMINATION_ID,
          IN_BANK_ID,
          V_MEMBER_PHOTOGRAPH,
              --ADDITION BY AKSHAY FOR 10D ENDED
        --      IN_CANCEL_CHEQUE_PATH,
          IN_APPLICATION_TYPE, --#ver4.6
          '',  --#ver4.21
          NULL, --#ver4.22
          NULL, --#ver4.22
          IN_3RDPARTY_NAME     ,
          IN_3RDPARTY_BANK_ACCNO ,
          IN_3RDPARTY_BANK_IFSC  ,
          IN_AUTH_LETTER_FILE_PATH ,
          V_BANK_NAME,
          V_BANK_BRANCH,
          V_NOMINATION_FAMILY_ID,
          V_NOMINEE_NAME,
          V_NOMINEE_DOB,
          V_NOMINEE_GENDER,
          V_NOMINEE_AADHAAR,
          V_NOMINEE_RELATION,
          V_NOMINEE_RELATION_OTHER,
          V_NOMINEE_ADDRESS,
          V_IS_MINOR_NOMINEE,
          V_IS_LUNATIC,
          V_NOM_SHARE_IN_PERCENT,
          V_GUARDIAN_NAME,
          V_GUARDIAN_RELATION,
          V_GUARDIAN_ADDRESS,
          V_NOM_ADDRESS1,
          V_NOM_ADDRESS2,
          V_NOM_CITY,
          V_NOM_DISTRICT,
          V_NOM_STATE,
          V_NOM_DISTRICT_ID,
          V_NOM_STATE_ID,
          V_NOM_PIN,	  
          V_OFFICE_NAME,
          V_ADDRESS_OF_OFFICE,
          V_PINCODE_OF_OFFICE,
          V_IS_WIDTHRAWAL_BENFIT_REQ,
          V_IS_WIDTHRAWAL_BENFIT_TAKEN,
          INSERT_STATUS ,
          INSERT_OUTPUT );
        IF INSERT_STATUS>0 THEN
        ------CAPTURE ERROR lOG***************************
        LOG_ERROR(VMODULE,'INSERT FAILED SAVE_OCS_CLAIM_DATA_LOG'||', '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
        RAISE DATA_INSERT_FAIL;
    END IF;
  END IF;
  IF IN_CLAIM_TYPE = '03' THEN
  LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CRD_DATA CALLED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
  END IF;
-- SAVE_OCS_CRD_DATA(V_MEMBER_ID,V_OFFICE_ID,IN_CLAIM_TYPE,V_TRACKING_ID,V_OCRD_STATUS,V_OCRD_OUTPUT);
-- IF IN_CLAIM_TYPE = '03' THEN
--  LOG_ERROR('SAVE_CLAIM_DATA: SAVE_OCS_CRD_DATA FINISHED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' V_OCRD_STATUS:'||V_OCRD_STATUS||' V_OCRD_OUTPUT:'||V_OCRD_OUTPUT);
--  END IF;
--  IF V_OCRD_STATUS=1 THEN
--    INSERT_OUTPUT:=V_OCRD_OUTPUT;
--    ------CAPTURE ERROR lOG***************************
--    LOG_ERROR('SAVE_OCS_CRD_DATA',V_OCRD_OUTPUT||', '||V_MEMBER_ID||' Ip-Address  '||T_IP_ADDRESS);
--    RAISE DATA_INSERT_FAIL;
--  END IF;

  --ADDED ON 15/05/2019 FOR 10D
  IF IN_CLAIM_TYPE='03' THEN
  LOG_ERROR('SAVE_CLAIM_DATA: CALLING PKG_EMP_PENSION_CLAIM.INSERT_OCS_FAMILY_NOMINATION','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
    PKG_EMP_PENSION_CLAIM.INSERT_OCS_FAMILY_NOMINATION(V_TRACKING_ID,V_NOMINATION_ID,'M',V_NOMINATION_SAVED);
    LOG_ERROR('SAVE_CLAIM_DATA: FINISHED PKG_EMP_PENSION_CLAIM.INSERT_OCS_FAMILY_NOMINATION','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' V_NOMINATION_SAVED:'||V_NOMINATION_SAVED);
    IF V_NOMINATION_SAVED <> 'SUCCESS' THEN
      INSERT_OUTPUT := V_NOMINATION_SAVED;
      LOG_ERROR('INSERT_OCS_FAMILY_NOMINATION','INSERT FAILED: '||INSERT_OUTPUT||', '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
      RAISE DATA_INSERT_FAIL;
    END IF;
  END IF;
  --ADDITION ON 15/05/2019 ENDED

  --#ver3.4
  --INSERT AADHAAR VERIFICATION LOG
--  LOG_AADHAAR_DEMO_VERIFICN_RESP(IN_UAN,V_TRACKING_ID,IN_AADHAAR_FOR_DEMO_VERIFY,V_MEMBER_NAME,V_MEMBER_DOB,V_MEMBER_GENDER,IN_AADHAAR_DEMO_VERIFY_STATUS,IN_AADHAAR_DEMO_VERIFY_CODE,V_BANK_AC_NO);

--  COMMIT;   --COMMENTED HERE AND MOVED TO SUBMIT_OCS_CLAIM
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: CHANGES COMMITTED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
  END IF;
  OUT_MOBILE_NUMBER:=V_MEMBER_MOBILE_NUMBER;
  OUT_MEMBER_NAME  :=V_MEMBER_NAME;
  IF IN_CLAIM_TYPE='01' OR IN_CLAIM_TYPE='04' THEN
  SELECT REASON
  INTO OUT_LEAVE_REASON
  FROM MEMBER_EXIT_REASON
  -- WHERE ID        =V_LEAVE_REASON_CODE;
  WHERE ID        =DECODE(V_LEAVE_REASON_CODE,'7',10,'8',11,'9',12,V_LEAVE_REASON_CODE);	--#ver4.2
  END IF;

  OUT_FS_NAME    :=V_MEMBER_FATHER_SPOUSE_NAME;
  OUT_DOJ_EPF    :=TO_CHAR(V_DOJ_EPF,'dd-Mon-yyyy');
  OUT_DOJ_EPS    :=TO_CHAR(V_DOJ_EPS,'dd-Mon-yyyy');
  OUT_DOE_EPF    :=TO_CHAR(V_DOE_EPF,'dd-Mon-yyyy');
  OUT_DOE_EPS    :=TO_CHAR(V_DOE_EPS,'dd-Mon-yyyy');
  OUT_DOB        :=TO_CHAR(V_MEMBER_DOB,'dd-Mon-yyyy');
  IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: DATA GATHERED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' OUT_FS_NAME:'||OUT_FS_NAME||' OUT_DOJ_EPF:'||OUT_DOJ_EPF||' OUT_DOJ_EPS:'||OUT_DOJ_EPS||' OUT_DOE_EPF'||OUT_DOE_EPF||' OUT_DOE_EPS:'||OUT_DOE_EPS||' OUT_DOB:'||OUT_DOB);
  END IF;
  IF IN_CLAIM_TYPE='01' THEN
  CASE WHEN ROUND(V_TOTAL_SERVICE_IN_MONTHS/12)<5 AND V_MEMBER_PAN IS NOT NULL AND LENGTH(V_MEMBER_PAN)=10 THEN
  OUT_PANCARD    :=V_MEMBER_PAN;
  WHEN ROUND(V_TOTAL_SERVICE_IN_MONTHS/12)>=5 THEN
  OUT_PANCARD    :=NVL(V_MEMBER_PAN,'NA');
  ELSE
  OUT_PANCARD    :='PAN NOT AVAILABLE ( '||V_CSE_OUTPUT||')';
  END CASE;
  ELSE
  OUT_PANCARD    :=NVL(V_MEMBER_PAN,'NA');
  END IF;


  OUT_AADHAAR    :=V_MEMBER_AADHAAR;
  OUT_BANK_ACC_NO:=TRIM(V_BANK_AC_NO);
  OUT_BANK_IFSC  :=V_IFSC;
  OUT_OFFICE_ID  :=V_OFFICE_ID;
   IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: DATA GATHERED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS||' OUT_AADHAAR:'||OUT_AADHAAR||' OUT_BANK_ACC_NO:'||OUT_BANK_ACC_NO||' OUT_BANK_IFSC:'||OUT_BANK_IFSC||' OUT_OFFICE_ID:'||OUT_OFFICE_ID);
  END IF;
  IF IN_CLAIM_TYPE <> '03' THEN
    SELECT NVL((B.NAME
      ||','
      ||BI.BRANCH),'NA')
    INTO OUT_BANK_DETAILS
    FROM BANK_IFSC BI
    LEFT JOIN BANK B
    ON B.ID           =BI.BANK_ID
    WHERE BI.IFSC_CODE=V_IFSC;
  END IF;

  OUT_MEMBER_ID    :=V_MEMBER_ID;
   IF IN_CLAIM_TYPE = '03' THEN
    LOG_ERROR('SAVE_CLAIM_DATA: PROCEDURE FINISHED','IN_UAN '||IN_UAN||' Ip-address '||T_IP_ADDRESS);
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
OUT_STATUS:=1;
OUT_MESSAGE:='DATA NOT FOUND EXCEPTION: '||SQLERRM;
WHEN OFFICE_ID_OR_TEMP_ID_NOT_FOUND THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='OFFICE ID NOT FOUND OR FAILED TO GENERATE TRACKING ID';

WHEN DATA_INSERT_FAIL THEN
  ROLLBACK;
  OUT_STATUS :=1;
  OUT_MESSAGE:='INSERT EXCEPTION: '||INSERT_OUTPUT;

WHEN CLAIM_PENDING THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='YOU HAVE ALREADY PENDING CLAIM,PLEASE TRACK CLAIM STATUS';

WHEN NOT_ELIGIBLE THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='ELIGIBLITY EXCEPTION: '||V_CSE_OUTPUT;

WHEN INVALID_CURSOR THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='DATA NOT AVAILABLE AGAINST THIS UAN,PLEASE ENTER VALID UAN';
  
WHEN PF_ADVANCE_NOT_ALLOWED THEN	--#ver3.8
  OUT_STATUS :=1;
  OUT_MESSAGE := 'PF ADVANCE NOT ALLOWED. '||OUT_MESSAGE;

WHEN FORM_10C_NOT_ALLOWED THEN    --#ver4.29
  OUT_STATUS :=1;
  OUT_MESSAGE:='ERROR: '||OUT_MESSAGE;
WHEN INVALID_68M_ADV_AMT THEN --#ver4.10
  OUT_STATUS :=1;
  OUT_MESSAGE:='INVALID ADVANCE AMOUNT.MAXIMUM LIMIT EXCEEDED';  

WHEN INVALID_IFSC THEN --#ver4.18
  OUT_STATUS :=1;
  OUT_MESSAGE:='Available IFSC ('||V_IFSC||') is invalid. Please update valid IFSC with latest Bank Account Number in KYC details through your employer/Unified Portal.'; 

WHEN INVALID_UAN THEN --#ver4.30
  OUT_STATUS :=1;
  OUT_MESSAGE:='UAN IS DEACTIVATED. CAN NOT PROCEED.';
  
WHEN CASE_NOT_FOUND THEN
  OUT_STATUS :=1;
  OUT_MESSAGE:='CASE NOT FOUND EXCEPTION: FROM SAVE_CLAIM_DATA_FOR_UP'||SQLERRM;  

WHEN OTHERS THEN    --ADDED BY AKSHAY ON 10/04/2019
  IF SQLCODE = -20001 THEN
    OUT_STATUS :=1;
    LOG_ERROR(VMODULE||IN_UAN,'EXCEPTION.SQLCODE = -20001, '||IN_UAN||' Error: '||SQLERRM); --#ver1.5
    V_ERROR_MESSAGE := SQLERRM;
    OUT_MESSAGE:=substr(V_ERROR_MESSAGE,instr(V_ERROR_MESSAGE,'Z#')+2,instr(V_ERROR_MESSAGE,'#Z')-(instr(V_ERROR_MESSAGE,'Z#')+2));
--    OUT_MESSAGE:=SQLERRM;
  ELSE
    LOG_ERROR(VMODULE||IN_UAN,'EXCEPTION.OTHERS, '||IN_UAN||' Error: '||SQLERRM); --#ver1.5
    OUT_STATUS :=1;
    OUT_MESSAGE:= 'Unexpected error while saving the claim. Please try after some time.';
        RAISE_APPLICATION_ERROR(-20001,SQLERRM);
 END IF;

END SAVE_CLAIM_DATA_FOR_UP;


--ver2.1
--ADDED ON 30/03/2020
--AS GUIDED BY RANJIT SIR, CHECK VALIDATE EXISTENCE OF KYC APPROVAL PDF WHILE FILING ONLINE CLAIM
--FOR UMANG CASES A SEPARATE SCHEDULAR IS WRITTEN BY SAURAVK
PROCEDURE GET_BANK_ACTIVITY_DETAILS(
	IN_UAN IN NUMBER,
	OUT_ACTIVITY_ID OUT NUMBER,
	OUT_DOCUMENT_NO OUT VARCHAR2,
	OUT_PDF_PATH OUT VARCHAR2,
	OUT_ACTUAL_DIRECTORY_FLAG OUT VARCHAR2	--#ver4.4
)
AS
	V_BANK_ACC_NO VARCHAR2(20);	--#ver3.1
	V_IFSC VARCHAR2(11);
	V_VALID_IFSC_COUNT NUMBER(2);  
	V_EST_SL_NO NUMBER(8);	--#ver3.1
	V_KYC_APPROVAL_TIME TIMESTAMP(6) := null;	--#ver3.1	--#ver4.4
	OUT_ACTIVITY_DETAILS COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE;	--#ver3.1
BEGIN
	SELECT	--#ver3.1
		BANK_ACC_NO,
		BANK_IFSC
	INTO
		V_BANK_ACC_NO,
		V_IFSC
	FROM
		UAN_REPOSITORY
	WHERE
		UAN = IN_UAN;

	--#ver3.1  
	PKG_LATEST_KYC.GET_KYC_PDF_ACTIVITY_DETAILS(IN_UAN,1,V_BANK_ACC_NO,OUT_ACTIVITY_DETAILS);
	--#ver3.1	
	FETCH OUT_ACTIVITY_DETAILS INTO OUT_ACTIVITY_ID,OUT_DOCUMENT_NO,OUT_PDF_PATH,V_EST_SL_NO,V_KYC_APPROVAL_TIME;

	-- IF OUT_ACTIVITY_ID <> 0 THEN	--#ver4.4	--COMMENTED FOR #ver4.5
		-- IF TRUNC(V_KYC_APPROVAL_TIME) < TRUNC(TO_DATE('08-AUG-2020','DD-MON-YYYY')) THEN
			-- --CHECK ARCHIVED & NODE LOCAL DIRECTORY
			-- OUT_ACTUAL_DIRECTORY_FLAG:='N';
		-- ELSE
			-- --CHECK ACTUAL DIRECTORY
			-- OUT_ACTUAL_DIRECTORY_FLAG:='O';
		-- END IF;
	-- END IF;
	OUT_ACTUAL_DIRECTORY_FLAG:='A'; --#ver4.5
--  OUT_DOCUMENT_NO:= TRIM(REGEXP_REPLACE(OUT_DOCUMENT_NO ,'[^0-9]', ''));
  /*	--COMMENTED FOR #ver3.1
	SELECT 
		ACTIVITY_ID,
		--  UAN,
		-- DOCUMENT_NO,
		TRIM(REGEXP_REPLACE(DOCUMENT_NO ,'[^0-9]', '')),	--#ver2.8
		PDF_NAME,
    IFSC
	INTO
		OUT_ACTIVITY_ID,
		OUT_DOCUMENT_NO,
		OUT_PDF_PATH,
    V_IFSC
	FROM (
		SELECT
			ID,
			ACTIVITY_ID,
			DOCUMENT_NO,
			UAN,
			TYPE_ID,
      IFSC,
			STATUS,
			DS_STATUS,
			PDF_NAME,
			PDF_TIME,
			RANK() OVER (PARTITION BY DOCUMENT_TYPE_ID ORDER BY PDF_TIME DESC ) AS myrank
		FROM (
			SELECT
				MK.ID,
				ACTIVITY_ID,
				DOCUMENT_NO,
				UAN,
				DOCUMENT_TYPE_ID,
        IFSC,
				EAL_O.TYPE_ID,
				EAL_O.STATUS,
				EAL_O.DS_STATUS,
				CASE
					WHEN EAL_O.TYPE_ID IN (1,2)     THEN EAL_O.DS_PDF_FILE_PATH||'/'||EAL_O.DS_PDF_NAME
					WHEN EAL_O.TYPE_ID IN (3,8,9)   THEN EAL_O.PDF_FILE_PATH||'/'||EAL_O.PDF_NAME
					ELSE
						CASE
							WHEN MK.ACTIVITY_ID = 0 THEN 'not_available.pdf'
						ELSE 
							NULL
						END
				END PDF_NAME,
				CASE
					WHEN EAL_O.TYPE_ID IN (1,2)     THEN EAL_O.DS_PDF_GENERATION_TIME
					WHEN EAL_O.TYPE_ID IN (3,8,9)   THEN EAL_O.PDF_GENERATION_TIME
					ELSE
						CASE
						--WHEN MK.ACTIVITY_ID = 0 THEN mk.MIGRATION_TIMESTAMP      --Added MIGRATION_TIMESTAMP instead of '15-Aug-1947'	 --#ver1.2
							WHEN MK.ACTIVITY_ID = 0 THEN NVL(mk.MIGRATION_TIMESTAMP,'15-Aug-1947')      --#ver1.2
						ELSE 
							NULL
						END
				END PDF_TIME
			FROM
				UNIFIED_PORTAL.MEMBER_KYC MK
			INNER JOIN UNIFIED_PORTAL.EST_ACTIVITY_LOG EAL_O ON
				EAL_O.ID = MK.ACTIVITY_ID
			WHERE
				MK.UAN                          = IN_UAN AND       --IN_UAN                                                 
				MK.DOCUMENT_TYPE_ID = 1     AND
				--MK.DOCUMENT_NO = '04801140010823' AND --IN_BANK_ACC_NO
				(
					EAL_O.STATUS IN ('A','O')       AND
					EAL_O.DS_STATUS = 'Y'
				)
			)
			WHERE
				PDF_NAME IS NOT NULL AND PDF_TIME IS NOT NULL                  --Added constraint of PDF time
		)
	WHERE
		myrank <= 1
	FETCH FIRST ROW ONLY
	;  
  */
  /* --#ver2.5
  SELECT COUNT(1) INTO V_VALID_IFSC_COUNT FROM BANK_IFSC WHERE IFSC_CODE=V_IFSC AND NVL(OBSOLETE,'Y')='N';
  IF V_VALID_IFSC_COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'Z#The IFSC code seeded against your bank account number is no more valid.Cannot proceed.#Z');--#ver2.4
  END IF;
  */
END GET_BANK_ACTIVITY_DETAILS;   


--#ver2.6
PROCEDURE VALIDATE_SCHEME_PARA(
	IN_UAN IN NUMBER,
	IN_PARA_CODE IN VARCHAR2,
	IN_SUB_PARA_CODE IN VARCHAR,
	IN_SUB_PARA_CATEGORY IN VARCHAR2,
  IN_TOTAL_SERVICE_IN_MONTHS IN NUMBER,
  DOE_EPF IN DATE,
	OUT_MESSAGE OUT VARCHAR2
)
AS
	V_DATE_OF_BIRTH DATE;
	V_MEMBERSHIP_INFO NUMBER(3):=0; --#ver4.29
    V_NOMINATION_COUNT NUMBER(3):=0; --#ver4.32

	CURSOR CUR_SCHEME_PARAS(V_DOB DATE, V_MEMBERSHIP NUMBER, V_NOMINATION NUMBER) IS --#ver4.32
		--ADDED ON 29/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR COVID-19 CORONAVIRUS REASON	--#ver2.0      
		SELECT 
			SPM_FINAL.PARA_CODE,
			SPM_FINAL.SUB_PARA_CODE,
			SPM_FINAL.SUB_PARA_CATEGORY,
			SPM_FINAL.PARA_DESCRIPTION,
			SPM_FINAL.MAX_EE_PERCENT,
			SPM_FINAL.MAX_ER_PERCENT,
			SPM_FINAL.PARA_DETAILS,
			SPM_FINAL.NO_OF_MONTHS,
			SPM_FINAL.MAX_NUMBER,
			SPM_FINAL.ELIGIBLE,
			SPM_FINAL.ELIGIBILITY_MESSAGE FROM
			(SELECT
			CASE
--				WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) = 0
                WHEN (V_NOMINATION = 0)   --#ver4.32
                    THEN 1 
                WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) < 2 --#ver4.20
					THEN 0
				ELSE 1
			END ELIGIBLE,
			CASE
--				WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) > 0 
            WHEN (V_NOMINATION = 0)   --#ver4.32
                    THEN 'NOMINATONS DETAILS NOT AVAILABLE' 
                WHEN COUNT_CLAIM_FOR_CORONAVIRUS(IN_UAN) >= 2 --#ver4.20
					THEN 'Only two advances are admissible under this paragraph'   --#ver4.0
--					THEN 'One PF Advance(Form-31) claim is already pending.'  --#ver3.2
			ELSE 
				'SERVICE OK'
			END ELIGIBILITY_MESSAGE,
			SPM.PARA_CODE
			||SUB_PARA_CODE
			||SUB_PARA_CATEGORY PARA_CC,
			SPM.*
			FROM SCHEME_PARA_MASTER SPM
			WHERE 
				FORM_TYPE=06 
				AND PARA_CODE = IN_PARA_CODE
				AND SUB_PARA_CODE = IN_SUB_PARA_CODE
				AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
			)SPM_FINAL WHERE PARA_CC IN ('8133')
			--ADDITION ON 29/03/2020 ENDED
      union all
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
         WHEN (V_NOMINATION = 0)   --#ver4.32
            THEN 1
        WHEN SPM.SERVICE_MONTHS<=IN_TOTAL_SERVICE_IN_MONTHS
        OR SPM.SERVICE_MONTHS  IS NULL
            THEN 0         
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (V_NOMINATION = 0)    --#ver4.32
             THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN SPM.SERVICE_MONTHS<=IN_TOTAL_SERVICE_IN_MONTHS
          OR SPM.SERVICE_MONTHS  IS NULL
          THEN 'SERVICE OK'
          ELSE 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
	  		AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY

--      )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','914-','1015-')
--      )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','1015-')
 --     )SPM_FINAL WHERE PARA_CC IN ('24-','48-','612M','612E','813-','1015-') --#ver4.0
--        )SPM_FINAL WHERE PARA_CC IN ('24-','48-','511-','612M','612E','813-','1015-','9999-') --ADDED FOR CORONAVIRUS
)SPM_FINAL WHERE PARA_CC IN ('48-','813-') -- revised filters for 612M,612E,1015-,24-               --#ver4.8
      UNION ALL --ADDED ON 26/06/2020 TO ALLOW ONLY ONE ADVANCE CLAIM FOR ILLNESS IN 30 DAYS      --#ver4.0
		SELECT 
			SPM_FINAL.PARA_CODE,
			SPM_FINAL.SUB_PARA_CODE,
			SPM_FINAL.SUB_PARA_CATEGORY,
			SPM_FINAL.PARA_DESCRIPTION,
			SPM_FINAL.MAX_EE_PERCENT,
			SPM_FINAL.MAX_ER_PERCENT,
			SPM_FINAL.PARA_DETAILS,
			SPM_FINAL.NO_OF_MONTHS,
			SPM_FINAL.MAX_NUMBER,
			SPM_FINAL.ELIGIBLE,
			SPM_FINAL.ELIGIBILITY_MESSAGE FROM
			(SELECT
			CASE
          WHEN (SPM.SERVICE_MONTHS<=IN_TOTAL_SERVICE_IN_MONTHS
          OR SPM.SERVICE_MONTHS  IS NULL) AND COUNT_ILLNESS_ADVNCE_IN_30DAYS(IN_UAN) = 0
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (SPM.SERVICE_MONTHS>IN_TOTAL_SERVICE_IN_MONTHS)
            THEN 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
          WHEN (COUNT_ILLNESS_ADVNCE_IN_30DAYS(IN_UAN) > 0) 
            THEN 'CLAIM APPROVED WITHIN ONE MONTH'  
          ELSE 
            'SERVICE OK'
        END ELIGIBILITY_MESSAGE,
			SPM.PARA_CODE
			||SUB_PARA_CODE
			||SUB_PARA_CATEGORY PARA_CC,
			SPM.*
			FROM SCHEME_PARA_MASTER SPM
			WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE	--#ver4.1
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE	--#ver4.1
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY	--#ver4.1
			)SPM_FINAL WHERE PARA_CC IN ('511-')
      --ADDED ON 02/03/2020 TO ALLOW ONLY ONE APPROVED PF ADVANCE CLAIM FOR POWER CUT REASON
      UNION ALL
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
         WHEN (V_NOMINATION = 0)  --#ver4.32
             THEN 1
          WHEN 
          /*FOLLOWING COMMENTED ON 02/09/2020 TO APPLY NEW FILTER i.e. Date of exit should not be there   --#ver4.8
          (SPM.SERVICE_MONTHS<=IN_TOTAL_SERVICE_IN_MONTHS
          OR SPM.SERVICE_MONTHS  IS NULL) */
          DOE_EPF IS NULL
          AND COUNT_CLAIM_FOR_POWERCUT(IN_UAN) = 0
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (V_NOMINATION = 0)  --#ver4.32
             THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN 
           DOE_EPF IS NOT NULL
           THEN 'Employee with current employment can opt for this paragraph'
           /*FOLLOWING COMMENTED ON 02/09/2020 TO APPLY NEW FILTER i.e. Date of exit should not be there  --#ver4.8
          (SPM.SERVICE_MONTHS>IN_TOTAL_SERVICE_IN_MONTHS)
            THEN 'TOTAL SERVICE IS LESS THAN '
            ||SPM.SERVICE_MONTHS
            ||' MONTHS'
            */
          WHEN (COUNT_CLAIM_FOR_POWERCUT(IN_UAN) > 0) 
            THEN 'Only one advance is admissible under this paragraph'  
          ELSE 
            'SERVICE OK'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
		AND PARA_CODE = IN_PARA_CODE
		AND SUB_PARA_CODE = IN_SUB_PARA_CODE
		AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('914-')
      --ADDITION ON 02/03/2020 ENDED          
      UNION ALL
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN (V_NOMINATION = 0)  --#ver4.32
            THEN 1
          WHEN TRUNC (MONTHS_BETWEEN (SYSDATE, V_DOB) / 12)>=55
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
         WHEN (V_NOMINATION = 0)  --#ver4.32
             THEN 'NOMINATION DETAILS NOT AVAILABLE'
        WHEN TRUNC (MONTHS_BETWEEN (SYSDATE, V_DOB) / 12)>=55
             THEN 'SERVICE OK FOR 90%WITHDRAWL'          
          ELSE 'AGE IS  '
            ||TRUNC (MONTHS_BETWEEN (SYSDATE, V_DOB) / 12)
            ||'YEARS ONLY,NOT ELIGIBLE'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('6516-')

      UNION ALL   --ADDED BY AKSHAY ON 17/09/2019 TO ADD 68HH IN PURPOSE OF ADVANCE
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN (V_NOMINATION = 0)  --#ver4.32
             THEN 1
          WHEN DOE_EPF IS NOT NULL AND MONTHS_BETWEEN (SYSDATE, DOE_EPF) > 1  and GET_68HH_CLAIMS_THR_LAST_ESTAB(IN_UAN,FORM_TYPE) = 0 --ONLY ONE CLAIM FOR THIS ESTABLISHMENT   --PENDING
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (V_NOMINATION = 0)  --#ver4.32
            THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN DOE_EPF IS NULL
            THEN 'DATE OF EXIT SHOULD BE AVAILABLE IN THE LAST EMPLOYMENT'
          WHEN MONTHS_BETWEEN (SYSDATE, DOE_EPF) <= 1
            THEN 'DIFFERENCE BETWEEN DATE OF CLAIM AND DATE OF EXIT SHOULD BE MORE THAN ONE MONTH'
          WHEN GET_68HH_CLAIMS_THR_LAST_ESTAB(IN_UAN,FORM_TYPE) > 0   --ONLY ONE CLAIM FOR THIS ESTABLISHMENT   --PENDING
            THEN 'Only one claim is allowed against one establishment'
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('411-')      
      /* COMMENTED TEMP                           --#ver4.8
      UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68K,PARA 68BB,PARA 68BC,PARA 68BD  ADVANCE
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND --#ver4.29
          SPM.MAX_NUMBER > COUNT_PARA68B1_CLAIMS(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS  --#ver4.29
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN SPM.MAX_NUMBER <= GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('37-','38-','39-')  */

       UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68K  ADVANCE        --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN (V_NOMINATION =0)  --#ver4.32
            THEN 1
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND 
          3 > GET_CLAIM_COUNT_FOR_68K(IN_UAN)
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (V_NOMINATION = 0)  --#ver4.32
            THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN 3 <= GET_CLAIM_COUNT_FOR_68K(IN_UAN)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('612E','612M') 

       UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED 68N ADVANCE            --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN (V_NOMINATION = 0)  --#ver4.32
            THEN 1
          WHEN 
          SPM.MAX_NUMBER > GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  and
          1 > COUNT_PARA68N_ADVNCE_IN_3YEARS(IN_UAN)  
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
         WHEN (V_NOMINATION = 0)  --#ver4.32
            THEN 'NOMINATION DETAILS NOT AVAILABLE'
        WHEN  
        SPM.MAX_NUMBER <= GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)   
        THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
        when 1 <= COUNT_PARA68N_ADVNCE_IN_3YEARS(IN_UAN)
           THEN 'Second claim will be allowed only after three years of first claim'
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('1015-') 

        UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68B(1)(a),PARA 68B(1)(b) ADVANCE        --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN (V_NOMINATION = 0)   --#ver4.32
            THEN 1
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND                   -- #ver4.11  --#ver4.29
          SPM.MAX_NUMBER > nvl(COUNT_PARA68B1_CLAIMS(IN_UAN, null),0) 
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
         WHEN (V_NOMINATION = 0)   --#ver4.32
            THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN SPM.MAX_NUMBER <= COUNT_PARA68B1_CLAIMS(IN_UAN, null)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('23-','25-','27-') 

       UNION ALL   --ADDED BY SHIWANI ON 02/09/2020 FOR REVISED PARA 68B(1)(c) ADVANCE        --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE    
          WHEN (V_NOMINATION = 0)    --#ver4.32
             THEN 1 
          WHEN  
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND            -- #ver4.11  --#ver4.29
          SPM.MAX_NUMBER > nvl(COUNT_PARA68B1_CLAIMS(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY) ,0)
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
         WHEN (V_NOMINATION = 0)    --#ver4.32
            THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
         WHEN SPM.MAX_NUMBER <= COUNT_PARA68B1_CLAIMS(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  
            THEN 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          ELSE 'PRECONDITIONS FULFILLED'            
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('24-') 

       UNION ALL   --ADDED BY SHIWANI ON 05/10/2020 FOR REVISED PARA 68B(7) ADVANCE          --#ver4.8
      SELECT SPM_FINAL.PARA_CODE,
      SPM_FINAL.SUB_PARA_CODE,
      SPM_FINAL.SUB_PARA_CATEGORY,
      SPM_FINAL.PARA_DESCRIPTION,
      SPM_FINAL.MAX_EE_PERCENT,
      SPM_FINAL.MAX_ER_PERCENT,
      SPM_FINAL.PARA_DETAILS,
      SPM_FINAL.NO_OF_MONTHS,
      SPM_FINAL.MAX_NUMBER,
      SPM_FINAL.ELIGIBLE,
      SPM_FINAL.ELIGIBILITY_MESSAGE FROM
      (SELECT
        CASE
          WHEN (V_NOMINATION = 0)   --#ver4.32
            THEN 1
          WHEN 
          V_MEMBERSHIP >= SPM.SERVICE_MONTHS AND                      -- #ver4.11 --#ver4.29
          SPM.MAX_NUMBER >= GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY)  and      --ver4.10 
          SPM.MAX_NUMBER > nvl(COUNT_PARA68B7_ADVNCE(IN_UAN),0) 
          THEN 0
          ELSE 1
        END ELIGIBLE,
        CASE
          WHEN (V_NOMINATION = 0)    --#ver4.32
            THEN 'NOMINATION DETAILS NOT AVAILABLE'
          WHEN V_MEMBERSHIP < SPM.SERVICE_MONTHS
            THEN 'TOTAL SERVICE IS LESS THAN '||SPM.SERVICE_MONTHS||' MONTHS'
          WHEN SPM.MAX_NUMBER <=  GET_CLAIM_COUNT_FOR_PARA(IN_UAN, SPM.PARA_CODE||SPM.SUB_PARA_CODE||SPM.SUB_PARA_CATEGORY) 
          then 'BENEFIT CAN ONLY BE AVAILED FOR MAXIMUM '|| SPM.MAX_NUMBER ||' NUMBER OF TIMES'
          WHEN 1 <= COUNT_PARA68B7_ADVNCE(IN_UAN)  
            THEN 'SECOND CLAIM WILL BE ALLOWED ONLY AFTER TEN YEARS OF FIRST CLAIM'
          ELSE 'PRECONDITIONS FULFILLED'
        END ELIGIBILITY_MESSAGE,
        SPM.PARA_CODE
        ||SUB_PARA_CODE
        ||SUB_PARA_CATEGORY PARA_CC,
        SPM.*
      FROM SCHEME_PARA_MASTER SPM
      WHERE FORM_TYPE=06
			AND PARA_CODE = IN_PARA_CODE
			AND SUB_PARA_CODE = IN_SUB_PARA_CODE
			AND SUB_PARA_CATEGORY = IN_SUB_PARA_CATEGORY
      )SPM_FINAL WHERE PARA_CC IN ('26-') 
      ;
BEGIN
	SELECT DOB INTO V_DATE_OF_BIRTH FROM UAN_REPOSITORY WHERE UAN=IN_UAN;--14-DEC-2017
  	V_MEMBERSHIP_INFO := FETCH_MEMBERSHIP(IN_UAN);
    -- V_NOMINATION_COUNT := OCS_UTILITY.GET_NOMINATION_COUNT(IN_UAN); --#ver4.32
    V_NOMINATION_COUNT := 1; --ADDED FOR BYPASS NOMINATION CHECK --#ver4.33
	FOR V_REC IN CUR_SCHEME_PARAS(V_DATE_OF_BIRTH, V_MEMBERSHIP_INFO, V_NOMINATION_COUNT)  --#ver4.32
	LOOP
		IF V_REC.ELIGIBLE = 1 THEN --NOT ELIGIBLE
			OUT_MESSAGE:= V_REC.ELIGIBILITY_MESSAGE;
		END IF;
	END LOOP;       
END VALIDATE_SCHEME_PARA; 


  PROCEDURE LOG_AADHAAR_DEMO_VERIFICN_RESP(
    IN_UAN IN NUMBER,
    IN_TRACKING_ID IN NUMBER,
    IN_AADHAAR IN NUMBER,
    IN_MEMBER_NAME IN VARCHAR2,
    IN_DOB IN DATE,
    IN_GENDER IN VARCHAR2,
    IN_DEMOGRAPHIC_STATUS IN CHAR,
    IN_AADHAAR_REFERENCE_CODE IN VARCHAR2,
    IN_BANK_ACC_NO VARCHAR2
  )
  AS
  BEGIN
    INSERT INTO OCS_VERIFICATION_LOG_SUMMARY (
      TRACKING_ID,	--NOT NULL
      AADHAAR,		--NOT NULL
      LOGGING_MODE,
      RECORD_CREATION_TIME,	--NOT NULL
      SCHEDULER_ID
    ) VALUES
    (
      IN_TRACKING_ID,
      IN_AADHAAR,
      'UPFRONT',
      SYSTIMESTAMP,
      NULL
    );

    INSERT INTO OCS_VERIFICATION_LOG_DETAILS (
      TRACKING_ID,	--NOT NULL
      UAN,			--NOT NULL
      NAME,
      DOB,
      GENDER,
      AADHAAR_REFERENCE_CODE,
      DEMOGRAPHIC_STATUS,
      DEMOGRAPHIC_TIMESTAMP,
      FLAG_UPDATE_TIME,
      BANK_ACC_NO,	--NOT NULL
      ACTIVITY_ID,
      KYC_PDF_LOCATION,
      IS_PROCESSED,	--NOT NULL
      SCHEDULER_ID
    ) VALUES
    (
      IN_TRACKING_ID,
      IN_UAN,
      IN_MEMBER_NAME,
      IN_DOB,
      IN_GENDER,
      IN_AADHAAR_REFERENCE_CODE,
      IN_DEMOGRAPHIC_STATUS,
      SYSTIMESTAMP,
      SYSTIMESTAMP,
      IN_BANK_ACC_NO,
      NULL,
      NULL,
      'Y',
      NULL
    );
  END LOG_AADHAAR_DEMO_VERIFICN_RESP;

  PROCEDURE CHECK_BANK_ACC_MAP_TO_OTHR_UAN(
    IN_UAN IN NUMBER,
    IN_AADHAAR IN NUMBER,
    IN_NAME IN VARCHAR2,
    IN_DOB IN DATE,
    IN_GENDER IN VARCHAR2,
    IN_BANK_ACC_NO IN VARCHAR2,
    IN_BANK_IFSC IN VARCHAR2	--#ver4.0
  )
  AS
    TYPE T_MATCHING_BANK_DATA_REC IS RECORD(
      UAN UAN_REPOSITORY.UAN%TYPE,
      NAME UAN_REPOSITORY.NAME%TYPE,
      DOB UAN_REPOSITORY.DOB%TYPE,
      GENDER UAN_REPOSITORY.GENDER%TYPE,
      AADHAAR UAN_REPOSITORY.AADHAAR%TYPE,
      BANK_IFSC UAN_REPOSITORY.BANK_IFSC%TYPE	--#ver4.0
    );

    TYPE T_MATCHING_BANK_DATA_TABLE IS TABLE OF T_MATCHING_BANK_DATA_REC;
    V_MATCHING_BANK_DATA T_MATCHING_BANK_DATA_TABLE;	

    l_index PLS_INTEGER;
--    V_NOT_MATCHING VARCHAR2(1 BYTE):= 'N';
    V_UANS_FOR_ERROR VARCHAR2(1024 BYTE);
    V_MEMBER_ID_COUNT NUMBER(2):=1;		--#ver4.7
    V_UAN_ALLOTMENT_DATE TIMESTAMP(6);		--#ver4.7
    V_DIRECT_UAN_ALLOTED_COUNT NUMBER(2):= 0;	--#ver4.7
    V_CHECK_LINKED_MEMBER_ID NUMBER(1):= 0;	--#ver4.7    
  BEGIN
    SELECT
      UR.UAN UAN,
      UR.NAME NAME,
      UR.DOB DOB,
      UR.GENDER GENDER,
      UR.AADHAAR AADHAAR,
      UR.BANK_IFSC	--#ver4.0
    BULK COLLECT INTO
      V_MATCHING_BANK_DATA
    FROM
      UAN_REPOSITORY UR
    WHERE
      TRIM(UR.BANK_ACC_NO) = IN_BANK_ACC_NO	--WE WILL PASS IN_BANK_ACC_NO AS TRIMMED ONLY
    ;

    IF V_MATCHING_BANK_DATA.COUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001,'Z#Failed to find bank account details.#Z');
    END IF;

    l_index := V_MATCHING_BANK_DATA.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
--      DBMS_OUTPUT.PUT_LINE(V_MATCHING_BANK_DATA(l_index).NAME); 
      IF V_MATCHING_BANK_DATA(l_index).UAN <> IN_UAN AND
--        V_NOT_MATCHING = 'N' AND
        V_MATCHING_BANK_DATA(l_index).AADHAAR = IN_AADHAAR AND
        -- UPPER(TRIM(V_MATCHING_BANK_DATA(l_index).NAME)) = UPPER(TRIM(IN_NAME)) AND	--#ver3.7 --COMMENTED FOR --#ver4.1
		UPPER(REPLACE(V_MATCHING_BANK_DATA(l_index).NAME,' ','')) = REPLACE(UPPER(IN_NAME),' ','') AND
        V_MATCHING_BANK_DATA(l_index).DOB = IN_DOB AND
        V_MATCHING_BANK_DATA(l_index).GENDER = IN_GENDER 
      THEN
        --DETAILS ARE MATCHING --MIGHT BE A SAME PERSON'S UAN
        NULL;
      ELSE
        --DETAILS MISMATCH
	--#ver4.0
        --CHECK IF IFSC MATCHING THEN ONLY WE CAN SAY THAT SAME BANK ACCOUNT IS LINKED WITH MULTIPLE UANs
        IF V_MATCHING_BANK_DATA(l_index).BANK_IFSC IS NULL OR V_MATCHING_BANK_DATA(l_index).BANK_IFSC = IN_BANK_IFSC THEN
--        V_NOT_MATCHING := 'Y';     
        IF V_MATCHING_BANK_DATA(l_index).UAN <> IN_UAN THEN        

	    --#ver4.7
            --EXCLUDE UAN ALLOTTED FROM CITIZEN PORTAL
            --1. CHECK WHETHER UAN IS ALLOTTED BEFORE 2016.            
            --2. IF STEP 1 FAILS, CHECK WHETHER UAN IS ALLOTTED THROUGH DIRECT UAN ALLOTMENT
            --3. IF EITHER OF STEP 1 OR STEP 2 SUCCEEDS, CHECK FOR EXISTENCE OF LINKED MEMBER_ID
            --4. IF LINKED MEMBER_ID FOUND, CONSIDER UAN FOR ERROR. IF LINKED MEMBER_ID NOT FOUND, EXCLUDE AN UAN FROM ERROR            
            SELECT UAN_ALLOTMENT_DATE INTO V_UAN_ALLOTMENT_DATE FROM UAN_REPOSITORY WHERE UAN = V_MATCHING_BANK_DATA(l_index).UAN;


            DBMS_OUTPUT.PUT_LINE('V_MATCHING_BANK_DATA(l_index).UAN: '||V_MATCHING_BANK_DATA(l_index).UAN);
            DBMS_OUTPUT.PUT_LINE('V_UAN_ALLOTMENT_DATE: '||V_UAN_ALLOTMENT_DATE);
            V_CHECK_LINKED_MEMBER_ID :=0;
            V_MEMBER_ID_COUNT := 1;
            IF V_UAN_ALLOTMENT_DATE >= TO_TIMESTAMP('23-DEC-2016','DD-MON-YYYY') THEN
              SELECT COUNT(1) INTO V_DIRECT_UAN_ALLOTED_COUNT FROM OPEN_MEMBER_REGISTRATION WHERE UAN = V_MATCHING_BANK_DATA(l_index).UAN;
              DBMS_OUTPUT.PUT_LINE('V_DIRECT_UAN_ALLOTED_COUNT: '||V_DIRECT_UAN_ALLOTED_COUNT);
              IF V_DIRECT_UAN_ALLOTED_COUNT > 0 THEN
                V_CHECK_LINKED_MEMBER_ID := 1;
              END IF;
            ELSE
              V_CHECK_LINKED_MEMBER_ID := 1;
            END IF;
            DBMS_OUTPUT.PUT_LINE('V_CHECK_LINKED_MEMBER_ID: '||V_CHECK_LINKED_MEMBER_ID);

            IF V_CHECK_LINKED_MEMBER_ID = 1 THEN
              --CHECK EXISTENCE OF LINKED MEMBER_ID
              SELECT COUNT(1) INTO V_MEMBER_ID_COUNT FROM MEMBER WHERE UAN = V_MATCHING_BANK_DATA(l_index).UAN AND EST_SLNO <> 0;   --#ver4.14
            END IF;            

            DBMS_OUTPUT.PUT_LINE('V_MEMBER_ID_COUNT: '||V_MEMBER_ID_COUNT);
            IF V_MEMBER_ID_COUNT > 0 THEN
              --ADD UAN FOR ERROR MESSAGE
              IF V_UANS_FOR_ERROR IS NULL THEN
                V_UANS_FOR_ERROR := COMMON_KYC_MASK.MASKED_BANK(V_MATCHING_BANK_DATA(l_index).UAN);
--            V_UANS_FOR_ERROR := V_MATCHING_BANK_DATA(l_index).UAN;
              ELSE
                V_UANS_FOR_ERROR := V_UANS_FOR_ERROR||', '||COMMON_KYC_MASK.MASKED_BANK(V_MATCHING_BANK_DATA(l_index).UAN);
--            V_UANS_FOR_ERROR := V_UANS_FOR_ERROR||', '||V_MATCHING_BANK_DATA(l_index).UAN;
              END IF;
            END IF;            
          END IF;
        END IF;
      END IF;
      l_index := V_MATCHING_BANK_DATA.NEXT(l_index);
    END LOOP;

    IF V_UANS_FOR_ERROR IS NOT NULL THEN
--      RAISE_APPLICATION_ERROR(-20001, 'Z#The bank account number ('||COMMON_KYC_MASK.MASKED_BANK(IN_BANK_ACC_NO)||') seeded against this UAN is also linked with following UAN''s: '||V_UANS_FOR_ERROR||', however the demographic details do not match.#Z');
      RAISE_APPLICATION_ERROR(-20001, 'Z#The bank account linked with this account is also linked with the following UANs : '||V_UANS_FOR_ERROR||' (with different demographic details). If these UANs are yours, then please get the basic details corrected in your other UANs and link them with your Aadhar for transfer of your accounts to the present one. If this bank account is not yours then please add your correct bank account and get it approved by the employer to avail online claim facility.#Z');

    END IF;
  EXCEPTION 
    WHEN OTHERS THEN
      IF SQLCODE = -20001 THEN
        RAISE;
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Z#Error while verifying bank account number mapping.#Z'||SQLERRM);
      END IF;
  END CHECK_BANK_ACC_MAP_TO_OTHR_UAN;

  --#ver3.5
  PROCEDURE INSERT_SIGN_FAILED_LOG(
    IN_ACTIVITY_ID IN NUMBER,
    IN_LOG_STATUS IN VARCHAR2
  )AS
  BEGIN
    PKG_ESIGN_FAILED_MODULEWISE.LOG_CHECKED_KYC_ACTIVITY(IN_ACTIVITY_ID,IN_LOG_STATUS,'OCS Upfront file check');
    COMMIT;
  EXCEPTION 
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END INSERT_SIGN_FAILED_LOG;
    FUNCTION GET_CLAIM_COUNT_FOR_PARA(
    IN_UAN IN NUMBER,
	IN_PARACC IN VARCHAR2
)
RETURN NUMBER AS
	V_RET_VAL NUMBER := 0;
	V_FORM_TYPE VARCHAR2(10) := '06';
  BEGIN
	SELECT
		COUNT(COF.OFFICE_ID) COUNT
	INTO 
		V_RET_VAL
	FROM
		(
			SELECT
				COF31.CLAIM_FORM_TYPE,
				COF31.PARA_CODE,
				COF31.SUB_PARA_CODE,
				COF31.SUB_PARA_CATEGORY,
				COF31.OFFICE_ID
			FROM
				CEN_OCS_FORM_31 COF31
			WHERE
				COF31.CLAIM_FORM_TYPE = V_FORM_TYPE   
				AND COF31.UAN = IN_UAN
				AND COF31.CLAIM_STATUS NOT IN ('R') --#ver4.16
				AND CASE WHEN COF31.CLAIM_STATUS = 'S'  THEN 0 ELSE 1 END = 1 --#ver4.15
		) COF
		RIGHT JOIN 
			SCHEME_PARA_MASTER SPM 
		ON 
			SPM.FORM_TYPE = COF.CLAIM_FORM_TYPE
		AND 
			SPM.PARA_CODE = COF.PARA_CODE
		AND 
			SPM.SUB_PARA_CODE = COF.SUB_PARA_CODE
		AND 
			SPM.SUB_PARA_CATEGORY = DECODE(COF.SUB_PARA_CATEGORY, '0', '-', COF.SUB_PARA_CATEGORY)
	WHERE 
		SPM.PARA_CODE|| SPM.SUB_PARA_CODE|| SPM.SUB_PARA_CATEGORY = IN_PARACC;
    RETURN V_RET_VAL;
  END GET_CLAIM_COUNT_FOR_PARA;

  --#ver4.6
  PROCEDURE GET_NOMINATION_DETAILS_FOR_SC(
	IN_UAN IN NUMBER,
	OUT_HAVING_NOMINATION_FAMILY OUT VARCHAR2,
	OUT_NOMINATION_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE,
	OUT_ERROR_MESSAGE OUT VARCHAR2
)
AS
	V_NOMINATION_ID NUMBER;
	V_EPS_FAMILY_MEM_COUNT NUMBER(2,0);	
BEGIN
	SELECT 
		MAX(NOMINATION_ID) 
	INTO 
		V_NOMINATION_ID 
	FROM 
		MEMBER_NOMINATION_DETAILS
	WHERE 
		UAN = IN_UAN AND 
		STATUS = 'E'
	;

	IF V_NOMINATION_ID IS NULL THEN
		OUT_ERROR_MESSAGE:= 'e-Signed nomination not found';
		GOTO EXIT_PROC;
	END IF;

	SELECT
		COUNT(1)
	INTO
		V_EPS_FAMILY_MEM_COUNT
	FROM
		MEMBER_NOMINATION_DETAILS MND
	INNER JOIN MEM_NOMINATION_FAMILY_DETAILS MNFD
		ON MND.NOMINATION_ID = MNFD.NOMINATION_ID
	WHERE
		MND.NOMINATION_ID = V_NOMINATION_ID
		AND MNFD.NOMINATION_TYPE = 'B'
	;

	IF V_EPS_FAMILY_MEM_COUNT > 0 THEN
		OUT_HAVING_NOMINATION_FAMILY := 'Y';
	ELSE
		OUT_HAVING_NOMINATION_FAMILY := 'N';
	END IF;
	<<EXIT_PROC>>
	IF OUT_ERROR_MESSAGE IS NULL THEN
		OPEN OUT_NOMINATION_DETAILS FOR
			SELECT			
				MNFD.NOMINEE_NAME,
				TO_CHAR(MNFD.NOMINEE_DOB,'DD/MM/YYYY') AS NOMINEE_DOB,
				CASE 
					WHEN MND.HAVING_FAMILY = 'Y' THEN
						PKG_MEMBER_NOMINATION.GET_RELATION_STR(MND.GENDER,MNFD.NOMINEE_RELATION)
					WHEN MND.HAVING_FAMILY = 'N' THEN
						MNFD.NOMINEE_RELATION_OTHER
					ELSE
						'Not Availsble'
				END AS NOMINEE_RELATION,
				NVL(MNFD.GUARDIAN_NAME,'NA') GUARDIAN_NAME,
				NVL(MNFD.GUARDIAN_RELATION,'NA') GUARDIAN_RELATION
			FROM
				MEMBER_NOMINATION_DETAILS MND
			INNER JOIN MEM_NOMINATION_FAMILY_DETAILS MNFD
				ON MND.NOMINATION_ID = MNFD.NOMINATION_ID
			WHERE
				MND.NOMINATION_ID = V_NOMINATION_ID
				AND MNFD.NOMINATION_TYPE IN ('B','S')
			;
	ELSE
		OPEN OUT_NOMINATION_DETAILS FOR
			SELECT 1 FROM DUAL;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		OUT_ERROR_MESSAGE := 'Error while fetching nomination details: '||SQLERRM;
		OPEN OUT_NOMINATION_DETAILS FOR
			SELECT 1 FROM DUAL;
END GET_NOMINATION_DETAILS_FOR_SC;


  --#ver4.6
  PROCEDURE VALIDATE_FORM_10C(
    IN_UAN IN NUMBER,
    IN_MEMBER_ID IN VARCHAR2,
    IN_CLAIM_TYPE IN VARCHAR2,
    IN_APPLICATION_FOR IN VARCHAR2,
    OUT_MESSAGE OUT VARCHAR2
  )
  AS
    V_MIN_DOJ_EPS DATE;
    V_LATEST_DOE_EPS DATE;
    V_LATEST_DOJ_EPS DATE;
    V_REASON_OF_LEAVING NUMBER(2);
    V_LATEST_MEMID VARCHAR2(24);
    V_EXM VARCHAR2(1);

    V_NOMINATION_COUNT NUMBER:=0;
    V_NOMINEE_PHOTO_COUNT NUMBER:=0;
    V_MEMBER_PHOTO_COUNT NUMBER:=0;
    V_PHOTO_CNT NUMBER(2):= 0;
    V_MAX_NOMINATION_ID NUMBER(12);
    V_NOMINATION_PDF_EXISTS CHAR(1);

    V_TOTAL_SERVICE NUMBER;
    V_10C_COUNT NUMBER(2,0);
    V_VERIFIED_AADHAAR_COUNT NUMBER(1,0);
    V_DOE_EPS DATE:=NULL; --#ver4.12
  BEGIN
    IF IN_CLAIM_TYPE = '04' THEN
      --VALID CLAIM TYPE
      --COMMON VALIDATIONS
--      V_LATEST_MEMID:=LAST_MID(IN_UAN);

      -- CHECK WHETHER EST IS EXEMPTED IN PENSION OR NOT
      SELECT DISTINCT NVL(PENSION_EXEMPTED,'N') INTO V_EXM FROM ESTABLISHMENT WHERE EST_ID=SUBSTR(IN_MEMBER_ID,0,15);
      IF V_EXM<>'N' THEN
        OUT_MESSAGE := 'AS YOUR ESTABLISHMENT IS EXEMPTED IN PENSION, PLEASE SUBMIT YOUR WITHDRAWAL CASE TO CONCERNED TRUST. -'||IN_APPLICATION_FOR;  --#ver4.35
        GOTO EXIT_PROC;
      END IF;

      --VALIDATE SERVICE DETAILS		
      SELECT DOJ_EPS, DOE_EPS, REASON_OF_LEAVING INTO V_LATEST_DOJ_EPS, V_LATEST_DOE_EPS, V_REASON_OF_LEAVING FROM MEMBER WHERE MEMBER_ID = IN_MEMBER_ID AND EST_SLNO <> 0;  --#ver4.14

      IF V_LATEST_DOJ_EPS IS NULL THEN
        OUT_MESSAGE :='DATE OF JOINING EPS IS NOT AVAILABLE. -'||IN_APPLICATION_FOR; --#ver4.35
        GOTO EXIT_PROC;
      END IF;

      IF V_LATEST_DOE_EPS IS NULL THEN
        OUT_MESSAGE :='REASON OF LEAVING EPS IS NOT AVAILABLE. -'||IN_APPLICATION_FOR; --#ver4.35
        GOTO EXIT_PROC;
      END IF;

      IF V_REASON_OF_LEAVING IS NULL THEN
        OUT_MESSAGE :='REASON OF LEAVING EPS IS NOT AVAILABLE. -'||IN_APPLICATION_FOR; --#ver4.35
        GOTO EXIT_PROC;
      END IF;

      --VALIDATE 2 MONTHS WAITING PERIOD
      IF (MONTHS_BETWEEN(SYSDATE,V_LATEST_DOE_EPS) <=2 AND 55 > GET_MEMBER_AGE(IN_UAN)) THEN
        OUT_MESSAGE :='DATE OF LEAVING EPS IS LESS THAN 2 MONTHS FROM TODAY. -'||IN_APPLICATION_FOR; --#ver4.35
        GOTO EXIT_PROC;
      END IF;

      --VALIDATE APPLICATION TYPE-WISE
      IF IN_APPLICATION_FOR = 'WB' THEN--WB=WITHDRAWAL BENEFIT
      V_LATEST_MEMID:= LAST_MID(IN_UAN);	  --#ver4.37
        --VALIDATE FOR WITHDRAWAL BENEFIT

        --VALIDATE TOTAL SERVICE
--        SELECT MIN(DOJ_EPS) INTO V_MIN_DOJ_EPS FROM MEMBER WHERE UAN=IN_UAN AND DOJ_EPS IS NOT NULL AND EST_SLNO <> 0;  --#ver4.14 --commented bcoz not needed


	--#ver4.12
--	SELECT ADD_MONTHS(DOB, 696) INTO V_DOE_EPS FROM UAN_REPOSITORY WHERE UAN=IN_UAN;
--	IF V_DOE_EPS IS NOT NULL AND V_LATEST_DOE_EPS < V_DOE_EPS THEN
--		V_DOE_EPS := V_LATEST_DOE_EPS;
--	END IF;

	  -- #ver4.37
--       SELECT
--          COUNT(1) 
--       INTO
--          V_10C_COUNT
--        FROM
--          OCS_CLAIM_DATA OCD
--        INNER JOIN OCS_CRD OCRD
--          ON OCD.TRACKING_ID = OCRD.TRACKING_ID
--        WHERE
--          OCD.UAN = IN_UAN AND
--          OCD.MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22) AND
--          OCD.CLAIM_FORM_TYPE = '04' AND
--          OCRD.CLAIM_STATUS = 5 AND 
--          NVL(OCD.FORM_10C_APPLICATION_TYPE,'WB') = 'WB';
    -- Yash Patidar Edits Here validate_10c
        SELECT
          COUNT(1) 
        INTO 
          V_10C_COUNT
        FROM 
          UNIFIED_PORTAL.CEN_OCS_FORM_10_C
        WHERE
          UAN = IN_UAN
          AND MEMBER_ID = SUBSTR(V_LATEST_MEMID,0,22)
          AND CLAIM_FORM_TYPE = '04'
          AND CLAIM_STATUS IN ('N','P','E');


        IF(V_10C_COUNT > 0) THEN
            OUT_MESSAGE :='PENSION WITHDRAWAL BENEFIT CLAIM IS ALREADY SETTLED.';
--        ELSIF(V_NEW_10C_COUNT > 0) THEN
--            OUT_MESSAGE :='PENSION WITHDRAWAL BENEFIT CLAIM IS ALREADY SETTLED.';
        ELSE   
  --        V_TOTAL_SERVICE := MONTHS_BETWEEN(NVL(V_DOE_EPS,V_LATEST_DOE_EPS),V_MIN_DOJ_EPS);
          V_TOTAL_SERVICE := CEN_OCS_UTILITY.FORM_10C_SERVICE_CALC(IN_UAN); --#ver4.34
          IF V_TOTAL_SERVICE>=6 THEN  --ADDED ON 10/01/2020 TO CHANGE AGE FROM 58 TO 55 --REF EMAIL FROM SMITA SONI TO SANDESH SIR DATED 09/01/2020
            IF V_TOTAL_SERVICE < 114 THEN
              --VALID CASE
  --            OPEN OUT_NOMINATION_DETAILS FOR SELECT * FROM DUAL WHERE 1=2;	--e-NOMINATION DATA IS NOT REQUIRED FOR THIS APPLICATION TYPE
              GOTO EXIT_PROC;
            ELSE
              OUT_MESSAGE :='TOTAL SERVICE IS GREATER THAN OR EQUAL TO 9.5 YEAR';
            END IF;
          ELSE
            OUT_MESSAGE :='TOTAL SERVICE IS LESS THAN 6 MONTHS';
          END IF;
        END IF;	    --#ver4.37
	
      ELSIF IN_APPLICATION_FOR = 'SC' THEN--SC=SCHEME CERTIFICATE
        --VALIDATE FOR SCHEME CERTIFICATE

        --VALIDATE WHETHER WITHDRAWAL BENEFIT IS ALREADY TAKEN FROM THE LATEST MEMBER_ID
--        SELECT
--          COUNT(1) 
--        INTO
--          V_10C_COUNT
--        FROM
--          OCS_CLAIM_DATA OCD
--        INNER JOIN OCS_CRD OCRD
--          ON OCD.TRACKING_ID = OCRD.TRACKING_ID
--        WHERE
--          OCD.UAN = IN_UAN AND
--          OCD.MEMBER_ID = IN_MEMBER_ID AND
--          OCD.CLAIM_FORM_TYPE = '04' AND
--          OCRD.CLAIM_STATUS = 5 
          -- AND NVL(OCD.FORM_10C_APPLICATION_TYPE,'WB') = 'WB'
--        ;
--        IF V_10C_COUNT <> 0 THEN
--          OUT_MESSAGE :='- PENSION WITHDRAWAL BENEFIT/SCHEME CERTIFICATE CLAIM IS ALREADY PROCESSED. '||IN_APPLICATION_FOR;
--          GOTO EXIT_PROC;
--        END IF;

		-- Yash Patidar Edits HERE VALIDATE WITHDRAWAL BENEFITS
		SELECT	
			COUNT(1)
		INTO 
			V_10C_COUNT
		FROM 
			CEN_OCS_FORM_10_C
		WHERE
			UAN = IN_UAN AND 
			MEMBER_ID = IN_MEMBER_ID 
			AND CLAIM_FORM_TYPE = '04' 
			AND CLAIM_STATUS IN ('N','P','E');
		
		IF V_10C_COUNT <> 0 THEN
          OUT_MESSAGE :='- PENSION WITHDRAWAL BENEFIT/SCHEME CERTIFICATE CLAIM IS ALREADY PROCESSED. '||IN_APPLICATION_FOR;
          GOTO EXIT_PROC;
        END IF;
		  
        --VALIDATE VERIFIED AADHAAR IS PRESENT OR NOT
        SELECT
          COUNT(1)
        INTO
          V_VERIFIED_AADHAAR_COUNT
        FROM
          UAN_REPOSITORY 
        WHERE
          UAN = IN_UAN AND
          AADHAAR IS NOT NULL AND
          AADHAAR_DEMO_VERIFICATION_STAT = 'S'
        ;			
        IF V_VERIFIED_AADHAAR_COUNT <> 1 THEN
          OUT_MESSAGE :='- VERIFIED AADHAAR IS NOT AVAILABLE AGAINST AN UAN. '||IN_APPLICATION_FOR;
          GOTO EXIT_PROC;
        END IF;

        --ESIGNED NOMINATION MUST BE PRESENT
--        SELECT COUNT(1) INTO V_NOMINATION_COUNT FROM MEMBER_NOMINATION_DETAILS WHERE UAN= IN_UAN AND STATUS = 'E';
        V_NOMINATION_COUNT :=CEN_OCS_UTILITY.GET_NOMINATION_COUNT(IN_UAN); --#ver4.32
        IF V_NOMINATION_COUNT = 0 THEN
          OUT_MESSAGE :='- NOMINATION DETAILS NOT AVAILABLE. '||IN_APPLICATION_FOR;
--        ELSE
--          SELECT MAX(NOMINATION_ID) INTO V_MAX_NOMINATION_ID FROM MEMBER_NOMINATION_DETAILS WHERE UAN = IN_UAN AND STATUS = 'E';
--          
--          SELECT
--            IS_VALID_PDF
--          INTO
--            V_NOMINATION_PDF_EXISTS
--          FROM
--            MEMBER_NOMINATION_DETAILS
--          WHERE
--            NOMINATION_ID = V_MAX_NOMINATION_ID;
----            V_NOMINATION_PDF_EXISTS:='N'; --ADDED FOR TESTING NEED TO REMOVE FOR PRODUCTION
--          IF V_NOMINATION_PDF_EXISTS = 'N' THEN
--            OUT_MESSAGE :='Your last e-Nomination was not successful, as your e-Sign has failed. Please e-Sign it again to proceed.';
--          END IF;
        END IF;	        
      ELSE
        --INVALID APPLICATION TYPE
        OUT_MESSAGE := 'INVALID APPLICATION TYPE FOR FORM-10C.';
      END IF;	
    ELSE
      OUT_MESSAGE := 'INVALID CLAIM TYPE FOR FORM-10C.';		
    END IF;

    <<EXIT_PROC>>
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END VALIDATE_FORM_10C;

  --#ver4.29
  PROCEDURE GET_CLAIM_DATA_FOR_10C_SC_PDF 
  (
    IN_TRACKING_ID IN OCS_CLAIM_DATA.TRACKING_ID%TYPE,
    OUT_OCS_CLAIM_DATA OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE,
    OUT_NOMINATION_DETAILS OUT COMM_TYPE_DECLARATIONS_WB.REF_CURSOR_TYPE
  )
  AS    
  BEGIN  
    OPEN OUT_OCS_CLAIM_DATA FOR
      SELECT
        OCD.UAN AS UAN,
        OCD.TRACKING_ID,
        OCD.MEMBER_ID,
        OCD.OFFICE_ID,
        TO_CHAR(OCD.RECEIPT_DATE, 'DD-MM-YYYY') AS RECEIPT_DATE,
        OCD.MEMBER_NAME,
        TO_CHAR(OCD.MEMBER_DOB, 'DD-MM-YYYY')  AS DOB,
        CASE
          WHEN OCD.MEMBER_GENDER = 'M' THEN 'Male'
          WHEN OCD.MEMBER_GENDER = 'F' THEN 'Female'			
          WHEN OCD.MEMBER_GENDER = 'T' THEN 'Transgender'			
        END AS GENDER,
        OCD.FAT_MOT_HUS_NAME,
        CASE
          WHEN OCD.MEMBER_MARITAL_STATUS = 'M' THEN 'Married'
          WHEN OCD.MEMBER_MARITAL_STATUS = 'U' THEN 'Unmarried'
          WHEN OCD.MEMBER_MARITAL_STATUS = 'W' THEN 'Widow/Widower'
          WHEN OCD.MEMBER_MARITAL_STATUS = 'D' THEN 'Divorcee'
          ELSE 'Not Provided'
        END AS MARITAL_STATUS,
        OCD.MOBILE,
        TO_CHAR(OCD.DOJ_EPF, 'DD-MM-YYYY')  AS DOJ_EPF,
        TO_CHAR(OCD.DOJ_EPS95, 'DD-MM-YYYY')  AS DOJ_EPS,
        TO_CHAR(OCD.DOE_EPF, 'DD-MM-YYYY')  AS DOE_EPF,
        TO_CHAR(OCD.DOE_EPS95, 'DD-MM-YYYY')  AS DOE_EPS,
        MER.REASON AS EXIT_REASON,
        EST.NAME AS ESTABLISHMENT_NAME,
        (OCD.MEMBER_ADDRESS1 || ',' || OCD.MEMBER_ADDRESS2 || ',' || OCD.MEMBER_CITY || ' - ' ||OCD.MEMBER_PIN) AS MEMBER_ADDRESS                
      FROM
        CEN_OCS_FORM_10_C OCD
      INNER JOIN MEMBER_EXIT_REASON MER
        ON MER.ID = OCD.REASON_OF_EXIT
      INNER JOIN ESTABLISHMENT EST
        ON EST.EST_ID = OCD.ESTABLISHMENT_ID
      WHERE
        OCD.TRACKING_ID = IN_TRACKING_ID	
      ;

    GET_NOMINEE_DETAILS_FOR_OCS(IN_TRACKING_ID, OUT_NOMINATION_DETAILS);
  END GET_CLAIM_DATA_FOR_10C_SC_PDF;

--ADDED BY KVINAYAK ON 24/11/2021
  PROCEDURE FETCH_LINKED_MEMBER_IDS_FOR_SC(
    IN_UAN IN NUMBER,
    OUT_LINKED_MEM_IDS OUT SYS_REFCURSOR
  )
  AS
  BEGIN	
    OPEN OUT_LINKED_MEM_IDS FOR
     SELECT
       MEM.ID MEM_SYS_ID,
       MEM.MEMBER_ID MEMBER_ID,
       EST.NAME EST_NAME,
       CASE 
         WHEN EST.PENSION_EXEMPTED = 'Y' THEN 1 --0 = ELIGIBLE, 1 = INELIGIBLE
         WHEN MEM.DOJ_EPS IS NULL THEN 1 -- Date of joining should be available in service history
         WHEN MEM.DOE_EPS IS NULL THEN 1 -- Date of exit should be available in service history
       ELSE 
         0 
       END ELIGIBLE,
       CASE 
         WHEN EST.PENSION_EXEMPTED = 'Y' THEN 'EXEMPTED IN PENSION. SUBMIT CLAIM TO THE CONCERNED TRUST'
         WHEN MEM.DOJ_EPS IS NULL THEN 'DATE OF JOINING(EPS) NOT AVAILABLE'            
         WHEN MEM.DOE_EPS IS NULL THEN 'DATE OF EXIT(EPS) NOT AVAILABLE'            
       ELSE 
         'ELIGIBLE'
       END ELIGIBILITY_MESSAGE
     FROM
       MEMBER MEM
         INNER JOIN ESTABLISHMENT EST
       ON MEM.EST_SLNO = EST.SL_NO
     WHERE
       MEM.UAN = IN_UAN 	
     ORDER BY
       MEM.ID
      ;   
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END FETCH_LINKED_MEMBER_IDS_FOR_SC;
  --#ver4.6
PROCEDURE GET_MEMBER_DATA(
    IN_UAN IN NUMBER,
    IN_MEMBER_ID IN VARCHAR2,
    OUT_MEMBER_DATA OUT SYS_REFCURSOR,
    OUT_MESSAGE OUT VARCHAR2,
    OUT_STATUS OUT NUMBER)
  AS
    V_COUNT NUMBER;
    V_CLAIM_COUNT NUMBER;
    V_MEM_ID VARCHAR2(22) ;
    V_PDB NUMBER;
    ---
    VV_DOJ_EPF DATE;
    VV_DOJ_EPS DATE;
    VV_DOE_EPF DATE;
    VV_DOE_EPS DATE;
    VV_ROE NUMBER;
  BEGIN
    V_COUNT    :=0;
    OUT_MESSAGE:='';
    OUT_STATUS :=0;
    V_MEM_ID:='';
    V_PDB:=0;

    SELECT COUNT(UAN) INTO V_COUNT FROM MEMBER WHERE UAN=IN_UAN AND EST_SLNO <> 0;--14-DEC-2017    --#ver4.14

    --- CHANGED HAS BEEM MADE IN BELLOW CODE TO HANDLE MULTIPLE MEMBER ID*************************************************************************************
    SELECT DOJ_EPF,DOJ_EPS,DOE_EPF,DOE_EPS,REASON_OF_LEAVING  INTO VV_DOJ_EPF,VV_DOJ_EPS,VV_DOE_EPF,VV_DOE_EPS,VV_ROE FROM MEMBER WHERE MEMBER_ID = IN_MEMBER_ID AND EST_SLNO <> 0;  --#ver4.14
      --- CHECK OFFICE IS IN PDB OR NOT
      SELECT COUNT(OFFICE_ID) INTO V_PDB FROM OCS_NO_PDB WHERE OFFICE_CODE=SUBSTR(IN_MEMBER_ID,0,5);
      IF V_PDB>0 THEN
        OUT_MESSAGE:='Your service details for '||IN_MEMBER_ID||' are in the process of being migrated to Central Portal. Please try again in a weeks time.';
        OUT_STATUS:=1;
      END IF;

      -- CHANGED HAS BEEN MADE IN BELLOW CODE TO HANDLE MULTIPLE MEMBER ID************************************************************
      OPEN OUT_MEMBER_DATA FOR SELECT
        --TRIM(UR.BANK_ACC_NO) BANK_ACC_NO,               --COMMENTED ON 14/06/2019
--        TRIM(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^0-9]', '')) BANK_ACC_NO, --ADDED ON 14/06/2019 TO OMIT EVERYTHING EXCEPT DIGITS  --ISSUE REPORTED ON WHATSAPP TO AKSHAY ON 12/06/2019  BY MS. SMITA SONI --Commented for #ver4.0
        TRIM(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^A-Za-z0-9]', '')) BANK_ACC_NO, --#ver4.0 --Guided by Harsh sir over phone
        --COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(TRIM(UR.BANK_ACC_NO))) MASKED_BANK_ACC_NO,      --ADDED BY AKSHAY ON 11/04/2019
--        COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^0-9]', ''))) MASKED_BANK_ACC_NO,      --ADDED BY AKSHAY ON 14/06/2019
        COMMON_KYC_MASK.MASKED_BANK(TO_CHAR(REGEXP_REPLACE(UR.BANK_ACC_NO ,'[^A-Za-z0-9]', ''))) MASKED_BANK_ACC_NO,      --#ver4.0
        GET_LATEST_IFSC(UR.BANK_IFSC) AS BANK_IFSC, --UR.BANK_IFSC, --#ver4.16
        B.NAME||','||B_IFSC.BRANCH AS BANK_DETAILS,
        --SAL.NAME||' '||
        UR.NAME AS NAME,
        UR.GENDER,
        UR.FATHER_OR_HUSBAND_NAME,
        UR.RELATION_WITH_MEMBER AS FATHER_OR_HUSBAND,
        TO_CHAR(UR.DOB,'DD-MON-YYYY') AS DOB,
        UR.MOBILE_NUMBER,
        COMMON_KYC_MASK.MASK_MOBILE_NUMBER(UR.MOBILE_NUMBER) AS MASKED_MOBILE_NUMBER,         --ADDED BY AKSHAY ON 11/04/2019
        UR.AADHAAR,
        COMMON_KYC_MASK.MASKED_AADHAAR(TO_CHAR(UR.AADHAAR)) AS MASKED_AADHAAR,            --ADDED BY AKSHAY ON 11/04/2019
        CASE 
        WHEN TRIM(UR.PAN) IS NOT NULL THEN
--          CASE 
--            WHEN UR.PAN_DEMO_VERIFICATION_STAT='S' THEN
--              UR.PAN 
--            ELSE
--              UR.PAN||' (PAN NOT VERIFIED)' 
--          END
          TRIM(UPPER(UR.PAN))  --#ver1.7
        ELSE 
          'N.A.' 
        END PAN,                                              -- Ver. 1.2 [ELSE '' END PAN changed to ELSE 'N.A.' END PAN] N.A.= Not Available                                                      -- Ver. 1.2 [ELSE '' END PAN changed to ELSE 'N.A.' END PAN] N.A.= Not Available
--      CASE WHEN UR.PAN IS NOT NULL THEN
      CASE 
--        WHEN UR.PAN IS NOT NULL AND PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UR.UAN,2) = UR.PAN THEN  --ADDED BY AKSHAY ON 17/05/2019
        WHEN TRIM(UR.PAN) IS NOT NULL THEN  --ADDED BY AKSHAY ON 17/05/2019
--          CASE 
--            WHEN PKG_LATEST_KYC.GET_KYC_BY_DOC_TYPE_ID(UR.UAN,2) = UR.PAN THEN
--              COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN))) 
--            ELSE
--              COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN)))||' (PAN NOT DIGITALLY SIGNED BY EMPLOYER)' 
--            END
          COMMON_KYC_MASK.MASKED_PAN(TRIM(UPPER(UR.PAN))) --#ver1.7
--      ELSE '' END PAN,
        ELSE 
          'NA' 
      END MASKED_PAN,
          MEM.MEMBER_ID,
          MEM.STATUS,
          UR.EMAIL_ID,
          TO_CHAR(MEM.DOJ_EPF,'DD-MON-YYYY') AS DOJ_EPF,
          TO_CHAR(MEM.DOJ_EPS,'DD-MON-YYYY') AS DOJ_EPS,
          TO_CHAR(MEM.DOE_EPF,'DD-MON-YYYY') AS DOE_EPF,
          TO_CHAR(MEM.DOE_EPS,'DD-MON-YYYY') AS DOE_EPS,
          -- MEM.REASON_OF_LEAVING AS LEAVE_REASON_CODE,
          DECODE(MEM.REASON_OF_LEAVING,10,7,11,8,12,9,MEM.REASON_OF_LEAVING) AS LEAVE_REASON_CODE,	--#ver4.2
          MER.REASON AS LEAVE_REASON,
          MER.REASON_CODE AS LEAVE_REASON_CHAR_CODE, --ADDED FOR 10D ON 07/05/2019
          V_COUNT AS V_COUNT,--ADDED TO HANDLE MULTIPLE MEMBER ID MESSAGE ON CLIENT SIDE 14-DEC-2017
          UR.ENCR_DOCUMENT_NO, --#ver4.13
          CASE
            WHEN (UR.BANK_VER_REF_CODE IS NOT NULL) AND (NVL(UR.BANK_ONLINE_VERIFICATION_STAT,'Y') <> 'N') THEN
                UR.BANK_VER_REF_CODE
            ELSE
                NULL
          END BANK_VER_REF_CODE --#ver4.17
          FROM UAN_REPOSITORY UR
          --LEFT JOIN SALUTATION SAL ON SAL.ID=UR.SALUTATION
          LEFT JOIN BANK_IFSC B_IFSC ON B_IFSC.IFSC_CODE=GET_LATEST_IFSC(UR.BANK_IFSC)
          LEFT JOIN BANK B ON B.ID=B_IFSC.BANK_ID
          LEFT JOIN MEMBER MEM ON MEM.UAN=UR.UAN
          LEFT JOIN MEMBER_EXIT_REASON MER ON MER.ID=MEM.REASON_OF_LEAVING 
        WHERE 
      UR.UAN = IN_UAN AND
          MEM.MEMBER_ID = IN_MEMBER_ID  AND MEM.EST_SLNO <> 0  --#ver4.14
        ;
      <<EXIT_PROC>>
      NULL;
    EXCEPTION
    WHEN OTHERS THEN
    LOG_ERROR('OCS_NEW_PACKAGE.GET_MEMBER_DATA','IN_MEMBER_ID: '||IN_MEMBER_ID||','||IN_UAN||','||OUT_MESSAGE||' ,'||SQLERRM);
      OUT_MESSAGE:='DATA NOT FOUND';
      OUT_STATUS :=1;
  END GET_MEMBER_DATA;

  /* --#ver4.8
Description : Returns total membership in months of an employee on basis of UAN
Input       : UAN 
Output      : Membership in months
ADDED ON    : 02/09/2020
*/
FUNCTION FETCH_MEMBERSHIP (	IN_UAN IN NUMBER )RETURN NUMBER
AS
  V_MEMBERSHIP NUMBER(3):=0;
  V_SETTLED_SERVICE NUMBER(3):=0;
  V_MONTHS_BETWEEN NUMBER(5) := 0;
BEGIN
/*
--1. CALCULATE TOTAL MEMBERSHIP
SELECT
  NVL(TRUNC(MONTHS_BETWEEN (CURRENT_DATE,MEM_DET.DOJ_EPF)),0)  INTO V_MEMBERSHIP
FROM
(
  SELECT
  DISTINCT
    min(MEM.DOJ_EPF) as DOJ_EPF
  FROM  
  MEMBER MEM
  WHERE MEM.UAN = IN_UAN
)MEM_DET; 
--2. CLACULATE SERVICE AGAINST WHICH CLAIM IS SETTLED             
/*           ver4.9
-- Original
select 
NVL(SUM(TRUNC(MONTHS_BETWEEN (SER_DET.DOE_EPF,SER_DET.DOJ_EPF))),0)  INTO  V_SETTLED_SERVICE
FROM
(
  SELECT
  DISTINCT
    MEM.MEMBER_ID,
    MEM.DOE_EPF AS DOE_EPF,
    MEM.DOJ_EPF
  FROM  
  MEMBER MEM
  inner JOIN
  OCS_CRD OC ON MEM.MEMBER_ID = OC.MEMBER_ID
  WHERE MEM.UAN = IN_UAN 
 AND ( CASE WHEN NVL(OC.CLAIM_FORM_TYPE,'00') = '01' AND NVL(OC.CLAIM_STATUS,0) = 5 THEN 1 ELSE 0 END)=1
 )SER_DET; 


 -- modified   ver4.9

 FOR VREC IN (	SELECT 
					DISTINCT 
						MEM.MEMBER_ID, 
						MEM.DOE_EPF AS DOE_EPF, 
						MEM.DOJ_EPF,
						NVL(OC.CLAIM_FORM_TYPE,'00') AS CLAIM_FORM_TYPE,
						NVL(OC.CLAIM_STATUS,0) AS CLAIM_STATUS
				FROM 
					MEMBER MEM 
				inner JOIN OCS_CRD OC ON 
					MEM.MEMBER_ID = OC.MEMBER_ID
				WHERE 
					MEM.UAN = IN_UAN )
LOOP
	IF VREC.CLAIM_FORM_TYPE = '01' AND VREC.CLAIM_STATUS = 5 THEN
		V_MONTHS_BETWEEN := V_MONTHS_BETWEEN + TRUNC(MONTHS_BETWEEN (VREC.DOE_EPF,VREC.DOJ_EPF));
	END IF;
END LOOP;

V_SETTLED_SERVICE := V_MONTHS_BETWEEN;

 --3. CALCULATE VALID MEMBERSHIP
V_MEMBERSHIP:= V_MEMBERSHIP - V_SETTLED_SERVICE;
*/
--#ver4.27
-- Exceptional Condition 01 -  In case all the eligible DOJ_EPF are found to be NULL then system will return ZERO due to NVL
-- Exceptional Condition 02 -  In case one/more but not all of the eligible DOJ_EPF are found to be NULL then system will consider MIN DOJ_EPF based on the remaining NOT NULL DOJ_EPF values
    SELECT
        NVL(TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), TRUNC(MIN(DOJ_EPF)))), 0) AS ELIGIBLE_MEMBERSHIP
        INTO
        V_MEMBERSHIP
    FROM
    (  
        SELECT 
            UAN,
            MEMBER_ID, 
            DOJ_EPF, 
            DOE_EPF,
            NVL(SETTLED_SERVICE,0) AS SETTLED_SERVICE,
            ROW_NUMBER() OVER (PARTITION BY MEMBER_ID ORDER BY SETTLED_SERVICE DESC) AS RN
        FROM
        (
            SELECT 
                DISTINCT
                UR.UAN			AS UAN,
                MEM.MEMBER_ID 	AS MEMBER_ID, 
                MEM.DOJ_EPF 		AS DOJ_EPF, 
                MEM.DOE_EPF 		AS DOE_EPF, 
                CASE 
                    WHEN (COF19.CLAIM_STATUS = 'S') THEN TRUNC(MONTHS_BETWEEN(TRUNC(MEM.DOE_EPF), TRUNC(MEM.DOJ_EPF)))
                    ELSE 0 
                END AS SETTLED_SERVICE  
            FROM 
            (
                SELECT 
                    AADHAAR 
                FROM 
                    UNIFIED_PORTAL.UAN_REPOSITORY
                WHERE 
                    UAN = IN_UAN 
            ) TMP
            INNER JOIN UNIFIED_PORTAL.UAN_REPOSITORY UR ON
                TMP.AADHAAR = UR.AADHAAR AND
                (UR.AADHAAR_OTP_VERIFICATION_STAT = 'S'
                OR UR.AADHAAR_DEMO_VERIFICATION_STAT = 'S'
                OR UR.AADHAAR_BIO_VERIFICATION_STAT = 'S')
            INNER JOIN UNIFIED_PORTAL.MEMBER MEM ON
                MEM.UAN = UR.UAN
            LEFT OUTER JOIN UNIFIED_PORTAL.CEN_OCS_FORM_19 COF19 ON 
                COF19.MEMBER_ID = MEM.MEMBER_ID AND 
                COF19.CLAIM_FORM_TYPE = '01'
        )
    )
    WHERE 
        RN = 1
        AND SETTLED_SERVICE = 0;

  RETURN V_MEMBERSHIP;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN V_MEMBERSHIP;

END FETCH_MEMBERSHIP;

/*  --#ver4.8
DESCRIPTION : TO ALLOW ONLY ONE ADVANCE FOR PARA 68N (Purchase of Handicap equipment) FOR 3 YEARS
INPUT       : UAN
OUTPUT      : NO OF CLIAMS SUBMITED UNDER PARA 68N
ADDED ON    : 02/09/2020
*/
FUNCTION COUNT_PARA68N_ADVNCE_IN_3YEARS (
	IN_UAN IN NUMBER
)
RETURN NUMBER
AS
  V_TOTAL_68N_CLAIMS NUMBER(2):=0;
BEGIN	
	SELECT
		COUNT(1)
	INTO
		V_TOTAL_68N_CLAIMS
	FROM
        CEN_OCS_FORM_31 COF31
--		OCS_CLAIM_DATA OCD
--	INNER JOIN OCS_CRD OCRD
--		ON OCD.TRACKING_ID = OCRD.TRACKING_ID
	WHERE
		COF31.UAN = IN_UAN			
		AND COF31.CLAIM_STATUS NOT IN ('R') --#ver4.16
		AND COF31.CLAIM_FORM_TYPE = '06'
		AND COF31.PARA_CODE = '10'
		AND COF31.SUB_PARA_CODE = '15'
		AND COF31.SUB_PARA_CATEGORY = '-'
    AND CASE WHEN COF31.CLAIM_STATUS = 'S' THEN 0 ELSE 1 END = 1
    AND COF31.RECEIPT_DATE >= TRUNC(SYSDATE) - interval '3' year
    ;
	RETURN 	V_TOTAL_68N_CLAIMS;
END COUNT_PARA68N_ADVNCE_IN_3YEARS;

 FUNCTION COUNT_PARA68B1_CLAIMS(                --#ver4.8
    IN_UAN IN NUMBER,
	IN_PARACC IN VARCHAR2
)RETURN NUMBER AS
	V_RET_VAL NUMBER := 0;
	V_FORM_TYPE VARCHAR2(10) := '06';
  BEGIN
  IF IN_PARACC IN( '25-' ,'23-','27-') OR IN_PARACC is null  THEN 

	SELECT
		COUNT(COF.TRACKING_ID) count
	INTO 
		V_RET_VAL
	FROM
		(
			SELECT
				COF31.CLAIM_FORM_TYPE,
				COF31.PARA_CODE,
				COF31.SUB_PARA_CODE,
				COF31.SUB_PARA_CATEGORY,
				COF31.OFFICE_ID,
                COF31.TRACKING_ID
			FROM
               CEN_OCS_FORM_31 COF31
--				ocs_claim_data ocd
--			INNER JOIN 
--				ocs_crd ocrd 
--			ON 
--				ocd.tracking_id = ocrd.tracking_id
			WHERE
				COF31.CLAIM_FORM_TYPE = V_FORM_TYPE   
				AND COF31.UAN = IN_UAN
			--	AND ocrd.claim_status  in (5)   --#ver4.15
				AND COF31.CLAIM_STATUS NOT IN ('R') --#ver4.15 --#ver4.16
				AND CASE WHEN COF31.CLAIM_STATUS = 'S' THEN 0 ELSE 1 END = 1 
		) COF
		RIGHT JOIN 
			SCHEME_PARA_MASTER SPM 
		ON 
			SPM.FORM_TYPE = COF.CLAIM_FORM_TYPE
		AND 
			SPM.PARA_CODE = COF.PARA_CODE
		AND 
			SPM.SUB_PARA_CODE = COF.SUB_PARA_CODE
		AND 
			SPM.SUB_PARA_CATEGORY = DECODE(COF.SUB_PARA_CATEGORY, '0', '-', COF.SUB_PARA_CATEGORY)
	WHERE 
		SPM.PARA_CODE|| SPM.SUB_PARA_CODE|| SPM.SUB_PARA_CATEGORY IN ( '25-' ,'23-' ,'24-','27-');

  ELSIF IN_PARACC = '24-' THEN 
--  else
  SELECT 
    CASE WHEN PARA_CC IN('23-','25-','27-') AND VCOUNT >= 1   THEN VCOUNT
    WHEN PARA_CC = '24-' AND VCOUNT > 1 THEN VCOUNT
         WHEN PARA_CC = '24-' AND VCOUNT = 1 THEN 0
         ELSE 0 END 
    INTO V_RET_VAL 
    FROM 
    (SELECT
		COUNT(COF.TRACKING_ID) AS VCOUNT,
    COF.para_code|| COF.sub_para_code|| COF.SUB_PARA_CATEGORY AS PARA_CC
	FROM
		(
			SELECT
				COF31.CLAIM_FORM_TYPE,
				COF31.PARA_CODE,
				COF31.SUB_PARA_CODE,
				COF31.SUB_PARA_CATEGORY,
				COF31.OFFICE_ID,
                COF31.TRACKING_ID
			FROM
                CEN_OCS_FORM_31 COF31
--				ocs_claim_data ocd
--			INNER JOIN 
--				ocs_crd ocrd 
--			ON 
--				ocd.tracking_id = ocrd.tracking_id
			WHERE
				COF31.CLAIM_FORM_TYPE = V_FORM_TYPE   
				AND COF31.UAN = IN_UAN
			--	AND ocrd.claim_status in (5)   --#ver4.15
				AND COF31.CLAIM_STATUS NOT IN ('R') --#ver4.15 --#ver4.16
				AND CASE WHEN COF31.CLAIM_STATUS = 'S' THEN 0 ELSE 1 END = 1 
		) COF
		RIGHT JOIN 
			SCHEME_PARA_MASTER SPM 
		ON 
			SPM.FORM_TYPE = COF.CLAIM_FORM_TYPE
		AND 
			SPM.PARA_CODE = COF.PARA_CODE
		AND 
			SPM.SUB_PARA_CODE = COF.SUB_PARA_CODE
		AND 
			SPM.SUB_PARA_CATEGORY = DECODE(COF.SUB_PARA_CATEGORY, '0', '-', COF.SUB_PARA_CATEGORY)
	WHERE 
		COF.PARA_CODE|| COF.SUB_PARA_CODE|| COF.SUB_PARA_CATEGORY IN ( '25-' ,'23-', '24-','27-') 
    GROUP BY COF.PARA_CODE|| COF.SUB_PARA_CODE|| COF.SUB_PARA_CATEGORY );

  END IF;
    RETURN V_RET_VAL;
END COUNT_PARA68B1_CLAIMS;  

/*  --#ver4.8
DESCRIPTION : TO ALLOW ONLY ONE ADVANCE FOR PARA 68B7 (Additions / Alterations of House) FOR 10 YEARS
INPUT       : UAN
OUTPUT      : NO OF CLIAMS SUBMITED UNDER PARA 687
ADDED ON    : 05/10/2020
*/
FUNCTION COUNT_PARA68B7_ADVNCE (
	IN_UAN IN NUMBER
)
RETURN NUMBER
AS
  V_TOTAL_68N_CLAIMS NUMBER(2):=0;
BEGIN	
	SELECT
--		case when COUNT(1) = 1 then 0 else  COUNT(1) end 
COUNT(1)
	INTO
		V_TOTAL_68N_CLAIMS
	FROM
        CEN_OCS_FORM_31 COF31
--		OCS_CLAIM_DATA OCD
--	INNER JOIN OCS_CRD OCRD
--		ON OCD.TRACKING_ID = OCRD.TRACKING_ID
	WHERE
		COF31.UAN = IN_UAN			
		AND COF31.CLAIM_STATUS NOT IN ('R') --#ver4.16
		AND COF31.CLAIM_FORM_TYPE = '06'
		AND COF31.PARA_CODE = '2'
		AND COF31.SUB_PARA_CODE = '6'
		AND COF31.SUB_PARA_CATEGORY = '-'
    AND CASE WHEN COF31.CLAIM_STATUS = 'S' THEN 0 ELSE 1 END = 1
    AND COF31.RECEIPT_DATE >= TRUNC(SYSDATE) - interval '10' year
    ;
	RETURN 	V_TOTAL_68N_CLAIMS;
  end COUNT_PARA68B7_ADVNCE ;

   FUNCTION GET_CLAIM_COUNT_FOR_68K( --#ver4.8
    IN_UAN IN NUMBER
)
RETURN NUMBER AS
	V_RET_VAL NUMBER := 0;
	V_FORM_TYPE VARCHAR2(10) := '06';
  BEGIN
	SELECT
		COUNT(COF.OFFICE_ID) COUNT
	INTO 
		V_RET_VAL
	FROM
		(
			SELECT
				COF31.CLAIM_FORM_TYPE,
				COF31.PARA_CODE,
				COF31.SUB_PARA_CODE,
				COF31.SUB_PARA_CATEGORY,
				COF31.OFFICE_ID
			FROM
                CEN_OCS_FORM_31 COF31
--				ocs_claim_data ocd
--			INNER JOIN 
--				ocs_crd ocrd 
--			ON 
--				ocd.tracking_id = ocrd.tracking_id
			WHERE
				COF31.UAN = IN_UAN   
				AND COF31.CLAIM_FORM_TYPE = V_FORM_TYPE
				AND COF31.CLAIM_STATUS  NOT IN ('R') --#ver4.16
				AND CASE WHEN COF31.CLAIM_STATUS = 'S' THEN 0 ELSE 1 END = 1 --#ver4.15
		) COF
		RIGHT JOIN 
			SCHEME_PARA_MASTER SPM 
		ON 
			SPM.FORM_TYPE = COF.CLAIM_FORM_TYPE
		AND 
			SPM.PARA_CODE = COF.PARA_CODE
		AND 
			SPM.SUB_PARA_CODE = COF.SUB_PARA_CODE
		AND 
			SPM.SUB_PARA_CATEGORY = DECODE(COF.SUB_PARA_CATEGORY, '0', '-', COF.SUB_PARA_CATEGORY)
	WHERE 
		SPM.PARA_CODE|| SPM.SUB_PARA_CODE|| SPM.SUB_PARA_CATEGORY IN ('612E','612M');
    RETURN V_RET_VAL;
  END GET_CLAIM_COUNT_FOR_68K;

   PROCEDURE GET_PARA68M_MAX_AMOUNT  --#ver4.8
    (
    OUT_MAX_AMOUNT OUT VARCHAR2
    )AS
    BEGIN 
      SELECT 
      MAX_AMOUNT INTO OUT_MAX_AMOUNT
      FROM SCHEME_PARA_MASTER SPM 
		WHERE 
			SPM.FORM_TYPE = '06'
		AND 
			SPM.PARA_CODE = '9'
		AND 
			SPM.SUB_PARA_CODE = '14'
		AND 
			SPM.SUB_PARA_CATEGORY = '-';

  EXCEPTION WHEN OTHERS THEN  
  OUT_MAX_AMOUNT:=0;
  END GET_PARA68M_MAX_AMOUNT;
  
PROCEDURE CEN_CHECK_NON_EKYC_CLAIM(
        IN_UAN IN NUMBER,
        OUT_NON_EKYC_COUNT OUT NUMBER
)
AS
BEGIN
SELECT SUM(COUNT) INTO OUT_NON_EKYC_COUNT
FROM (
       SELECT 
              COUNT(COF19.TRACKING_ID) COUNT
        FROM
                CEN_OCS_FORM_19 COF19
        WHERE
                COF19.UAN = IN_UAN
            AND COF19.CLAIM_STATUS IN ('N','P','E')       
            AND COF19.EKYC_STATUS='N'
            AND COF19.CLAIM_SOURCE_FLAG='EE'
            AND COF19.CLAIM_MODE<>'P'
  UNION ALL
        SELECT 
              COUNT(COF31.TRACKING_ID) COUNT
        FROM
                CEN_OCS_FORM_31 COF31
        WHERE
                COF31.UAN = IN_UAN
            AND COF31.CLAIM_STATUS IN ('N','P','E')       
            AND COF31.EKYC_STATUS='N'
            AND COF31.CLAIM_SOURCE_FLAG='EE'  
            AND COF31.CLAIM_MODE<>'P'
);
END CEN_CHECK_NON_EKYC_CLAIM;

PROCEDURE CEN_DELETE_NON_EKYC_CLAIM(
        IN_UAN IN NUMBER,
        OUT_MESSAGE OUT VARCHAR2
)AS
        V_COUNT NUMBER :=0;
        CLAIM_FORM_TYPE VARCHAR2(2) :='';
  CURSOR NON_EKYC_CLAIMS_CUR(IN_UAN_CUR NUMBER)
        IS
        SELECT 
              COF19.TRACKING_ID,COF19.CLAIM_FORM_TYPE 
        FROM
              CEN_OCS_FORM_19 COF19
        WHERE
                COF19.UAN = IN_UAN
            AND COF19.CLAIM_STATUS IN ('N','P','E')       
            AND COF19.EKYC_STATUS='N'
            AND COF19.CLAIM_SOURCE_FLAG='EE'
            AND COF19.CLAIM_MODE<>'P'
  UNION ALL
        SELECT 
              COF31.TRACKING_ID,COF31.CLAIM_FORM_TYPE 
        FROM
              CEN_OCS_FORM_31 COF31
        WHERE
                COF31.UAN = IN_UAN
            AND COF31.CLAIM_STATUS IN ('N','P','E')       
            AND COF31.EKYC_STATUS='N'
            AND COF31.CLAIM_SOURCE_FLAG='EE'
            AND COF31.CLAIM_MODE<>'P';   
BEGIN

        FOR V_REC IN NON_EKYC_CLAIMS_CUR(IN_UAN)
        LOOP
                V_COUNT := 0;
        IF V_REC.CLAIM_FORM_TYPE = '01' THEN
        
                INSERT INTO CEN_OCS_FORM_19_REJ_LOG (
                SELECT COF19.*, SYSTIMESTAMP AS REJCTION_TIMESTAMP FROM CEN_OCS_FORM_19 COF19 WHERE TRACKING_ID=V_REC.TRACKING_ID); 
        
                DELETE CEN_OCS_FORM_19_UIDAI_RESPONSE WHERE TRACKING_ID=V_REC.TRACKING_ID;
               
                DELETE CEN_OCS_FORM_19_LOG WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;
                DELETE CEN_OCS_FORM_19 WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;
                IF V_COUNT = 2 THEN
                        COMMIT;
                ELSE
                        ROLLBACK;
                END IF;
         ELSIF V_REC.CLAIM_FORM_TYPE = '06' THEN
         
                INSERT INTO CEN_OCS_FORM_31_REJ_LOG (
                SELECT COF31.*, SYSTIMESTAMP AS REJCTION_TIMESTAMP FROM CEN_OCS_FORM_31 COF31 WHERE TRACKING_ID=V_REC.TRACKING_ID);
         
                DELETE CEN_OCS_FORM_31_UIDAI_RESPONSE WHERE TRACKING_ID=V_REC.TRACKING_ID;
               
                DELETE CEN_OCS_FORM_31_LOG WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;
                DELETE CEN_OCS_FORM_31 WHERE TRACKING_ID=V_REC.TRACKING_ID;
                IF SQL%ROWCOUNT  =1 THEN
                        V_COUNT:=V_COUNT+1;
                END IF;
                IF V_COUNT = 2 THEN
                        COMMIT;
                ELSE
                        ROLLBACK;
                END IF;  
        END IF;
        END LOOP;
        IF V_COUNT = 2 THEN
                OUT_MESSAGE := '0#~#Pending claim(s) deleted successfully.';
        ELSE
                OUT_MESSAGE := '1#~#Failed to delete pending claim(s).';
        END IF; 
EXCEPTION
        WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END CEN_DELETE_NON_EKYC_CLAIM;

PROCEDURE GET_CRITERIA(
        IN_AMOUNT IN NUMBER,
        IN_CLAIM_FORM_TYPE IN VARCHAR2,
        OUT_CRITERIA_ID OUT NUMBER,
        OUT_CRITERIA_FLOW_ID OUT NUMBER
)
AS
  BEGIN
      CASE IN_CLAIM_FORM_TYPE
          WHEN '06' THEN
              IF IN_AMOUNT > 0 AND IN_AMOUNT <= 50000 THEN
--                SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'PF ADVANCE'
--                             AND DESCRIPTION = 'UPTO 50000';
				
				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF ADVANCE'
				  AND DESCRIPTION = 'UPTO 50000'
				  AND OBSOLETE = 'N';
				  
              ELSIF
                IN_AMOUNT > 50000 AND IN_AMOUNT <= 500000 THEN
--                SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'PF ADVANCE'
--                             AND DESCRIPTION = '50000 TO 500000';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF ADVANCE'
				  AND DESCRIPTION = '50000 TO 500000'
				  AND OBSOLETE = 'N';

               ELSIF
                 IN_AMOUNT > 500000 AND IN_AMOUNT <= 2500000 THEN
--                 SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                     FROM FO_AUTH_PROCESS_CRITERIA
--                         WHERE 
--                             PROCESS_NAME = 'PF ADVANCE'
--                             AND DESCRIPTION = '500000 TO 2500000';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF ADVANCE'
				  AND DESCRIPTION = '500000 TO 2500000'
				  AND OBSOLETE = 'N';

               ELSIF
                 IN_AMOUNT > 2500000 AND IN_AMOUNT <= 999999999 THEN
--                 SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                     FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'PF ADVANCE'
--                             AND DESCRIPTION = '2500000 TO 999999999';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF ADVANCE'
				  AND DESCRIPTION = '2500000 TO 999999999'
				  AND OBSOLETE = 'N';

              END IF;
         WHEN '01' THEN
              IF IN_AMOUNT > 0 AND IN_AMOUNT <= 50000 THEN
--                 SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                            PROCESS_NAME = 'PF FINAL SETTLEMENT'
--                            AND DESCRIPTION = 'UPTO 50000';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF FINAL SETTLEMENT'
				  AND DESCRIPTION = 'UPTO 50000'
				  AND OBSOLETE = 'N';

              ELSIF
                IN_AMOUNT > 50000 AND IN_AMOUNT <= 500000 THEN
--                SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'PF FINAL SETTLEMENT'
--                             AND DESCRIPTION = '50000 TO 500000';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF FINAL SETTLEMENT'
				  AND DESCRIPTION = '50000 TO 500000'
				  AND OBSOLETE = 'N';

               ELSIF
                 IN_AMOUNT > 500000 AND IN_AMOUNT <= 2500000 THEN
--                 SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'PF FINAL SETTLEMENT'
--                             AND DESCRIPTION = '500000 TO 2500000';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF FINAL SETTLEMENT'
				  AND DESCRIPTION = '500000 TO 2500000'
				  AND OBSOLETE = 'N';

               ELSIF
                 IN_AMOUNT > 2500000 AND IN_AMOUNT <= 999999999 THEN
--                 SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'PF FINAL SETTLEMENT'
--                             AND DESCRIPTION = '2500000 TO 999999999';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'PF FINAL SETTLEMENT'
				  AND DESCRIPTION = '2500000 TO 999999999'
				  AND OBSOLETE = 'N';

              END IF;
          WHEN '05' THEN
              IF IN_AMOUNT > 0 AND IN_AMOUNT <= 50000 THEN
--                 SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                            PROCESS_NAME = 'TRANSFER CLAIM'
--                            AND DESCRIPTION = 'UPTO 50000';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'TRANSFER CLAIM'
				  AND DESCRIPTION = 'UPTO 50000'
				  AND OBSOLETE = 'N';

              ELSIF
                IN_AMOUNT > 50000 AND IN_AMOUNT <= 999999999 THEN
--                SELECT CRITERIA_ID INTO OUT_CRITERIA_ID
--                    FROM FO_AUTH_PROCESS_CRITERIA
--                        WHERE 
--                             PROCESS_NAME = 'TRANSFER CLAIM'
--                             AND DESCRIPTION = '50000 TO 999999999';

				SELECT DISTINCT
				  FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
				INTO
				  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
				FROM 
				  FO_AUTH_PROCESS_CRITERIA FAPC
				INNER JOIN 
				  FO_AUTH_PROCESS_FLOW FAPF
				ON
				  FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
				WHERE 
				  UPPER(FAPC.PROCESS_NAME) = 'TRANSFER CLAIM'
				  AND DESCRIPTION = '50000 TO 999999999'
				  AND OBSOLETE = 'N';
  
              END IF;
          WHEN '04' THEN
            SELECT DISTINCT
              FAPF.CRITERIA_ID, FAPF.CRITERIA_FLOW_ID
			INTO
			  OUT_CRITERIA_ID, OUT_CRITERIA_FLOW_ID
            FROM
              FO_AUTH_PROCESS_CRITERIA FAPC
            INNER JOIN 
              FO_AUTH_PROCESS_FLOW FAPF
            ON
              FAPC.CRITERIA_ID = FAPF.CRITERIA_ID
            WHERE 
              UPPER(FAPC.PROCESS_NAME)= 'WITHDRAWAL BENEFIT'
              AND OBSOLETE = 'N'; 
              
         END CASE;
         EXCEPTION
                WHEN OTHERS THEN
                  RAISE;    
END GET_CRITERIA;

END CEN_OCS_NEW_PACKAGE;