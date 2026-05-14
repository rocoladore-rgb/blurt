'use client'

import { motion } from 'framer-motion'
import { useInView } from './use-in-view'
import { FnKey } from './fn-key'
import { Waveform } from './waveform'

const steps = [
  {
    number: '01',
    title: 'Press & Hold Fn',
    description: 'Activate Blurt from anywhere. No switching apps. No interruption.',
    visual: 'fnkey',
  },
  {
    number: '02',
    title: 'Speak Naturally',
    description: 'Talk the way you think. Blurt handles punctuation, formatting, and flow automatically.',
    visual: 'waveform',
  },
  {
    number: '03',
    title: 'Words Appear Instantly',
    description: 'Your words land exactly where your cursor is — in Slack, Notion, Gmail, code editors, anywhere.',
    visual: 'cursor',
  },
]

export function HowItWorks() {
  const { ref, isInView } = useInView()

  return (
    <section id="how-it-works" className="relative py-32 lg:py-40 bg-black">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <h2 className="text-4xl sm:text-5xl lg:text-[52px] font-semibold tracking-[-0.02em] text-[#F5F5F7] mb-6">
            Three steps. No thinking required.
          </h2>
          <p className="text-lg text-[#A1A1A6] max-w-xl mx-auto">
            Zero learning curve. Works in every app.
          </p>
        </motion.div>

        {/* Steps Grid */}
        <div className="grid md:grid-cols-3 gap-8">
          {steps.map((step, index) => (
            <StepCard key={step.number} step={step} index={index} />
          ))}
        </div>
      </div>
    </section>
  )
}

function StepCard({ step, index }: { step: typeof steps[0]; index: number }) {
  const { ref, isInView } = useInView()

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 30 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      className="glow-card-wrapper h-full"
    >
      <div className="glow-card-inner p-8">
        {/* Step Number — big, bright, glowing */}
        <span className="step-number">{step.number}</span>

        {/* Visual */}
        <div className="h-24 flex items-center justify-center mb-6">
          {step.visual === 'fnkey' && <FnKey size="large" />}
          {step.visual === 'waveform' && <Waveform barCount={16} className="scale-75" />}
          {step.visual === 'cursor' && <CursorVisual />}
        </div>

        {/* Content */}
        <h3 className="text-xl font-semibold text-[#F5F5F7] mb-3">{step.title}</h3>
        <p className="text-[#A1A1A6] text-sm leading-relaxed">{step.description}</p>
      </div>
    </motion.div>
  )
}

function CursorVisual() {
  return (
    <div className="flex items-center gap-2 bg-[#0A0A0A] rounded-lg px-4 py-2 border border-[rgba(255,255,255,0.08)]">
      <span className="text-[#F5F5F7] text-sm">Hello world</span>
      <motion.span
        className="w-0.5 h-4 bg-[#6E56CF]"
        animate={{ opacity: [1, 0] }}
        transition={{ duration: 0.6, repeat: Infinity }}
      />
    </div>
  )
}
