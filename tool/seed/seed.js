// Loads the demo data into Firebase and creates the demo sign-ins.
// Run it again any time to reset the demo (before recording a video, say).
//
//   cd tool/seed
//   npm install
//   node seed.js
//
// Needs serviceAccountKey.json in this folder:
// Firebase console > Project settings > Service accounts > Generate new private key.
// Never commit that file (it is in .gitignore) or share it.

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const KEY = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(KEY)) {
  console.error('Missing tool/seed/serviceAccountKey.json. See the comment at the top of seed.js.');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(require(KEY)) });
const db = admin.firestore();
const auth = admin.auth();

const DATA = path.join(__dirname, '..', '..', 'assets', 'data');
const read = (name) => JSON.parse(fs.readFileSync(path.join(DATA, name), 'utf8'));

// Must match lib/core/constants/app_config.dart
const EMAIL_DOMAIN = 'hm-trade.example.com';
const ADMIN_EMAIL = 'admin@hm-trade.example.com';
const ADMIN_UID = 'admin-1';
const PASSWORD = 'demo1234';

async function upsertUser(uid, email, displayName) {
  try {
    await auth.updateUser(uid, { email, password: PASSWORD, displayName });
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    await auth.createUser({ uid, email, password: PASSWORD, displayName });
  }
}

async function deleteCollection(name) {
  const snap = await db.collection(name).get();
  let batch = db.batch();
  let n = 0;
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
    if (++n % 400 === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }
  await batch.commit();
  return snap.size;
}

// The orders were written for 3 Nov 2026. Shift them so the newest is today.
function shiftDays(orders) {
  const newest = orders.map((o) => new Date(o.placedAt)).reduce((a, b) => (a > b ? a : b));
  const today = new Date();
  const dayOf = (d) => Date.UTC(d.getFullYear(), d.getMonth(), d.getDate());
  return Math.max(0, Math.round((dayOf(today) - dayOf(newest)) / 86400000));
}

async function main() {
  const products = read('products.json');
  const customers = read('customers.json');
  const orders = read('orders.json');

  // 1. Sign-ins. A buyer's uid is the customer id, so customers/{uid} lines up.
  for (const c of customers) {
    await upsertUser(c.id, `${c.accountNo.toLowerCase()}@${EMAIL_DOMAIN}`, c.companyName);
  }
  await upsertUser(ADMIN_UID, ADMIN_EMAIL, 'Branch admin');
  await db.doc(`admins/${ADMIN_UID}`).set({ name: 'Branch admin', email: ADMIN_EMAIL });
  console.log(`Sign-ins ready: ${customers.length} buyers + 1 admin (password ${PASSWORD})`);

  // 2. Clear old demo data, including orders placed during earlier demos.
  const removed = await deleteCollection('orders');
  console.log(`Removed ${removed} old orders`);

  // 3. Products and customers.
  let batch = db.batch();
  for (const p of products) {
    const { id, ...rest } = p;
    batch.set(db.doc(`products/${id}`), rest);
  }
  for (const c of customers) {
    const { id, ...rest } = c;
    batch.set(db.doc(`customers/${id}`), rest);
  }
  await batch.commit();

  // 4. Orders, dated so the newest is today.
  const shift = shiftDays(orders);
  batch = db.batch();
  for (const o of orders) {
    const { id, ...rest } = o;
    const placed = new Date(o.placedAt);
    placed.setDate(placed.getDate() + shift);
    batch.set(db.doc(`orders/${id}`), { ...rest, placedAt: admin.firestore.Timestamp.fromDate(placed) });
  }
  const lastNo = Math.max(...orders.map((o) => parseInt(o.orderNo.replace(/\D/g, ''), 10)));
  batch.set(db.doc('meta/counters'), { lastOrderNo: lastNo });
  await batch.commit();

  console.log(`Loaded ${products.length} products, ${customers.length} customers, ${orders.length} orders (moved ${shift} days forward).`);
  console.log('Buyer sign-in: TA-4102 / demo1234   Admin: admin@hm-trade.example.com / demo1234');
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
