/*
==============================
CREATED DATE: 23-03-2024
CREARTED BY: Divyesh Waghmare
DESC: GET S.A.C to HUF SALES REGISTER DATA

UPDATED ON : 18-04-2024
UPDATED BY : JAY DHIMMER
DESCRIPTION : ADDED WHERE CONDITION AND REMOVED UNECESSARY PARAMETER
==============================
*/



ALTER PROCEDURE [dbo].[GetHufToCustomerPendingList]
@SortColumn       NVARCHAR(50) = 'SalesId',   
@SortOrder        NVARCHAR(4)  = 'DESC'
AS
BEGIN
	SET NOCOUNT ON;
			DECLARE @lSortCol NVARCHAR(20), @TimeZoneOffset   NVARCHAR(10) = '+05:30';  
			SET @lSortCol = LTRIM(RTRIM(@SortColumn));  

			SELECT ROW_NUMBER() OVER(  
                  ORDER BY 
                  CASE  
                      WHEN(@lSortCol = 'SalesId'  
                           AND @SortOrder = 'ASC')  
                      THEN SM.[SalesId]
                  END ASC,  
                  CASE  
                      WHEN(@lSortCol = 'SalesId'  
                           AND @SortOrder = 'DESC')  
                      THEN SM.[SalesId]
                  END DESC 
                 ) [RowNo]  
				,SM.SalesId
				,SM.CustomerId
				,SM.CompanyId
				,CU.FullName AS CustomerName
				,SM.BillNo
				,SM.SalesDate
				,PTM.[Name] AS PayType
				,IT.[Name] AS InvoiceType
				,RT.[Name] AS RegisterType
				,ISNULL(SM.RegisterNo,'-') AS RegisterNo
				,TM.[Name] AS TaxMethod
				,ISNULL(TMS.[Name],'-') AS BrokerName
				,ISNULL(ST.[Name],'-') AS StateName
				,ISNULL(SM.TotalQty,0) AS TotalQty
				,ISNULL(SM.GrossAmt,0) AS GrossAmt
				,ISNULL(SM.AddLessAmt,0) AS AddLessAmt
				,ISNULL(SM.RoundOffAmt,0) AS RoundOffAmt
				,(ISNULL(SM.GrossAmt,0) - ISNULL(SM.CGSTAmt,0) - ISNULL(SM.SGSTAmt,0)) AS TaxableAmt
				,ISNULL(SM.NetAmt,0) AS NetAmt
				,ISNULL(HCS.IsCashToCustomerSaleDone,0) As IsCashToCustomerSaleDone
				,ISNULL(HCS.IsShreeAquaCareToHUFSaleDone,0) AS IsShreeAquaCareToHUFSaleDone
				,ISNULL(HCS.IsHUFPurchaseDone,0) AS IsHUFPurchaseDone
				,ISNULL(HCS.IsHUFToCustomerSaleDone,0) AS IsHUFToCustomerSaleDone

		  FROM SalesMst AS SM  
			LEFT JOIN Customer AS CU   ON CU.CustomerId = SM.CustomerId 
			LEFT JOIN PayTypeMst AS PTM   ON PTM.PayTypeId = SM.PayTypeId
			LEFT JOIN InvoiceTypeMst AS IT   ON IT.InvoiceTypeId = SM.InvoiceTypeId
			LEFT JOIN RegisterTypeMst AS RT   ON RT.RegisterTypeId = SM.RegisterTypeId
			LEFT JOIN TaxTypeMst AS TT  ON TT.TaxTypeId = SM.TaxTypeId
			LEFT JOIN TaxMethodMst AS TM   ON TM.TaxMethodId = SM.TaxMethodId
			LEFT JOIN StateMst AS ST   ON ST.StateId = SM.StateId
			LEFT JOIN Users AS US   ON US.UserId = SM.InsertedBy
			LEFT JOIN Users AS UU   ON UU.UserId = SM.UpdatedBy
			LEFT JOIN CompanyMst AS CT   ON CT.CompanyId = SM.CompanyId
			LEFT JOIN BrokerMst AS TMS   ON TMS.BId= SM.BrokerId
			INNER JOIN HUFCycleStatus AS HCS  ON HCS.SalesId= SM.SalesId

		WHERE SM.IsHufTransaction = 1 AND
		HCS.IsHUFToCustomerSaleDone = 0
		ORDER BY [RowNo] ASC  
  END;
