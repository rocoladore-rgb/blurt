'use client'

import { Download, Apple } from 'lucide-react'

export function DownloadCTA() {
  return (
    <section id="download" className="py-28 px-6 bg-surface border-t border-white/[0.06]">
      <div className="max-w-3xl mx-auto text-center">
        {/* Glow */}
        <div className="relative">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[300px] rounded-full bg-primary/15 blur-[80px] pointer-events-none" />

          <div className="relative">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full border border-primary/30 bg-primary/10 text-sm text-accent-purple-light mb-6">
              <span className="w-1.5 h-1.5 rounded-full bg-primary" />
              macOS 13 Ventura and later
            </div>

            <h2 className="text-4xl md:text-[56px] font-bold tracking-tight text-white leading-tight mb-4">
              Start dictating<br />
              <span className="text-gradient">in 60 seconds.</span>
            </h2>

            <p className="text-lg text-muted-text max-w-md mx-auto mb-10">
              Download Blurt, grant microphone access, and the model downloads itself. Hold Fn, speak — done.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <a
                href="#"
                className="flex items-center gap-2.5 px-7 py-3.5 rounded-xl bg-primary hover:bg-primary-dark text-white font-semibold text-[15px] transition-colors shadow-lg shadow-primary/30"
              >
                <Download size={17} />
                Download Blurt — Free for Mac
              </a>
              <div className="flex items-center gap-1.5 text-sm text-muted-text">
                <Apple size={14} />
                <span>Apple Silicon &amp; Intel</span>
              </div>
            </div>

            <p className="mt-6 text-xs text-tertiary-text">
              Free forever · No account required · Open source
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
