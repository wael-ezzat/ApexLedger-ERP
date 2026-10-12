-- ===============================================================================
-- Project: ApexLedger ERP (SQL Server Database Schema)
-- Version: 1.2.0 (Base Open Core Architecture)
-- Author: Wael Ezzat
-- Description: Core Database Tables, Relationships, and Data Types Definition.
-- 
-- NOTE ON COMMERCIAL FEATURES:
-- This public file includes the foundational database schema (21 Core Tables).
-- Advanced operational triggers (Real-time Stock Sync, Negative Balance Prevention),
-- Full System Audit Logging, and 48/48 Automated Test Validation Scripts are 
-- exclusively included in the Production Commercial Package available at:
-- https://waelezzat.gumroad.com/l/apexledger-erp-v120
-- ===============================================================================

USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ApexLedgerERP')
BEGIN
    CREATE DATABASE [ApexLedgerERP];
END;
GO

USE [ApexLedgerERP];
GO

-- ===============================================================================
-- 1. SECURITY & RBAC MODULE
-- ===============================================================================

CREATE TABLE [dbo].[Roles] (
    [RoleID] INT IDENTITY(1,1) PRIMARY KEY,
    [RoleName] NVARCHAR(50) NOT NULL UNIQUE,
    [Description] NVARCHAR(255) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [dbo].[Users] (
    [UserID] INT IDENTITY(1,1) PRIMARY KEY,
    [Username] NVARCHAR(50) NOT NULL UNIQUE,
    [Email] NVARCHAR(100) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(256) NOT NULL,
    [RoleID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Roles]([RoleID]),
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- ===============================================================================
-- 2. MASTER DATA MODULE (ITEMS, CATEGORIES, WAREHOUSES)
-- ===============================================================================

CREATE TABLE [dbo].[Categories] (
    [CategoryID] INT IDENTITY(1,1) PRIMARY KEY,
    [CategoryName] NVARCHAR(100) NOT NULL UNIQUE,
    [ParentCategoryID] INT NULL FOREIGN KEY REFERENCES [dbo].[Categories]([CategoryID])
);

CREATE TABLE [dbo].[Items] (
    [ItemID] INT IDENTITY(1,1) PRIMARY KEY,
    [SKU] NVARCHAR(50) NOT NULL UNIQUE,
    [ItemName] NVARCHAR(150) NOT NULL,
    [CategoryID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Categories]([CategoryID]),
    [UnitPrice] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [CostPrice] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [ReorderLevel] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [dbo].[Warehouses] (
    [WarehouseID] INT IDENTITY(1,1) PRIMARY KEY,
    [WarehouseName] NVARCHAR(100) NOT NULL UNIQUE,
    [Location] NVARCHAR(255) NULL
);

CREATE TABLE [dbo].[StockBalances] (
    [StockID] INT IDENTITY(1,1) PRIMARY KEY,
    [ItemID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Items]([ItemID]),
    [WarehouseID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Warehouses]([WarehouseID]),
    [QuantityOnHand] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [ReservedQuantity] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    CONSTRAINT UQ_Item_Warehouse UNIQUE ([ItemID], [WarehouseID])
);

-- ===============================================================================
-- 3. GENERAL LEDGER & ACCOUNTING MODULE
-- ===============================================================================

CREATE TABLE [dbo].[ChartOfAccounts] (
    [AccountID] INT IDENTITY(1,1) PRIMARY KEY,
    [AccountCode] NVARCHAR(20) NOT NULL UNIQUE,
    [AccountName] NVARCHAR(100) NOT NULL,
    [AccountType] NVARCHAR(30) NOT NULL, -- Asset, Liability, Equity, Revenue, Expense
    [ParentAccountID] INT NULL FOREIGN KEY REFERENCES [dbo].[ChartOfAccounts]([AccountID]),
    [IsActive] BIT NOT NULL DEFAULT 1
);

CREATE TABLE [dbo].[JournalHeaders] (
    [JournalID] INT IDENTITY(1,1) PRIMARY KEY,
    [VoucherNumber] NVARCHAR(50) NOT NULL UNIQUE,
    [TransactionDate] DATETIME2 NOT NULL,
    [Description] NVARCHAR(255) NULL,
    [CreatedByUserID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Users]([UserID]),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [dbo].[JournalDetails] (
    [JournalDetailID] INT IDENTITY(1,1) PRIMARY KEY,
    [JournalID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[JournalHeaders]([JournalID]) ON DELETE CASCADE,
    [AccountID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[ChartOfAccounts]([AccountID]),
    [DebitAmount] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [CreditAmount] DECIMAL(18,4) NOT NULL DEFAULT 0.0000
);

-- ===============================================================================
-- 4. COMMERCIAL MODULE (COMMERCIAL PARTNERS & TRANSACTIONS)
-- ===============================================================================

CREATE TABLE [dbo].[Partners] (
    [PartnerID] INT IDENTITY(1,1) PRIMARY KEY,
    [PartnerName] NVARCHAR(150) NOT NULL,
    [PartnerType] NVARCHAR(20) NOT NULL, -- Customer, Vendor, Both
    [Email] NVARCHAR(100) NULL,
    [Phone] NVARCHAR(30) NULL,
    [Address] NVARCHAR(255) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE [dbo].[SalesHeaders] (
    [SalesInvoiceID] INT IDENTITY(1,1) PRIMARY KEY,
    [InvoiceNumber] NVARCHAR(50) NOT NULL UNIQUE,
    [CustomerID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Partners]([PartnerID]),
    [InvoiceDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [TotalAmount] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [CreatedByUserID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Users]([UserID])
);

CREATE TABLE [dbo].[SalesDetails] (
    [SalesDetailID] INT IDENTITY(1,1) PRIMARY KEY,
    [SalesInvoiceID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SalesHeaders]([SalesInvoiceID]) ON DELETE CASCADE,
    [ItemID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Items]([ItemID]),
    [WarehouseID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Warehouses]([WarehouseID]),
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitPrice] DECIMAL(18,4) NOT NULL,
    [LineTotal] AS ([Quantity] * [UnitPrice])
);

CREATE TABLE [dbo].[PurchaseHeaders] (
    [PurchaseInvoiceID] INT IDENTITY(1,1) PRIMARY KEY,
    [InvoiceNumber] NVARCHAR(50) NOT NULL UNIQUE,
    [VendorID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Partners]([PartnerID]),
    [InvoiceDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [TotalAmount] DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    [CreatedByUserID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Users]([UserID])
);

CREATE TABLE [dbo].[PurchaseDetails] (
    [PurchaseDetailID] INT IDENTITY(1,1) PRIMARY KEY,
    [PurchaseInvoiceID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[PurchaseHeaders]([PurchaseInvoiceID]) ON DELETE CASCADE,
    [ItemID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Items]([ItemID]),
    [WarehouseID] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Warehouses]([WarehouseID]),
    [Quantity] DECIMAL(18,4) NOT NULL,
    [UnitPrice] DECIMAL(18,4) NOT NULL,
    [LineTotal] AS ([Quantity] * [UnitPrice])
);

-- ===============================================================================
-- 5. AUDIT LOGGING SCHEMA STUB (FULL IMPLEMENTATION IN COMMERCIAL LICENSE)
-- ===============================================================================

CREATE TABLE [dbo].[AuditLogs] (
    [AuditID] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [TableName] NVARCHAR(128) NOT NULL,
    [ActionType] NVARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    [PerformedByUserID] INT NULL,
    [TimestampUtc] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [OldValuesXml] XML NULL,
    [NewValuesXml] XML NULL
);

GO
