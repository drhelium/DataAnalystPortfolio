/* 
Cleaning Date in SQL Queries
*/

select * 
from NashvilleHousing

-- Standardize Date Format
Select SaleDate, Convert(Date, SaleDate) as UpdatedDate
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)



-- Populate Property Address Data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull (a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
Substring (PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))

Select * 
from NashvilleHousing


Select OwnerAddress
from NashvilleHousing

Select
Parsename(Replace(OwnerAddress,',','.'),1)
From NashvilleHousing

Select
Parsename(Replace(OwnerAddress,',','.'),3)
,Parsename(Replace(OwnerAddress,',','.'),2)
,Parsename(Replace(OwnerAddress,',','.'),1)
From NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)

Select *
from NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(Soldasvacant), Count(SoldasVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldasVacant
, 
Case 
	when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case 
	when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
End



-- Removing Duplicates


With RowNumCTE as (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From NashvilleHousing
--order by parcelID
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress


--Deleting
With RowNumCTE as (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From NashvilleHousing
--order by parcelID
)
Delete
From RowNumCTE
where row_num > 1
--order by PropertyAddress


-- Delete Unused Columns

Select *
From NashvilleHousingData..NashvilleHousing

Alter Table NashvilleHousingData..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table NashvilleHousingData..NashvilleHousing
Drop Column SaleDate

