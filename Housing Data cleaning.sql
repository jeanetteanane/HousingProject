-- Cleaning Data

SELECT * 
FROM Housing


-- Changing Date Format
SELECT SaleDateConverted
FROM Housing

--the first update does not work on data
UPDATE Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Housing
ADD SaleDateConverted Date;

UPDATE Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populating Property address. Self join and updating the address in blank property addresses

SELECT *
FROM Housing
WHERE PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM Housing
--WHERE PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
FROM Housing

ALTER TABLE Housing
ADD PropertyStreetSplit nvarchar(255);

UPDATE Housing
SET PropertyStreetSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing
ADD PropertyCitySplit nvarchar(255);

UPDATE Housing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

select *
from Housing



select OwnerAddress
from Housing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM Housing

ALTER TABLE Housing
ADD OwnerStreetSplit nvarchar(255);

UPDATE Housing
SET OwnerStreetSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE Housing
ADD OwnerCitySplit nvarchar(255);

UPDATE Housing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE Housing
ADD OwnerStateSplit nvarchar(255);

UPDATE Housing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- Change Y and N to Yes and No for the "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Housing

Update Housing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


-- Removing Duplicates
WITH DuplicateCTE AS (
select *,
	ROW_NUMBER() OVER (PARTITION BY
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID
	) Row_num
from Housing
)

--DELETE
--FROM DuplicateCTE
--WHERE Row_num > 1

SELECT *
FROM DuplicateCTE
WHERE Row_num > 1
ORDER BY PropertyAddress



 Delete Unused Columns
SELECT *
FROM Housing

ALTER TABLE Housing
DROP COLUMN OwnerAddress, SaleDate, PropertyAddress, TaxDistrict