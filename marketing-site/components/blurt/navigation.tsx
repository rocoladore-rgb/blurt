'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Menu, X, Mic } from 'lucide-react'

const navLinks = [
  { name: 'How It Works', href: '#how-it-works' },
  { name: 'Features',     href: '#features'     },
  { name: 'Pricing',      href: '#pricing'      },
]

export function Navigation() {
  const [scrolled,        setScrolled]        = useState(false)
  const [mobileMenuOpen,  setMobileMenuOpen]  = useState(false)

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 80)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <>
      <motion.nav
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ duration: 0.6, ease: 'easeOut' }}
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
          scrolled ? 'glass py-4' : 'py-6 bg-transparent'
        }`}
      >
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="flex items-center justify-between">

            {/* Logo */}
            <a href="#" className="flex items-center gap-2 group">
              <div className="relative">
                <Mic className="h-6 w-6 text-[#6E56CF]" />
                <div className="absolute inset-0 bg-[#6E56CF] blur-lg opacity-50 group-hover:opacity-75 transition-opacity" />
              </div>
              <span className="text-xl font-semibold tracking-tight text-[#F5F5F7]">
                Blurt
              </span>
            </a>

            {/* Desktop nav pills */}
            <div className="hidden md:flex items-center gap-3">
              {navLinks.map((link) => (
                <a key={link.name} href={link.href} className="nav-pill">
                  {link.name}
                </a>
              ))}
            </div>

            {/* CTA */}
            <div className="hidden md:block">
              <a href="#download" className="nav-cta">Download Free</a>
            </div>

            {/* Mobile toggle */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 text-[#A1A1A6] hover:text-[#F5F5F7] transition-colors"
              aria-label="Toggle menu"
            >
              {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>
      </motion.nav>

      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 md:hidden"
          >
            <div className="absolute inset-0 bg-black/95 backdrop-blur-xl" />
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 20 }}
              transition={{ delay: 0.1 }}
              className="relative flex flex-col items-center justify-center h-full gap-6"
            >
              {navLinks.map((link, i) => (
                <motion.a
                  key={link.name}
                  href={link.href}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.1 + i * 0.05 }}
                  onClick={() => setMobileMenuOpen(false)}
                  className="nav-pill text-lg"
                >
                  {link.name}
                </motion.a>
              ))}
              <motion.a
                href="#download"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                onClick={() => setMobileMenuOpen(false)}
                className="nav-cta mt-4 text-base"
              >
                Download Free
              </motion.a>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}
