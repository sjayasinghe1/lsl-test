CREATE OR REPLACE PROCEDURE create_rejected_lines (p_data IN BLOB, p_msg OUT varchar2)
AS
l_msg         varchar2(1000);
BEGIN
  BEGIN
   INSERT INTO REJECTED_LINE_HEADER (PurchaseRequestId, DateRequired, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email)
   SELECT PurchaseRequestId, DateRequired, StoreId, Street, City, State, PostCode, Country, ContactName, Phone, Email        
   FROM json_table(p_data format JSON , '$' COLUMNS 
   ( PurchaseRequestId VARCHAR2 PATH '$.PurchaseRequestId',    
     DateRequired VARCHAR2 PATH '$.DateRequired', 
     StoreId VARCHAR2 PATH '$.StoreId',
     Street VARCHAR2 PATH '$.Address.Street', 
     City VARCHAR2 PATH '$.Address.City', 
     State VARCHAR2 PATH '$.Address.State', 
     PostCode VARCHAR2 PATH '$.Address.PostCode', 
     Country VARCHAR2 PATH '$.Address.Country', 
     ContactName VARCHAR2 PATH '$.Address.ContactName', 
     Phone VARCHAR2 PATH '$.Address.Phone', 
     Email VARCHAR2 PATH '$.Address.Email'));
             
   INSERT INTO REJECTED_LINE_LINES (PurchaseRequestLineId, ProductId, Quantity, Unit, SupplierId, PerUnitCost, 
          PerUnitCostTax, LineTotalCost, LineTotalCostTax, PerUnitPrice, PerUnitPriceTax, PurchaseOrderId)
   SELECT  PurchaseRequestLineId, ProductId, Quantity, Unit, SupplierId, PerUnitCost, 
          PerUnitCostTax, LineTotalCost, LineTotalCostTax, PerUnitPrice, PerUnitPriceTax, PurchaseOrderId     
         FROM json_table(p_data format JSON , '$' COLUMNS 
         ( PurchaseRequestId VARCHAR2 PATH '$.PurchaseRequestId',    
           DateRequired VARCHAR2 PATH '$.DateRequired', 
           StoreId VARCHAR2 PATH '$.StoreId', 
           Street VARCHAR2 PATH '$.Address.Street', 
           City VARCHAR2 PATH '$.Address.City', 
           State VARCHAR2 PATH '$.Address.State', 
           PostCode VARCHAR2 PATH '$.Address.PostCode', 
           Country VARCHAR2 PATH '$.Address.Country', 
           ContactName VARCHAR2 PATH '$.Address.ContactName', 
           Phone VARCHAR2 PATH '$.Address.Phone', 
           Email VARCHAR2 PATH '$.Address.Email',  
         NESTED PATH '$.Lines[*]' 
         COLUMNS ( PurchaseRequestLineId VARCHAR2 PATH '$.PurchaseRequestLineId', 
                   ProductId VARCHAR2 PATH '$.ProductId',
                   Quantity VARCHAR2 PATH '$.Quantity',
                   Unit VARCHAR2 PATH '$.Unit',
                   SupplierId VARCHAR2 PATH '$.SupplierId',
                   PerUnitCost VARCHAR2 PATH '$.PerUnitCost',
                   PerUnitCostTax VARCHAR2 PATH '$.PerUnitCostTax',
                   LineTotalCost VARCHAR2 PATH '$.LineTotalCost',
                   LineTotalCostTax VARCHAR2 PATH '$.LineTotalCostTax',
                   PerUnitPrice VARCHAR2 PATH '$.PerUnitPrice',
                   PerUnitPriceTax VARCHAR2 PATH '$.PerUnitPriceTax',
                   PurchaseOrderId VARCHAR2 PATH '$.PurchaseOrderId' )));
  COMMIT;

    select 'successful operation'
    into l_msg
    from dual;

    p_msg := l_msg;    
    
EXCEPTION
  WHEN OTHERS THEN
    select 'Invalid input (e.g. if the StoreId, SupplierId, or ProductId could not be found.'
    into l_msg
    from dual;
    
    p_msg := l_msg;
    
    END;    
END;
/

BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule3.v1',
                     p_base_path      => 'lslmodule3/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'rejected line odule');             
  COMMIT;
END;
/  

BEGIN
  ords.define_template(p_module_name => 'lslmodule3.v1',
                       p_pattern     => 'rejected-lines/',
                       p_comments    => 'rejected lines template');

  COMMIT;
END;

begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule3.v1',
    p_pattern        => 'rejected-lines/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => q'[DECLARE                            
                            v_msg VARCHAR2(1000);
                            l_response  VARCHAR2(32767);                      
                           BEGIN                             
                             -- Build response.
                             create_rejected_lines(p_data => UTL_RAW.cast_to_varchar2(:body), p_msg => v_msg);
                             l_response := v_msg;
 
                             -- Output response text.
                             HTP.p(l_response);
                             
                         END;]',
    p_items_per_page => 0);

  COMMIT;
END;


--https://13.67.34.43:8443/ords/api/lslmodule3/v1/purchase-request/


SELECT * FROM PURCHASE_REQUESTS_HEADER ;

SELECT * FROM PURCHASE_REQUESTS_LINES;

{
  "PurchaseRequestId": "123",
  "DateRequired": "string",
  "StoreId": 0,
  "Address": {
    "Street": "123 Example St\nLevel 2",
    "City": "Melbourne",
    "State": "VIC",
    "PostCode": "3000",
    "Country": "Australia",
    "ContactName": "John",
    "Phone": "+613 9876 4321",
    "Email": "john@example.com"
  },
  "Lines": [
    {
      "PurchaseRequestLineId": "123",
      "ProductId": "d94c2221-4f48-4e3f-8153-89c42794ba6a",
      "Quantity": "5.4",
      "Unit": "ea",
      "SupplierId": "d94c2221-4f48-4e3f-8153-89c42794ba6a",
      "PerUnitCost": 4.55,
      "PerUnitCostTax": 0.45,
      "LineTotalCost": 4.55,
      "LineTotalCostTax": 0.45,
      "PerUnitPrice": 4.55,
      "PerUnitPriceTax": 0.45,
      "PurchaseOrderId": "321"
    }
  ]
}