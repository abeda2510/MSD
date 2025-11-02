// Add Cakes and Chocolates to Database
const mongoose = require('mongoose');
require('dotenv').config();

const MenuItem = require('./models/MenuItem');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Sample Cakes
const cakes = [
  {
    name: 'Chocolate Truffle Cake',
    description: 'Rich chocolate cake with smooth truffle filling',
    price: 550,
    category: 'cakes',
    image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&q=80',
    preparationTime: 120
  },
  {
    name: 'Red Velvet Cake',
    description: 'Soft red velvet with cream cheese frosting',
    price: 480,
    category: 'cakes',
    image: 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=500&q=80',
    preparationTime: 120
  },
  {
    name: 'Black Forest Cake',
    description: 'Chocolate layers with cherries and whipped cream',
    price: 520,
    category: 'cakes',
    image: 'https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?w=500&q=80',
    preparationTime: 120
  },
  {
    name: 'Vanilla Delight Cake',
    description: 'Classic vanilla sponge with buttercream',
    price: 400,
    category: 'cakes',
    image: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=500&q=80',
    preparationTime: 90
  },
  {
    name: 'Butterscotch Cake',
    description: 'Creamy butterscotch flavored cake',
    price: 450,
    category: 'cakes',
    image: 'https://images.unsplash.com/photo-1602351447937-745cb720612f?w=500&q=80',
    preparationTime: 90
  }
];

// Sample Chocolates
const chocolates = [
  {
    name: 'Dairy Milk Chocolate',
    description: 'Smooth milk chocolate bar',
    price: 120,
    category: 'chocolates',
    image: 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=500&q=80',
    preparationTime: 0
  },
  {
    name: 'Ferrero Rocher',
    description: 'Hazelnut filled chocolate with wafer',
    price: 350,
    category: 'chocolates',
    image: 'https://images.unsplash.com/photo-1606312619070-d48b4cdb0da0?w=500&q=80',
    preparationTime: 0
  },
  {
    name: 'KitKat',
    description: 'Crispy wafer chocolate bar',
    price: 50,
    category: 'chocolates',
    image: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=500&q=80',
    preparationTime: 0
  },
  {
    name: 'Snickers',
    description: 'Peanut, caramel and nougat chocolate bar',
    price: 60,
    category: 'chocolates',
    image: 'https://images.unsplash.com/photo-1481391032119-d89fee407e44?w=500&q=80',
    preparationTime: 0
  },
  {
    name: 'Toblerone',
    description: 'Swiss chocolate with honey and almond',
    price: 280,
    category: 'chocolates',
    image: 'https://images.unsplash.com/photo-1611250282651-310f907f00eb?w=500&q=80',
    preparationTime: 0
  }
];

// Add items to database
async function addItems() {
  try {
    // Check if items already exist
    const existingCakes = await MenuItem.find({ category: 'cakes' });
    const existingChocolates = await MenuItem.find({ category: 'chocolates' });

    if (existingCakes.length === 0) {
      await MenuItem.insertMany(cakes);
      console.log(`✅ Added ${cakes.length} cakes to database`);
    } else {
      console.log(`⚠️  ${existingCakes.length} cakes already exist, skipping...`);
    }

    if (existingChocolates.length === 0) {
      await MenuItem.insertMany(chocolates);
      console.log(`✅ Added ${chocolates.length} chocolates to database`);
    } else {
      console.log(`⚠️  ${existingChocolates.length} chocolates already exist, skipping...`);
    }

    // Display all items
    const allItems = await MenuItem.find();
    console.log(`\n📊 Total menu items: ${allItems.length}`);
    
    // Group by category
    const categories = {};
    allItems.forEach(item => {
      if (!categories[item.category]) {
        categories[item.category] = [];
      }
      categories[item.category].push(item.name);
    });

    console.log('\n📋 Items by category:');
    Object.keys(categories).forEach(cat => {
      console.log(`  ${cat}: ${categories[cat].length} items`);
    });

    console.log('\n✅ Database update complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error adding items:', error);
    process.exit(1);
  }
}

// Run the function
addItems();
