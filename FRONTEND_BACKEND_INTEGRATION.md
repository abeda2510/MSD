# Frontend-Backend Integration Guide

## 🔗 Connecting React Frontend to Node.js Backend

### Step 1: Install Axios in Frontend
```bash
cd c:\Users\Dell\OneDrive\Desktop\MSD\frontend
npm install axios
```

### Step 2: Create API Service File

Create `frontend/src/services/api.js`:
```javascript
import axios from 'axios';

const API_URL = 'http://localhost:5000/api';

// Get token from localStorage
const getAuthHeader = () => {
  const token = localStorage.getItem('token');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

// Auth API calls
export const authAPI = {
  register: (userData) => axios.post(`${API_URL}/auth/register`, userData),
  login: (credentials) => axios.post(`${API_URL}/auth/login`, credentials),
  getProfile: () => axios.get(`${API_URL}/auth/me`, { headers: getAuthHeader() }),
  updateProfile: (data) => axios.put(`${API_URL}/auth/profile`, data, { headers: getAuthHeader() })
};

// Menu API calls
export const menuAPI = {
  getAllItems: () => axios.get(`${API_URL}/menu`),
  getItemById: (id) => axios.get(`${API_URL}/menu/${id}`),
  getByCategory: (category) => axios.get(`${API_URL}/menu/category/${category}`)
};

// Order API calls
export const orderAPI = {
  createOrder: (orderData) => axios.post(`${API_URL}/orders`, orderData, { headers: getAuthHeader() }),
  getMyOrders: () => axios.get(`${API_URL}/orders/my-orders`, { headers: getAuthHeader() }),
  getOrderById: (id) => axios.get(`${API_URL}/orders/${id}`, { headers: getAuthHeader() }),
  cancelOrder: (id) => axios.put(`${API_URL}/orders/${id}/cancel`, {}, { headers: getAuthHeader() })
};

export default { authAPI, menuAPI, orderAPI };
```

---

## 📝 Update Login.jsx

Replace the localStorage login with API call:

```javascript
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { authAPI } from '../services/api';
import '../styles/auth.css';

function Login() {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await authAPI.login(formData);
      const { token, user } = response.data;
      
      // Store token and user data
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      
      alert('Login successful!');
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-box">
        <h2>Login to FoodieHub</h2>
        {error && <div className="error-message">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              required
            />
          </div>
          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </form>
        <div className="auth-links">
          <Link to="/forgot-password">Forgot Password?</Link>
          <p>Don't have an account? <Link to="/signup">Sign Up</Link></p>
        </div>
      </div>
    </div>
  );
}

export default Login;
```

---

## 📝 Update Signup.jsx

```javascript
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { authAPI } from '../services/api';
import '../styles/auth.css';

function Signup() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    phone: '',
    address: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    setLoading(true);

    try {
      const { confirmPassword, ...userData } = formData;
      const response = await authAPI.register(userData);
      const { token, user } = response.data;
      
      // Store token and user data
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      
      alert('Registration successful!');
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-box">
        <h2>Sign Up for FoodieHub</h2>
        {error && <div className="error-message">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Full Name</label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Phone</label>
            <input
              type="tel"
              name="phone"
              value={formData.phone}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Address</label>
            <textarea
              name="address"
              value={formData.address}
              onChange={handleChange}
              rows="3"
              required
            />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Confirm Password</label>
            <input
              type="password"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              required
            />
          </div>
          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Signing up...' : 'Sign Up'}
          </button>
        </form>
        <div className="auth-links">
          <p>Already have an account? <Link to="/login">Login</Link></p>
        </div>
      </div>
    </div>
  );
}

export default Signup;
```

---

## 📝 Update Menu.jsx to Fetch from Backend

```javascript
import { useState, useEffect } from 'react';
import { menuAPI } from '../services/api';
import FoodCard from '../components/FoodCard';
import './Menu.css';

function Menu() {
  const [menuItems, setMenuItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');

  useEffect(() => {
    fetchMenuItems();
  }, [selectedCategory]);

  const fetchMenuItems = async () => {
    setLoading(true);
    setError('');
    try {
      let response;
      if (selectedCategory === 'all') {
        response = await menuAPI.getAllItems();
      } else {
        response = await menuAPI.getByCategory(selectedCategory);
      }
      setMenuItems(response.data.data);
    } catch (err) {
      setError('Failed to load menu items');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const categories = [
    { id: 'all', name: 'All Items' },
    { id: 'biryanis', name: 'Biryanis' },
    { id: 'mandis', name: 'Mandis' },
    { id: 'cool-drinks', name: 'Cool Drinks' },
    { id: 'fast-foods', name: 'Fast Foods' }
  ];

  return (
    <div className="menu-page">
      <div className="menu-header">
        <h1>Our Menu</h1>
        <p>Explore our delicious offerings</p>
      </div>

      <div className="category-filter">
        {categories.map(cat => (
          <button
            key={cat.id}
            className={selectedCategory === cat.id ? 'active' : ''}
            onClick={() => setSelectedCategory(cat.id)}
          >
            {cat.name}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="loading">Loading menu...</div>
      ) : error ? (
        <div className="error">{error}</div>
      ) : (
        <div className="menu-grid">
          {menuItems.map(item => (
            <FoodCard key={item._id} item={item} />
          ))}
        </div>
      )}
    </div>
  );
}

export default Menu;
```

---

## 📝 Update Payment.jsx to Create Order

```javascript
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { orderAPI } from '../services/api';
import './Payment.css';

function Payment() {
  const navigate = useNavigate();
  const cart = JSON.parse(localStorage.getItem('cart')) || [];
  const user = JSON.parse(localStorage.getItem('user'));

  const [formData, setFormData] = useState({
    customerName: user?.name || '',
    phoneNumber: user?.phone || '',
    address: user?.address || '',
    paymentMethod: 'phonepe',
    notes: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const orderData = {
        ...formData,
        items: cart.map(item => ({
          menuItem: item._id,
          name: item.name,
          quantity: item.quantity,
          price: item.price
        })),
        totalAmount: total
      };

      const response = await orderAPI.createOrder(orderData);
      alert('Order placed successfully!');
      localStorage.removeItem('cart');
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to place order');
    } finally {
      setLoading(false);
    }
  };

  if (cart.length === 0) {
    return (
      <div className="payment-page">
        <h2>Your cart is empty</h2>
        <button onClick={() => navigate('/menu')}>Browse Menu</button>
      </div>
    );
  }

  return (
    <div className="payment-page">
      <h1>Checkout</h1>
      {error && <div className="error-message">{error}</div>}
      
      <div className="payment-container">
        <div className="order-summary">
          <h2>Order Summary</h2>
          {cart.map((item, index) => (
            <div key={index} className="summary-item">
              <span>{item.name} x {item.quantity}</span>
              <span>₹{item.price * item.quantity}</span>
            </div>
          ))}
          <div className="summary-total">
            <strong>Total:</strong>
            <strong>₹{total}</strong>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="payment-form">
          <div className="form-group">
            <label>Name</label>
            <input
              type="text"
              name="customerName"
              value={formData.customerName}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Phone</label>
            <input
              type="tel"
              name="phoneNumber"
              value={formData.phoneNumber}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label>Delivery Address</label>
            <textarea
              name="address"
              value={formData.address}
              onChange={handleChange}
              rows="3"
              required
            />
          </div>
          <div className="form-group">
            <label>Payment Method</label>
            <select
              name="paymentMethod"
              value={formData.paymentMethod}
              onChange={handleChange}
            >
              <option value="phonepe">PhonePe</option>
              <option value="paytm">Paytm</option>
              <option value="cod">Cash on Delivery</option>
            </select>
          </div>
          <div className="form-group">
            <label>Special Instructions (Optional)</label>
            <textarea
              name="notes"
              value={formData.notes}
              onChange={handleChange}
              rows="2"
            />
          </div>
          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? 'Placing Order...' : 'Place Order'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default Payment;
```

---

## 🔧 Testing the Integration

1. **Start Backend Server**:
   ```bash
   cd c:\Users\Dell\OneDrive\Desktop\MSD\backend
   node server.js
   ```

2. **Start Frontend Dev Server**:
   ```bash
   cd c:\Users\Dell\OneDrive\Desktop\MSD\frontend
   npm run dev
   ```

3. **Test Flow**:
   - Go to http://localhost:5174
   - Sign up with a new account
   - Browse the menu (loaded from backend)
   - Add items to cart
   - Proceed to checkout
   - Place an order
   - Check backend terminal for order creation log

---

## 📊 Data Flow

```
Frontend (React) → API Service (Axios) → Backend (Express) → MongoDB
                 ←                      ←                   ←
```

1. User interacts with React components
2. Components call API service functions
3. Axios sends HTTP requests to Express server
4. Express processes requests, interacts with MongoDB
5. MongoDB returns data
6. Express sends response back
7. Axios receives response
8. React updates UI

---

## 🔐 Authentication Flow

```
1. User enters credentials in Login.jsx
2. authAPI.login() sends POST to /api/auth/login
3. Backend verifies credentials, generates JWT
4. JWT token returned to frontend
5. Token stored in localStorage
6. Token included in Authorization header for protected routes
7. Backend verifies token for each protected request
```

---

## ✅ Integration Checklist

- [ ] Install axios in frontend
- [ ] Create api.js service file
- [ ] Update Login.jsx
- [ ] Update Signup.jsx
- [ ] Update Menu.jsx
- [ ] Update Payment.jsx
- [ ] Update Cart.jsx (if needed)
- [ ] Test user registration
- [ ] Test user login
- [ ] Test menu loading
- [ ] Test order creation
- [ ] Test protected routes
- [ ] Handle loading states
- [ ] Handle error states
- [ ] Test complete user journey

---

*Ready to integrate! Follow the steps above to connect your frontend to the working backend.*
