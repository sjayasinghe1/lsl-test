-----------------------------CASH_MANAGEMENT-----------------------------
SELECT   GCC.segment3
        ,CBA.BANK_ACCOUNT_NAME
        ,CBA.BANK_ACCOUNT_NUM
FROM 
        XLA_TRANSACTION_ENTITIES XEH, 
        XLA_AE_LINES XAL, 
        XLA_AE_HEADERS XAH, 
        GL_CODE_COMBINATIONS GCC,
        CE_CASHFLOWS CCF,
        CE_BANK_ACCOUNTS CBA,
        CE_BANK_ACCT_USES_ALL CBU,
        CE_BANKS_V CB,
        GL_IMPORT_REFERENCES GIR,
        GL_JE_LINES JEL, 
        GL_JE_HEADERS JEH,
        GL_JE_BATCHES JEB
WHERE   1 = 1
        AND XAL.LEDGER_ID = XEH.LEDGER_ID 
        AND XEH.ENTITY_ID = XAH.ENTITY_ID 
        AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID 
        AND GCC.CODE_COMBINATION_ID = XAL.CODE_COMBINATION_ID 
        AND XEH.SOURCE_ID_INT_1 = CCF.CASHFLOW_ID
        --AND XEH.ENTITY_CODE = 'CE_CASHFLOWS'
        AND CCF.CASHFLOW_BANK_ACCOUNT_ID = CBU.BANK_ACCT_USE_ID(+)
        AND CBU.BANK_ACCOUNT_ID = CBA.BANK_ACCOUNT_ID(+)
        AND CBA.BANK_ID = CB.BANK_PARTY_ID(+)
        AND XAL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
        AND JEL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
        AND GIR.JE_LINE_NUM = JEL.JE_LINE_NUM
        AND GIR.JE_HEADER_ID = JEH.JE_HEADER_ID
        AND JEH.JE_HEADER_ID = JEL.JE_HEADER_ID
        AND JEB.JE_BATCH_ID = JEH.JE_BATCH_ID
        AND GCC.segment3 is not null
        AND rownum = 1 ;