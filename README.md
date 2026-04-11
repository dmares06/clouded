# Clouded

Clouded is a local-first macOS productivity app with a matching marketing site.

It combines quick capture, lightweight planning, and always-available desktop surfaces:

- Tasks with categories and due dates
- Notes for fast capture
- Projects with dedicated task lists
- A Pomodoro-style focus timer
- Brain Dump voice capture
- Calendar / Up Next integration
- Pop-out desktop widgets and a notch-style panel

## Open Source

Clouded is open source under the MIT License. You are free to use, modify, and distribute it under the terms in [LICENSE](LICENSE).

## Repository Structure

```text
cloudapp/   Native macOS app built with SwiftUI
landing/    Next.js marketing site and download pages
```

## Getting Started

### macOS app

Open `cloudapp/Cloud.xcodeproj` in Xcode and run the `Cloud` target.

### Landing site

Requirements:

- Node.js 18+
- pnpm

Install dependencies:

```bash
cd landing
pnpm install
```

Run the development server:

```bash
pnpm dev
```

Build for production:

```bash
pnpm build
```

## Contributing

Issues and pull requests are welcome. If you change behavior, docs, or public messaging, keep the app and landing site consistent.

## License

MIT
