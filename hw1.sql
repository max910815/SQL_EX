-- ��X�M�̶Q�����~�P���O���Ҧ����~
select *
from Products
where CategoryID = (
	select top 1 CategoryID
	from Products
	order by UnitPrice desc
)
-- ��X�M�̶Q�����~�P���O�̫K�y�����~

--select 
--	top 1 *
--from Products
--where CategoryID = (
--	select top�@1 CategoryID
--	from Products
--	--order by UnitPrice desc
--)
--order by UnitPrice

-- �p��X�W�����O�̶Q�M�̫K�y����Ӳ��~�����t
select 
	max (UnitPrice) - min(UnitPrice) as PriceDifference
from Products
where CategoryID = (
	select 
		top 1 CategoryID
	from Products
	order by UnitPrice desc
)

-- ��X�S���q�L����ӫ~���Ȥ�Ҧb���������Ҧ��Ȥ�

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

-- ��X�� 5 �Q��� 8 �K�y�����~�����~���O

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


-- ��X�ֶR�L�� 5 �Q��� 8 �K�y�����~
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


-- ��X�ֽ�L�� 5 �Q��� 8 �K�y�����~

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

-- ��X 13 ���P�������q�� (�c�]���q��)

select *
from Orders
where DATEPART(WEEKDAY, OrderDate) = 6 and DAY(OrderDate) = 13

-- ��X�֭q�F�c�]���q��

select c.CustomerID, c.ContactName
from Orders o
join Customers c on o.CustomerID = c.CustomerID
where DATEPART(WEEKDAY, OrderDate) = 6 and DAY(OrderDate) = 13

-- ��X�c�]���q��̦����򲣫~

select p.ProductID, p.ProductName
from Orders o 
join [Order Details] od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
where DATEPART(WEEKDAY, OrderDate) = 6 and DAY(OrderDate) = 13

-- �C�X�q�ӨS������ (Discount) �X�⪺���~

select 
	p.ProductID , p.ProductName
from Products p
join [Order Details] od on p.ProductID = od.ProductID
where od.Discount = 0

-- �C�X�ʶR�D���ꪺ���~���Ȥ�

select c.CustomerID ,c.ContactName, s.Country, c.Country
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on o.OrderID = od.OrderID
join Products p on p.ProductID = od.ProductID
join Suppliers s on s.SupplierID = p.SupplierID
where c.Country != s.Country

-- �C�X�b�P�ӫ����������q���u�i�H�A�Ȫ��Ȥ�

select c.CustomerID, c.ContactName
from Customers c
join Orders o on c.CustomerID = o.CustomerID
join Employees e on e.EmployeeID = o.EmployeeID
where c.City = e.City

-- �C�X���ǲ��~�S���H�R�L

select *
from Products p
where p.ProductID not in (
	select od.ProductID
	from [Order Details] od
)

----------------------------------------------------------------------------------------
-- �C�X�Ҧ��b�C�Ӥ�멳���q��

SELECT *
FROM Orders
WHERE OrderDate = EOMONTH(OrderDate)

-- �C�X�C�Ӥ�멳��X�����~

select p.ProductID, p.ProductName
from Orders o
join [Order Details] od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
where OrderDate = EOMONTH(OrderDate)

-- ��X���ѹL�̶Q���T�Ӳ��~��������@�Ӫ��e�T�Ӥj�Ȥ�

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
	where�@p.ProductID in (
		select ProductID
		from Products
		where UnitPrice in (
			select Top 3�@UnitPrice
			from Products
			order by  UnitPrice�@desc
		)
	)
)
group by o.CustomerID
order by sum(od.UnitPrice*(1-od.Discount)*od.Quantity) desc




-- ��X���ѹL�P����B�e�T���Ӳ��~���e�T�Ӥj�Ȥ�

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

-- ��X���ѹL�P����B�e�T���Ӳ��~�������O���e�T�Ӥj�Ȥ�

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


-- �C�X���O�`���B����Ҧ��Ȥᥭ�����O�`���B���Ȥ᪺�W�r�A�H�ΫȤ᪺���O�`���B

select o.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from [Order Details] od
join Orders o on o.OrderID = od.OrderID
group by o.CustomerID
having sum((1-od.Discount)*od.Quantity*od.UnitPrice) > (
	select sum((1-od.Discount)*od.Quantity*od.UnitPrice)/COUNT(o.CustomerID)
	from [Order Details] od
	join Orders o on o.OrderID = od.OrderID
)
-- �C�X�̼��P�����~�A�H�γQ�ʶR���`���B

select top 1 sum(od.Quantity),sum((1-od.Discount)*od.Quantity*od.UnitPrice), od.ProductID
from [Order Details] od
group by od.ProductID
order by sum(od.Quantity) desc

-- �C�X�̤֤H�R�����~

select top 1 sum(od.Quantity), od.ProductID
from [Order Details] od
group by od.ProductID
order by sum(od.Quantity)

-- �C�X�̨S�H�n�R�����~���O (Categories)

select c.CategoryID
from Categories c
EXCEPT
select p.CategoryID
from [Order Details] od
left join Products p on p.ProductID = od.ProductID
where od.ProductID = p.ProductID


-- �C�X��P��̦n�������ӶR�̦h���B���Ȥ�P�ʶR���B (�t�ʶR�䥦�����Ӫ����~)

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

-- �C�X��P��̦n�������ӶR�̦h���B���Ȥ�P�ʶR���B (���t�ʶR�䥦�����Ӫ����~)

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

-- �C�X���ǲ��~�S���H�R�L

select p.ProductID
from Products p
EXCEPT
select od.ProductID
from [Order Details] od


-- �C�X�S���ǯu (Fax) ���Ȥ�M�������O�`���B

select c.CustomerID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on od.OrderID = o.OrderID
join Products p on od.ProductID = p.ProductID
where c.Fax is NULL
group by c.CustomerID

-- �C�X�C�@�ӫ������O�����~�����ƶq

select Count(od.ProductID), c.City
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on od.OrderID = o.OrderID
group by c.City

-- �C�X�ثe�S���w�s�����~�b�L�h�`�@�Q�q�ʪ��ƶq
select od.ProductID, sum(od.Quantity)
from [Order Details] od
join Products p on p.ProductID = od.ProductID
where od.ProductID in(
	select ProductID
	from Products
	where UnitsInStock = 0
)
group by od.ProductID


-- �C�X�ثe�S���w�s�����~�b�L�h���g�Q���ǫȤ�q�ʹL

select distinct o.CustomerID
from [Order Details] od
full join Products p on p.ProductID = od.ProductID
full join Orders o on o.OrderID= od.OrderID
where od.ProductID in(
	select ProductID
	from Products
	where UnitsInStock = 0
)


-- �C�X�C����u���U�ݪ��~�Z�`���B

select o.EmployeeID, sum((1-od.Discount)*od.Quantity*od.UnitPrice)
from Orders o
join [Order Details] od on o.OrderID = od.OrderID
group by o.EmployeeID

-- �C�X�C�a�f�B���q�B�e�̦h�����@�ز��~���O�P�`�ƶq

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

-- �C�X�C�@�ӫȤ�R�̦h�����~���O�P���B
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



-- �C�X�C�@�ӫȤ�R�̦h�����@�Ӳ��~�P�ʶR�ƶq

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


-- ���ӫ��������A��X�C�@�ӫ����̪�@���q�檺�e�f�ɶ�
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




-- �C�X�ʶR���B�Ĥ��W�P�ĤQ�W���Ȥ�A�H�Ψ�ӫȤ᪺���B�t�Z
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
  


