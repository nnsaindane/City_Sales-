-- 1. What is the demographic profile of the clients and how does it vary across districts ?

-- By city 

SELECT City AS District, COUNT(*) AS NumberOfBusinesses
FROM Business_info
GROUP BY City
ORDER BY NumberOfBusinesses DESC;

SELECT B.City AS District, 
       SUM(SD.Sales_Amount) AS TotalSales, 
       SUM(SD.Sales_Amount - SD.Gst_Amount) AS NetAmount, 
       SUM(0.60 * (SD.Sales_Amount - SD.Gst_Amount)) AS TotalProfit
FROM Business_info B
JOIN Sales_Data SD ON B.Business_Id = SD.Business_Id
GROUP BY B.City
ORDER BY TotalSales DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. How the Biz have performed over the years. Give their detailed analysis year & month-wise. 
    
SELECT 
    YEAR(STR_TO_DATE(Login_Date, '%Y-%m-%d')) AS Year,
    MONTH(STR_TO_DATE(Login_Date, '%Y-%m-%d')) AS Month,
    SUM((Sales_Amount)) AS TotalSales,
    SUM((Gst_Amount)) AS TotalGST,
    SUM((NetAmount)) As TotalNetAmount,
    sum((Profit)) As TotalProfit 
FROM Sales_Data
GROUP BY YEAR(STR_TO_DATE(Login_Date, '%Y-%m-%d')), MONTH(STR_TO_DATE(Login_Date, '%Y-%m-%d'))
ORDER BY Year, Month;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. What are the most common types of clients and how do they differ in terms of usage and profitability?

SELECT 
    Bc.Business_category,
    COUNT(DISTINCT Bc.Business_ID) AS NumberOfClients,
    SUM(SD.sales_Amount) AS TotalSales,
    SUM(SD.NetAmount) AS TotalNetAmount,
    SUM(SD.Profit) AS TotalProfit
FROM 
    Business_category Bc
JOIN 
    Sales_data SD ON Bc.Business_ID = SD.Business_ID
GROUP BY 
    Bc.Business_category
ORDER BY 
    COUNT(DISTINCT Bc.Business_ID) DESC
LIMIT 1000;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. Which types of product are most frequently used by the clients and what is the overall profitability of the client need?   

SELECT 
    BC.Product_Proposal,
    COUNT(*) AS Frequency,
    SUM(CAST(SD.Sales_Amount AS DECIMAL(10, 2))) AS TotalSales,
    SUM(CAST(SD.Sales_Amount AS DECIMAL(10, 2)) - CAST(SD.Gst_Amount AS DECIMAL(10, 2))) AS NetAmount,
    SUM(0.60 * (CAST(SD.Sales_Amount AS DECIMAL(10, 2)) - CAST(SD.Gst_Amount AS DECIMAL(10, 2)))) AS TotalProfit
FROM Business_Category BC
JOIN Sales_Data SD ON BC.Business_Id = SD.Business_Id
GROUP BY BC.Product_Proposal
ORDER BY Frequency DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. What are the major expenses of the Biz and how can they be reduced to improve profitability?

SELECT 
    SUM(SD.GST_amount) AS TotalExpenses
FROM 
    sales_data SD
GROUP BY 
    SD.Expenses
HAVING 
    SUM(SD.GST_amount) < 25000
ORDER BY 
    SUM(SD.GST_amount) DESC
LIMIT 0, 1000 ;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. What is the client portfolio and how does it vary across different purposes and client segments?

SELECT 
    B.Business_Name AS Business_Name,                    -- Client segment
    BC.Business_Category AS Purpose,        -- Business purpose or category
    COUNT(*) AS NumberOfTransactions,      -- Number of transactions (if applicable)
    SUM(SD.Sales_Amount) AS TotalRevenue   -- Total revenue by purpose
FROM 
    Business_info B
JOIN 
    Business_Category BC ON B.Business_Id = BC.Business_Id
JOIN 
    Sales_Data SD ON B.Business_Id = SD.Business_Id
GROUP BY 
    B.Business_Name, BC.Business_Category
ORDER BY 
    B.Business_Name, TotalRevenue DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 7. How are telecallers role in the sales.

SELECT 
    Tellercaler_name,
    COUNT(*) AS NumberOfCalls,
    SUM((SD.Sales_Amount)) AS TotalSales
FROM MEETING_DATA MD
JOIN Sales_Data SD ON MD.Business_Id = SD.Business_Id
GROUP BY Tellercalername;


SELECT 
    Tellercaler_name,
    SUM((SD.Sales_Amount)) AS TotalSales
FROM MEETING_DATA MD
JOIN Sales_Data SD ON MD.Business_Id = SD.Business_Id
GROUP BY Tellercaler_name;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8. What is BDM's indivisual performance with various segments of client. 

SELECT 
    MD.BDM_name,
    BC.Business_Category,
    SUM(SD.Sales_amount) AS TotalSales
FROM meeting_data MD
JOIN Business_info BI ON MD.Business_Id = BI.Business_Id
JOIN sales_data SD ON BI.Business_Id = SD.Business_Id
JOIN Business_Category BC ON BI.Business_Id = BC.Business_Id
WHERE MD.BDM_name IS NOT NULL AND MD.BDM_name != ''
GROUP BY 
    MD.BDM_name, 
    BC.Business_Category
ORDER BY 
    MD.BDM_name,
    SUM(SD.Sales_amount) DESC
LIMIT 1000;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9. Which is best selling prodcut and category.

SELECT 
BC.Product_Proposal,
COUNT(*) AS Frequency,
SUM((SD.Sales_Amount)) AS TotalSales
FROM Business_Category BC
JOIN Sales_Data SD ON BC.Business_Id = SD.Business_Id
GROUP BY BC.Product_Proposal
ORDER BY TotalSales DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 10. What is popular selling amount.

SELECT Product_proposal, COUNT(*) AS num_sales
FROM Business_Category
GROUP BY Product_proposal
ORDER BY num_sales DESC
LIMIT 1;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 11. retriev the business name that took services more than 5 times 

select
BI.Business_name
from Business_Info BI
join Business_Category BC on BI.Business_ID = BC.Business_ID
group by Business_name
having count(Business_Category) > 5;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 12. Find a doctor who have their own clinic

SELECT 
BI.Business_name
from Business_Info BI
join Business_Category BC on BI.Business_ID = BC.Business_ID
WHERE BC.business_subcategory = 'clinic' ;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 13. just find out city with less than 10 business meetings 

Select
	BI.City
From 
    Business_Info BI
join meeting_data MD on BI.Business_ID = MD.Business_ID
Group by
    BI.City
Having
    Count(Meeting_Date) < 10;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 14. Find the customer who have more than one businesses

Select 
    BI.Contact_Person,
    BI.Business_Name
From
    Business_Info BI
Group by
    BI.Contact_Person, BI.Business_Name
having 
    Count(Contact_Person) > 1;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    
-- 15. calculate the sales and profit ratio of only health realted business

SELECT 
    Total_Sales,
    Total_Profit,
    CASE WHEN Total_Profit = 0 THEN NULL ELSE Total_Sales / Total_Profit END AS Sales_to_Profit_Ratio
FROM (
    SELECT 
        SUM(Sales_Data.Sales_Amount) AS Total_Sales,
        SUM(Sales_Data.Sales_Amount - Sales_Data.GST_Amount) AS Total_Profit
    FROM Sales_Data
    JOIN Business_Category ON Sales_Data.Business_ID = Business_Category.Business_ID
    WHERE Business_Category.Business_subCategory = 'Health'
) AS HealthSales;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 16. calculate profit and sales based on city, year respected BDM and Tele

SELECT 
    BI.city,
    MD.BDM_name,
    MD.Tellercaler_Name,
    SUM(SD.Profit) AS total_profit,
    SUM(SD.sales_Amount) AS total_sales
FROM 
    Business_info BI
JOIN 
    meeting_data MD ON BI.Business_ID = MD.Business_ID
JOIN 
    sales_data SD ON BI.Business_ID = SD.Business_ID
GROUP BY 
    BI.city, 
    MD.BDM_name,
	MD.Tellercaler_Name;
  
    
#====================================================================================* * * * * * *====================================================================================











  
    
    

