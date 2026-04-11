import Link from "next/link"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Privacy Policy - Clouded",
  description: "Privacy policy for the Clouded macOS app",
}

export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-3xl px-4 py-16">
      <Link href="/" className="text-sm text-muted-foreground hover:text-foreground mb-8 inline-block">
        &larr; Back to home
      </Link>

      <h1 className="text-3xl font-bold mb-8">Privacy Policy</h1>
      <p className="text-sm text-muted-foreground mb-8">Last updated: March 19, 2026</p>

      <div className="prose prose-neutral dark:prose-invert max-w-none space-y-6">
        <section>
          <h2 className="text-xl font-semibold mb-3">Overview</h2>
          <p className="text-muted-foreground">
            Clouded is a macOS productivity app that stores all your data locally on your device.
            We do not collect, transmit, or store any of your personal data on external servers.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Data Storage</h2>
          <p className="text-muted-foreground">
            All your tasks, notes, projects, brain dumps, and settings are stored locally in
            your macOS Application Support directory. No data leaves your device. There are no
            user accounts, cloud sync, or analytics in the app itself.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">System Permissions</h2>
          <p className="text-muted-foreground mb-2">Clouded requests the following system permissions:</p>
          <ul className="list-disc pl-6 space-y-2 text-muted-foreground">
            <li>
              <strong>Calendar Access</strong> &mdash; Used to display your upcoming events in the
              &quot;Up Next&quot; tab and to create calendar events for task due dates. Calendar data
              is read locally via the EventKit framework and is never transmitted externally.
            </li>
            <li>
              <strong>Microphone Access</strong> &mdash; Used for the voice input feature in Brain
              Dump. Audio is processed on-device using Apple&apos;s Speech framework and is never
              recorded or stored.
            </li>
            <li>
              <strong>Speech Recognition</strong> &mdash; Used to transcribe voice input into text.
              Transcription is performed on-device by Apple&apos;s Speech framework.
            </li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Landing Page Analytics</h2>
          <p className="text-muted-foreground">
            This website uses Vercel Analytics to collect anonymous, aggregate page view data.
            No personally identifiable information is collected. No cookies are used for tracking.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Third-Party Services</h2>
          <p className="text-muted-foreground">
            The Clouded app does not integrate with any third-party services, APIs, or analytics
            platforms. Your data stays on your machine.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Changes to This Policy</h2>
          <p className="text-muted-foreground">
            We may update this privacy policy from time to time. Changes will be posted on this
            page with an updated revision date.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold mb-3">Contact</h2>
          <p className="text-muted-foreground">
            If you have questions about this privacy policy, contact us at{" "}
            <a href="mailto:support@getclouded.com" className="text-primary hover:underline">
              support@getclouded.com
            </a>.
          </p>
        </section>
      </div>
    </main>
  )
}
