import Link from "next/link"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "License - Clouded",
  description: "Open-source licensing information for the Clouded macOS app",
}

export default function TermsPage() {
  return (
    <main className="mx-auto max-w-3xl px-4 py-16">
      <Link href="/" className="text-sm text-muted-foreground hover:text-foreground mb-8 inline-block">
        &larr; Back to home
      </Link>

      <h1 className="text-3xl font-bold mb-8">License</h1>
      <p className="text-sm text-muted-foreground mb-8">Last updated: April 10, 2026</p>

      <div className="prose prose-neutral dark:prose-invert max-w-none space-y-6">
        <section>
          <h2 className="text-xl font-semibold mb-3">Open Source License</h2>
          <p className="text-muted-foreground">
            Clouded is released under the MIT License. You may use, copy, modify,
            merge, publish, distribute, sublicense, and sell copies of the app
            and source code under the terms of that license.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Where to Find It</h2>
          <p className="text-muted-foreground">
            The full license text is available in the repository&apos;s LICENSE file.
            If you redistribute Clouded or substantial portions of it, keep the
            copyright notice and license text with your distribution.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Warranty Disclaimer</h2>
          <p className="text-muted-foreground">
            As with the MIT License itself, Clouded is provided &quot;as is&quot;,
            without warranty of any kind, express or implied.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Your Data</h2>
          <p className="text-muted-foreground">
            All data created in Clouded is stored locally on your device. You are solely
            responsible for backing up your data. We are not responsible for any data loss.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Contact</h2>
          <p className="text-muted-foreground">
            If you have questions about Clouded or its license, contact us at{" "}
            <a href="mailto:support@getclouded.com" className="text-primary hover:underline">
              support@getclouded.com
            </a>.
          </p>
        </section>
      </div>
    </main>
  )
}
