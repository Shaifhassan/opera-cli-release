## Opera PMS Excel Connector

> A lightweight solution for Excel to retrieve data from Opera PMS using custom formulas and a secure connector.

---

## What is Opera PMS Excel Connector?

**Opera PMS Excel Connector** is a solution that enables Excel users to fetch Opera PMS data through custom Excel formulas. It is built around a lightweight Rust-based data connector that links Excel to Opera without requiring heavy third-party clients.

This solution is designed for analysts and reporting teams who want the flexibility of Excel while keeping Opera SQL logic centralized and reusable.

### Core Components

1. **Data Connector**
   - A Rust application that bridges Excel and Opera.
   - Can run locally or inside Docker.
   - Handles secure database connections and returns Opera data to Excel.

2. **Excel Add-in**
   - Adds new custom formulas directly to Excel.
   - Lets users request Opera data by formula, without manual exports.

3. **Database Objects**
   - Custom tables and stored procedures for Opera setup.
   - Provides reusable database objects that support the connector and Excel formulas.

---

### Why this solution matters

- **Excel-first workflows:** Keep analysis in Excel while sourcing live Opera PMS data.
- **Minimal dependencies:** No heavy PMS client is required on the user machine.
- **Flexible deployment:** Run the connector locally or in Docker depending on your environment.
- **Reusable logic:** SQL and database procedures are managed centrally, not scattered across spreadsheets.

---

### Features at a glance

| Feature              | Benefit                                                                 |
| -------------------- | ----------------------------------------------------------------------- |
| Custom Excel formula | Pull Opera PMS data directly into worksheets with a single formula.     |
| Rust connector       | Reliable, high-performance connector that can run locally or in Docker. |
| Database objects     | Structured Opera-side setup for reusable queries and stored procedures. |
| Secure connection    | Protects Opera credentials and reduces manual database access.          |

---
