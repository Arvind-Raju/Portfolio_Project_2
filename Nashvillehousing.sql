/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

SELECT SaleDate, CONVERT(date,saledate)
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

--update command not functioning
update Nashville_Housing
set Saledateconverted= CONVERT(date,saledate) 

--alter command used to get around update
ALTER TABLE Nashville_Housing
ADD Saledateconverted Date

SELECT *
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
WHERE PropertyAddress is null
ORDER BY ParcelID

--SELECT 
--TABLE_CATALOG,
--TABLE_SCHEMA,
--TABLE_NAME, 
--COLUMN_NAME, 
--DATA_TYPE 
--FROM INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME = '[Portfolio_Project].[dbo].[Nashville_Housing]' 

--populating null address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_Project].[dbo].[Nashville_Housing] a
JOIN [Portfolio_Project].[dbo].[Nashville_Housing] b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_Project].[dbo].[Nashville_Housing] a
JOIN [Portfolio_Project].[dbo].[Nashville_Housing] b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--TESTING IF CODE IS GOOD FOR SEPARATING ADDRESS

SELECT 
SUBSTRING(PropertyAddress,1,charindex(',',propertyaddress)-1)as address,
SUBSTRING(PropertyAddress,charindex(',',propertyaddress)+1,len(propertyaddress))as address
FROM [Portfolio_Project].[dbo].[Nashville_Housing]


--SEPARATES PROPERTY NUMBER AND STORES IT SEPARATELY IN propertysplitaddress
ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD propertysplitaddress nvarchar(255)

update [Portfolio_Project].[dbo].[Nashville_Housing]
set propertysplitaddress=SUBSTRING(PropertyAddress,1,charindex(',',propertyaddress)-1)


--SEPARATES CITY FROM PROPERTY ADDRESS AND STORES IT SEPARATELY propertysplitcity
ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD propertysplitcity nvarchar(255)

update [Portfolio_Project].[dbo].[Nashville_Housing]
set propertysplitcity=SUBSTRING(PropertyAddress,charindex(',',propertyaddress)+1,len(propertyaddress))

SELECT *
FROM [Portfolio_Project].[dbo].[Nashville_Housing]


SELECT OwnerAddress
FROM [Portfolio_Project].[dbo].[Nashville_Housing]


--SEPARATING OWNER ADDRESS
select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD ownersplitaddress nvarchar(255)
update [Portfolio_Project].[dbo].[Nashville_Housing]
set ownersplitaddress=PARSENAME(replace(owneraddress,',','.'),3)

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD ownersplitcity nvarchar(255)
update [Portfolio_Project].[dbo].[Nashville_Housing]
set ownersplitcity=PARSENAME(replace(owneraddress,',','.'),2)

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD ownersplitstate nvarchar(255)
update [Portfolio_Project].[dbo].[Nashville_Housing]
set ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1)


-------------------------------------------------------------------------------------------

--Fixing Soldasvacant column
SELECT SoldAsVacant,
case when soldasvacant = 'y' then 'yes'
	 when soldasvacant='n' then 'no'
	 else soldasvacant
	 end
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

update [Portfolio_Project].[dbo].[Nashville_Housing]
set SoldAsVacant=case when soldasvacant = 'y' then 'Yes'
	 when soldasvacant='n' then 'No'
	 else soldasvacant
	 end

SELECT distinct(SoldAsVacant)
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

--------------------------------------------------------------------------

--Remove Duplicates with CTE
WITH RownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
	propertyaddress, saleprice,saledate,
	legalreference
	ORDER BY
	Uniqueid) row_num
	FROM [Portfolio_Project].[dbo].[Nashville_Housing]
	)

delete
FROM rownumcte
where row_num>1
----------------------------------------------------------------

--REMOVE UNWANTED COLUMNS
ALTER table [Portfolio_Project].[dbo].[Nashville_Housing]
DROP column owneraddress,taxdistrict,propertyaddress,saledate





