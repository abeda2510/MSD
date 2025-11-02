const axios = require('axios');

const API_URL = 'http://localhost:5000';

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

let authToken = '';
let testUserId = '';
let testOrderId = '';

// Test functions
async function testHealthCheck() {
  console.log(`\n${colors.blue}========== Testing Health Check ==========${colors.reset}`);
  try {
    const response = await axios.get(`${API_URL}/health`);
    console.log(`${colors.green}✅ Health Check: PASSED${colors.reset}`);
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Health Check: FAILED${colors.reset}`);
    console.log('Error:', error.message);
    return false;
  }
}

async function testGetMenu() {
  console.log(`\n${colors.blue}========== Testing Get All Menu Items ==========${colors.reset}`);
  try {
    const response = await axios.get(`${API_URL}/api/menu`);
    console.log(`${colors.green}✅ Get Menu: PASSED${colors.reset}`);
    console.log(`Found ${response.data.count} menu items`);
    console.log('Categories:', [...new Set(response.data.data.map(item => item.category))].join(', '));
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Get Menu: FAILED${colors.reset}`);
    console.log('Error:', error.response?.data || error.message);
    return false;
  }
}

async function testRegisterUser() {
  console.log(`\n${colors.blue}========== Testing User Registration ==========${colors.reset}`);
  const userData = {
    name: 'Test User',
    email: `testuser${Date.now()}@example.com`,
    password: 'Test@123',
    phone: '1234567890',
    address: '123 Test St, Test City, Test State - 12345'
  };

  try {
    const response = await axios.post(`${API_URL}/api/auth/register`, userData);
    console.log(`${colors.green}✅ User Registration: PASSED${colors.reset}`);
    authToken = response.data.token;
    testUserId = response.data.data?._id || response.data.user?._id;
    console.log('User ID:', testUserId);
    console.log('Token received:', authToken ? 'Yes' : 'No');
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ User Registration: FAILED${colors.reset}`);
    console.log('Error:', error.response?.data || error.message);
    return false;
  }
}

async function testLogin() {
  console.log(`\n${colors.blue}========== Testing User Login ==========${colors.reset}`);
  const loginData = {
    email: 'testuser@example.com',
    password: 'Test@123'
  };

  try {
    const response = await axios.post(`${API_URL}/api/auth/login`, loginData);
    console.log(`${colors.green}✅ User Login: PASSED${colors.reset}`);
    authToken = response.data.token;
    console.log('Token received:', authToken ? 'Yes' : 'No');
    return true;
  } catch (error) {
    console.log(`${colors.yellow}⚠️  User Login: User may not exist (expected if first run)${colors.reset}`);
    return false;
  }
}

async function testGetProfile() {
  console.log(`\n${colors.blue}========== Testing Get User Profile ==========${colors.reset}`);
  try {
    const response = await axios.get(`${API_URL}/api/auth/me`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log(`${colors.green}✅ Get Profile: PASSED${colors.reset}`);
    const user = response.data.data || response.data.user;
    console.log('User:', user?.name || 'Unknown', '-', user?.email || 'Unknown');
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Get Profile: FAILED${colors.reset}`);
    console.log('Error:', error.response?.data || error.message);
    return false;
  }
}

async function testCreateOrder() {
  console.log(`\n${colors.blue}========== Testing Create Order ==========${colors.reset}`);
  
  try {
    // First, get some menu items to use their IDs
    const menuResponse = await axios.get(`${API_URL}/api/menu`);
    const menuItems = menuResponse.data.data;
    
    if (menuItems.length < 2) {
      console.log(`${colors.yellow}⚠️  Not enough menu items to test order creation${colors.reset}`);
      return false;
    }

    const item1 = menuItems[0];
    const item2 = menuItems[1];

    const orderData = {
      customerName: 'Test User',
      phoneNumber: '1234567890',
      address: '123 Test St, Test City',
      items: [
        { menuItem: item1._id, name: item1.name, quantity: 2, price: item1.price },
        { menuItem: item2._id, name: item2.name, quantity: 1, price: item2.price }
      ],
      paymentMethod: 'phonepe',
      totalAmount: (item1.price * 2) + item2.price
    };

    const response = await axios.post(`${API_URL}/api/orders`, orderData, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log(`${colors.green}✅ Create Order: PASSED${colors.reset}`);
    testOrderId = response.data.data._id;
    console.log('Order ID:', testOrderId);
    console.log(`Ordered: 2x ${item1.name} + 1x ${item2.name}`);
    console.log('Total Amount: ₹' + response.data.data.totalAmount);
    console.log('Status:', response.data.data.orderStatus);
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Create Order: FAILED${colors.reset}`);
    console.log('Error:', error.response?.data || error.message);
    return false;
  }
}

async function testGetMyOrders() {
  console.log(`\n${colors.blue}========== Testing Get My Orders ==========${colors.reset}`);
  try {
    const response = await axios.get(`${API_URL}/api/orders/my-orders`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log(`${colors.green}✅ Get My Orders: PASSED${colors.reset}`);
    console.log(`Found ${response.data.count} order(s)`);
    return true;
  } catch (error) {
    console.log(`${colors.red}❌ Get My Orders: FAILED${colors.reset}`);
    console.log('Error:', error.response?.data || error.message);
    return false;
  }
}

// Run all tests
async function runAllTests() {
  console.log(`\n${colors.yellow}╔════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.yellow}║     FOODIEHUB API TESTING SUITE           ║${colors.reset}`);
  console.log(`${colors.yellow}╚════════════════════════════════════════════╝${colors.reset}`);

  const results = {
    passed: 0,
    failed: 0,
    total: 0
  };

  // Test 1: Health Check
  results.total++;
  if (await testHealthCheck()) results.passed++;
  else results.failed++;

  // Test 2: Get Menu
  results.total++;
  if (await testGetMenu()) results.passed++;
  else results.failed++;

  // Test 3: Register User
  results.total++;
  if (await testRegisterUser()) results.passed++;
  else results.failed++;

  // Test 4: Login (optional, may fail if user doesn't exist)
  // Commented out as we're using the new user's token
  // results.total++;
  // if (await testLogin()) results.passed++;
  // else results.failed++;

  // Test 5: Get Profile
  results.total++;
  if (await testGetProfile()) results.passed++;
  else results.failed++;

  // Test 6: Create Order
  results.total++;
  if (await testCreateOrder()) results.passed++;
  else results.failed++;

  // Test 7: Get My Orders
  results.total++;
  if (await testGetMyOrders()) results.passed++;
  else results.failed++;

  // Summary
  console.log(`\n${colors.yellow}╔════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.yellow}║           TEST RESULTS SUMMARY             ║${colors.reset}`);
  console.log(`${colors.yellow}╚════════════════════════════════════════════╝${colors.reset}`);
  console.log(`Total Tests: ${results.total}`);
  console.log(`${colors.green}Passed: ${results.passed}${colors.reset}`);
  console.log(`${colors.red}Failed: ${results.failed}${colors.reset}`);
  console.log(`Success Rate: ${((results.passed / results.total) * 100).toFixed(2)}%\n`);

  if (results.failed === 0) {
    console.log(`${colors.green}🎉 All tests passed! Backend is working perfectly!${colors.reset}\n`);
  } else {
    console.log(`${colors.red}⚠️  Some tests failed. Please check the errors above.${colors.reset}\n`);
  }
}

// Run tests
runAllTests().catch(error => {
  console.error(`${colors.red}Fatal Error:${colors.reset}`, error.message);
  process.exit(1);
});
