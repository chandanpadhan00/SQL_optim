To optimize the provided SQL query, let's start by cleaning up the formatting and making the query easier to read and understand. Below is the optimized version of the query:

```sql
SELECT 
    DISTINCT
    CAST (STANDARD_HASH(ENTP_PRD_NM || 'ADMINISTERED DRUG PRODUCT PRESENTATION' || UOP_DESC || CONC_VALUE || B.STD_VALUE) AS VARCHAR2(255)) AS ADMN_PRES_PKEY,
    ENTP_PRD_NM,
    PRD_NM,
    PIPE_ENTP_PRD_NM,
    'ADMINISTERED DRUG PRODUCT PRESENTATION' AS PRD_CATG,
    ENTP_PRD_DESC,
    REPLACE(DS_STR, '.0', '') AS DS_STR,
    NVL(DS_STR_UOM, 'N/A') AS DS_STR_UOM,
    NVL(A.STD_VALUE, 'N/A') AS STD_DS_STR_UOM,
    ADMN_DS_FRM_CD,
    ADMN_DS_FRM_CD_DESC,
    UOP,
    UOP_DESC,
    CASE 
        WHEN C_N1 IS NOT NULL AND C_N1 <> 'N/A' AND C_N2 IS NOT NULL AND C_N2 <> 'N/A' THEN UPPER(TRIM(C_N1 || '/' || C_N2)) 
        ELSE C_N1 
    END AS CONC_VALUE,
    CASE 
        WHEN C_DI IS NOT NULL AND C_D1 <> 'N/A' AND C_D2 IS NOT NULL AND C_D2 <> 'N/A' THEN UPPER(TRIM(C_D1 || '/' || C_D2)) 
        ELSE C_N2 
    END AS CONC_UOM,
    EDF_PIPELINE_CANDIDATE_KEY,
    ROWID_OBJECT,
    ADMN_RTE_CD,
    ADMN_RTE_CD_DESC,
    LG_CD,
    PHM_PRD_DESC AS ADMN_PRD_DESC
FROM
    (SELECT
        DISTINCT
        pkg.ROWID_OBJECT,
        REPLACE(UPPER(NVL(SUBSTR(TRIM(p.PRD_NM), 1, INSTR(TRIM(p.PRD_NM), ' ') - 1), '')), '?', '') AS BRAND,
        NVL(SUBSTR(TRIM(p.PRD_NM), 1, INSTR(TRIM(p.PRD_NM), ' ') - 1), '') || ' ' ||
        CASE 
            WHEN PRSTN_STR_AL = 'N/A' THEN CONC_STR_VAL
            WHEN INSTR(PRSTN_STR_VAL, '/') > 0 THEN TRIM(SUBSTR(PRSTN_STR_VAL, 1, INSTR(PRSTN_STR_VAL, '/') - 1))
            WHEN INSTR(PRSTN_STR_VAL, 'per') > 0 THEN TRIM(SUBSTR(PRSTN_STR_VAL, 1, INSTR(PRSTN_STR_VAL, 'per') - 1))
            ELSE PRSTN_STR_VAL 
        END || ' ' || TRIM(SUBSTR(lkpdsfrm.ADMN_DS_FRM_CD_DESC, 1, INSTR(lkpdsfrm.ADMN_DS_FRM_CD_DESC, '(') - 1)) || 
        ' in ' || TRIM(SUBSTR(lkpcnt.CNTNR_TYP_CD_DESC, 1, INSTR(lkpcnt.CNTNR_TYP_CD_DESC, '(') - 1) || ' for ' || ROA.Route_of_Admin) AS ADMN_PRD_NM,
        p.PRD_NM,
        mf.UOP,
        lkpuop.UOP_DESC,
        mf.ADMN_DS_FRM_CD,
        lkpdsfrm.ADMN_DS_FRM_CD_DESC,
        S.PRSTN_STR_VAL,
        S.CONC_STR_VAL,
        CASE 
            WHEN CONC_STR_VAL <> 'N/A' THEN REGEXP_SUBSTR(REPLACE(CONC_STR_VAL, 'per', '/'), '[0-9]+(\.[0-9]+)?') 
            ELSE 'N/A' 
        END AS C_N1,
        CASE 
            WHEN CONC_STR_VAL <> 'N/A' THEN REGEXP_SUBSTR(REPLACE(CONC_STR_VAL, 'per', '/'), '[0-9]+(\.[0-9]+)?', 1, 2) 
            ELSE 'N/A' 
        END AS C_N2,
        '/' AS SEPARATOR,
        CASE 
            WHEN CONC_STR_VAL <> 'N/A' THEN REGEXP_SUBSTR(REPLACE(CONC_STR_VAL, 'per', '/'), '[a-zA-Z()]+') 
            ELSE 'N/A' 
        END AS C_D1,
        CASE 
            WHEN CONC_STR_VAL <> 'N/A' THEN REGEXP_SUBSTR(REPLACE(CONC_STR_VAL, 'per', '/'), '[a-zA-Z()]+', 1, 2) 
            ELSE 'N/A' 
        END AS C_D2,
        PRD_DESC.PHM_PRD_DESC,
        PRD_DESC.LG_CD,
        ADMN_RTE.ADMN_RTE_CD,
        lkpr.RTE_DESC,
        cnt.PKG_ITM_CNTNR_TYP_CD,
        lkpcnt.CNTNR_TYP_CD_DESC
    FROM
        PRODUCT_GXP.C_BO_PHM_PRD@DB_LNK_GXP mf
        LEFT JOIN
            (SELECT DISTINCT ENTP_PRD_NM, UPPER(TRD_NM.TRADE_NM) AS TRADE_NM 
             FROM C_BO_ENT_PRD ENT_PRD 
             INNER JOIN C_BO_TRD_NM TRD_NM ON ENT_PRD.ROWID_OBJECT = TRD_NM.ENTP_PRD_FK) TRD_NM ON M.BRAND = TRD_NM.TRADE_NM
        LEFT JOIN
            (SELECT * FROM C_L_CONFIG_STD_VALUE WHERE TYP = 'UNIT') A ON M.DS_STR_UOM = A.RAW_VALUE
        LEFT JOIN
            (SELECT * FROM C_L_CONFIG_STD_VALUE WHERE TYP = 'UNIT') B ON M.CONC_UOM = B.RAW_VALUE
        LEFT JOIN
            PRODUCT_GXP.C_BO_PHM_PRD_ADMN_RTE@DB_LNK_GXP ADMN_RTE ON MF.ROWID_OBJECT = ADMN_RTE.PHM_PRD_FK
        LEFT JOIN
            PRODUCT_GXP.C_BO_PHM_PRD_DESC@DB_LNK_GXP PRD_DESC ON MF.ROWID_OBJECT = PRD_DESC.PHM_PRD_FK
        LEFT JOIN
            PRODUCT_GXP.C_BO_PHM_PRD_ING@DB_LNK_GXP PKG_ING ON MF.ROWID_OBJECT = PKG_ING.PHM_PRD_FK
        LEFT JOIN
            PRODUCT_GXP.C_BO_ING@DB_LNK_GXP I ON I.ROWID_OBJECT = PKG_ING.ING_FK
        LEFT JOIN
            PRODUCT_GXP.C_BO_ING_SUBS@DB_LNK_GXP S ON I.SUBS_FK = S.ROWID_OBJECT
        LEFT JOIN
            PRODUCT_GXP.C_BO_MD_PRD@DB_LNK_GXP P ON MF.MD_PRD_FK = P.ROWID_OBJECT
        LEFT JOIN
            PRODUCT_GXP.C_BO_PKDMP_CNTNR@DB_LNK_GXP CNT ON PKG.ROWID_OBJECT = CNT.PKDMP_FK
        LEFT JOIN
            PRODUCT_GXP.C_BO_PKDMP@DB_LNK_GXP PKG ON P.ROWID_OBJECT = PKG.MD_PRD_FK
        LEFT JOIN
            PRODUCT_GXP.C_BT_CNTNR_TYP_CD@DB_LNK_GXP LKPCNT ON LKPCNT.CNTNR_TYP_CD = CNT.PKG_ITM_CNTNR_TYP_CD
        LEFT JOIN
            PRODUCT_GXP.C_BT_UOP@DB_LNK_GXP LKPUOP ON LKPUOP.UOP = MF.UOP
        LEFT JOIN
            PRODUCT_GXP.C_BT_ADMN_DS_FRM@DB_LNK_GXP LKPDsfrm ON LKPDsfrm.ADMN_DS_FRM_CD = MF.ADMN_DS_FRM_CD
        LEFT JOIN
            PRODUCT_GXP.C_BT_ADMN_RTE_CD@DB_LNK_GXP LKPR ON LKPR.ADMN_RTE_CD = ADMN_RTE.ADMN_RTE_CD
        LEFT JOIN
            (SELECT 
                 PHM_PRD_FK,
                 LISTAGG(SUBSTR(LKPR.RTE_DESC, 1, INSTR(LKPR.RTE_DESC, '(') - 1), ', ') 
                 WITHIN GROUP (ORDER BY SUBSTR(LKPR.RTE_DESC, 1, INSTR(LKPR.RTE_DESC, '(') - 1)) AS ROUTE_OF_ADMIN
             FROM PRODUCT_GXP.C_BO_PHM_PRD_ADMN_RTE@DB_LNK_GXP ADMN_RTE 
             INNER JOIN PRODUCT_GXP.C_BT_ADMN_RTE_CD@DB_LNK_GXP LKPR ON LKPR.ADMN_RTE_CD = ADMN_RTE.ADMN_RTE_CD 
             GROUP BY PHM_PRD_FK) ROA ON ROA.PHM_PRD_FK = ADMN_RTE.PHM_PRD_FK
    ) IDMP
LEFT JOIN
    (SELECT 
         EDF_PIPELINE_CANDIDATE_KEY, 
         PIPELINE_CANDIDATE_CODE 
     FROM C_P_L_PIPE_CND 
     WHERE EDF_PIPELINE_CANDIDATE_KEY IN ('5b682a62-52f4-451c-aad1-4ccb1736f461', '21de3684-74dd-5ae9-86bd-3d9bf984b861')) SEM 
ON REPLACE(IDMP.PIPE_ENTP_PRD_NM, ' ', '') = SEM.PIPELINE_CANDIDATE_CODE
```

In the provided query, there were several formatting issues, unnecessary subqueries, and redundant calculations. 
I have cleaned up the query to improve its readability and identified potential areas for further optimization, including cleaning up redundant subqueries and optimizing JOINs.