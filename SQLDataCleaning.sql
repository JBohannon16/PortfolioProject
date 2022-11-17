/****** Data Cleaning Tenessee Housing Market Data using SQL  ******/

-------------------------------------------------

Select *
From dbo.NashvilleHousing

/* Standardize "date" format */

Select SaleDateConverted, CONVERT(date, SaleDate)
From dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------
/* Populate Property Address Data */

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Filling in the null values with the address from a record with the same property
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------
/* Breaking out Address into Individual Columns (Address, City, State) */


Select PropertyAddress
From dbo.NashvilleHousing

--Splitting data where the comma is located
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))as Address
from dbo.NashvilleHousing

--adding new splits into their own columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing

-- Same process for owner address field

Select OwnerAddress
From dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

Select *
from dbo.NashvilleHousing
order by ParcelID


--------------------------------------------------------
/* Change Y and N to Yes and No in "Sold as Vacant" field */
-- This is to standardize the data field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
,  CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From dbo.NashvilleHousing

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


-------------------------------------------------------------
/* Remove Duplicates */


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
FROM RowNumCTE
WHERE row_num > 1
Order By PropertyAddress


--------------------------------------------------
/* Delete Unused Columns */


Select *
From dbo.NashvilleHousing
Order by ParcelID

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate

