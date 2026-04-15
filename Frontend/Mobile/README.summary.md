# Mobile Frontend Project Summary

## Purpose
Mobile app for Gold Wallet System. Allows users to view/manage products, wallet, transactions, and notifications.

## Key Technologies
- Flutter (Dart)
- Bloc/Cubit (state management)
- Dio (HTTP client)
- SignalR/WebSocket client (to be implemented)

## Main Folders
- `lib/features/`: Feature modules (product, wallet, transaction, notification, etc.)
- `lib/features/<feature>/presentation/cubit/`: Cubits for state management
- `lib/features/<feature>/presentation/pages/`: UI pages
- `lib/core/`: Core utilities/services

## Real-Time/Sync
- Will use SignalR/WebSocket for real-time updates (stock, wallet, product, transaction)
- Cubits will subscribe to events and update state
- Polling/timers are currently used for dashboard, products, wallet, transactions
- Polling will be removed where SignalR is working, kept as fallback

## Key Files for Real-Time
- `lib/features/product/presentation/cubit/product_cubit.dart`: Product state
- `lib/features/wallet/presentation/cubit/wallet_cubit.dart`: Wallet state
- `lib/features/transaction/presentation/cubit/transaction_cubit.dart`: Transaction state
- `lib/features/notification/presentation/cubit/notification_cubit.dart`: Notification state

## Patterns
- Use Cubit for state
- Use dependency injection for services
- Avoid duplicate refresh (polling + SignalR)
- Clean up listeners/subscriptions

## To-Do
- Implement SignalR/WebSocket client
- Update cubits to use real-time events
- Remove polling where possible
