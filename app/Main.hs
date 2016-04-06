module Main where

import MtLib

generateSupplierTable :: MtSpecificTable
generateSupplierTable = mtSpecificTableFromList
    [("S_SUPPKEY", MtSpecific)
    ,("S_NAME", MtComparable)
    ,("S_ADDRESS", MtComparable)
    ,("S_NATIONKEY", MtComparable)
    ,("S_PHONE", (MtTransformable "phoneToUniversal" "phoneFromUniversal"))
    ,("S_ACCTBAL", (MtTransformable "currencyToUniversal" "currencyFromUniversal"))
    ,("S_COMMENT", MtComparable)
    ]

-- generateCustomerTableSpec :: MtTableSpec
-- generateCustomerTableSpec = mtSpecificTableFromList
--     [
--     ]

generateTestSchema :: MtSchemaSpec
generateTestSchema = mtSchemaSpecFromList
    [("REGION", MtGlobalTable)
    ,("NATION", MtGlobalTable)
    ,("SUPPLIER", FromMtSpecificTable generateSupplierTable)
    ]

main :: IO ()
main = do
    queries <- return ["SELECT * From Emp;"
        , "SELECT name From Emp;"
        , "SELECT name from Emp WHERE age > 42;"
        ]
    schemaSpec <- return generateTestSchema
    
    -- test pretty print
    putStrLn "\nPretty Print with error looks like this:"
    putStrLn $ mtPrettyPrint $ mtParse "SELECT;" -- should print an error message
    putStrLn "\nPretty Print for normal query looks like this:"
    putStrLn $ mtPrettyPrint $ mtParse $ queries !! 0 -- should print something correct
    
    -- test parsing and rewrite
    mapM_ (\query -> do
        putStrLn $ "\n" ++ query ++ " parses to:"
        parsedQuery <- return $ mtParse query
        putStrLn $ show parsedQuery
        putStrLn $ "\n Its rewritten form is:\n  " ++ (mtPrettyPrintRewrittenQuery $ mtRewrite parsedQuery schemaSpec)
        )
        queries

    putStrLn "\n\n"