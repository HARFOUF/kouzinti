# Kouzinti - Food Ordering App

A Flutter food ordering and delivery app with Firebase backend.

## Features

- **User Authentication**: Sign up/login with role selection (customer/chef)
- **Image Upload**: Upload dish images from gallery or camera
- **Real-time Data**: Firebase Firestore integration
- **Cart Management**: Add/remove items from cart
- **Order Management**: Place and track orders
- **Profile Management**: User profiles and dish management for chefs

## Image Upload Feature

The app now supports image upload for dishes using Firebase Storage:

### For Chefs:
1. Navigate to Profile → Manage Dishes
2. Tap the + button to add a new dish
3. Tap the image area to select an image source:
   - **Gallery**: Choose from your device's photo gallery
   - **Camera**: Take a new photo
4. Fill in dish details (name, description, category, price)
5. Save the dish

### Image Upload Features:
- **Automatic Compression**: Images are compressed to 1024x1024 max resolution
- **Quality Optimization**: 85% quality for optimal file size
- **Storage Management**: Old images are automatically deleted when replaced
- **Error Handling**: Graceful fallback to placeholder images if upload fails

### Technical Details:
- Uses `firebase_storage` for cloud storage
- Uses `image_picker` for device camera/gallery access
- Images are stored in Firebase Storage under `dishes/` folder
- File naming: `dish_{dishId}_{timestamp}.jpg`

## Setup

1. **Firebase Configuration**:
   - Enable Firebase Storage in your Firebase Console
   - Set up Storage rules for security
   - Configure authentication and Firestore

2. **Dependencies**:
   ```yaml
   firebase_storage: ^11.5.6
   image_picker: ^1.0.4
   ```

3. **Permissions** (Android):
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   ```

## Usage

1. **Sign up** as a chef or customer
2. **Add dishes** (chefs only) with images
3. **Browse dishes** on the home screen
4. **Add to cart** and place orders
5. **Track orders** in the orders section

## File Structure

```
lib/
├── src/
│   ├── services/
│   │   ├── storage_service.dart      # Image upload service
│   │   └── dish_service.dart         # Dish CRUD operations
│   ├── widgets/
│   │   └── image_picker_widget.dart  # Reusable image picker
│   └── models/
│       └── dish_model.dart           # Updated dish model
```

## Troubleshooting

- **Image upload fails**: Check Firebase Storage rules and internet connection
- **Camera not working**: Ensure camera permissions are granted
- **Gallery access denied**: Check storage permissions
- **Images not loading**: Verify Firebase Storage configuration
