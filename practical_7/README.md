# Practical 7 — Product Catalog (GridView)

Minimal app demonstrating a product catalog using `GridView` and reusable cards with local images.

Features
- GridView responsive layout
- Reusable product card widget
- Local asset images

Run

```powershell
cd practical_7
flutter pub get
flutter run
```

Assets

- To use local images, add them under `practical_7/assets/images/` and the project will load them automatically.

Navigation

- Tap any product card to open the product detail page.

Local images

- To use local images replace the `image` URL in `lib/main.dart` product list with an asset path like `assets/images/my_image.jpg` and use `Image.asset` in `ProductCard`.
# practical_7

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
