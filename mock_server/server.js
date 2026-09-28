// mock_server/server.js - Lightweight mock REST API for CredLite
// Generates realistic credit card data, rewards, and 5,000 transactions on startup.
const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());

// Simulates network latency (300ms - 600ms) to test asynchronous loading states in Flutter.
const delay = (req, res, next) => setTimeout(next, 300 + Math.random() * 300);
app.use(delay);

const cards = [
  { id: 'card_1', cardholderName: 'Alex Morgan', cardNumber: '•••• 4242', network: 'Visa', totalLimit: 250000, outstandingBalance: 48750.50, dueDate: '2026-10-15', billMonth: 'October' },
  { id: 'card_2', cardholderName: 'Alex Morgan', cardNumber: '•••• 8821', network: 'Mastercard', totalLimit: 150000, outstandingBalance: 14200.00, dueDate: '2026-10-22', billMonth: 'October' },
  { id: 'card_3', cardholderName: 'Alex Morgan', cardNumber: '•••• 3099', network: 'Amex', totalLimit: 500000, outstandingBalance: 89400.75, dueDate: '2026-11-02', billMonth: 'November' },
];

const categories = ['Dining', 'Shopping', 'Travel', 'Bills', 'Groceries', 'Entertainment'];
const merchants = {
  Dining: ['Starbucks', 'Swiggy', 'Zomato', 'Blue Tokai', 'Subway'],
  Shopping: ['Amazon', 'Flipkart', 'Zara', 'Apple Store', 'Myntra'],
  Travel: ['Uber', 'MakeMyTrip', 'Air India', 'Ola', 'Booking.com'],
  Bills: ['Airtel', 'BESCOM', 'Jio Fiber', 'Netflix', 'Tata Power'],
  Groceries: ['Blinkit', 'Instamart', 'Nature Basket', 'Zepto', 'BigBasket'],
  Entertainment: ['BookMyShow', 'Spotify', 'PVR Cinemas', 'Steam', 'SonyLIV'],
};

// Generate 5,000 transactions deterministically on startup
const transactions = [];
const startDate = new Date('2026-01-01').getTime();
const endDate = new Date('2026-09-28').getTime();

for (let i = 1; i <= 5000; i++) {
  const cat = categories[i % categories.length];
  const merchantList = merchants[cat];
  const merchant = merchantList[i % merchantList.length];
  const amount = Number(((i * 37) % 8500 + 49.50).toFixed(2));
  const timestamp = new Date(startDate + ((endDate - startDate) * (i / 5000)));
  const cardId = cards[i % cards.length].id;
  transactions.push({
    id: `tx_${i}`,
    merchant,
    category: cat,
    amount,
    date: timestamp.toISOString(),
    cardId,
  });
}

let rewards = [
  { id: 'rew_1', title: 'Flat ₹500 Cashback', description: 'Cred Pay on Swiggy', discountCode: 'CREDSWIGGY500', isScratched: false },
  { id: 'rew_2', title: '15% Off Flights', description: 'Book with MakeMyTrip', discountCode: 'CREDFLIGHT15', isScratched: false },
  { id: 'rew_3', title: 'Free Coffee Box', description: 'Blue Tokai Roasters', discountCode: 'COFFEELOVER', isScratched: false },
  { id: 'rew_4', title: '₹1,000 Voucher', description: 'Amazon shopping festival', discountCode: 'AMZCRED1000', isScratched: false },
  { id: 'rew_5', title: '3 Months Free', description: 'Spotify Premium Family', discountCode: 'SPOTCRED3M', isScratched: false },
  { id: 'rew_6', title: 'Buy 1 Get 1 Free', description: 'PVR Cinema tickets', discountCode: 'PVRBOGO26', isScratched: false },
];

app.get('/cards', (req, res) => res.json(cards));

app.get('/transactions', (req, res) => {
  let list = transactions;
  const { category, q } = req.query;
  if (category && category !== 'All') {
    list = list.filter(t => t.category.toLowerCase() === category.toLowerCase());
  }
  if (q) {
    const query = q.toLowerCase();
    list = list.filter(t => t.merchant.toLowerCase().includes(query) || t.category.toLowerCase().includes(query));
  }
  res.json(list);
});

app.get('/rewards', (req, res) => res.json(rewards));

app.post('/rewards/:id/scratch', (req, res) => {
  const reward = rewards.find(r => r.id === req.params.id);
  if (!reward) return res.status(404).json({ error: 'Reward not found' });
  reward.isScratched = true;
  res.json(reward);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`CredLite Mock Server running on port ${PORT}`));
