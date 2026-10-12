IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ApexLedgerERP_DB')
BEGIN
    ALTER DATABASE ApexLedgerERP_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ApexLedgerERP_DB;
END
GO

CREATE DATABASE ApexLedgerERP_DB;
GO

USE ApexLedgerERP_DB;
GO

SET NOCOUNT ON;
GO

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) NOT NULL,
    RoleKey VARCHAR(50) NOT NULL,                
    RoleNameEn NVARCHAR(100) NOT NULL,           
    RoleNameAr NVARCHAR(100) NOT NULL,           
    IsActive BIT DEFAULT (1) NOT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY CLUSTERED (RoleId ASC),
    CONSTRAINT UQ_Roles_RoleKey UNIQUE (RoleKey)
);

CREATE TABLE Permissions (
    PermissionId INT IDENTITY(1,1) NOT NULL,
    PermissionKey VARCHAR(100) NOT NULL,          
    DescriptionEn NVARCHAR(250) NULL,             
    DescriptionAr NVARCHAR(250) NULL,             
    CONSTRAINT PK_Permissions PRIMARY KEY CLUSTERED (PermissionId ASC),
    CONSTRAINT UQ_Permissions_PermissionKey UNIQUE (PermissionKey)
);

CREATE TABLE RolePermissions (
    RoleId INT NOT NULL,
    PermissionId INT NOT NULL,
    GrantedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_RolePermissions PRIMARY KEY CLUSTERED (RoleId ASC, PermissionId ASC),
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY (RoleId) REFERENCES Roles (RoleId) ON DELETE CASCADE,
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY (PermissionId) REFERENCES Permissions (PermissionId) ON DELETE CASCADE
);

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) NOT NULL,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,          
    FullName NVARCHAR(150) NOT NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    LastLoginAt DATETIME NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId ASC),
    CONSTRAINT UQ_Users_Username UNIQUE (Username),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);

CREATE TABLE UserRoles (
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    AssignedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_UserRoles PRIMARY KEY CLUSTERED (UserId ASC),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES Users (UserId) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES Roles (RoleId) ON DELETE CASCADE
);

CREATE TABLE AuditLogs (
    LogId BIGINT IDENTITY(1,1) NOT NULL,
    UserId INT NULL,
    ActionType VARCHAR(50) NOT NULL,             
    TableName VARCHAR(100) NOT NULL,
    RecordId INT NULL,
    OldValues NVARCHAR(MAX) NULL,                
    NewValues NVARCHAR(MAX) NULL,                
    IpAddress VARCHAR(45) NULL,
    ExecutedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_AuditLogs PRIMARY KEY CLUSTERED (LogId ASC),
    CONSTRAINT FK_AuditLogs_Users FOREIGN KEY (UserId) REFERENCES Users (UserId) ON DELETE SET NULL
);
GO

CREATE TABLE Branches (
    BranchId INT IDENTITY(1,1) NOT NULL,
    BranchCode VARCHAR(20) NOT NULL,
    BranchNameEn NVARCHAR(100) NOT NULL,
    BranchNameAr NVARCHAR(100) NOT NULL,
    AddressEn NVARCHAR(250) NULL,
    AddressAr NVARCHAR(250) NULL,
    Phone VARCHAR(20) NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Branches PRIMARY KEY CLUSTERED (BranchId ASC),
    CONSTRAINT UQ_Branches_BranchCode UNIQUE (BranchCode)
);

CREATE TABLE Warehouses (
    WarehouseId INT IDENTITY(1,1) NOT NULL,
    BranchId INT NOT NULL,
    WarehouseCode VARCHAR(20) NOT NULL,
    WarehouseNameEn NVARCHAR(100) NOT NULL,
    WarehouseNameAr NVARCHAR(100) NOT NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Warehouses PRIMARY KEY CLUSTERED (WarehouseId ASC),
    CONSTRAINT UQ_Warehouses_WarehouseCode UNIQUE (WarehouseCode),
    CONSTRAINT FK_Warehouses_Branches FOREIGN KEY (BranchId) REFERENCES Branches (BranchId) ON DELETE CASCADE
);

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) NOT NULL,
    CategoryCode VARCHAR(20) NOT NULL,
    CategoryNameEn NVARCHAR(100) NOT NULL,
    CategoryNameAr NVARCHAR(100) NOT NULL,
    ParentCategoryId INT NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (CategoryId ASC),
    CONSTRAINT UQ_Categories_CategoryCode UNIQUE (CategoryCode),
    CONSTRAINT FK_Categories_Categories FOREIGN KEY (ParentCategoryId) REFERENCES Categories (CategoryId)
);

CREATE TABLE ProductUnits (
    UnitId INT IDENTITY(1,1) NOT NULL,
    UnitNameEn NVARCHAR(50) NOT NULL,
    UnitNameAr NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_ProductUnits PRIMARY KEY CLUSTERED (UnitId ASC)
);

CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) NOT NULL,
    CategoryId INT NOT NULL,
    UnitId INT NOT NULL,
    ProductSku VARCHAR(50) NOT NULL,
    ProductNameEn NVARCHAR(150) NOT NULL,
    ProductNameAr NVARCHAR(150) NOT NULL,
    CostPrice DECIMAL(18, 4) NOT NULL,
    SalePrice DECIMAL(18, 4) NOT NULL,
    MinimumStockLevel INT DEFAULT (0) NOT NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (ProductId ASC),
    CONSTRAINT UQ_Products_ProductSku UNIQUE (ProductSku),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId),
    CONSTRAINT FK_Products_ProductUnits FOREIGN KEY (UnitId) REFERENCES ProductUnits (UnitId)
);

CREATE TABLE ProductStock (
    StockId BIGINT IDENTITY(1,1) NOT NULL,
    BranchId INT NOT NULL,
    WarehouseId INT NOT NULL,
    ProductId INT NOT NULL,
    CurrentQuantity DECIMAL(18, 3) DEFAULT (0.000) NOT NULL,
    LastUpdatedUser INT NULL,
    LastUpdatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_ProductStock PRIMARY KEY CLUSTERED (StockId ASC),
    CONSTRAINT UQ_Branch_Warehouse_Product UNIQUE (BranchId, WarehouseId, ProductId),
    CONSTRAINT FK_ProductStock_Branches FOREIGN KEY (BranchId) REFERENCES Branches (BranchId),
    CONSTRAINT FK_ProductStock_Warehouses FOREIGN KEY (WarehouseId) REFERENCES Warehouses (WarehouseId),
    CONSTRAINT FK_ProductStock_Products FOREIGN KEY (ProductId) REFERENCES Products (ProductId) ON DELETE CASCADE,
    CONSTRAINT FK_ProductStock_Users FOREIGN KEY (LastUpdatedUser) REFERENCES Users (UserId) ON DELETE SET NULL
);
GO

CREATE TABLE Suppliers (
    SupplierId INT IDENTITY(1,1) NOT NULL,
    SupplierCode VARCHAR(20) NOT NULL,
    SupplierNameEn NVARCHAR(150) NOT NULL,
    SupplierNameAr NVARCHAR(150) NOT NULL,
    VatNumber VARCHAR(30) NULL,                  
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Suppliers PRIMARY KEY CLUSTERED (SupplierId ASC),
    CONSTRAINT UQ_Suppliers_SupplierCode UNIQUE (SupplierCode)
);

CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) NOT NULL,
    CustomerCode VARCHAR(20) NOT NULL,
    CustomerNameEn NVARCHAR(150) NOT NULL,
    CustomerNameAr NVARCHAR(150) NOT NULL,
    VatNumber VARCHAR(30) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    IsActive BIT DEFAULT (1) NOT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (CustomerId ASC),
    CONSTRAINT UQ_Customers_CustomerCode UNIQUE (CustomerCode)
);

CREATE TABLE PurchaseInvoices (
    PurchaseInvoiceId BIGINT IDENTITY(1,1) NOT NULL,
    BranchId INT NOT NULL,
    WarehouseId INT NOT NULL,
    SupplierId INT NOT NULL,
    InvoiceNumber VARCHAR(50) NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    TotalSubTotal DECIMAL(18,4) NOT NULL,
    TotalDiscount DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
    TotalVat DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
    TotalFinal DECIMAL(18,4) NOT NULL,
    PaymentType VARCHAR(20) NOT NULL,            
    CreatedByUser INT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_PurchaseInvoices PRIMARY KEY CLUSTERED (PurchaseInvoiceId ASC),
    CONSTRAINT UQ_PurchaseInvoices_Number UNIQUE (InvoiceNumber),
    CONSTRAINT FK_PurchaseInvoices_Branches FOREIGN KEY (BranchId) REFERENCES Branches (BranchId),
    CONSTRAINT FK_PurchaseInvoices_Warehouses FOREIGN KEY (WarehouseId) REFERENCES Warehouses (WarehouseId),
    CONSTRAINT FK_PurchaseInvoices_Suppliers FOREIGN KEY (SupplierId) REFERENCES Suppliers (SupplierId),
    CONSTRAINT FK_PurchaseInvoices_Users FOREIGN KEY (CreatedByUser) REFERENCES Users (UserId)
);

CREATE TABLE PurchaseInvoiceDetails (
    PurchaseDetailId BIGINT IDENTITY(1,1) NOT NULL,
    PurchaseInvoiceId BIGINT NOT NULL,
    ProductId INT NOT NULL,
    Quantity DECIMAL(18,3) NOT NULL,
    UnitPrice DECIMAL(18,4) NOT NULL,
    DiscountAmount DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
    VatPercentage DECIMAL(5,2) DEFAULT (14.00) NOT NULL, 
    VatAmount DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
    RowTotal DECIMAL(18,4) NOT NULL,
    CONSTRAINT PK_PurchaseInvoiceDetails PRIMARY KEY CLUSTERED (PurchaseDetailId ASC),
    CONSTRAINT FK_PurchaseInvoiceDetails_Header FOREIGN KEY (PurchaseInvoiceId) REFERENCES PurchaseInvoices (PurchaseInvoiceId) ON DELETE CASCADE,
    CONSTRAINT FK_PurchaseInvoiceDetails_Products FOREIGN KEY (ProductId) REFERENCES Products (ProductId)
);

CREATE TABLE SalesInvoices (
    SalesInvoiceId BIGINT IDENTITY(1,1) NOT NULL,
    BranchId INT NOT NULL,
    WarehouseId INT NOT NULL,
    CustomerId INT NOT NULL,
    InvoiceNumber VARCHAR(50) NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    TotalSubTotal DECIMAL(18,4) NOT NULL,
    TotalDiscount DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
    TotalVat DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
    TotalFinal DECIMAL(18,4) NOT NULL,
    PaymentType VARCHAR(20) NOT NULL,            
    CreatedByUser INT NULL,
    CreatedAt DATETIME DEFAULT (GETDATE()) NOT NULL,
	CONSTRAINT PK_SalesInvoices PRIMARY KEY CLUSTERED (SalesInvoiceId ASC),
CONSTRAINT UQ_SalesInvoices_Number UNIQUE (InvoiceNumber),
CONSTRAINT FK_SalesInvoices_Branches_KEY_REFB FOREIGN KEY (BranchId) REFERENCES Branches (BranchId),
CONSTRAINT FK_SalesInvoices_Warehouses_KEY_REFW FOREIGN KEY (WarehouseId) REFERENCES Warehouses (WarehouseId),
CONSTRAINT FK_SalesInvoices_Customers_KEY_REFC FOREIGN KEY (CustomerId) REFERENCES Customers (CustomerId),
CONSTRAINT FK_SalesInvoices_Users_KEY_REFU FOREIGN KEY (CreatedByUser) REFERENCES Users (UserId)
);
CREATE TABLE SalesInvoiceDetails (
SalesDetailId BIGINT IDENTITY(1,1) NOT NULL,
SalesInvoiceId BIGINT NOT NULL,
ProductId INT NOT NULL,
Quantity DECIMAL(18,3) NOT NULL,
UnitPrice DECIMAL(18,4) NOT NULL,
DiscountAmount DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
VatPercentage DECIMAL(5,2) DEFAULT (14.00) NOT NULL,
VatAmount DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
RowTotal DECIMAL(18,4) NOT NULL,
CONSTRAINT PK_SalesInvoiceDetails PRIMARY KEY CLUSTERED (SalesDetailId ASC),
CONSTRAINT FK_SalesInvoiceDetails_Header FOREIGN KEY (SalesInvoiceId) REFERENCES SalesInvoices (SalesInvoiceId) ON DELETE CASCADE,
CONSTRAINT FK_SalesInvoiceDetails_Products FOREIGN KEY (ProductId) REFERENCES Products (ProductId)
);
GO
CREATE TABLE Accounts (
AccountId INT IDENTITY(1,1) NOT NULL,
AccountCode VARCHAR(20) NOT NULL,
AccountNameEn NVARCHAR(150) NOT NULL,
AccountNameAr NVARCHAR(150) NOT NULL,
AccountType VARCHAR(30) NOT NULL,
ParentAccountId INT NULL,
IsActive BIT DEFAULT (1) NOT NULL,
CONSTRAINT PK_Accounts PRIMARY KEY CLUSTERED (AccountId ASC),
CONSTRAINT UQ_Accounts_Code UNIQUE (AccountCode),
CONSTRAINT FK_Accounts_Parent FOREIGN KEY (ParentAccountId) REFERENCES Accounts (AccountId)
);
CREATE TABLE JournalEntries (
EntryId BIGINT IDENTITY(1,1) NOT NULL,
EntryNumber VARCHAR(50) NOT NULL,
EntryDate DATETIME DEFAULT (GETDATE()) NOT NULL,
ReferenceSource VARCHAR(50) NULL,
NarrationEn NVARCHAR(250) NULL,
NarrationAr NVARCHAR(250) NULL,
CreatedByUser INT NULL,
CONSTRAINT PK_JournalEntries PRIMARY KEY CLUSTERED (EntryId ASC),
CONSTRAINT UQ_JE_Number UNIQUE (EntryNumber),
CONSTRAINT FK_JE_Users FOREIGN KEY (CreatedByUser) REFERENCES Users (UserId)
);
CREATE TABLE JournalEntryLines (
LineId BIGINT IDENTITY(1,1) NOT NULL,
EntryId BIGINT NOT NULL,
AccountId INT NOT NULL,
Debit DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
Credit DECIMAL(18,4) DEFAULT (0.0000) NOT NULL,
CONSTRAINT PK_JournalEntryLines PRIMARY KEY CLUSTERED (LineId ASC),
CONSTRAINT FK_JEL_Header FOREIGN KEY (EntryId) REFERENCES JournalEntries (EntryId) ON DELETE CASCADE,
CONSTRAINT FK_JEL_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts (AccountId),
CONSTRAINT CK_Debit_Positive CHECK (Debit >= 0),
CONSTRAINT CK_Credit_Positive CHECK (Credit >= 0)
);
GO
CREATE TRIGGER TR_SalesInvoiceDetails_Insert
ON SalesInvoiceDetails
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
UPDATE PS
SET PS.CurrentQuantity = PS.CurrentQuantity - I.Quantity,
PS.LastUpdatedAt = GETDATE()
FROM ProductStock PS
INNER JOIN inserted I ON PS.ProductId = I.ProductId
INNER JOIN SalesInvoices SI ON I.SalesInvoiceId = SI.SalesInvoiceId
WHERE PS.BranchId = SI.BranchId
AND PS.WarehouseId = SI.WarehouseId;
INSERT INTO ProductStock (BranchId, WarehouseId, ProductId, CurrentQuantity, LastUpdatedAt)
SELECT SI.BranchId, SI.WarehouseId, I.ProductId, -I.Quantity, GETDATE()
FROM inserted I
INNER JOIN SalesInvoices SI ON I.SalesInvoiceId = SI.SalesInvoiceId
WHERE NOT EXISTS (
SELECT 1 FROM ProductStock PS
WHERE PS.BranchId = SI.BranchId
AND PS.WarehouseId = SI.WarehouseId
AND PS.ProductId = I.ProductId
);
END;
GO
CREATE TRIGGER TR_PurchaseInvoiceDetails_Insert
ON PurchaseInvoiceDetails
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
UPDATE PS
SET PS.CurrentQuantity = PS.CurrentQuantity + I.Quantity,
PS.LastUpdatedAt = GETDATE()
FROM ProductStock PS
INNER JOIN inserted I ON PS.ProductId = I.ProductId
INNER JOIN PurchaseInvoices PI ON I.PurchaseInvoiceId = PI.PurchaseInvoiceId
WHERE PS.BranchId = PI.BranchId
AND PS.WarehouseId = PI.WarehouseId;
INSERT INTO ProductStock (BranchId, WarehouseId, ProductId, CurrentQuantity, LastUpdatedAt)
SELECT PI.BranchId, PI.WarehouseId, I.ProductId, I.Quantity, GETDATE()
FROM inserted I
INNER JOIN PurchaseInvoices PI ON I.PurchaseInvoiceId = PI.PurchaseInvoiceId
WHERE NOT EXISTS (
SELECT 1 FROM ProductStock PS
WHERE PI.BranchId = PS.BranchId
AND PI.WarehouseId = PS.WarehouseId
AND I.ProductId = PS.ProductId
);
UPDATE P
SET P.CostPrice = I.UnitPrice
FROM Products P
INNER JOIN inserted I ON P.ProductId = I.ProductId;
END;
GO
