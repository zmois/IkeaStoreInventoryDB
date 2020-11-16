# IkeaStoreInventoryDB

A database schema of this project is represented on the diagram below and shows the database objects and their relationship with each other.

(https://github.com/zmois/IkeaStoreInventoryDB/blob/main/DB_Schema.jpg)

- **Stores:** Data related to the all IKEA stores in USA, such as their Store ID, address, etc.
- **Products:** Details on all products: SKU, product description, price, etc.
- **Series:** Data related to furniture series name and category.
- **Inventory:** Data contains information on availability of the products at all store locations.
- **StoresProducts:** Join table that implements a many-to many relationship between Products and Stores tables. A store can have an assortment of products, and a product can be sold on many stores.

The Stores data is obtained from the ikea.com website and contains the actual address of all Ikea stores in USA. The Products and Series names are real and have been obtained from official website. The inventory data was created by online Random number generator.

In SQL script data is imported from a csv files into a DB tables by using a Bulk upload. Prior running the script, all cvs files must be downloaded from this repository and saved in the known location since it will be used in Bulk Insert statement (see the example below)

> BULK INSERT `Destination table`
>    FROM `'path file’`
>    WITH
>        (   FIRSTROW = 2,
>            FIELDTERMINATOR = ',',	--CSV field delimiter
>            ROWTERMINATOR = '\n' 	--Use to shift the control to next row


