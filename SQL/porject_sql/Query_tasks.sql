USE BikeStores;
GO



Steps
--A_Explore  Data
--Display all data on the tables

select * from production.brands;
select * from production.categories;
select * from production.products;
select * from production.stocks;

select * from sales.customers;
select * from sales.order_items;
select * from sales.orders;
select * from sales.staffs;
select * from sales.stores;

--B. Questions
--1) Which bike is most expensive? What could be the motive behind pricing this
--bike at the high price?
SELECT TOP 1
    product_name,
    list_price
FROM production.products
ORDER BY list_price DESC;

--2) How many total customers does BikeStore have? Would you consider
--people with order status 3 as customers substantiate your answer?
SELECT COUNT(*) AS TotalCustomers
FROM sales.customers 

--3) How many stores does BikeStore have?
select count(*) as store_exist
from sales.stores;
--or
select count(store_name) as store_exist
from sales.stores

--4) What is the total price spent per order?
--Hint: total price = [list_price] *[quantity]*(1-[discount])

SELECT
    order_id,
    SUM(list_price * quantity * (1 - discount)) AS total_price
FROM sales.order_items
GROUP BY order_id
ORDER BY order_id

--5) What’s the sales/revenue per store?
--Hint: Sales revenue = ([list_price] *[quantity]*(1-[discount]))

SELECT
    s.store_name,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS sales_revenue
FROM sales.orders o
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN sales.stores s
    ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY sales_revenue DESC

--6) Which category is most sold?
SELECT
    c.category_name,
    SUM(oi.quantity) AS total_sold
FROM production.categories c
JOIN production.products p
    ON c.category_id = p.category_id
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY total_sold DESC






--7) Which category rejected more orders?
SELECT
    c.category_name,
    COUNT(*) AS rejected_orders
FROM production.categories c
JOIN production.products p
    ON c.category_id = p.category_id
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
JOIN sales.orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY c.category_name
ORDER BY rejected_orders DESC










--8) Which bike is the least sold?
SELECT TOP 1
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM production.products p
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_sold ASC
--or
SELECT TOP 1
    p.product_name,
    oi.quantity AS total_sold
FROM production.products p
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
ORDER BY total_sold ASC





--9) What’s the full name of a customer with ID 259?
SELECT
    customer_id AS id_,
    first_name AS firstname,
    last_name AS lastname
FROM sales.customers
WHERE customer_id = 259;
--or
SELECT
    customer_id AS id_,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM sales.customers
WHERE customer_id = 259


--10) What did the customer on question 9 buy and when? What’s the status of
--this order?
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS full_name,
    p.product_name,
    o.order_date,
    o.order_status
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN production.products p
    ON oi.product_id = p.product_id
WHERE c.customer_id = 259







--11) Which staff processed the order of customer 259? And from which
--store?
SELECT
    c.customer_id,
    st.first_name + ' ' + st.last_name AS staff_name,
    s.store_name
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
JOIN sales.staffs st
    ON o.staff_id = st.staff_id
JOIN sales.stores s
    ON o.store_id = s.store_id
WHERE c.customer_id = 259


--12) How many staff does BikeStore have? Who seems to be the lead
--Staff at BikeStore?
-- Number of staff
SELECT COUNT(*) AS TotalStaff
FROM sales.staffs;

-- Lead staff (staff who have no manager)
SELECT 
    staff_id,
    first_name + ' ' + last_name AS StaffName
FROM sales.staffs
WHERE manager_id IS NULL;





--13) Which brand is the most liked?


SELECT TOP 1
    b.brand_name AS BrandName,
    SUM(oi.quantity) AS TotalQuantitySold
FROM production.brands b
JOIN production.products p
    ON b.brand_id = p.brand_id
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
GROUP BY b.brand_id, b.brand_name
ORDER BY TotalQuantitySold DESC;


--14) How many categories does BikeStore have, and which one is the least
--liked?

-- Number of categories
SELECT COUNT(*) AS TotalCategories
FROM production.categories;

-- Least liked category
SELECT TOP 1
    c.category_name AS CategoryName,
    SUM(oi.quantity) AS TotalQuantitySold
FROM production.categories c
JOIN production.products p
    ON c.category_id = p.category_id
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name
ORDER BY TotalQuantitySold ASC;






--15) Which store still have more products of the most liked brand?

WITH MostLikedBrand AS
(
    SELECT TOP 1
        p.brand_id
    FROM production.products p
    JOIN sales.order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.brand_id
    ORDER BY SUM(oi.quantity) DESC
)
SELECT 
    s.store_name AS StoreName,
    COUNT(st.product_id) AS NumberOfProducts
FROM sales.stores s
JOIN production.stocks st
    ON s.store_id = st.store_id
JOIN production.products p
    ON st.product_id = p.product_id
JOIN MostLikedBrand mb
    ON p.brand_id = mb.brand_id
GROUP BY s.store_id, s.store_name
ORDER BY NumberOfProducts DESC;




--16) Which state is doing better in terms of sales?

SELECT TOP 1
    s.state AS State,
    SUM(
        oi.list_price * oi.quantity * (1 - oi.discount)
    ) AS TotalSales
FROM sales.stores s
JOIN sales.orders o
    ON s.store_id = o.store_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
GROUP BY s.state
ORDER BY TotalSales DESC;






--17) What’s the discounted price of product id 259?
SELECT 
    oi.product_id,
    oi.list_price,
    oi.discount,
    oi.list_price * (1 - oi.discount) AS DiscountedPrice
FROM sales.order_items oi
WHERE oi.product_id = 259;






---18) What’s the product name, quantity, price, category, model year and brand
--name of product number 44?
SELECT 
    p.product_name AS ProductName,
    SUM(st.quantity) AS Quantity,
    p.list_price AS Price,
    c.category_name AS Category,
    p.model_year AS ModelYear,
    b.brand_name AS Brand
FROM production.products p
JOIN production.categories c
    ON p.category_id = c.category_id
JOIN production.brands b
    ON p.brand_id = b.brand_id
JOIN production.stocks st
    ON p.product_id = st.product_id
WHERE p.product_id = 44
GROUP BY
    p.product_name,
    p.list_price,
    c.category_name,
    p.model_year,
    b.brand_name;





--19) What’s the zip code of CA?

SELECT DISTINCT zip_code
FROM sales.customers
WHERE state = 'CA';






--20) How many states does BikeStore operate in?

SELECT COUNT(DISTINCT state) AS NumberOfStates
FROM sales.stores;




--21) How many bikes under the children category were sold in the last 8
--months?

SELECT 
    SUM(oi.quantity) AS TotalChildrenBikesSold
FROM sales.orders o
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN production.products p
    ON oi.product_id = p.product_id
JOIN production.categories c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Children Bicycles'
  AND o.order_date >= DATEADD(MONTH, -8, GETDATE());




--22) What’s the shipped date for the order from customer 523

SELECT 
    o.order_id,
    o.shipped_date
FROM sales.orders o
WHERE o.customer_id = 523;




--23) How many orders are still pending?
SELECT COUNT(*) AS PendingOrders
FROM sales.orders
WHERE order_status = 1;









--24) What’s the names of category and brand does "Electra white water 3i
-- 2018" fall under?
SELECT 
    p.product_name,
    c.category_name AS CategoryName,
    b.brand_name AS BrandName
FROM production.products p
JOIN production.categories c
    ON p.category_id = c.category_id
JOIN production.brands b
    ON p.brand_id = b.brand_id
WHERE p.product_name = 'Electra White Water 3i - 2018';








/*
25) Create a view that displays all completed orders with the following columns:
● Order ID
● Customer Full Name
● Store Name
● Staff Name
● Total Order Price
*/
CREATE VIEW vw_CompletedOrders
AS
SELECT
    o.order_id AS OrderID,
    c.first_name + ' ' + c.last_name AS CustomerFullName,
    s.store_name AS StoreName,
    st.first_name + ' ' + st.last_name AS StaffName,
    SUM(
        oi.list_price * oi.quantity * (1 - oi.discount)
    ) AS TotalOrderPrice
FROM sales.orders o
JOIN sales.customers c
    ON o.customer_id = c.customer_id
JOIN sales.stores s
    ON o.store_id = s.store_id
JOIN sales.staffs st
    ON o.staff_id = st.staff_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY
    o.order_id,
    c.first_name,
    c.last_name,
    s.store_name,
    st.first_name,
    st.last_name;



SELECT *
FROM vw_CompletedOrders;


/*
26) Create a view named vw_ProductDetails that contains:
● Product Name
● Brand Name
● Category Name
● Model Year
● List Price
.View ثم اعرض كل البيانات من الـ
*/

CREATE VIEW vw_ProductDetails
AS
SELECT
    p.product_name AS ProductName,
    b.brand_name AS BrandName,
    c.category_name AS CategoryName,
    p.model_year AS ModelYear,
    p.list_price AS ListPrice
FROM production.products p
JOIN production.brands b
    ON p.brand_id = b.brand_id
JOIN production.categories c
    ON p.category_id = c.category_id;

SELECT *
FROM vw_ProductDetails;





/*
27) Create a view that shows the total sales for each store.
Columns:
● Store Name
● Total Sales
*/
CREATE VIEW vw_StoreSales
AS
SELECT
    s.store_name AS StoreName,
    SUM(
        oi.list_price * oi.quantity * (1 - oi.discount)
    ) AS TotalSales
FROM sales.stores s
JOIN sales.orders o
    ON s.store_id = o.store_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    s.store_id,
    s.store_name;


    SELECT *
FROM vw_StoreSales;




28) Using a CTE, display customers who spent more than the average customer
spending.
Columns:
● Customer ID
● Customer Name
● Total Spending


WITH CustomerSpending AS
(
    SELECT
        c.customer_id AS CustomerID,
        c.first_name + ' ' + c.last_name AS CustomerName,
        SUM(
            oi.list_price * oi.quantity * (1 - oi.discount)
        ) AS TotalSpending
    FROM sales.customers c
    JOIN sales.orders o
        ON c.customer_id = o.customer_id
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    CustomerID,
    CustomerName,
    TotalSpending
FROM CustomerSpending
WHERE TotalSpending >
(
    SELECT AVG(TotalSpending)
    FROM CustomerSpending
);






29) Using a CTE, rank products from highest to lowest revenue using ROW_NUMBER().

Columns:
● Rank
● Product Name
● Revenue

WITH ProductRevenue AS
(
    SELECT
        p.product_name AS ProductName,
        SUM(
            oi.list_price * oi.quantity * (1 - oi.discount)
        ) AS Revenue
    FROM production.products p
    JOIN sales.order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    ROW_NUMBER() OVER (ORDER BY Revenue DESC) AS [Rank],
    ProductName,
    Revenue
FROM ProductRevenue
ORDER BY [Rank];







30) Using a CTE, display the top 5 most sold bikes.
Columns:
● Product Name
● Total Quantity Sold

WITH ProductSales AS
(
    SELECT
        p.product_name AS ProductName,
        SUM(oi.quantity) AS TotalQuantitySold
    FROM production.products p
    JOIN sales.order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT TOP 5
    ProductName,
    TotalQuantitySold
FROM ProductSales
ORDER BY TotalQuantitySold DESC;









31) Using a recursive CTE, display the staff hierarchy (Manager → Employee).
Columns:
● Staff Name
● Manager Name
● Level
(.staffs في جدول id_manager يعتمد على وجود)


WITH StaffHierarchy AS
(
    -- Managers
    SELECT
        staff_id,
        first_name + ' ' + last_name AS StaffName,
        CAST(NULL AS VARCHAR(100)) AS ManagerName,
        0 AS [Level]
    FROM sales.staffs
    WHERE manager_id IS NULL

    UNION ALL

    -- Employees
    SELECT
        e.staff_id,
        e.first_name + ' ' + e.last_name AS StaffName,
        m.first_name + ' ' + m.last_name AS ManagerName,
        sh.[Level] + 1
    FROM sales.staffs e
    JOIN sales.staffs m
        ON e.manager_id = m.staff_id
    JOIN StaffHierarchy sh
        ON e.manager_id = sh.staff_id
)
SELECT
    StaffName,
    ManagerName,
    [Level]
FROM StaffHierarchy
ORDER BY [Level], StaffName;









32) Find all products whose price is higher than the average product price using a
subquery.




SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE list_price >
(
    SELECT AVG(list_price)
    FROM production.products
);




33) Find customers who have placed more orders than the average number of orders
per customer.

SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS CustomerName,
    COUNT(o.order_id) AS NumberOfOrders
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(o.order_id) >
(
    SELECT AVG(OrderCount)
    FROM
    (
        SELECT
            customer_id,
            COUNT(*) AS OrderCount
        FROM sales.orders
        GROUP BY customer_id
    ) AS CustomerOrderCounts
);








34) Display the most expensive bike(s) using a subquery only.

SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE list_price =
(
    SELECT MAX(list_price)
    FROM production.products
);



35) Find all products that have never been ordered.

SELECT
    p.product_id,
    p.product_name
FROM production.products p
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales.order_items oi
    WHERE oi.product_id = p.product_id
);






36) Find the store with the highest total sales using a subquery.

SELECT
    s.store_name,
    SUM(
        oi.list_price * oi.quantity * (1 - oi.discount)
    ) AS TotalSales
FROM sales.stores s
JOIN sales.orders o
    ON s.store_id = o.store_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    s.store_id,
    s.store_name
HAVING SUM(
    oi.list_price * oi.quantity * (1 - oi.discount)
) =
(
    SELECT MAX(StoreSales)
    FROM
    (
        SELECT
            SUM(
                oi2.list_price * oi2.quantity * (1 - oi2.discount)
            ) AS StoreSales
        FROM sales.orders o2
        JOIN sales.order_items oi2
            ON o2.order_id = oi2.order_id
        GROUP BY o2.store_id
    ) AS StoreTotals
);







37) Display customers who purchased products from the most liked brand.

SELECT DISTINCT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS CustomerName
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN production.products p
    ON oi.product_id = p.product_id
WHERE p.brand_id =
(
    SELECT TOP 1
        p2.brand_id
    FROM production.products p2
    JOIN sales.order_items oi2
        ON p2.product_id = oi2.product_id
    GROUP BY p2.brand_id
    ORDER BY SUM(oi2.quantity) DESC
);







38) Find categories whose total sales are above the average category sales.

WITH CategorySales AS
(
    SELECT
        c.category_id,
        c.category_name AS CategoryName,
        SUM(
            oi.list_price * oi.quantity * (1 - oi.discount)
        ) AS TotalSales
    FROM production.categories c
    JOIN production.products p
        ON c.category_id = p.category_id
    JOIN sales.order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        c.category_id,
        c.category_name
)
SELECT
    CategoryName,
    TotalSales
FROM CategorySales
WHERE TotalSales >
(
    SELECT AVG(TotalSales)
    FROM CategorySales
);





39) Display the products whose price is greater than the average price of their category.

SELECT
    p.product_id,
    p.product_name,
    p.list_price,
    p.category_id
FROM production.products p
WHERE p.list_price >
(
    SELECT AVG(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = p.category_id
);







40) Find the staff member who processed the highest number of completed orders.


SELECT TOP 1
    st.staff_id,
    st.first_name + ' ' + st.last_name AS StaffName,
    COUNT(o.order_id) AS CompletedOrders
FROM sales.staffs st
JOIN sales.orders o
    ON st.staff_id = o.staff_id
WHERE o.order_status = 4
GROUP BY
    st.staff_id,
    st.first_name,
    st.last_name
ORDER BY CompletedOrders DESC;








Bonus (Advanced SQL)
41) Create a view named vw_CustomerSales showing:
● Customer ID
● Customer Name
● Number of Orders
● Total Spending


CREATE VIEW vw_CustomerSales
AS
SELECT
    c.customer_id AS CustomerID,
    c.first_name + ' ' + c.last_name AS CustomerName,
    COUNT(DISTINCT o.order_id) AS NumberOfOrders,
    COALESCE(
        SUM(oi.list_price * oi.quantity * (1 - oi.discount)),
        0
    ) AS TotalSpending
FROM sales.customers c
LEFT JOIN sales.orders o
    ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;









42) Using the view created in Question 41, display customers whose total spending is
greater than the average spending of all customers.


SELECT
    CustomerID,
    CustomerName,
    NumberOfOrders,
    TotalSpending
FROM vw_CustomerSales
WHERE TotalSpending >
(
    SELECT AVG(TotalSpending)
    FROM vw_CustomerSales
);











43) Using a CTE, calculate the cumulative sales by order date.
Columns:
● Order Date
● Daily Sales
● Running Total








WITH DailySales AS
(
    SELECT
        o.order_date AS OrderDate,
        SUM(
            oi.list_price * oi.quantity * (1 - oi.discount)
        ) AS DailySales
    FROM sales.orders o
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
SELECT
    OrderDate,
    DailySales,
    SUM(DailySales) OVER
    (
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM DailySales
ORDER BY OrderDate;

44) Using a subquery, find the second most expensive bike.


SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE list_price =
(
    SELECT MAX(list_price)
    FROM production.products
    WHERE list_price <
    (
        SELECT MAX(list_price)
        FROM production.products
    )
);