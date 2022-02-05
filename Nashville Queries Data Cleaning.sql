---CLEANING DATA IN SQL QUERIES

SELECT *
FROM Nashville

--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) AS Date
FROM Nashville

--Update table--This one didn't work but it normally does
UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)

--ALTER TABLE
ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate) AS Date
FROM Nashville

--Populate Property Address Data based off of PacelID and Address matching

SELECT PropertyAddress
From Nashville
WHERE PropertyAddress is NULL
ORDER BY ParcelID

--Populate Property Address Data Part 2
SELECT *
From Nashville
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

--Populate Property Address Data Part 3
--JOIN THE TABLE TO ITSELF TO TRY AND POPULATE THE ADDRESS TABLE IF THE UNIQUE ID IS DIFFERENT

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville as a
JOIN Nashville as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--UPDATING 
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville as a
JOIN Nashville as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out PropertyAddress into individual columns(Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
--CHARINDEX(',', PropertyAddress)
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Nashville

--ALTER TABLE--Adding a column
ALTER TABLE Nashville
ADD Address nvarchar(255); --column that why we have ";"
--UPDATE
UPDATE Nashville
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD City NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--- MY WAY OF UPDATING AND ALTERING OWNERADDRESS INTO # COLUMNS
SELECT 
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1) AS OwnerAddress1,
--CHARINDEX(',', OwnerAddress)
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, CHARINDEX(',', OwnerAddress)-4) AS OwnerCity1,
SUBSTRING(OwnerAddress, 36, LEN(OwnerAddress)) AS OwnerState1
FROM Nashville

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD OwnerAddress1 NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET OwnerAddress1 = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1)

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD OwnerCity1 NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET OwnerCity1 = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, CHARINDEX(',', OwnerAddress)-4)

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD OwnerState1 NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET OwnerState1 = SUBSTRING(OwnerAddress, 36, LEN(OwnerAddress))

ALTER TABLE Nashville
DROP COLUMN OwnerAddress1, OwnerCity1, OwnerState1;

-- MY WAY OF UPDATING AND ALTERING OWNERADDRESS INTO # COLUMNS

--EASIER WAY OF UPDATING AND ALTERING OWNERADDRESS INTO # COLUMNS WITH PARSENAME

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddress1,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity1,
		 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState1
FROM Nashville

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD OwnerAddress1 NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD OwnerCity1 NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET OwnerCity1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD OwnerState1 NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET OwnerState1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--EASIER WAY OF UPDATING AND ALTERING OWNERADDRESS INTO # COLUMNS WITH PARSENAME


--CHANGE Y AND N to Yes and No in "Sold as Vacant" Field with CASE STATEMENT

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY Count DESC

SELECT SoldAsVacant,
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END AS New_Yes_No
FROM Nashville

--ALTER TABLE-- Adding a column
ALTER TABLE Nashville
ADD New_Yes_No NVARCHAR(255);
--UPDATE
UPDATE Nashville
SET New_Yes_No = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END 

SELECT DISTINCT(New_Yes_No), COUNT(New_Yes_No) AS Count
FROM Nashville
GROUP BY New_Yes_No
ORDER BY Count DESC

--IF I WANTED TO DELETE COLUMNS--------------------------------
ALTER TABLE Nashville
DROP COLUMN New_Yes_No

--FINDING AND REMOVING DUPLICATES BY USING TEMP TABLE CTE PART !

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
								PARTITION BY ParcelID,
											 PropertyAddress,
											 SalePrice,
											 Saledate,
											 LegalReference
								ORDER BY
											 UniqueID
							 )row_num
FROM Nashville
				)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETION PART 2--------------------------------------------
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
								PARTITION BY ParcelID,
											 PropertyAddress,
											 SalePrice,
											 Saledate,
											 LegalReference
								ORDER BY
											 UniqueID
							 )row_num
FROM Nashville
				)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--REMOVE UNUSED COLUMNS--------------------------------------
SELECT *
FROM Nashville

ALTER TABLE
DROP COLUMN PropertyAdress, SaleDate, OwnerAddress

