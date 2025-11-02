# FoodieHub - Complete Food Ordering Application

## 🚀 Project Overview
FoodieHub is a fully developed, modern food ordering web application built with React. It features a complete user experience from browsing menus to placing orders with integrated payment options.

## ✨ Features Implemented

### 1. **Home Page** (`Home.jsx`)
- **Hero Section** with attractive gradient background
- **Call-to-Action buttons** for quick navigation
- **Features Section** highlighting:
  - Fast Delivery (30 minutes or free)
  - Fresh Food quality
  - Quality Service (4.8/5 rating)
  - Best Prices
- **Popular Items** showcase with images and quick links
- **Final CTA Section** encouraging orders
- Fully responsive design

### 2. **Menu Page** (`Menu.jsx`)
- **Organized Categories**:
  - 🍛 Biryanis (6 items)
  - 🍗 Mandis (2 items)
  - 🥤 Cool Drinks (2 items)
  - 🍔 Fast Foods (2 items)
- **Section Navigation** with jump links
- **Visual Separators** between sections
- **Add to Cart** functionality with login verification
- **localStorage Integration** for cart persistence
- Responsive grid layout

### 3. **About Page** (`About.jsx`)
- **Hero Banner** with brand introduction
- **Mission Statement** section
- **Company Story** narrative
- **Core Values** display:
  - Quality First
  - Speed
  - Customer Care
  - Sustainability
- **Team Members** showcase
- **Statistics Section**:
  - 10,000+ Happy Customers
  - 50+ Menu Items
  - 30 Min Average Delivery
  - 4.8/5 Rating
- Professional layout with images

### 4. **Cart Page** (`Cart.jsx`)
- **Item Display** with images and prices
- **Remove Items** functionality
- **Total Calculation** with dynamic updates
- **Proceed to Payment** button
- **Empty Cart** message
- localStorage synchronization
- Responsive card-based design

### 5. **Payment Page** (`Payment.jsx`)
- **Order Summary** with itemized list
- **Customer Details Form**:
  - Full Name
  - Phone Number
  - Delivery Address
- **Payment Method Selection**:
  - PhonePe (with QR code)
  - Paytm
  - Cash on Delivery
- **Google Sheets Integration** for order tracking
- Enhanced UI with gradient buttons and icons
- Form validation

### 6. **Authentication Pages**

#### Login Page (`Login.jsx`)
- Email and password fields
- User validation against localStorage
- Forgot password link
- Signup redirect
- Enhanced styling with auth.css

#### Signup Page (`Signup.jsx`)
- Name, Email, Password fields
- Password confirmation
- Duplicate user check
- Auto-login after signup
- User data storage in localStorage

#### Forgot Password (`ForgotPassword.jsx`)
- Email input for reset link
- Simulated email sending
- Back to login option

#### Reset Password (`ResetPassword.jsx`)
- New password input
- Password confirmation
- Success redirect to login

### 7. **Components**

#### Navbar (`Navbar.jsx`)
- **Responsive Navigation** with hamburger menu
- **Logo** with icon and text
- **Navigation Links**:
  - Home
  - Menu
  - About
  - Cart
- **Authentication Buttons**:
  - Login/Signup (when logged out)
  - Logout (when logged in)
- Sticky positioning
- Gradient background
- Mobile-friendly

#### Footer (`Footer.jsx`)
- **Brand Section** with social media links
- **Quick Links** navigation
- **Categories** menu links
- **Contact Information**:
  - Email
  - Phone
  - Address
  - Operating hours
- **Copyright** notice
- Grid-based responsive layout

## 🎨 Styling Enhancements

### CSS Files Created:
1. **`Home.css`** - Complete home page styling
2. **`About.css`** - Professional about page design
3. **`Menu.css`** - Enhanced menu card layouts
4. **`auth.css`** - Unified authentication styling
5. **`Navbar.css`** - Modern navbar with animations
6. **`Footer.css`** - Elegant footer design
7. **`main.css`** - Global styles and variables

### Design Features:
- **Color Scheme**: Orange (#ff6b35) and Red (#d7263d) gradients
- **Typography**: Poppins font family
- **Animations**: Smooth transitions and hover effects
- **Shadows**: Elevated card designs
- **Responsive**: Mobile-first approach
- **Icons**: Emoji-based for universal compatibility

## 🛠️ Technical Implementation

### State Management:
- **AuthContext** for user authentication
- **localStorage** for:
  - User data persistence
  - Cart management
  - Login state
  - Order totals

### Routing:
- React Router for navigation
- Protected routes for authenticated pages
- Dynamic navigation based on auth state

### Form Handling:
- Controlled components
- Input validation
- Error messaging
- Success feedback

## 📱 Responsive Design

### Breakpoints:
- **Desktop**: 1200px+
- **Tablet**: 768px - 1199px
- **Mobile**: Below 768px

### Mobile Features:
- Hamburger menu
- Stack layouts
- Touch-friendly buttons
- Optimized images

## 🚀 Running the Application

### Development Server:
```bash
cd frontend
npm install
npm run dev
```

### Access:
- Local: `http://localhost:5174/`
- Network: Use `--host` flag to expose

## 📦 Dependencies

### Required Packages:
- `react` - UI library
- `react-dom` - React rendering
- `react-router-dom` - Routing
- `qrcode` - QR code generation

## 🔐 Authentication Flow

1. **Signup**: User creates account → Stored in localStorage → Auto-login
2. **Login**: Validates credentials → Sets login state → Redirects to home
3. **Logout**: Clears login state → Redirects to home
4. **Protected Actions**: Add to cart requires login

## 🛒 Order Flow

1. **Browse Menu** → Select items
2. **Add to Cart** → View cart
3. **Proceed to Payment** → Fill customer details
4. **Select Payment Method** → Confirm order
5. **Order Placed** → Data sent to Google Sheets

## 📊 Data Storage

### localStorage Keys:
- `users` - Array of user objects
- `cart` - Array of cart items
- `isLoggedIn` - Boolean login state
- `total` - Order total amount

## 🎯 Future Enhancements (Recommendations)

1. **Backend Integration**: Replace localStorage with proper API
2. **Real Payment Gateway**: Integrate actual payment processors
3. **Order Tracking**: Live order status updates
4. **User Profile**: Account management page
5. **Reviews & Ratings**: Customer feedback system
6. **Search Functionality**: Menu item search
7. **Filters**: Price, category, dietary filters
8. **Favorites**: Save favorite items
9. **Order History**: View past orders
10. **Admin Panel**: Manage menu, orders, users

## 👥 Credits

**Developers**: Shaik Abeda Begum & Anand Kumar
**Project**: FoodieHub - Complete Food Ordering System
**Year**: 2025

## 📄 License

© 2025 FoodieHub. All rights reserved.

---

**Status**: ✅ All pages fully developed and functional
**Errors**: 0
**Responsiveness**: Full mobile support
**Browser Support**: Chrome, Firefox, Safari, Edge
