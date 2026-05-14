'use client'

import { Download, Lock, Zap, WifiOff } from 'lucide-react'

const waveDelays = ['0ms', '100ms', '200ms', '50ms', '150ms', '250ms', '300ms', '80ms',
                    '180ms', '280ms', '30ms', '130ms', '230ms', '330ms', '60ms',
                    '160ms', '260ms', '110ms', '210ms', '310ms', '70ms', '170ms', '270ms', '320ms']

const waveHeights = [30, 45, 65, 85, 95, 85, 65, 75, 90, 70, 55, 80, 100, 80, 55, 70, 90, 75, 65, 85, 95, 85, 65, 45]

export function Hero() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center pt-24 pb-20 px-6 overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full bg-primary/10 blur-[120px] pointer-events-none" />

      {/* Badge */}
      <div className="mb-6 flex items-center gap-2 px-3 py-1.5 rounded-full border border-white/10 bg-white/[0.03] text-sm text-muted-text animate-fade-in">
        <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
        <span>Free · Local · Open Source</span>
      </div>

      {/* Headline */}
      <h1 className="text-center font-bold tracking-tight animate-fade-up" style={{ animationDelay: '80ms', opacity: 0 }}>
        <span className="block text-[56px] md:text-[72px] lg:text-[84px] leading-[1.05] text-white">
          Hold. Speak.
        </span>
        <span className="block text-[56px] md:text-[72px] lg:text-[84px] leading-[1.05] text-gradient">
          Done.
        </span>
      </h1>

      {/* Subtext */}
      <p className="mt-6 text-center text-lg md:text-xl text-muted-text max-w-[520px] leading-relaxed animate-fade-up" style={{ animationDelay: '160ms', opacity: 0 }}>
        Blurt listens while you hold a key, transcribes your voice on-device, and types the result anywhere on your Mac — instantly and privately.
      </p>

      {/* CTAs */}
      <div className="mt-10 flex flex-col sm:flex-row items-center gap-3 animate-fade-up" style={{ animationDelay: '240ms', opacity: 0 }}>
        <a
          href="#download"
          className="flex items-center gap-2 px-6 py-3 rounded-xl bg-primary hover:bg-primary-dark text-white font-semibold text-[15px] transition-colors shadow-lg shadow-primary/25"
        >
          <Download size={16} />
          Download Blurt — Free for Mac
        </a>
        <a
          href="#how-it-works"
          className="px-6 py-3 rounded-xl border border-white/10 text-[15px] text-muted-text hover:text-white hover:border-white/20 transition-colors"
        >
          See how it works
        </a>
      </div>

      {/* Feature pills */}
      <div className="mt-8 flex flex-wrap items-center justify-center gap-3 animate-fade-up" style={{ animationDelay: '320ms', opacity: 0 }}>
        {[
          { icon: Lock,   label: '100% Private'  },
          { icon: Zap,    label: 'Under 1 second' },
          { icon: WifiOff, label: 'No internet'   },
        ].map(({ icon: Icon, label }) => (
          <span key={label} className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/[0.04] border border-white/[0.08] text-sm text-muted-text">
            <Icon size={13} className="text-accent-purple" />
            {label}
          </span>
        ))}
      </div>

      {/* Pill window mockup */}
      <div className="mt-16 animate-fade-up" style={{ animationDelay: '400ms', opacity: 0 }}>
        <div className="relative max-w-3xl mx-auto">
          {/* Static background glow (always present, subtle) */}
          <div className="absolute -inset-4 bg-gradient-to-r from-[#6E56CF]/20 via-[#3B82F6]/10 to-[#6E56CF]/20 rounded-3xl blur-2xl opacity-40 transition-opacity duration-500" />

          {/* Glow border wrapper — animates on hover */}
          <div className="hero-window-wrapper animate-float">
            {/* Window */}
            <div className="hero-window-inner bg-[#161616] border border-[rgba(255,255,255,0.08)] shadow-2xl">
              <div className="flex items-center gap-2 px-4 py-3 border-b border-white/[0.06] bg-card-elevated">
                <div className="flex gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-[#FF5F57]" />
                  <div className="w-3 h-3 rounded-full bg-[#FFBD2E]" />
                  <div className="w-3 h-3 rounded-full bg-[#28CA41]" />
                </div>
                <span className="flex-1 text-center text-xs text-tertiary-text">Blurt — Recording</span>
              </div>

              {/* Pill window content */}
              <div className="px-12 py-10 flex items-center justify-center bg-[#0A0A0A]">
                <div className="flex items-center gap-3 px-8 py-4 rounded-full bg-[#1A1A1A] border border-white/10 shadow-xl">
                  <div className="flex items-end gap-[3px] h-10">
                    {waveHeights.map((h, i) => (
                      <div
                        key={i}
                        className="w-[2.5px] rounded-full"
                        style={{
                          height: `${h}%`,
                          background: 'linear-gradient(to top, #6E56CF, #8B5CF6)',
                          animation: `wave 1.4s ease-in-out infinite`,
                          animationDelay: waveDelays[i] ?? '0ms',
                          transformOrigin: 'bottom',
                        }}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </div>{/* end hero-window-inner */}
          </div>{/* end hero-window-wrapper */}

          {/* Floating label */}
          <div className="absolute -bottom-4 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-primary/20 border border-primary/30 text-xs text-accent-purple-light whitespace-nowrap">
            Floating pill · bottom-centre of your screen
          </div>
        </div>
      </div>
    </section>
  )
}
