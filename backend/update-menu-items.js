// Update menu items to match original design
const mongoose = require('mongoose');
require('dotenv').config();

const MenuItem = require('./models/MenuItem');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Additional Cool Drinks (to make it 5 total)
const additionalCoolDrinks = [
  {
    name: 'Sprite',
    description: 'Refreshing lemon-lime flavored soda',
    price: 40,
    category: 'cool-drinks',
    image: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=500&q=80',
    preparationTime: 0
  },
  {
    name: 'Fanta',
    description: 'Orange flavored carbonated drink',
    price: 40,
    category: 'cool-drinks',
    image: 'https://images.unsplash.com/photo-1624517452488-04869289c4ca?w=500&q=80',
    preparationTime: 0
  },
  {
    name: 'Pepsi',
    description: 'Classic cola drink',
    price: 40,
    category: 'cool-drinks',
    image: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=500&q=80',
    preparationTime: 0
  }
];

// Additional Mandi (to make it 3 total)
const additionalMandi = [
  {
    name: 'Fish Mandi',
    description: 'Fresh fish with aromatic Yemeni rice and spices',
    price: 850,
    category: 'mandis',
    image: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80',
    preparationTime: 45
  }
];

// Update items
async function updateItems() {
  try {
    // Check current counts
    const coolDrinksCount = await MenuItem.countDocuments({ category: 'cool-drinks' });
    const mandisCount = await MenuItem.countDocuments({ category: 'mandis' });

    console.log(`\n📊 Current counts:`);
    console.log(`  Cool Drinks: ${coolDrinksCount}`);
    console.log(`  Mandis: ${mandisCount}\n`);

    // Add cool drinks if needed
    if (coolDrinksCount < 5) {
      await MenuItem.insertMany(additionalCoolDrinks);
      console.log(`✅ Added ${additionalCoolDrinks.length} cool drinks`);
    } else {
      console.log(`⚠️  Cool drinks already complete (${coolDrinksCount} items)`);
    }

    // Add mandi if needed
    if (mandisCount < 3) {
      await MenuItem.insertMany(additionalMandi);
      console.log(`✅ Added ${additionalMandi.length} mandi`);
    } else {
      console.log(`⚠️  Mandis already complete (${mandisCount} items)`);
    }

    // Display final counts
    const categories = ['biryanis', 'mandis', 'cool-drinks', 'fast-foods', 'cakes', 'chocolates'];
    console.log('\n📋 Final menu structure:');
    for (const cat of categories) {
      const count = await MenuItem.countDocuments({ category: cat });
      console.log(`  ${cat}: ${count} items`);
    }

    const total = await MenuItem.countDocuments();
    console.log(`\n✅ Total menu items: ${total}`);
    console.log('✅ Database update complete!\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

updateItems();
