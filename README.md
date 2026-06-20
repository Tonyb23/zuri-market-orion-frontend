# Zuri Market — Frontend

## 1. Project Overview

This is the React frontend for Zuri Market. It displays products fetched from the backend API, lets the user filter products by category, and includes a cart with quantity management. The user sees a storefront — a hero banner, a filterable product grid, and a slide-out cart — and every product/store request goes to a separate backend API over HTTP.

## 2. Tech Stack

- **React** 18.3
- **Vite** 6.4 (dev server + production bundler)
- **@vitejs/plugin-react** — React Fast Refresh support for Vite
- Plain CSS (custom properties), no CSS framework
- **Node.js 18+** required to install dependencies and run the dev server/build (the Docker image is built on `node:18-alpine`)

## 3. Project Structure

```
src/
├── components/
│   ├── Navbar.jsx
│   ├── Hero.jsx
│   ├── FilterBar.jsx
│   ├── ProductGrid.jsx
│   ├── ProductCard.jsx
│   └── CartSidebar.jsx
├── hooks/
│   └── useCart.js
├── App.jsx
├── main.jsx
└── index.css
```

- **`Navbar.jsx`** — Renders the store name and a cart button with an item-count badge. Receives `storeName`, `cartCount`, `onCartOpen`.
- **`Hero.jsx`** — Renders the landing banner/headline below the navbar. Receives `storeName`.
- **`FilterBar.jsx`** — Renders the row of category pills (`all`, `gear`, `apparel`, `home`, `tech`). Receives `activeCategory`, `onCategoryChange`.
- **`ProductGrid.jsx`** — Renders the grid of products, or a skeleton/error/empty state depending on fetch status. Receives `products`, `loading`, `error`, `onAddToCart`.
- **`ProductCard.jsx`** — Renders a single product (image, category, name, description, price, "Add to cart" button). Receives `product`, `onAddToCart`.
- **`CartSidebar.jsx`** — Renders the slide-out cart with line items, quantity steppers, subtotal, and checkout/clear buttons. Receives `cartItems`, `cartTotal`, `onRemove`, `onUpdateQuantity`, `onClear`, `onClose`.
- **`useCart.js`** — Custom hook holding cart state and exposing `cartItems`, `addToCart`, `removeFromCart`, `updateQuantity`, `clearCart`, `cartCount`, `cartTotal`.

## 4. Environment Variables

| Variable | Description |
|---|---|
| `VITE_API_URL` | Base URL of the backend API (e.g. `http://localhost:5000`) |
| `VITE_STORE_NAME` | Fallback store name shown if the `/api/store` request fails |

Vite only exposes environment variables to browser code if they're prefixed with `VITE_`. Any variable without that prefix (e.g. just `API_URL`) will be `undefined` in the app — it exists in the build environment but is never injected into the client bundle. This is a Vite security default, not a bug, so don't drop the prefix when adding new variables.

Copy `.env.example` to `.env` and fill in your values before running the app:

```bash
cp .env.example .env
```

## 5. Running Locally

```bash
npm install
npm run dev
```

The dev server starts on `http://localhost:3000`.

The backend API must also be running (at the URL set in `VITE_API_URL`) for the storefront to load — without it, the product grid will show its error state and the store name will fall back to `VITE_STORE_NAME`.

## 6. Building for Production

```bash
npm run build
```

This runs `vite build` and outputs a static, optimized bundle to the `dist/` folder. `dist/` is what gets copied into the Nginx layer of the Docker image — it's the only build artifact the container ever serves. It's excluded from Git (see `.gitignore`) since it's generated on every build, not checked-in source.

You can sanity-check the production build locally before deploying:

```bash
npm run preview
```

## 7. Docker

The `Dockerfile` uses a two-stage build:

1. **Build stage** — `node:18-alpine`. Installs dependencies with `npm ci`, accepts `VITE_API_URL` as a build argument, and runs `npm run build`.
2. **Runtime stage** — `nginx:alpine`. Copies only the `dist/` output from the build stage and serves it on port `80`.

```bash
docker build --build-arg VITE_API_URL=http://localhost:5000 -t tonyb23/zuriapp-frontend .
docker run -p 8080:80 tonyb23/zuriapp-frontend
```

Docker Hub image: **`tonyb23/zuriapp-frontend`**

## 8. Component Reference

| Component | Renders | Receives (props) |
|---|---|---|
| `Navbar` | Store name + nav links + cart button with item badge | `storeName`, `cartCount`, `onCartOpen` |
| `Hero` | Landing banner with headline and CTA buttons | `storeName` |
| `FilterBar` | Category filter pills | `activeCategory`, `onCategoryChange` |
| `ProductGrid` | Product card grid, loading skeletons, error message, or empty state | `products`, `loading`, `error`, `onAddToCart` |
| `ProductCard` | Single product: image, category, name, description, price, add-to-cart button | `product`, `onAddToCart` |
| `CartSidebar` | Slide-out panel: cart line items, quantity steppers, subtotal, checkout/clear buttons | `cartItems`, `cartTotal`, `onRemove`, `onUpdateQuantity`, `onClear`, `onClose` |
