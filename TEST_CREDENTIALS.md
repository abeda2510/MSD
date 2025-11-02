# 🔐 TEST USER CREDENTIALS

## Ready-to-Use Test Account

### Option 1: Create Your Own Account
**Go to**: http://localhost:5174/signup

Fill in:
- **Name**: Your Name
- **Email**: your.email@example.com
- **Phone**: 1234567890 (optional)
- **Address**: Your address (optional)
- **Password**: password123
- **Confirm Password**: password123

Click "Sign Up" → Auto-login → Start using!

---

## Option 2: Use API to Create Test Account

I can create a test account for you right now. Here are sample credentials:

### Test Account 1:
```
Name: John Doe
Email: john@example.com
Phone: 9876543210
Address: 123 Main Street, Food City
Password: Test@123
```

### Test Account 2:
```
Name: Jane Smith
Email: jane@example.com
Phone: 9876543211
Address: 456 Oak Avenue, Food Town
Password: Test@123
```

### Test Account 3:
```
Name: Demo User
Email: demo@foodiehub.com
Phone: 5551234567
Address: 789 Demo Lane, Test City
Password: Demo@2024
```

---

## 🚀 Quick Test Flow

### Step 1: Sign Up
1. Go to: http://localhost:5174/signup
2. Use any credentials above (or create your own)
3. Click "Sign Up"
4. ✅ You're automatically logged in!

### Step 2: Verify Login
1. See your name in the navbar
2. Cart icon appears
3. "Logout" button visible

### Step 3: Browse Menu
1. Click "Menu" in navbar
2. See 12 items from database:
   - **Biryanis**: Dum Biryani (₹180), Fry Piece Biryani (₹200), Veg Biryani (₹130), Paneer Biryani (₹150), Egg Biryani (₹110), Mutton Biryani (₹280)
   - **Mandis**: Chicken Mandi (₹220), Mutton Mandi (₹250)
   - **Cool Drinks**: Pepsi (₹40), Fanta (₹40)
   - **Fast Foods**: French Fries (₹60), Chicken Nuggets (₹80)

### Step 4: Add to Cart
1. Click "Add to Cart" on any item
2. See confirmation alert
3. Cart badge updates

### Step 5: Place Order
1. Click cart icon
2. Click "Proceed to Checkout"
3. Details auto-filled from your account
4. Select payment method
5. Click "Confirm Order"
6. ✅ Order saved in database!
7. See Order ID in confirmation

---

## 🔑 Important Notes

### Password Requirements:
- At least 6 characters
- Any combination (letters, numbers, symbols)

### Email:
- Must be valid email format
- Must be unique (not already registered)

### Optional Fields:
- Phone and Address are optional
- But recommended for smoother checkout

---

## 🧪 Testing Different Scenarios

### Test 1: New User Signup
```
Email: test1@example.com
Password: Test123
→ Should create account and auto-login
```

### Test 2: Login with Existing Account
```
Use the email/password you signed up with
→ Should login successfully
```

### Test 3: Wrong Password
```
Email: test1@example.com
Password: WrongPassword
→ Should show error: "Invalid credentials"
```

### Test 4: Duplicate Email
```
Sign up with same email twice
→ Should show error: "User already exists"
```

---

## 💡 Pro Tips

1. **Remember Your Password**: Backend uses real bcrypt hashing, so passwords can't be retrieved
2. **Use Simple Passwords for Testing**: Like "Test123" or "Demo2024"
3. **Multiple Accounts**: You can create multiple accounts with different emails
4. **Test Orders**: Add items and place test orders to see full functionality

---

## 🎯 What You Can Test

✅ User registration (creates user in MongoDB)
✅ User login (generates JWT token)
✅ Browse menu (loads from database)
✅ Add to cart (stored locally)
✅ Place orders (saves to database)
✅ View order confirmation (real order ID)
✅ Logout (clears token)

---

## 🔐 Your Account Data

After signup, your data is stored in MongoDB:
- **Password**: Hashed with bcrypt (secure!)
- **JWT Token**: 30-day expiry
- **Orders**: All saved with order IDs
- **Profile**: Can be updated later

---

## 📞 Need Help?

**Can't signup?**
- Check backend terminal is running
- Verify MongoDB is connected
- Try different email address

**Forgot password?**
- Use "Forgot Password" link (page exists)
- Or create new account with different email

**Can't login?**
- Make sure you signed up first
- Check email/password spelling
- Try the test credentials above

---

## 🎊 Ready to Start!

**Recommended First Test Account:**
```
Name: Test User
Email: test@foodiehub.com
Password: Test123
```

1. Go to http://localhost:5174/signup
2. Enter above details
3. Click "Sign Up"
4. Start ordering! 🍕

**Backend is running, database is ready, frontend is integrated!**

---

*All passwords are hashed with bcrypt for security*
*JWT tokens expire after 30 days*
*Data persists in MongoDB database*
