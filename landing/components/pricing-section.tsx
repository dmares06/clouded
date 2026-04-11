"use client"

import { motion, useInView } from "framer-motion"
import { useRef } from "react"
import { Check } from "lucide-react"

const DOWNLOAD_URL = "https://github.com/dmares06/clouded/releases/latest/download/Clouded.dmg"

const features = [
  "Unlimited tasks & projects",
  "Rich notes editor",
  "Pomodoro focus timer",
  "Brain dump with voice",
  "Calendar integration",
  "Widget customization",
  "Desktop & notch widgets",
  "Local-only data storage",
]

export function PricingSection() {
  const containerRef = useRef<HTMLDivElement>(null)
  const isInView = useInView(containerRef, { once: true, margin: "-100px" })

  return (
    <section
      ref={containerRef}
      className="py-24 bg-gradient-to-b from-secondary/30 to-background"
    >
      <div className="mx-auto max-w-2xl px-4">
        <motion.div
          initial={{ y: 40, opacity: 0 }}
          animate={isInView ? { y: 0, opacity: 1 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl font-bold text-foreground md:text-4xl mb-4">
            Free and open source
          </h2>
          <p className="text-muted-foreground max-w-xl mx-auto">
            Clouded is MIT-licensed. Use it, modify it, and build on it with all
            features available from day one.
          </p>
        </motion.div>

        <motion.div
          initial={{ y: 60, opacity: 0 }}
          animate={isInView ? { y: 0, opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 0.15, ease: [0.22, 1, 0.36, 1] }}
          className="relative bg-card rounded-2xl p-8 shadow-lg ring-2 ring-primary shadow-2xl"
        >
          <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-primary text-primary-foreground text-sm px-4 py-1 rounded-full font-medium">
            MIT
          </div>

          <div className="text-center mb-6">
            <h3 className="text-xl font-bold text-card-foreground mb-2">
              Everything included
            </h3>
            <p className="text-sm text-muted-foreground mb-4">
              All features, source included
            </p>
            <div className="flex items-baseline justify-center gap-1">
              <span className="text-4xl font-bold text-card-foreground">$0</span>
              <span className="text-muted-foreground">free under MIT</span>
            </div>
          </div>

          <ul className="space-y-3 mb-8">
            {features.map((feature) => (
              <li key={feature} className="flex items-center gap-3 text-sm">
                <Check className="w-5 h-5 text-primary flex-shrink-0" />
                <span className="text-card-foreground">{feature}</span>
              </li>
            ))}
          </ul>

          <a
            href={DOWNLOAD_URL}
            className="block w-full text-center rounded-md bg-primary text-primary-foreground py-2.5 font-medium hover:bg-primary/90 transition-colors"
          >
            Download for macOS
          </a>
        </motion.div>
      </div>
    </section>
  )
}
