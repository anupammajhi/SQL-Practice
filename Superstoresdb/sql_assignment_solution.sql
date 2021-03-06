/*======================================= SQL Assignment =======================================*/

/* 
==================================================================================================
Task 1: Understanding the data in hand
==================================================================================================
------ A. Describe the data in hand in your own words. (Word Limit is 500)
==================================================================================================


SOLUTION:

The data here contains five tables namely market_fact, orders_dimen, prod_dimen, shipping_dimen,
and cust_dimen. All the five tales contain normalized data of sales of products and the 
information regarding each sale of the superstore.

cust_dimen:
This table contains the information of the customer irrespective of what orders he has ever
placed. Each row comprises of a unique customer. Each customer is recognized uniquely with
their customer ID (cust_id). The other verticals contain other information about them, i.e
Customer's name (customer_name), Region (region) & Province (province) where he/she lives,
and also the customer segment (customer_segment) that tells about if the customer is an end 
consumer or corporate or any other segment.

prod_dimen:
This table contains the information of each product being sold. Each product is recognized by
its unique ID (prod_id). The other information of each product is regarding its category and 
subcategory which determines the nature or type of the product.

orders_dimen
This table contains the information of each order placed. Each order might comprise of 
multiple products. This describes more of a customer’s shopping per session than what exactly 
the customer has purchased.
Each order is determined by its unique ID (ord_id). The other dimensions are order 
date (order_date), order priority (order_priority) and order ID (order_id). 
Here order_id is not same as ord_id. Ord_id is unique whereas order_id is not. 
order_id rather does not give much information with the provided data.

Shipping_dimen
This table comprises of information of shipping details. This table gives the detail of the 
shipping, which may comprise of more than one product per shipping. Each shipping is determined 
by it’s unique ID (ship_id). The other dimensions have the shipping date (ship_date) , 
shipping mode (ship_mode) and Order ID (order_id) but this order ID does not correspond to 
the ord_id in market_facts or orders_dimen.

Market_facts:
This is the largest table which comprises of each and every order placed by customers. 
This table does not have any single unique dimension. The orders are not necessarily 
separate orders, they might also contain orders which were placed in same session but have 
different products or otherwise. This table comprises of information taken from the rest of 
the tables described before, but mostly determined by the ID’s from other tables and not the 
details. For example, it gives the custumer ID who has placed the order but not the other 
customer details like name and address. This way the table remains concise and other necessary 
details like name etc can be fetched only if required by referring other tables. The referring 
dimensions are ord_id, prod_id, ship_id and cust_id.
Additionally it also has amount of sales (sales), discount on the order (discount), number of 
that product ordered in that order (order_quantity), profit made out of that order (profit), 
shipping cost for that order (shipping_cost) and the product’s base margin (product_base_margin).





    

/*
==================================================================================================
------ B. Identify and list the Primary Keys and Foreign Keys for this dataset (Hint: If a table
don’t have Primary Key or Foreign Key, then specifically mention it in your answer.)
==================================================================================================


SOLUTION:

TABLE : cust_dimen
Primary Key : cust_id
Foreign Key : No foreign key reference

TABLE : shipping_dimen
Primary Key : ship_id
Foreign Key : No foreign key reference

TABLE : order_dimen
Primary Key : ord_id
Foreign Key : No foreign key reference

TABLE : prod_dimen
Primary Key : prod_id
Foreign Key : No foreign key reference

TABLE : market_facts
Primary Key : There are no primary key that can uniquely identify any row.
Foreign Key : ord_id references ord_id of table orders_dimen
				prod_id references prod_id of table prod_dimen
                ship_id references ship_id of table shipping_dimen
                cust_id references cust_id of table cust_dimen
                
*/





/*
==================================================================================================
Task 2: Basic Analysis
==================================================================================================
Write the SQL queries for the following:
==================================================================================================
------ A. Find the total and the average sales (display total_sales and avg_sales)
==================================================================================================
*/


# SOLUTION :


SELECT SUM(Sales) as total_sales,
       AVG(Sales) as avg_sales 
FROM market_fact;




/*
==================================================================================================
------ B. Display the number of customers in each region in decreasing order of
no_of_customers. The result should contain columns Region, no_of_customers
==================================================================================================
*/

# SOLUTION : 

SELECT Region, 
       COUNT(*) as no_of_customers 
FROM cust_dimen 
GROUP BY Region 
ORDER BY no_of_customers DESC;




/*
==================================================================================================
------ C. Find the region having maximum customers (display the region name and
max(no_of_customers)
==================================================================================================
*/

# SOLUTION : 

SELECT Region, 
       COUNT(*) as no_of_customers 
FROM cust_dimen 
GROUP BY Region 
ORDER BY no_of_customers DESC 
LIMIT 1;


/*
==================================================================================================
------ D. Find the number and id of products sold in decreasing order of products sold (display
product id, no_of_products sold)
==================================================================================================
*/

# SOLUTION : 

SELECT Prod_id, 
       SUM(Order_Quantity) as no_of_products_sold 
FROM market_fact 
GROUP BY Prod_id
ORDER BY no_of_products_sold DESC;


/*
==================================================================================================
------ E. Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and
the number of tables purchased (display the customer name, no_of_tables purchased)
==================================================================================================
*/

# SOLUTION :

SELECT Customer_Name, 
       SUM(Order_quantity) as number_of_tables_purchased 
FROM cust_dimen c, market_fact m
WHERE c.Cust_id = m.Cust_id
    AND c.Region = 'Atlantic'
    AND m.Prod_id IN (SELECT Prod_id 
                     FROM prod_dimen 
                     WHERE Product_Sub_Category = 'TABLES')
GROUP BY c.cust_id;





/*
==================================================================================================
Task 3: Advanced Analysis
==================================================================================================
Write sql queries for the following:
==================================================================================================
------ A. Display the product categories in descending order of profits (display the product
category wise profits i.e. product_category, profits)?
==================================================================================================
*/

# SOLUTION :

SELECT Product_Category,SUM(Profit) as Profits 
FROM market_fact m 
    INNER JOIN prod_dimen p 
    ON m.prod_id = p.prod_id 
GROUP BY Product_Category 
ORDER BY Profits DESC;


/*
==================================================================================================
------ B. Display the product category, product sub-category and the profit within each
subcategory in three columns.
==================================================================================================
*/

# SOLUTION : 

SELECT product_category, 
       product_sub_category,
       SUM(profit) as profit 
FROM prod_dimen p 
     INNER JOIN market_fact m 
     ON p.prod_id = m.prod_id 
GROUP BY product_sub_category 
ORDER BY product_category ;



/*
==================================================================================================
------ C. Where is the least profitable product subcategory shipped the most? For the least
profitable product sub-category, display the region-wise no_of_shipments and the
profit made in each region in decreasing order of profits (i.e. region,
no_of_shipments, profit_in_each_region)
o Note: You can hardcode the name of the least profitable product subcategory
==================================================================================================
*/

# SOLUTION : For the least profitable product sub-category, displaying the region-wise no_of_shipments
# and the profit made in each region in decreasing order of profits

# NOTE : Assuming Least Profitable refers to negative profits (loss) also.

SELECT Region, 
       COUNT(DISTINCT ship_id) as no_of_shipments, 
       SUM(profit) as profit_in_each_region 
FROM cust_dimen c 
     INNER JOIN market_fact m 
     ON m.cust_id = c.cust_id 
WHERE m.prod_id IN (SELECT prod_id 
                    FROM prod_dimen 
                    WHERE product_sub_category = 'TABLES' ) 
GROUP BY Region 
ORDER BY profit_in_each_region DESC;


# SOLUTION : For Where is the least profitable product subcategory shipped the most?

SELECT Region, 
       COUNT(DISTINCT ship_id) as no_of_shipments, 
       SUM(profit) as profit_in_each_region 
FROM cust_dimen c 
     INNER JOIN market_fact m 
     ON m.cust_id = c.cust_id 
WHERE m.prod_id IN (SELECT prod_id 
                    FROM prod_dimen 
                    WHERE product_sub_category = 'TABLES' ) 
GROUP BY Region 
ORDER BY no_of_shipments DESC 
LIMIT 1;

/*
==================================================================================================
Important Note:
Submit your answers for all these tasks in a .sql file.
==================================================================================================
*/