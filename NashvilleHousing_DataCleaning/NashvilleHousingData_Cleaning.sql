/*

CLEANING DATA IN SQL SERIES

*/


Select *
From Portfolio_Project.dbo.Nashville_Housing
--------------------------------------------------------------------------------------------------------------------------

-- STANDARDLIZE DATE FORMAT

Alter table Nashville_Housing
Add SaleDateConverted Date

Update Nashville_Housing
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
From Portfolio_Project.dbo.Nashville_Housing



 --------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

Select *
From Portfolio_Project.dbo.Nashville_Housing
Order by ParcelID
  
--- Self join to check if each ParcelID has the same PropertyAddress, then update the null Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
Join Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
Join Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

Select PropertyAddress
From Portfolio_Project.dbo.Nashville_Housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From Portfolio_Project.dbo.Nashville_Housing

Alter table Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From Portfolio_Project.dbo.Nashville_Housing


Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From Portfolio_Project.dbo.Nashville_Housing



Alter table Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Alter table Nashville_Housing
Drop column POwnerSplitCity;

Update Nashville_Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From Portfolio_Project.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------


-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.Nashville_Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Project.dbo.Nashville_Housing

Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select *
From Portfolio_Project.dbo.Nashville_Housing
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

Select *
From Portfolio_Project.dbo.Nashville_Housing

With RowNumCTE AS (
Select *, Row_number() over (
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID)
	row_num
From Portfolio_Project.dbo.Nashville_Housing
)

Delete
From RowNumCTE
Where row_num > 1


---------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS

Select *
From Portfolio_Project.dbo.Nashville_Housing


ALTER TABLE Portfolio_Project.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
