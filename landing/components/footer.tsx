"use client"

import { motion } from "framer-motion"
import Link from "next/link"
import { Github, Mail, Cloud } from "lucide-react"

const DOWNLOAD_URL = "https://github.com/dmares06/clouded/releases/latest/download/Clouded.dmg"

const footerLinks = {
  Product: [
    { name: "Features", href: "#features" },
    { name: "Pricing", href: "#pricing" },
    { name: "Download", href: DOWNLOAD_URL },
  ],
  Legal: [
    { name: "Privacy", href: "/privacy" },
    { name: "License", href: "/terms" },
  ],
}

const socialLinks = [
  { name: "GitHub", icon: Github, href: "https://github.com/dmares06/clouded" },
  { name: "Email", icon: Mail, href: "mailto:support@getclouded.com" },
]

export function Footer() {
  return (
    <footer className="bg-foreground text-background py-16">
      <div className="mx-auto max-w-6xl px-4">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
          {/* Brand */}
          <div className="col-span-2">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="flex items-center gap-2 mb-4"
            >
              <div className="w-10 h-10 rounded-xl bg-primary flex items-center justify-center">
                <Cloud className="w-6 h-6 text-primary-foreground" />
              </div>
              <span className="text-xl font-bold">Clouded</span>
            </motion.div>
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 }}
              className="text-background/70 text-sm mb-4 max-w-xs"
            >
              Your simple cloud note for macOS. The easiest way to create tasks,
              check calendar, and brain dump ideas.
            </motion.p>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.2 }}
              className="flex gap-4"
            >
              {socialLinks.map((social) => (
                <Link
                  key={social.name}
                  href={social.href}
                  className="w-10 h-10 rounded-full bg-background/10 hover:bg-background/20 flex items-center justify-center transition-colors"
                >
                  <social.icon className="w-5 h-5" />
                </Link>
              ))}
            </motion.div>
          </div>

          {/* Links */}
          {Object.entries(footerLinks).map(([category, links], index) => (
            <motion.div
              key={category}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 * (index + 2) }}
            >
              <h3 className="font-semibold mb-4">{category}</h3>
              <ul className="space-y-2">
                {links.map((link) => (
                  <li key={link.name}>
                    <Link
                      href={link.href}
                      className="text-sm text-background/70 hover:text-background transition-colors"
                    >
                      {link.name}
                    </Link>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>

        {/* Bottom */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.5 }}
          className="pt-8 border-t border-background/10 flex flex-col md:flex-row items-center justify-between gap-4"
        >
          <p className="text-sm text-background/50">
            &copy; {new Date().getFullYear()} Clouded. Released under the MIT License.
          </p>
          <div className="flex items-center gap-2">
            <span className="text-sm text-background/50">Made with</span>
            <span className="text-primary">&#9829;</span>
            <span className="text-sm text-background/50">for macOS</span>
          </div>
        </motion.div>
      </div>
    </footer>
  )
}
