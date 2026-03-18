"use client"

import { motion, useScroll, useTransform } from "framer-motion"
import { useRef } from "react"
import Image from "next/image"

const title = "Clouded"

export function HeroSection() {
  const containerRef = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"],
  })

  const cloudLeftX = useTransform(scrollYProgress, [0, 0.5], [0, -150])
  const cloudRightX = useTransform(scrollYProgress, [0, 0.5], [0, 150])
  const textY = useTransform(scrollYProgress, [0, 0.5], [0, -100])
  const opacity = useTransform(scrollYProgress, [0, 0.3], [1, 0])

  return (
    <section
      ref={containerRef}
      className="relative h-screen w-full overflow-hidden"
    >
      {/* Background Sky */}
      <div className="absolute inset-0 bg-gradient-to-b from-[#0077cc] via-[#4aa3df] to-[#a8d4ef]" />

      {/* Cloud Image Background */}
      <div className="absolute inset-0">
        <Image
          src="/images/clouds-hero.png"
          alt="Clouds"
          fill
          className="object-cover"
          priority
        />
      </div>

      {/* Animated Cloud Overlays for parallax effect */}
      <motion.div
        style={{ x: cloudLeftX }}
        className="absolute left-0 top-0 h-full w-1/2 pointer-events-none"
      >
        <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent" />
      </motion.div>

      <motion.div
        style={{ x: cloudRightX }}
        className="absolute right-0 top-0 h-full w-1/2 pointer-events-none"
      >
        <div className="absolute inset-0 bg-gradient-to-l from-white/20 to-transparent" />
      </motion.div>

      {/* Content */}
      <motion.div
        style={{ y: textY, opacity }}
        className="relative z-10 flex h-full flex-col items-center justify-center px-4"
      >
        {/* Animated Title */}
        <div className="flex overflow-hidden">
          {title.split("").map((letter, index) => (
            <motion.span
              key={index}
              initial={{ y: 100, opacity: 0, rotateX: -90 }}
              animate={{ y: 0, opacity: 1, rotateX: 0 }}
              transition={{
                duration: 0.8,
                delay: 0.5 + index * 0.1,
                ease: [0.22, 1, 0.36, 1],
              }}
              className="text-6xl font-bold text-white drop-shadow-lg md:text-8xl lg:text-9xl"
              style={{ textShadow: "0 4px 20px rgba(0, 0, 0, 0.3)" }}
            >
              {letter}
            </motion.span>
          ))}
        </div>

        {/* Subtitle */}
        <motion.p
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8, delay: 1.5 }}
          className="mt-6 text-xl font-medium text-white/90 drop-shadow-md md:text-2xl"
        >
          Your simple cloud note for macOS
        </motion.p>

        {/* Description */}
        <motion.p
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8, delay: 1.8 }}
          className="mt-4 max-w-md text-center text-base text-white/80 drop-shadow-sm md:text-lg"
        >
          The easiest way to create tasks, check calendar, and brain dump ideas
        </motion.p>

        {/* CTA Button */}
        <motion.button
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8, delay: 2.1 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="mt-8 rounded-full bg-white px-8 py-3 font-semibold text-primary shadow-xl transition-shadow hover:shadow-2xl"
        >
          Download for macOS
        </motion.button>

        {/* Scroll Indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 2.5 }}
          className="absolute bottom-10 flex flex-col items-center"
        >
          <span className="mb-2 text-sm text-white/70">Scroll to explore</span>
          <motion.div
            animate={{ y: [0, 10, 0] }}
            transition={{ duration: 1.5, repeat: Infinity }}
            className="h-10 w-6 rounded-full border-2 border-white/50 p-1"
          >
            <motion.div
              animate={{ y: [0, 12, 0] }}
              transition={{ duration: 1.5, repeat: Infinity }}
              className="h-2 w-2 rounded-full bg-white/80"
            />
          </motion.div>
        </motion.div>
      </motion.div>
    </section>
  )
}
