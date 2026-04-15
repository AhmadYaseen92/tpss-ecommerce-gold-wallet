# Backend Project Summary

## Purpose
Handles all business logic, data storage, and API endpoints for Gold Wallet System.

## Key Technologies
- ASP.NET Core Web API
- Entity Framework Core
- SignalR (to be implemented)

## Main Folders
- `Controllers/`: API endpoints (Products, Wallet, Transactions, WebAdmin, etc.)
- `Services/`: Business logic (WebAdminDashboardService, etc.)
- `Models/`: DTOs and API models
- `Infrastructure/`: Database context, repositories
- `Hubs/`: SignalR hubs (real-time events)

## Real-Time/Sync
- SignalR hub: `/Hubs/RealtimeHub.cs` (to be used for stock, wallet, product, transaction updates)
- Controllers/services must emit events after DB updates

## Key Files for Real-Time
- `Program.cs`: Registers SignalR, maps hub
- `Controllers/ProductsController.cs`: Product CRUD, stock updates
- `Controllers/WalletController.cs`: Wallet actions
- `Controllers/TransactionHistoryController.cs`: Transaction updates
- `Controllers/WebAdminController.cs`: Admin actions, approval/reject
- `Services/WebAdminDashboardService.cs`: Dashboard data

## Patterns
- All DB changes must emit real-time events after save
- Use dependency injection for services/hub context
- Keep DB update before event emission

## Polling
- No polling in backend; only push via SignalR

## To-Do
- Implement event emission in controllers/services
- Ensure all relevant updates are broadcast
