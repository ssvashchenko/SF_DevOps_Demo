CREATE TABLE MY_INVENTORY
(
    SKU VARCHAR, 
    PRICE NUMBER(9,3)
);

EXECUTE IMMEDIATE FROM './insert-inventory.sql'

--SELECT SKU, PRICE FROM MY_INVENTORY ORDER BY PRICE DESC;
