# Project: Family Neobank Ledger 

## 1. Project Overview
This application is a neobank ledger designed for families, operating on a hierarchical "Tree System." The core architecture revolves around two primary roles: **Parents** (administrators) and **Children** (dependents). 

## 2. Current State & Technical Context
* **Authentication:** The login page is already connected to Supabase. 
* **UI State:** The frontend screens are currently using static data and messy navigation. 
* **Current Objective:** Transition to real-time Supabase data, enforce strict financial data integrity, and refactor the Flutter UI to use Riverpod and a single navigation stack.

## 3. Core Architectural Rules (CRITICAL)
Before implementing any feature, the following rules must be strictly adhered to:
1.  **Financial Integrity:** The database is the absolute source of truth. Money is ALWAYS stored as integers (minor units like paisas/cents) to prevent float math errors. Client-side math is strictly forbidden for state updates. All money movement must occur inside a secure Postgres RPC transaction that debits/credits simultaneously.
2.  **State Management:** The app will use **Riverpod** for global state management (e.g., global balance, pending requests badge). Do not use `setState` for global data.
3.  **UI Navigation:** The app must have a single root `MaterialApp` and a single shared Bottom Navigation Bar component (`ParentBottomNav` / `ChildBottomNav`). Stop nesting Navigators. 
4.  **Database Topology:** Families are a distinct entity (`families` table). Users are linked to a `family_id`. 

## 4. Database Schema Guidelines
* **Families:** The central anchor `id`, `name`.
* **Profiles:** Links `id` to auth.users, holds `family_id`, `role` ('parent', 'child', 'pending'), and `balance` (BIGINT).
* **Invitations:** Secure table handling `family_id`, unique `code`, `role_offered`, and `expires_at`.
* **Transactions:** The immutable ledger. Records `sender_id`, `receiver_id`, `amount` (BIGINT), and timestamps. Never updated/deleted, only appended.
* **Requests:** State machine for borrow/loans. Tracks `requester_id`, `approver_id`, `amount`, and `status` ('pending' -> 'approved' -> 'executed').

## 5. Feature Breakdown & Implementation Requirements

### Onboarding Flow
* New users sign up and default to a `pending` role with a null `family_id`.
* They are immediately routed to a "Waiting for Invite / Enter Invite Code" screen.
* Redeeming a valid code from the `invitations` table securely assigns them to the family and updates their role.

### Parent Capabilities
* **Activities Section:** Fetch and monitor the ledger for every dependent linked to their `family_id`.
* **Tree Section (Management):** * Generate secure, single-use family invitations (inserts into `invitations` table).
    * View the aggregated monetary standing of the entire family.
    * Click on an individual dependent to adjust limits, or send money via the secure transfer RPC.

### Child Capabilities
* **Activities Section:** Fetch and display strictly their own personal transaction history from the ledger. 
* **Tree Section:** View a read-only list of family members.
* **Transactions:** Send money or request a borrow/loan (creates a 'pending' row in `requests`).
* **Pending Requests (`dependent_approval11` screen):** Use a Riverpod `StreamProvider` to dynamically check Supabase for any active/pending requests directed at the child. 

## 6. Instructions for the AI Assistant (Cursor)
When I ask you to implement a specific page or feature from this plan, you must follow this workflow:
1.  **Acknowledge Architecture:** Confirm you are adhering to the Riverpod state management and single root Navigator rules.
2.  **Provide Supabase Code First:** If a feature requires database interaction, provide the exact Supabase SQL commands (RPCs, RLS policies, etc.) first so I can run them in the SQL Editor.
3.  **Write the Implementation Code:** Replace static UI code with Riverpod providers and Supabase calls. 
4.  **No Client-Side Balances:** If I ask you to "update a balance," you must write or call a Supabase RPC to do it.