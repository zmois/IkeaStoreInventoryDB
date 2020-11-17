# ReadMe

**Code Louisville SQL Project - Ikea Store Inventory Database**

A database schema of this project is represented on the diagram below and shows the database objects and their relationship with each other.

<img src="DB_Schema.png " width="250" />

- **Stores:** Data related to the all IKEA stores in USA, such as their Store ID, address, etc.
- **Products:** Details on all products: SKU, product description, price, etc.
- **Series:** Data related to furniture series name and category.
- **Inventory:** Data contains information on availability of the products at all store locations.
- **StoresProducts:** Join table that implements a many-to many relationship between Products and Stores tables. A store can have an assortment of products, and a product can be sold on many stores.

The Stores data is obtained from the <ikea.com> website and contains the actual address of all Ikea stores in USA. The Products and Series names are real and have been obtained from official website. The inventory data was created by online Random number generator.

## How to run 

The SQL script data is imported from a .csv files into a DB tables by using a Bulk upload. Prior running the script, all .cvs files must be downloaded from this repository and saved in the known location since it will be used in Bulk Insert statement (see the example below)

> BULK INSERT `Destination table`<br>
> FROM `'path file’`<br>
> WITH <br>
> (   FIRSTROW = 2,<br>
>     FIELDTERMINATOR = ',',	--CSV field delimiter<br>
>     ROWTERMINATOR = '\n' 	--Use to shift the control to next row<br>
<br>

Other option for importing a .csv files into a SQL Server database is to use Import Flat File wizard. The detailed step-by-step instructions is here. 
<a href="https://docs.microsoft.com/en-us/sql/relational-databases/import-export/import-flat-file-wizard?view=sql-server-ver15 title="Instructions">here</a>
