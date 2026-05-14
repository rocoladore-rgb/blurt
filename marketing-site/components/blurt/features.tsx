'use client'

import { Lock, Cpu, Mic, Type, Sliders, Keyboard } from 'lucide-react'

const features = [
  {
    icon: Lock,
    title: 'Completely Private',
    description: 'Your voice never leaves your Mac. No cloud, no servers, no data collection — ever. Blurt uses on-device AI for full privacy.',
  },
  {
    icon: Cpu,
    title: 'Apple Silicon Optimised',
    description: 'Built on whisper.cpp with Metal GPU acceleration. Blurt is tuned for M1, M2, and M3 chips — transcription completes in under a second.',
  },
  {
    icon: Mic,
    title: 'Works in Any App',
    description: "Uses CGEvent keyboard simulation to type directly into whatever app you're focused on. Slack, Notion, email, terminal — all supported.",
  },
  {
    icon: Type,
    title: 'Smart Formatting',
    description: 'Three formality presets — Formal, Neutral, and Casual. Punctuation, capitalisation, and filler word removal happen automatically.',
  },
  {
    icon: Sliders,
    title: 'Fully Customisable',
    description: 'Edit your filler word list, add custom substitutions (gonna → going to), toggle punctuation, and choose the Whisper model size.',
  },
  {
    icon: Keyboard,
    title: 'Configurable Hotkey',
    description: "Blurt defaults to the Fn key — always out of the way. Reassign to any key combination that suits your workflow.",
  },
]

export function Features() {
  return (
    <section id="features" className="py-28 px-6 bg-surface border-y border-white/[0.06]">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-16">
          <p className="text-sm font-medium text-primary uppercase tracking-widest mb-3">Features</p>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight text-white">
            Everything you need.<br />Nothing you don&apos;t.
          </h2>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
          {features.map(({ icon: Icon, title, description }) => (
            <div key={title} className="p-6 rounded-2xl border-subtle bg-card hover:bg-card-elevated transition-colors group">
              <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center mb-4 group-hover:bg-primary/20 transition-colors">
                <Icon size={18} className="text-primary" />
              </div>
              <h3 className="text-[17px] font-semibold text-white mb-2">{title}</h3>
              <p className="text-sm text-muted-text leading-relaxed">{description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
