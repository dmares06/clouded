"use client"

import { motion, useInView } from "framer-motion"
import { useRef, useState } from "react"
import { Check } from "lucide-react"
import { Button } from "@/components/ui/button"

const plans = [
  {
    name: "Free",
    price: "$0",
    period: "forever",
    description: "Perfect for getting started",
    features: [
      "Up to 50 tasks",
      "Basic notes",
      "1 project",
      "Focus timer",
      "Community support",
    ],
    cta: "Get Started",
    popular: false,
  },
  {
    name: "Pro",
    price: "$9",
    period: "/month",
    description: "For power users who want more",
    features: [
      "Unlimited tasks",
      "Unlimited notes",
      "Unlimited projects",
      "Advanced focus timer",
      "Brain dump with voice",
      "Calendar integration",
      "Widget customization",
      "Priority support",
    ],
    cta: "Start Free Trial",
    popular: true,
  },
  {
    name: "Team",
    price: "$19",
    period: "/user/month",
    description: "For teams that work together",
    features: [
      "Everything in Pro",
      "Team collaboration",
      "Shared projects",
      "Admin dashboard",
      "Usage analytics",
      "SSO integration",
      "Dedicated support",
      "Custom onboarding",
    ],
    cta: "Contact Sales",
    popular: false,
  },
]

export function PricingSection() {
  const containerRef = useRef<HTMLDivElement>(null)
  const isInView = useInView(containerRef, { once: true, margin: "-100px" })
  const [isAnnual, setIsAnnual] = useState(false)

  return (
    <section
      ref={containerRef}
      className="py-24 bg-gradient-to-b from-secondary/30 to-background"
    >
      <div className="mx-auto max-w-6xl px-4">
        <motion.div
          initial={{ y: 40, opacity: 0 }}
          animate={isInView ? { y: 0, opacity: 1 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl font-bold text-foreground md:text-4xl mb-4">
            Simple, transparent pricing
          </h2>
          <p className="text-muted-foreground max-w-xl mx-auto mb-8">
            Start free and upgrade when you&apos;re ready. No hidden fees, no
            surprises.
          </p>

          {/* Billing Toggle */}
          <div className="flex items-center justify-center gap-4">
            <span
              className={`text-sm ${
                !isAnnual ? "text-foreground font-medium" : "text-muted-foreground"
              }`}
            >
              Monthly
            </span>
            <button
              onClick={() => setIsAnnual(!isAnnual)}
              className="relative w-14 h-7 rounded-full bg-secondary transition-colors"
            >
              <motion.div
                animate={{ x: isAnnual ? 28 : 4 }}
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
                className="absolute top-1 w-5 h-5 rounded-full bg-primary"
              />
            </button>
            <span
              className={`text-sm ${
                isAnnual ? "text-foreground font-medium" : "text-muted-foreground"
              }`}
            >
              Annual
              <span className="ml-1 text-xs text-primary">(Save 20%)</span>
            </span>
          </div>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {plans.map((plan, index) => (
            <motion.div
              key={plan.name}
              initial={{ y: 60, opacity: 0 }}
              animate={isInView ? { y: 0, opacity: 1 } : {}}
              transition={{
                duration: 0.6,
                delay: index * 0.15,
                ease: [0.22, 1, 0.36, 1],
              }}
              className={`relative bg-card rounded-2xl p-8 shadow-lg ${
                plan.popular
                  ? "ring-2 ring-primary scale-105 shadow-2xl"
                  : "hover:shadow-xl"
              } transition-all duration-300`}
            >
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-primary text-primary-foreground text-sm px-4 py-1 rounded-full font-medium">
                  Most Popular
                </div>
              )}

              <div className="text-center mb-6">
                <h3 className="text-xl font-bold text-card-foreground mb-2">
                  {plan.name}
                </h3>
                <p className="text-sm text-muted-foreground mb-4">
                  {plan.description}
                </p>
                <div className="flex items-baseline justify-center gap-1">
                  <span className="text-4xl font-bold text-card-foreground">
                    {isAnnual && plan.price !== "$0"
                      ? `$${Math.floor(parseInt(plan.price.slice(1)) * 0.8)}`
                      : plan.price}
                  </span>
                  <span className="text-muted-foreground">{plan.period}</span>
                </div>
              </div>

              <ul className="space-y-3 mb-8">
                {plan.features.map((feature) => (
                  <li key={feature} className="flex items-center gap-3 text-sm">
                    <Check className="w-5 h-5 text-primary flex-shrink-0" />
                    <span className="text-card-foreground">{feature}</span>
                  </li>
                ))}
              </ul>

              <Button
                className={`w-full ${
                  plan.popular
                    ? "bg-primary text-primary-foreground hover:bg-primary/90"
                    : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                }`}
              >
                {plan.cta}
              </Button>
            </motion.div>
          ))}
        </div>

        {/* Money-back guarantee */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="text-center text-sm text-muted-foreground mt-12"
        >
          💳 14-day free trial • No credit card required • Cancel anytime
        </motion.p>
      </div>
    </section>
  )
}
