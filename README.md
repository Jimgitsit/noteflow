# NoteFlow ✏️

> A lightweight, browser-based note-taking web application designed for speed and simplicity.

[![CI](https://github.com/jimgitsit/noteflow/actions/workflows/ci.yml/badge.svg)](https://github.com/jimgitsit/noteflow/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Local Development Setup](#local-development-setup)
- [Environment Variables](#environment-variables)
- [Running Tests](#running-tests)
- [Contribution Guidelines](#contribution-guidelines)
- [Milestones](#milestones)
- [License](#license)

---

## Overview

NoteFlow lets users create, edit, search, and organize notes without unnecessary friction. The app targets individuals who want a fast, distraction-free writing experience accessible from any device.

**Key features:**
- 📝 Plain-text and Markdown note editing with auto-save
- 🔍 Instant full-text search across all notes
- 🏷️ Tag-based organization
- 🔐 Secure JWT auth via HTTP-only cookies
- 📱 Responsive two-panel layout (desktop) / stacked layout (mobile)
- ⌨️ Keyboard shortcuts & command palette (`Cmd/Ctrl+K`)

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | React 18 + TypeScript | Component-based UI with strong typing |
| Styling | Tailwind CSS | Utility-first, zero runtime overhead |
| State | Zustand | Lightweight global state management |
| Backend | Node.js + Express | REST API server |
| Database | PostgreSQL | Relational data + full-text search (tsvector) |
| Auth | JWT (HTTP-only cookies) | Stateless, XSS-resistant authentication |
| Frontend Hosting | Vercel | CDN-backed, zero-config React deploys |
| Backend Hosting | Railway | Managed Node.js + PostgreSQL hosting |

---

## Repository Structure

This is a monorepo containing both the frontend and backend packages.

```
noteflow/
├── .github/
│   └── workflows/
│       └── ci.yml           # GitHub Actions CI pipeline
├── packages/
│   ├── client/              # React + TypeScript frontend
│   │   ├── public/
│   │   ├── src/
│   │   │   ├── components/  # Reusable UI components
│   │   │   ├── hooks/       # Custom React hooks
│   │   │   ├── pages/       # Route-level page components
│   │   │   ├── store/       # Zustand state stores
│   │   │   ├── types/       # Shared TypeScript types
│   │   │   ├── utils/       # Utility functions
│   │   │   ├── App.tsx
│   │   │   └── main.tsx
│   │   ├── .env.example
│   │   ├── index.html
│   │   ├── package.json
│   │   ├── tailwind.config.ts
│   │   ├── tsconfig.json
│   │   └── vite.config.ts
│   └── server/              # Node.js + Express backend
│       ├── src/
│       │   ├── controllers/ # Route handler logic
│       │   ├── middleware/  # Auth, error handling, rate limiting
│       │   ├── models/      # Database models / queries
│       │   ├── routes/      # Express route definitions
│       │   ├── types/       # Shared TypeScript types
│       │   ├── utils/       # Helpers (JWT, bcrypt, etc.)
│       │   └── index.ts     # App entry point
│       ├── .env.example
│       ├── package.json
│       └── tsconfig.json
├── .gitignore
├── package.json             # Root workspace package.json
└── README.md
```

---

## Local Development Setup

### Prerequisites

- **Node.js** v20+ ([download](https://nodejs.org/))
- **npm** v10+ (included with Node.js)
- **PostgreSQL** v15+ ([download](https://www.postgresql.org/download/))
- **Git**

### 1. Clone the repository

```bash
git clone https://github.com/jimgitsit/noteflow.git
cd noteflow
```

### 2. Install all dependencies

From the root of the monorepo:

```bash
npm install
```

This installs dependencies for the root workspace and all packages (`client` and `server`) via npm workspaces.

### 3. Set up environment variables

```bash
# Backend
cp packages/server/.env.example packages/server/.env

# Frontend
cp packages/client/.env.example packages/client/.env
```

Fill in the values as described in the [Environment Variables](#environment-variables) section.

### 4. Set up the database

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE noteflow;"

# Run migrations
npm run db:migrate --workspace=packages/server
```

### 5. Start the development servers

```bash
# Start both client and server concurrently from the root
npm run dev
```

Or start them individually:

```bash
# Terminal 1 — Backend (http://localhost:3001)
npm run dev --workspace=packages/server

# Terminal 2 — Frontend (http://localhost:5173)
npm run dev --workspace=packages/client
```

---

## Environment Variables

### Backend (`packages/server/.env`)

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Runtime environment | `development` |
| `PORT` | Express server port | `3001` |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/noteflow` |
| `JWT_SECRET` | Secret key for signing JWTs (min 32 chars) | `your-super-secret-key-here` |
| `JWT_EXPIRES_IN` | JWT expiry duration | `7d` |
| `COOKIE_SECRET` | Secret for signed cookies | `your-cookie-secret` |
| `CLIENT_URL` | Frontend origin for CORS | `http://localhost:5173` |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window in ms | `900000` |
| `RATE_LIMIT_MAX` | Max requests per window | `100` |

### Frontend (`packages/client/.env`)

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_URL` | Backend API base URL | `http://localhost:3001` |

> ⚠️ **Never commit `.env` files.** They are listed in `.gitignore`. Always use `.env.example` as the template.

---

## Running Tests

```bash
# Run all tests across all packages
npm test

# Run tests for a specific package
npm test --workspace=packages/server
npm test --workspace=packages/client

# Run tests in watch mode
npm run test:watch --workspace=packages/client
```

The CI pipeline runs the full test suite on every pull request targeting `main` or `develop`.

---

## Contribution Guidelines

We welcome contributions! Please follow these steps:

### Branching strategy

```
main         ← production-ready code (protected)
develop      ← integration branch (protected)
feature/*    ← new features  (e.g. feature/note-search)
bugfix/*     ← bug fixes     (e.g. bugfix/auto-save-race-condition)
hotfix/*     ← urgent prod fixes branched from main
```

### Workflow

1. **Fork** the repository (external contributors) or create a branch from `develop`.
2. **Branch naming:** `feature/<short-description>` or `bugfix/<short-description>`.
3. **Commit messages:** Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` new feature
   - `fix:` bug fix
   - `chore:` tooling / config changes
   - `docs:` documentation only
   - `test:` adding or fixing tests
   - `refactor:` code restructure without behaviour change
4. **Pull requests:**
   - Open PRs against `develop` (not `main`).
   - Fill out the PR template completely.
   - Ensure all CI checks pass before requesting review.
   - At least **1 approving review** is required to merge.
5. **Code style:** ESLint + Prettier are configured. Run `npm run lint` and `npm run format` before pushing.

### Issue labels

| Label | Meaning |
|-------|---------|
| `M1-Foundation` | Auth, basic CRUD, plain-text editor (Week 2) |
| `M2-Search-Tags` | Full-text search, tag system (Week 4) |
| `M3-Polish` | Markdown preview, shortcuts, mobile (Week 6) |
| `M4-Launch` | Performance, accessibility, production deploy (Week 8) |
| `bug` | Something isn't working |
| `enhancement` | New feature or request |
| `documentation` | Improvements or additions to documentation |
| `good first issue` | Good for newcomers |
| `help wanted` | Extra attention is needed |
| `wontfix` | This will not be worked on |

---

## Milestones

| Phase | Scope | Target |
|-------|-------|--------|
| **M1 – Foundation** | User auth (register/login/logout), note CRUD, plain-text editor, auto-save | Week 2 |
| **M2 – Search & Tags** | Full-text search, tag CRUD, tag-based filtering | Week 4 |
| **M3 – Polish** | Markdown preview, keyboard shortcuts, command palette, mobile layout | Week 6 |
| **M4 – Launch** | Performance tuning (LCP < 1.5s), WCAG 2.1 AA audit, production deploy | Week 8 |

---

## License

This project is licensed under the [MIT License](LICENSE).
