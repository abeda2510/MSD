// Fix broken images and add more fast foods
const mongoose = require('mongoose');
require('dotenv').config();

const MenuItem = require('./models/MenuItem');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Fixed image URLs
const imageUpdates = [
  {
    name: 'Wings Biriyani',
    newImage: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&q=80'
  },
  {
    name: 'Fried Rice',
    newImage: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&q=80'
  },
  {
    name: 'Ferrero Rocher',
    newImage: 'https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=500&q=80'
  },
  {
    name: 'Toblerone',
    newImage: 'https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?w=500&q=80'
  }
];

// Additional Fast Foods (to make it 5 total)
const newFastFoods = [
  {
    name: 'Chicken Burger',
    description: 'Juicy chicken patty with fresh vegetables and special sauce',
    price: 150,
    category: 'fast-foods',
    image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
    preparationTime: 15
  },
  {
    name: 'French Fries',
    description: 'Crispy golden fries with seasoning',
    price: 80,
    category: 'fast-foods',
    image: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&q=80',
    preparationTime: 10
  },
  {
    name: 'Chicken Nuggets',
    description: 'Crispy breaded chicken nuggets with dipping sauce',
    price: 180,
    category: 'fast-foods',
    image: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=500&q=80',
    preparationTime: 12
  }
];

// Update function
async function updateMenu() {
  try {
    console.log('\n🔧 FIXING BROKEN IMAGES...\n');
    
    // Fix broken images
    for (const update of imageUpdates) {
      const result = await MenuItem.findOneAndUpdate(
        { name: update.name },
        { $set: { image: update.newImage } },
        { new: true }
      );
      
      if (result) {
        console.log(`✅ Updated ${update.name}`);
      } else {
        console.log(`⚠️  ${update.name} not found`);
      }
    }

    console.log('\n🍔 ADDING FAST FOODS...\n');

    // Check current fast foods count
    const currentFastFoods = await MenuItem.find({ category: 'fast-foods' });
    console.log(`Current fast foods: ${currentFastFoods.length}`);

    if (currentFastFoods.length < 5) {
      const itemsToAdd = 5 - currentFastFoods.length;
      const itemsToInsert = newFastFoods.slice(0, itemsToAdd);
      
      await MenuItem.insertMany(itemsToInsert);
      console.log(`✅ Added ${itemsToInsert.length} fast food items`);
    } else {
      console.log(`⚠️  Already have ${currentFastFoods.length} fast foods`);
    }

    // Display final menu structure
    console.log('\n📋 FINAL MENU STRUCTURE:\n');
    const categories = ['biryanis', 'mandis', 'cool-drinks', 'fast-foods', 'cakes', 'chocolates'];
    
    for (const cat of categories) {
      const items = await MenuItem.find({ category: cat });
      console.log(`  ${cat}: ${items.length} items`);
      items.forEach(item => {
        console.log(`    - ${item.name}`);
      });
      console.log('');
    }

    const total = await MenuItem.countDocuments();
    console.log(`✅ Total menu items: ${total}`);
    console.log('✅ All updates complete!\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

updateMenu();
