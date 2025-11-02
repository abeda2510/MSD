# FoodieHub Backend API

## 🚀 Complete Backend Implementation

### Features
- ✅ User Authentication (Register, Login, JWT)
- ✅ Menu Management (CRUD operations)
- ✅ Order Management (Create, Track, Update)
- ✅ User Profile Management
- ✅ Admin Panel Features
- ✅ MongoDB Database Integration
- ✅ Protected Routes with JWT
- ✅ Password Hashing (bcrypt)
- ✅ Role-based Access Control

### Tech Stack
- Node.js
- Express.js
- MongoDB with Mongoose
- JWT for authentication
- bcryptjs for password hashing
- CORS enabled

### API Endpoints

#### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - Login user
- `GET /me` - Get current user (Protected)
- `PUT /profile` - Update profile (Protected)

#### Menu (`/api/menu`)
- `GET /` - Get all menu items
- `GET /:id` - Get single menu item
- `GET /category/:category` - Get items by category
- `POST /` - Create menu item (Admin)
- `PUT /:id` - Update menu item (Admin)
- `DELETE /:id` - Delete menu item (Admin)

#### Orders (`/api/orders`)
- `POST /` - Create new order (Protected)
- `GET /my-orders` - Get user orders (Protected)
- `GET /:id` - Get single order (Protected)
- `PUT /:id/cancel` - Cancel order (Protected)
- `GET /admin/all` - Get all orders (Admin)
- `PUT /:id/status` - Update order status (Admin)
- `GET /admin/stats` - Get statistics (Admin)

#### Users (`/api/users`)
- `GET /` - Get all users (Admin)
- `GET /:id` - Get single user (Admin)
- `PUT /:id` - Update user (Admin)
- `DELETE /:id` - Delete user (Admin)

### Setup Instructions

1. **Install Dependencies**
```bash
cd backend
npm install
```

2. **Configure Environment**
Create `.env` file with:
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/foodiehub
JWT_SECRET=your_secret_key
NODE_ENV=development
```

3. **Start MongoDB**
Make sure MongoDB is running on your system

4. **Seed Database**
```bash
node seed.js
```

5. **Start Server**
```bash
npm start
# or for development with auto-reload
npm run dev
```

### Database Models

#### User Schema
- name, email, password (hashed)
- phone, address
- role (user/admin)
- isActive status

#### MenuItem Schema
- name, description, price
- category (biryanis, mandis, etc.)
- image URL
- availability, preparation time
- rating and reviews

#### Order Schema
- user reference
- customer details (name, phone, address)
- items array with quantities
- totalAmount
- payment method and status
- order status tracking
- delivery time

### Testing

Access the API at: `http://localhost:5000`

Health check: `http://localhost:5000/health`

### Security Features
- JWT token authentication
- Password hashing with bcrypt
- Protected routes middleware
- Role-based authorization
- Input validation

### Error Handling
- Comprehensive error messages
- HTTP status codes
- Development vs Production error details

## 📦 Ready to Use!

All backend functionality is complete and tested.
