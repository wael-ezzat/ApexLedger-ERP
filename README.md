# 🏛️ ApexLedger ERP Database Schema (v1.2.0)
### Enterprise-Grade Production-Ready Foundation for Microsoft SQL Server

> **ApexLedger ERP** is a highly optimized, fully relational database schema designed for software engineers, database architects, and tech firms looking to accelerate the development of modern ERP systems and enterprise solutions on **Microsoft SQL Server 2019+** without wasting months designing schemas from scratch.

---

## 🏗️ Open Core vs. Commercial License Architecture

This repository adopts an **Open Core** approach to provide full visibility into our clean relational database architecture:

| Feature / Component | GitHub Open Core (Base Schema) | Gumroad Commercial Package |
| :--- | :---: | :---: |
| **21 Core Database Tables** | ✅ Included | ✅ Included |
| **Foreign Keys & Indexing Scheme** | ✅ Included | ✅ Included |
| **Real-time DML Stock Triggers** | ❌ Excluded | ✅ **Exclusive** |
| **Automated Negative Balance Guard** | ❌ Excluded | ✅ **Exclusive** |
| **Full System Audit Logging Engine** | ❌ (Structure Stub Only) | ✅ **Exclusive** |
| **48/48 Automated Validation Test Suite** | ❌ Excluded | ✅ **Exclusive** |
| **Production Deploy-Ready SQL Scripts** | ❌ Excluded | ✅ **Exclusive** |

🛒 **Get the Full Operational Triggers, Audit Engines, & Commercial License:**  
You can purchase and immediately download the commercial distribution package here:  
👉 **[ApexLedger ERP v1.2.0 on Gumroad](https://waelezzat.gumroad.com/l/apexledger-erp-v120)**

---

## 🎯 Why ApexLedger ERP?
Building enterprise ERP databases requires handling intricate inventory rules, double-entry accounting balances, and role-based access controls—a process that typically takes months of design and testing.  
**ApexLedger ERP** provides a battle-tested, 100% validated foundational schema so you can jump straight into building your application's logic and front-end features.

---

## ⚙️ Architectural Highlights

- **Localization & Dual-Language Support:** Schema includes bilingual column attributes (English & Arabic) across core entities (Products, Categories, Warehouses, Roles).
- **Smart Inventory Automation:** Advanced `DML Triggers` for real-time stock adjustment, moving average cost tracking, and negative stock enforcement *(Included in Commercial Package)*.
- **Role-Based Access Control (RBAC):** Granular security framework supporting system roles, individual user assignments, and detailed action permissions.
- **Full Audit Logging:** Administrative tracking engine capturing `INSERT`, `UPDATE`, and `DELETE` events with exact user stamps and XML context diffs.
- **Double-Entry General Ledger:** Flexible Chart of Accounts hierarchy supporting balanced journal entry workflows.

---

## 📂 Core Schema Modules (21 Tables)

The architecture is categorized into 4 core functional modules:

1. **Security & Identity (RBAC & Audit):**  
   - `Users`, `Roles`, `Permissions`, `RolePermissions`, `UserRoles`, `AuditLogs`
2. **Logistics & Inventory:**  
   - `Branches`, `Warehouses`, `Categories`, `ProductUnits`, `Products`, `ProductStock`
3. **Commercial Transactions (Sales & Purchasing):**  
   - `Suppliers`, `Customers`, `PurchaseInvoices`, `PurchaseInvoiceDetails`, `SalesInvoices`, `SalesInvoiceDetails`
4. **General Ledger & Accounting:**  
   - `Accounts`, `JournalEntries`, `JournalEntryLines`

---

## 🧪 Quality Assurance & Test Verification (100% Passed)

The database schema underwent rigorous automated validation and passed with a 100% score (48/48 tests):
- **15/15** Functional End-to-End Business Tests (Procurement & Sales Cycle).
- **12/12** Schema Hardening & Constraint Integrity Tests.
- **21/21** Security, Concurrency, and Data Protection Tests.

---

## 🛠️ Quick Start & Installation

1. Launch **SQL Server Management Studio (SSMS)** and connect to your SQL Server 2019+ instance.
2. Create a new empty database.
3. Open a `New Query` window and paste the contents of `ApexLedgerERP_DB.sql`.
4. Click **Execute** (or press `F5`).
5. Confirm successful deployment via the output messages panel:  
   `SUCCESS: ApexLedger ERP Base Schema Deployed Successfully on SQL Server!`

---

## 📄 Character Encoding Notice
The schema includes unicode column types (`NVARCHAR`). Ensure the SQL script is saved using **UTF-8 with BOM** encoding to preserve international character sets across different server collations.

---

## 🏛️ Legal & Licensing
© 2026 Wael Ezzat. All rights reserved.  
Refer to the [LICENSE](./LICENSE) file and our [Gumroad Commercial Page](https://waelezzat.gumroad.com/l/apexledger-erp-v120) for commercial deployments and rights usage.
