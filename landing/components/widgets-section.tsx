"use client"

import { motion, useInView } from "framer-motion"
import { useRef } from "react"
import {
  CheckCircle2,
  Clock,
  Calendar,
  FileText,
  Brain,
  Layout,
} from "lucide-react"

const widgets = [
  {
    id: 1,
    title: "Quick Tasks",
    description: "Access your tasks instantly from any screen",
    icon: CheckCircle2,
    color: "from-primary to-accent",
    preview: (
      <div className="space-y-2">
        <div className="flex items-center gap-2 text-sm">
          <div className="w-4 h-4 rounded-full border-2 border-primary" />
          <span>Review meeting notes</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <div className="w-4 h-4 rounded-full border-2 border-primary" />
          <span>Send weekly report</span>
        </div>
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <div className="w-4 h-4 rounded-full bg-primary/20" />
          <span className="line-through">Call client</span>
        </div>
      </div>
    ),
  },
  {
    id: 2,
    title: "Focus Timer",
    description: "Pomodoro timer to boost your productivity",
    icon: Clock,
    color: "from-accent to-primary",
    preview: (
      <div className="flex items-center justify-center">
        <div className="relative w-24 h-24">
          <svg className="w-24 h-24 -rotate-90">
            <circle
              cx="48"
              cy="48"
              r="42"
              stroke="currentColor"
              strokeWidth="6"
              fill="none"
              className="text-secondary"
            />
            <circle
              cx="48"
              cy="48"
              r="42"
              stroke="currentColor"
              strokeWidth="6"
              fill="none"
              strokeDasharray={263.89}
              strokeDashoffset={263.89 * 0.25}
              className="text-primary"
            />
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-xl font-bold">18:45</span>
          </div>
        </div>
      </div>
    ),
  },
  {
    id: 3,
    title: "Calendar View",
    description: "See your upcoming events at a glance",
    icon: Calendar,
    color: "from-primary to-primary/70",
    preview: (
      <div className="space-y-2">
        <div className="flex items-center gap-2 text-sm">
          <div className="w-2 h-2 rounded-full bg-primary" />
          <span className="text-muted-foreground">10:00</span>
          <span>Team standup</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <div className="w-2 h-2 rounded-full bg-accent" />
          <span className="text-muted-foreground">14:00</span>
          <span>Design review</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <div className="w-2 h-2 rounded-full bg-chart-2" />
          <span className="text-muted-foreground">16:30</span>
          <span>1:1 with manager</span>
        </div>
      </div>
    ),
  },
  {
    id: 4,
    title: "Quick Notes",
    description: "Capture ideas without switching apps",
    icon: FileText,
    color: "from-accent to-chart-2",
    preview: (
      <div className="space-y-2">
        <div className="bg-secondary/50 rounded-lg px-3 py-2 text-sm">
          Meeting notes from today...
        </div>
        <div className="bg-secondary/50 rounded-lg px-3 py-2 text-sm">
          Project ideas to explore
        </div>
      </div>
    ),
  },
  {
    id: 5,
    title: "Brain Dump",
    description: "Voice-enabled idea capture",
    icon: Brain,
    color: "from-chart-2 to-primary",
    preview: (
      <div className="text-center py-4">
        <div className="w-12 h-12 mx-auto rounded-full bg-primary/20 flex items-center justify-center mb-2">
          <span className="text-2xl">🎤</span>
        </div>
        <p className="text-sm text-muted-foreground">Tap to record</p>
      </div>
    ),
  },
  {
    id: 6,
    title: "Projects",
    description: "Organize work by project",
    icon: Layout,
    color: "from-primary/70 to-accent",
    preview: (
      <div className="space-y-2">
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium">Website Redesign</span>
          <span className="text-muted-foreground">3/8</span>
        </div>
        <div className="w-full bg-secondary rounded-full h-2">
          <div className="bg-primary h-2 rounded-full w-[37.5%]" />
        </div>
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium">Mobile App</span>
          <span className="text-muted-foreground">12/15</span>
        </div>
        <div className="w-full bg-secondary rounded-full h-2">
          <div className="bg-accent h-2 rounded-full w-[80%]" />
        </div>
      </div>
    ),
  },
]

export function WidgetsSection() {
  const containerRef = useRef<HTMLDivElement>(null)
  const isInView = useInView(containerRef, { once: true, margin: "-100px" })

  return (
    <section
      ref={containerRef}
      className="py-24 bg-gradient-to-b from-background to-secondary/30"
    >
      <div className="mx-auto max-w-6xl px-4">
        <motion.div
          initial={{ y: 40, opacity: 0 }}
          animate={isInView ? { y: 0, opacity: 1 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl font-bold text-foreground md:text-4xl mb-4">
            Widgets for Every Need
          </h2>
          <p className="text-muted-foreground max-w-xl mx-auto">
            Pop out any widget and place it on your screen for quick access.
            Always visible, never in the way.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {widgets.map((widget, index) => (
            <motion.div
              key={widget.id}
              initial={{ y: 60, opacity: 0 }}
              animate={isInView ? { y: 0, opacity: 1 } : {}}
              transition={{
                duration: 0.6,
                delay: index * 0.1,
                ease: [0.22, 1, 0.36, 1],
              }}
              whileHover={{ y: -8, scale: 1.02 }}
              className="group relative bg-card rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-all duration-300 cursor-pointer overflow-hidden"
            >
              {/* Gradient Border Effect */}
              <div
                className={`absolute inset-0 bg-gradient-to-br ${widget.color} opacity-0 group-hover:opacity-10 transition-opacity duration-300 rounded-2xl`}
              />

              {/* Header */}
              <div className="flex items-center gap-3 mb-4 relative z-10">
                <div
                  className={`w-10 h-10 rounded-xl bg-gradient-to-br ${widget.color} flex items-center justify-center`}
                >
                  <widget.icon className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="font-semibold text-card-foreground">
                    {widget.title}
                  </h3>
                  <p className="text-xs text-muted-foreground">
                    {widget.description}
                  </p>
                </div>
              </div>

              {/* Preview */}
              <div className="relative z-10 bg-secondary/30 rounded-xl p-4 min-h-[120px]">
                {widget.preview}
              </div>

              {/* Pop-out indicator */}
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                whileHover={{ opacity: 1, scale: 1 }}
                className="absolute top-4 right-4 bg-primary text-primary-foreground text-xs px-2 py-1 rounded-full font-medium"
              >
                Pop out ↗
              </motion.div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
