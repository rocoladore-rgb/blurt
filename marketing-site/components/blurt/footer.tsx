'use client'

import { Mic } from 'lucide-react'

export function Footer() {
  const year = new Date().getFullYear()

  return (
    <footer className="border-t border-white/[0.06] py-12 px-6">
      <div className="max-w-5xl mx-auto">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-8">
          {/* Logo */}
          <div>
            <a href="/" className="flex items-center gap-2 mb-3">
              <div className="w-6 h-6 rounded-md bg-primary flex items-center justify-center">
                <Mic size={12} className="text-white" />
              </div>
              <span className="text-[15px] font-semibold text-white">Blurt</span>
            </a>
            <p className="text-sm text-muted-text max-w-[240px] leading-relaxed">
              Local voice dictation for Mac. Hold. Speak. Done.
            </p>
          </div>

          {/* Links */}
          <div className="grid grid-cols-2 gap-x-12 gap-y-2">
            <a href="#how-it-works" className="text-sm text-muted-text hover:text-white transition-colors">How it works</a>
            <a href="https://github.com/rocoladore-rgb/blurt/releases/download/v1.0.1/Blurt-v1.0.1.dmg" className="text-sm text-muted-text hover:text-white transition-colors">Download</a>
            <a href="#features"     className="text-sm text-muted-text hover:text-white transition-colors">Features</a>
            <a href="https://github.com/rocoladore-rgb/blurt" className="text-sm text-muted-text hover:text-white transition-colors">GitHub</a>
          </div>
        </div>

        <div className="mt-10 pt-6 border-t border-white/[0.06] flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-tertiary-text">
          <span>© {year} Blurt. All rights reserved.</span>
          <span>Built for macOS · Local-first · No tracking</span>
        </div>
      </div>
    </footer>
  )
}
