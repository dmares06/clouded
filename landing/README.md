# Clouded

**Your simple cloud note for macOS**

The easiest way to create tasks, check calendar, and brain dump ideas. Simple, beautiful, and powerful productivity for macOS.

## Features

- **Tasks** — Create, categorize, and track tasks with completion status
- **Notes** — Quick-capture notes without switching apps
- **Projects** — Organize work into projects with dedicated task lists
- **Focus Timer** — Pomodoro-style timer to stay productive
- **Brain Dump** — Voice-enabled idea capture for when inspiration strikes
- **Calendar / Up Next** — See upcoming events at a glance
- **Pop-out Widgets** — Detach any widget (tasks, timer, calendar, notes, brain dump, projects) and place it on your screen

## Tech Stack

- [Next.js](https://nextjs.org/) 16 with App Router
- [React](https://react.dev/) 19
- [TypeScript](https://www.typescriptlang.org/)
- [Tailwind CSS](https://tailwindcss.com/) 4
- [Framer Motion](https://www.framer.com/motion/) for scroll-driven animations and transitions
- [shadcn/ui](https://ui.shadcn.com/) (Radix UI primitives, New York style)
- [Vercel Analytics](https://vercel.com/analytics)

## Getting Started

### Prerequisites

- Node.js 18+
- [pnpm](https://pnpm.io/)

### Install

```bash
pnpm install
```

### Development

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

```bash
pnpm build
```

### Start (production)

```bash
pnpm start
```

### Lint

```bash
pnpm lint
```

## Project Structure

```
app/            Next.js App Router — page, layout, global styles
components/     Page sections (hero, product demo, widgets, pricing, footer)
  ui/           shadcn/ui component library
hooks/          Custom React hooks
lib/            Utility functions
public/         Static assets (images, icons, SVGs)
```

## License

All rights reserved.
