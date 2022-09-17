--CONVERTING SALEDATE COLUMN TO DATE DATATYPE AND CREATE NEW COLUMN

SELECT SaleDate, CONVERT(date,saledate)
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

ALTER TABLE Nashville_Housing
ADD Saledateconverted Date

UPDATE Nashville_Housing
SET Saledateconverted= CONVERT(date,saledate) 
---------------------------------------------------------------------------------------------------------------

--POPULATING NULL ADDRESS WITH REQUIRED VALUE USING SELF JOIN

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_Project].[dbo].[Nashville_Housing] a
JOIN [Portfolio_Project].[dbo].[Nashville_Housing] b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_Project].[dbo].[Nashville_Housing] a
JOIN [Portfolio_Project].[dbo].[Nashville_Housing] b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
------------------------------------------------------------------------------------------------------------------

--SEPARATING PROPERTY NUMBER AND STORING IT SEPARATELY IN PROPERTYSPLITADDRESS

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD propertysplitaddress nvarchar(255)

UPDATE [Portfolio_Project].[dbo].[Nashville_Housing]
SET propertysplitaddress=SUBSTRING(PropertyAddress,1,charindex(',',propertyaddress)-1)

-------------------------------------------------------------------------------------------------------------------

--SEPARATING CITY FROM PROPERTY ADDRESS AND STORING IT SEPARATELY IN PROPERTYSPLITCITY

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD propertysplitcity nvarchar(255)

UPDATE [Portfolio_Project].[dbo].[Nashville_Housing]
SET propertysplitcity=SUBSTRING(PropertyAddress,charindex(',',propertyaddress)+1,len(propertyaddress))
--------------------------------------------------------------------------------------------------------------------

--SEPARATING OWNER ADDRESS INTO THREE PARTS

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD ownersplitaddress nvarchar(255)
UPDATE [Portfolio_Project].[dbo].[Nashville_Housing]
SET ownersplitaddress=PARSENAME(replace(owneraddress,',','.'),3)

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD ownersplitcity nvarchar(255)
update [Portfolio_Project].[dbo].[Nashville_Housing]
set ownersplitcity=PARSENAME(replace(owneraddress,',','.'),2)

ALTER TABLE [Portfolio_Project].[dbo].[Nashville_Housing]
ADD ownersplitstate nvarchar(255)
update [Portfolio_Project].[dbo].[Nashville_Housing]
set ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------

--FIXING SOLDASVACANT COLUMN WITH MULTIPLE DIFFERENT ENTRIES USING SWITCH CASE

UPDATE [Portfolio_Project].[dbo].[Nashville_Housing]
SET SoldAsVacant = 
    CASE WHEN soldasvacant = 'y' then 'Yes'
	 WHEN soldasvacant = 'n' then 'No'
	 ELSE soldasvacant
	 END

--------------------------------------------------------------------------------------------------------------------

--REMOVING DUPLICATES WITH CTE

WITH RownumCTE AS(
	SELECT *,
	ROW_NUMBER() 
	OVER(
	PARTITION BY 
	parcelid,
	propertyaddress, 
	saleprice,
	saledate,
	legalreference
	ORDER BY
	Uniqueid) row_num
	FROM [Portfolio_Project].[dbo].[Nashville_Housing]
	)
DELETE
FROM rownumcte
WHERE row_num>1
------------------------------------------------------------------------------------------------------------------------

--REMOVING UNWANTED COLUMNS (PRACTICE NOT RECOMMENDED IN A PROFESSIONAL WORK ENVIRONMENT WITHOUT AUTHORIZATION)

ALTER table [Portfolio_Project].[dbo].[Nashville_Housing]
DROP column owneraddress,taxdistrict,propertyaddress,saledate

------------------------------------------------------------------------------------------------------------------------





