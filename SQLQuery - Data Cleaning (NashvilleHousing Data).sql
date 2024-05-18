SELECT *
FROM NashvilleHousing

---TASK 1; POPULATING THE PROPERTYADDRESS COLUMN THAT CONTAIN NULL VALUES ---
--- Observed Parcel ID serves as an identifier for the address hence NULL spaces could be populated on the Property address
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

--- Doing a self join ---
SELECT *
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--- We want to populate the address in b.PropertyAddress on a.PropertyAddress ---
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---Confirming if it worked. No rows appeared, meaning that the column has been completely populated ---
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


--- TASK 2; SPLITTING THE ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) USING SUBSTRINGS ---
SELECT PropertyAddress
FROM NashvilleHousing --- Notice that it has the address and city together

--- Let's try to separate the City from the column using a SUBSTRING and CHARINDEX ---
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM NashvilleHousing --- Notice the comma delimiter is still showing just after the address

--- To remove the comma ---
SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM NashvilleHousing


--- Creating a column containing just the City ---
SELECT 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

--- Adding these 2 new columns to the table ---
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--- Let's see our result ---
SELECT *
FROM NashvilleHousing


--- STEP 3;  SPLITTING THE OWNERADDRESS ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) USING PARSE NAME ---
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)
 --- Note that parsename works with periods not commas hence the replace ---

FROM NashvilleHousing

--- Adding the new columns to the table and updating the values ---
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCityCode Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCityCode = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)

--- Let's See our result ---
SELECT *
FROM NashvilleHousing -- Made a naming error, but let's go on ---


--- TASK 4; CHANGE 1 and 0 TO YES AND NO IN 'SOLD AS VACANT FIELD' USING CASE STATEMENT ---
--- Let's see distinct values to be sure of the column distinct values ---
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = '1' THEN 'YES' 
	WHEN SoldAsVacant = '0' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

--- Let's Update the 'SoldAsVacant' field' ---
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = '1' THEN 'YES' 
	WHEN SoldAsVacant = '0' THEN 'NO'
	ELSE SoldAsVacant
	END

--- let's see our result ---
SELECT *
FROM NashvilleHousing


--- TASK 5; REMOVING DUPLICATES USING ROW NUMBER (IT'S NOT A STANDARD PRCTICE TO DLETE DATA IN YOUR DATABASE ---
---Write a CTE 
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
					ORDER BY UniqueID
					) ROW_NUM
from NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

--- DELETE THE DUPLICATE ---
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
					ORDER BY UniqueID
					) ROW_NUM
from NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1


--- See if it worked ---
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
					ORDER BY UniqueID
					) ROW_NUM
from NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

--- Yes, it did ---

--- TASK  6; DELETE UNUSED COLUMNS ---
SELECT *
FROM NashvilleHousing

--- Deleting OwnwerAddress, TaxDistrict, PropertyAddress ---
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--- See if it worked ---
SELECT *
FROM NashvilleHousing







 
