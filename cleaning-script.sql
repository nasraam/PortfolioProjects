/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %e, %Y') AS CleanedDate
FROM NashvilleHousing;

SET SQL_SAFE_UPDATES = 0;

UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y')
WHERE SaleDate LIKE '%,%';

SELECT DISTINCT SaleDate
FROM NashvilleHousing
LIMIT 100;


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;



UPDATE NashvilleHousing
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
WHERE a.PropertyAddress IS NULL;

SET SQL_SAFE_UPDATES = 0;

UPDATE NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.`UniqueID` <> b.`UniqueID`
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;






--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM NashvilleHousing;


SELECT
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1)  AS Address
,  SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, CHAR_LENGTH(PropertyAddress))  AS Address
FROM NashvilleHousing;



ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitAddress VARCHAR(225);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1);

ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitCity VARCHAR(225);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, CHAR_LENGTH(PropertyAddress));

SELECT *
FROM NashvilleHousing;




SELECT OwnerAddress
FROM NashvilleHousing;


SELECT
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)
,SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1)
,SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1)
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1);

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitCity VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1);


ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitState VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1);

SELECT *
FROM NashvilleHousing;



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant
, CASE when SoldAsVacant = "Y" THEN "Yes"
	   When SoldAsVacant = "N" THEN "No"
       ELSE SoldAsVacant
       END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = "Y" THEN "Yes"
	   When SoldAsVacant = "N" THEN "No"
       ELSE SoldAsVacant
       END;
       
       
     -- Remove Duplicates
  
  WITH RowNumCTE AS(
     SELECT * , 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
        ORDER BY UniqueID
		) AS row_num
                     
				
     FROM NashvilleHousing
     )
   SELECT *
		FROM RowNumCTE
        WHERE row_num > 1
        ORDER BY PropertyAddress;
  
      SELECT *
      FROM NashvilleHousing;
      
      
      
      -- Delete Unused Columns
      
      SELECT *
      FROM NashvilleHousing;
      
      ALTER TABLE NashvilleHousing
      DROP COLUMN OwnerAddress,
      DROP COLUMN TaxDistrict,
      DROP COLUMN PropertyAddress;
      
	
    ALTER TABLE NashvilleHousing
    DROP COLUMN SaleDate;