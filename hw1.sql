-- 找出和最貴的產品同類別的所有產品
select *
from Products
where CategoryID = (
	select top 1 CategoryID
	from Products
	order by UnitPrice desc
)
-- 找出和最貴的產品同類別最便宜的產品

--select 
--	top 1 *
--from Products
--where CategoryID = (
--	select top　1 CategoryID
--	from Products
--	--order by UnitPrice desc
--)
--order by UnitPrice

-- 計算出上面類別最貴和最便宜的兩個產品的價差
select 
	max (UnitPrice) - min(UnitPrice) as PriceDifference
from Products
where CategoryID = (
	select 
		top 1 CategoryID
	from Products
	order by UnitPrice desc
)

-- 找出沒有訂過任何商品的客戶所在的城市的所有客戶

select *
from Customers
where City in (
	select City
	from Customers 
	where CustomerID NOT IN(
		select CustomerID
		from Orders
	)
)

-- 找出第 5 貴跟第 8 便宜的產品的產品類別

with RankerProducts as(
	select 
		*,
		ROW_NUMBER() over(order by UnitPrice desc) as priceRank
	from Products
)
select CategoryID from RankerProducts
where priceRank = 5 or priceRank = (
	select COUNT(*)
	from RankerProducts
) -7;


-- 找出誰買過第 5 貴跟第 8 便宜的產品
with RankerProducts as(
	select 
		ProductID, UnitPrice, CategoryID,
		ROW_NUMBER() over(order by UnitPrice desc) as priceRank
	from Products
)

select r.ProductID,r.UnitPrice, r.CategoryID
from RankerProducts r
join Products p on r.CategoryID = p.CategoryID
where priceRank = 5 or priceRank = (
	select COUNT(*)
	from RankerProducts
) -7


-- 找出誰賣過第 5 貴跟第 8 便宜的產品

with RankerProducts as(
	select 
		*,
		ROW_NUMBER() over(order by UnitPrice desc) as priceRank
	from Products
)
select SupplierID
from RankerProducts
where priceRank = 5 or priceRank = (
	select COUNT(*)
	from RankerProducts
) -8;

-- 找出 13 號星期五的訂單 (惡魔的訂單)

select *
from Orders
where DATEPART(WEEKDAY, OrderDate) = 6 and DAY(OrderDate) = 13

-- 找出誰訂了惡魔的訂單

select c.CustomerID, c.ContactName
from Orders o
join Customers c on o.CustomerID = c.CustomerID
where DATEPART(WEEKDAY, OrderDate) = 6 and DAY(OrderDate) = 13

-- 找出惡魔的訂單裡有什麼產品

select p.ProductID, p.ProductName
from Orders o 
join [Order Details] od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
where DATEPART(WEEKDAY, OrderDate) = 6 and DAY(OrderDate) = 13

-- 列出從來沒有打折 (Discount) 出售的產品

select 
	p.ProductID , p.ProductName
from Products p
join [Order Details] od on p.ProductID = od.ProductID
where od.Discount = 0

-- 列出購買非本國的產品的客戶

select c.CustomerID ,c.ContactName, s.Country, c.Country
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on o.OrderID = od.OrderID
join Products p on p.ProductID = od.ProductID
join Suppliers s on s.SupplierID = p.SupplierID
where c.Country != s.Country

-- 列出在同個城市中有公司員工可以服務的客戶

select c.CustomerID, c.ContactName
from Customers c
join Orders o on c.CustomerID = o.CustomerID
join Employees e on e.EmployeeID = o.EmployeeID
where c.City = e.City

-- 列出那些產品沒有人買過

select *
from Products p
where p.ProductID not in (
	select od.ProductID
	from [Order Details] od
)

----------------------------------------------------------------------------------------
-- 列出所有在每個月月底的訂單

SELECT *
FROM Orders
WHERE OrderDate = EOMONTH(OrderDate)

-- 列出每個月月底售出的產品

select p.ProductID, p.ProductName
from Orders o
join [Order Details] od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
where OrderDate = EOMONTH(OrderDate)

-- 找出有敗過最貴的三個產品中的任何一個的前三個大客戶

select top 3 sum(od.UnitPrice*(1-od.Discount)*od.Quantity), O.CustomerID
from Customers c
join Orders o on c.CustomerID = o.CustomerID
join [Order Details] od on od.OrderID = o.OrderID
where c.CustomerID in (
	select c.CustomerID
	from Customers c
	join Orders o on o.CustomerID = c.CustomerID
	join [Order Details] od on od.OrderID = o.OrderID
	join Products p on p.ProductID = od.ProductID
	where　p.ProductID in (
		select ProductID
		from Products
		where UnitPrice in (
			select Top 3　UnitPrice
			from Products
			order by  UnitPrice　desc
		)
	)
)
group by o.CustomerID
order by sum(od.UnitPrice*(1-od.Discount)*od.Quantity) desc




-- 找出有敗過銷售金額前三高個產品的前三個大客戶

select top 3 o.CustomerID,sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Products p
join [Order Details] od on od.ProductID = p.ProductID
join Orders o on o.OrderID = od.OrderID
where od.ProductID in (
	select top 3  od.ProductID
	from [Order Details] od
	group by od.ProductID
	order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc
)
group by o.CustomerID
order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc



--sum((1-od.Discount)*od.Quantity*od.UnitPrice),

-- 找出有敗過銷售金額前三高個產品所屬類別的前三個大客戶

select p.CategoryID, p.ProductID
from Products p
join Categories c on c.CategoryID = p.CategoryID
where p.ProductID in(
	select top 3 od.ProductID
	from [Order Details] od
	group by od.ProductID
	order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc
)




select ProductID, CategoryID
from Products
order by ProductID


-- 列出消費總金額高於所有客戶平均消費總金額的客戶的名字，以及客戶的消費總金額

select o.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from [Order Details] od
join Orders o on o.OrderID = od.OrderID
group by o.CustomerID
having sum((1-od.Discount)*od.Quantity*od.UnitPrice) > (
	select sum((1-od.Discount)*od.Quantity*od.UnitPrice)/COUNT(o.CustomerID)
	from [Order Details] od
	join Orders o on o.OrderID = od.OrderID
)
-- 列出最熱銷的產品，以及被購買的總金額

select top 1 sum(od.Quantity),sum((1-od.Discount)*od.Quantity*od.UnitPrice), od.ProductID
from [Order Details] od
group by od.ProductID
order by sum(od.Quantity) desc

-- 列出最少人買的產品

select top 1 sum(od.Quantity), od.ProductID
from [Order Details] od
group by od.ProductID
order by sum(od.Quantity)

-- 列出最沒人要買的產品類別 (Categories)

select c.CategoryID
from Categories c
EXCEPT
select p.CategoryID
from [Order Details] od
left join Products p on p.ProductID = od.ProductID
where od.ProductID = p.ProductID


-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (含購買其它供應商的產品)

select top 1 o.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Customers c
left join Orders o on o.CustomerID = c.CustomerID
left join [Order Details] od on od.OrderID = o.OrderID
where EXISTS(
	select top 1 s.SupplierID 
	from Suppliers s
	left join Products p on s.SupplierID = p.SupplierID
	left join [Order Details] od on od.ProductID = p.ProductID
	group by s.SupplierID
	order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc
)
group by o.CustomerID
order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc

-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (不含購買其它供應商的產品)

select top 1 o.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Customers c
left join Orders o on o.CustomerID = c.CustomerID
left join [Order Details] od on od.OrderID = o.OrderID
left join Products p on od.ProductID = p.ProductID
where p.SupplierID in (
	select top 1 s.SupplierID 
	from Suppliers s
	left join Products p on s.SupplierID = p.SupplierID
	left join [Order Details] od on od.ProductID = p.ProductID
	group by s.SupplierID
	order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc
)
group by o.CustomerID
order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc

-- 列出那些產品沒有人買過

select p.ProductID
from Products p
EXCEPT
select od.ProductID
from [Order Details] od


-- 列出沒有傳真 (Fax) 的客戶和它的消費總金額

select c.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on od.OrderID = o.OrderID
join Products p on od.ProductID = p.ProductID
where c.Fax is NULL
group by c.CustomerID

-- 列出每一個城市消費的產品種類數量

select Count(od.ProductID), c.City
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on od.OrderID = o.OrderID
group by c.City

-- 列出目前沒有庫存的產品在過去總共被訂購的數量
select od.ProductID, sum(od.Quantity)
from [Order Details] od
join Products p on p.ProductID = od.ProductID
where od.ProductID in(
	select ProductID
	from Products
	where UnitsInStock = 0
)
group by od.ProductID


-- 列出目前沒有庫存的產品在過去曾經被那些客戶訂購過

select distinct o.CustomerID
from [Order Details] od
full join Products p on p.ProductID = od.ProductID
full join Orders o on o.OrderID= od.OrderID
where od.ProductID in(
	select ProductID
	from Products
	where UnitsInStock = 0
)


-- 列出每位員工的下屬的業績總金額

select o.EmployeeID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Orders o
join [Order Details] od on o.OrderID = od.OrderID
group by o.EmployeeID

-- 列出每家貨運公司運送最多的那一種產品類別與總數量

select a.ShipperID, max(a.sums)
from (
	select s.ShipperID  , p.CategoryID, sum(p.CategoryID)as sums
	from Shippers s
	join Orders o on s.ShipperID = o.ShipVia
	join [Order Details] od on od.OrderID = o.OrderID
	join Products p on p.ProductID = od.ProductID
	group by s.ShipperID, p.CategoryID
) a
group by a.ShipperID

-- 列出每一個客戶買最多的產品類別與金額
select distinct a.CustomerID, a.sum2, a.CategoryID
from(
	select c.CustomerID , p.CategoryID, sum(p.CategoryID) as sums,
	sum((1-od.Discount)*od.Quantity*od.UnitPrice) as sum2,
	rank()over(
		PARTITION BY c.CustomerID
		ORDER BY SUM(p.CategoryID) DESC
	)as rank
	from Customers c
	join Orders	o on o.CustomerID = c.CustomerID
	join [Order Details] od on od.OrderID = o.OrderID
	join Products p on p.ProductID = od.ProductID
	group by c.CustomerID, p.CategoryID
) a
where rank = 1



-- 列出每一個客戶買最多的那一個產品與購買數量

select a.CustomerID,a.ProductID, a.TotalQuantity
from(
	select c.CustomerID , p.ProductID,SUM(od.Quantity) as TotalQuantity,
	rank()over(
		PARTITION BY c.CustomerID
		ORDER BY SUM(od.Quantity) DESC
	)as rank
	from Customers c
	join Orders	o on o.CustomerID = c.CustomerID
	join [Order Details] od on od.OrderID = o.OrderID
	join Products p on p.ProductID = od.ProductID
	group by c.CustomerID, p.ProductID
) a
where rank = 1


-- 按照城市分類，找出每一個城市最近一筆訂單的送貨時間
select *
from(
	select c.City,o.ShippedDate,
		RANK()over (
			PARTITION BY c.City
			ORDER BY o.ShippedDate DESC
		)as RowNumber
	from Customers c 
	join Orders o on o.CustomerID = c.CustomerID
) a
where RowNumber = 1




-- 列出購買金額第五名與第十名的客戶，以及兩個客戶的金額差距
select 
	sum(case when rownumber = 5 then a.sums else 0 end)-
	sum(case when rownumber = 10 then a.sums else 0 end)
from (
	select c.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice) as sums,
	ROW_NUMBER()over(
		order by sum((1-od.Discount)*od.Quantity*od.UnitPrice) desc
	) rownumber
	from Customers c
	join Orders	o on o.CustomerID = c.CustomerID
	join [Order Details] od on od.OrderID = o.OrderID
	join Products p on p.ProductID = od.ProductID
	group by c.CustomerID
)as a
  


