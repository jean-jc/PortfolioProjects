
--Cleaning data using sql queries


SELECT *
FROM NashvilleHousing;


--Standardize the date format from datetime to date

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

SELECT SaleDate
FROM NashvilleHousing;

--populate property address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID; --parcel ids match property address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


--Breaking up Property Address address into different columns (Address, City)

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


--Breaking up Owner Address into separate columns (Address, City, State)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress + ',') - 1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress + ',') + 1, CHARINDEX(',', OwnerAddress + ',', 
	CHARINDEX(',', OwnerAddress + ',') + 1) - CHARINDEX(',', OwnerAddress + ',') - 1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress + ',', CHARINDEX(',', OwnerAddress + ',') + 1) + 1, 
	LEN(OwnerAddress));



--change Y and N to Yes and No in 'SoldAsVacant' field


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
ORDER BY 2; --to see the number of records that has Y or N instead of Yes or No in the 'SoldAsVacant' fiel



UPDATE NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;


--Remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) RowNum
FROM NashvilleHousing)
DELETE --it is not in best practice to delete from a database
FROM RowNumCTE
WHERE RowNum > 1;


--Delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, Taxdistrict;

