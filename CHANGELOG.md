# Changelog - Tingungu Project

All notable changes to the Tingungu project will be documented in this file.

## [1.0.0] - 2026-05-07

### Summary
Tingungu is a comprehensive church companion application designed to bridge the gap between church societies and their members. It serves as a central hub for spiritual growth, community engagement, and financial utility, providing a seamless digital experience for the modern congregant.

**Value Proposition:**
- **Community Connectivity:** Stay deeply connected with your specific church society and receive instant updates.
- **Financial Utility:** Conveniently manage utility payments (Airtime, Electricity) and wallet top-ups within a single app.
- **Spiritual Growth:** Access on-demand media through Tingungu TV and stay informed about church events and notices.
- **Secure Philanthropy:** A trusted platform for tithes, offerings, and pledges.

### Implemented Features

#### Mobile Application (Flutter)
- **Onboarding Experience:** Interactive multi-page introduction highlighting key app benefits.
- **Society Selection:** Dynamic selection and connection to local church societies.
- **Digital Wallet System:** 
  - Integrated wallet balance management.
  - Multi-channel top-up (Google Pay & PayFast).
  - Transaction history tracking.
- **Utility Services:**
  - Airtime purchase integration for major networks (MTN, Vodacom, Cell C, Telkom).
  - Voucher redemption system.
- **Spiritual Content (Tingungu TV):** Dedicated media screen for video streaming and spiritual content.
- **Community & Communication:**
  - Society-specific notices and announcements.
  - Interactive events calendar with society-level filtering.
  - Community engagement screens.
- **Giving Module:** Secure interface for Tithes, Offerings, and Pledges.

#### Admin Portal (React)
- **Central Dashboard:** Real-time overview of app metrics and activity.
- **User Management:** Full control over user profiles and system roles.
- **Society Management:** Tools to add, edit, and manage different church societies.
- **Financial Oversight:** Detailed transaction logs for giving and wallet activities.
- **Content Management:** 
  - Media management for Tingungu TV.
  - Notice board and announcement controls.
  - Event scheduling and management.
- **Marketplace Management:** Inventory and sales tracking for church-related items.
- **Ticketing System:** Management of event tickets and attendance.

> [!IMPORTANT]
> **Production Readiness Note:**
> The current implementation of **Google Pay**, **PayFast**, and **Airtime Services** is using **Test Credentials** and **Sandbox Environments**. 
> - **Action Required:** Replace Test Merchant IDs and Sandbox API Keys with **Live Production Credentials** before the final release.
