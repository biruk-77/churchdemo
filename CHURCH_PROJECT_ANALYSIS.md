# Ethiopian Orthodox Tewahedo Church (EOTC) Digital Platform
## Comprehensive System & Architecture Analysis

---

## Executive Summary

The **EOTC Digital Contribution & Governance Ecosystem** is a dual-platform digital infrastructure designed to modernize financial contributions, parish administration, and spiritual communication for the Ethiopian Orthodox Tewahedo Church (EOTC). 

The platform bridges traditional church practices—such as **Asrat (ዓሥራት - Tithes)**, **Bekuart (በኵራት - Firstfruits)**, and **Mitzwat/Selet (ምፅዋት/ስእለት - Offerings & Vows)**—with modern digital payment solutions, transparent accounting, and multi-tier administrative governance.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           EOTC DIGITAL ECOSYSTEM                                │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
          ┌───────────────────────────┴───────────────────────────┐
          ▼                                                       ▼
┌───────────────────────────────────┐                   ┌───────────────────────────────────┐
│     MOBILE APP (`church`)         │                   │   WEB ADMIN (`church_admin_web`)  │
│  Flutter (iOS & Android)          │                   │   React 19 + Vite + TailwindCSS   │
└───────────────────────────────────┘                   └───────────────────────────────────┘
                  │                                                       │
                  └───────────────────────────┬───────────────────────────┘
                                              ▼
                               ┌──────────────────────────────┐
                               │       FIREBASE BACKEND       │
                               │  Auth, Firestore, Messaging  │
                               │   Storage, Rules & Indexes   │
                               └──────────────────────────────┘
                                              │
                                              ▼
                               ┌──────────────────────────────┐
                               │   ETHIOPIAN PAYMENT HUBS     │
                               │ Telebirr, CBE Birr, Chapa    │
                               └──────────────────────────────┘
```

---

## Key Modules & Core Solutions

### 1. Flutter Mobile Application (`church`)
- **Target Audience:** Church members, parish faithful, and donors.
- **Core Technology:** Flutter (Dart), Riverpod (State Management), GoRouter, Firebase SDKs, Dio HTTP client, PDF generation & printing engine.

#### Core Problems Solved:
1. **Frictionless Asrat (Tithes 10%) & Offerings:**
   - Enables members anywhere in Ethiopia or the Diaspora to calculate and remit their monthly 10% tithe (**Asrat**), firstfruits (**Bekuart**), and special pledges directly to their home parish.
2. **Local Payment Gateway Integration:**
   - Seamlessly connects with Ethiopian payment providers including **Telebirr**, **CBE Birr**, **Chapa**, and direct Bank Transfers.
3. **Parish & Diocese Mapping:**
   - Members can search, select, and affiliate with their specific local church/parish under their respective Diocese (**ሀገረ ስብከት**).
4. **Digital Receipting & Auditing:**
   - Instantly generates verifiable digital and printable PDF receipts with transaction reference numbers for tax and canonical auditing.
5. **Real-time Notifications & Announcements:**
   - Keeps members updated on parish events, holy day celebrations, emergency relief appeals, and spiritual advisories via Firebase Cloud Messaging.

---

### 2. React Admin Web Portal (`church_admin_web`)
- **Target Audience:** Bishops, Archdioceses, Parish Administrators, Clergy, and Treasurers.
- **Core Technology:** React 19, Vite, TailwindCSS v4, MapLibre GL (Interactive Mapping), Firebase Firestore & Security Rules.

#### Core Problems Solved:
1. **Hierarchical Diocese Management (**ሀገረ ስብከት**):**
   - Provides macro and micro administrative oversight across dioceses, sub-dioceses, and individual parishes with interactive geographical map visualization (MapLibre GL).
2. **Transparent Financial Accounting & Reporting:**
   - Replaces vulnerable paper logbooks with real-time financial dashboards, break-down reports by contribution type (Asrat vs. Building Fund), and exportable audit ledgers.
3. **Centralized Member & Clergy Directory:**
   - Tracks parishioner registries, member contact details, and spiritual father (**የነፍስ አባት**) assignments.
4. **Broadcast & Public Relations Hub:**
   - Enables administrative authorized broadcast alerts directly to mobile app users in specific dioceses or nationwide.

---

## Primary Business & Canonical Problems Solved

| Problem | Traditional Process | EOTC Digital Platform Solution |
| :--- | :--- | :--- |
| **Manual Cash Ledgering** | Physical cash collection susceptible to manual errors or loss. | **Instant Digital Recording:** Automated ledgering in Firestore with cryptographically verifiable PDF receipts. |
| **Diaspora Contribution Barriers** | Difficult for overseas members to send regular tithes to home parishes. | **Multi-Currency & Gateways:** Mobile app integration with digital wallets and global payment gateways. |
| **Lack of Financial Visibility** | Dioceses lacked real-time visibility into local parish revenues. | **Centralized Admin Dashboard:** Real-time analytics, filtering by diocese, parish, date range, and contribution type. |
| **Member Engagement & Communication** | Notice boards and verbal announcements reached only physical attendees. | **Push Broadcast System:** Direct notifications for events, feasts, emergency funds, and spiritual guidance. |

---

## Security & Data Integrity
- **Granular Security Rules:** Implemented in `firestore.rules` to ensure members can only view their own contributions while parish admins access only authorized diocese data.
- **Secure Authentication:** Phone-number OTP authentication with session state management.
- **Auditable Transactions:** Every transaction is tied to an immutable receipt ID and timestamp.
