# ApexLedger ERP - Enterprise SQL Server Database Schema (v1.0.0)

**ApexLedger ERP** is a production-ready, highly optimized relational database schema designed for modern enterprise-grade solutions. Built using strict clean architectural standards for **Microsoft SQL Server 2019 and above**, this schema provides a solid foundation for software developers, architects, and startups looking to build Multi-Tenant SaaS or traditional localized ERP systems without wasting months on database planning.

---

## 🚀 Key Features & Architectural Highlights

- **Multi-Language (Localization) Support:** Built-in dual-language column implementation (English and Arabic) across core master tables (Products, Categories, Warehouses, Roles, and Accounts).
- **Intelligent Inventory Automation (Triggers):** Integrated backend triggers that dynamically manage real-time stock balances, automatic multi-warehouse logging, and rolling product cost price calculation on every sale or purchase transaction.
- **Enterprise Security (RBAC):** Granular Role-Based Access Control layout supporting infinite custom system roles, explicit permissions mapping, and user assignment tables.
- **System Audit Logging:** Complete administrative tracking engine that records database manipulations (`INSERT`, `UPDATE`, `DELETE`) with user context stamps.
- **Double-Entry Financial Accounting:** Full hierarchical Chart of Accounts schema supporting complex tree structures and strict self-balancing Journal Entry lines.

---

## 📂 Core Modules Included

1. **Identity & Security Module (RBAC):** `Users`, `Roles`, `Permissions`, `RolePermissions`, `UserRoles`, and `AuditLogs`.
2. **Logistics & Inventory Module:** `Branches`, `Warehouses`, `Categories`, `ProductUnits`, `Products`, and `ProductStock`.
3. **Commercial Trading Module:** `Suppliers`, `Customers`, `PurchaseInvoices`, `PurchaseInvoiceDetails`, `SalesInvoices`, and `SalesInvoiceDetails`.
4. **General Ledger Financial Module:** `Accounts` (Hierarchical tree configuration), `JournalEntries`, and `JournalEntryLines`.

---

## 🛠️ Deployment & Installation Guide

1. Open **SQL Server Management Studio (SSMS)** and connect to your SQL Server 2019+ instance.
2. Create a fresh target database configuration or let the initialization handler manage it.
3. Open a **New Query** window, paste the unified script contents from `ApexLedgerERP_Schema.sql`.
4. Click **Execute** (`F5`).
5. Ensure the success confirmation log appears inside the output window:  
   `SUCCESS: ApexLedger ERP Database Deployed Successfully on SQL 2019!`

---

## 📄 File Encoding Notice
This script utilizes `NVARCHAR` types to safely preserve localized Arabic configurations. The primary script file must be saved and kept under **UTF-8 with BOM Encoding** to prevent language compilation corruption across varying server locales.

---

## 🏛️ License & Copyright
© 2026 Wael Ezzat. All rights reserved. Registered Commercial Asset on Envato Market / CodeCanyon.
