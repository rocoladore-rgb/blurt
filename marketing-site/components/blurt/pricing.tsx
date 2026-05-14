'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Check } from 'lucide-react'
import { useInView } from './use-in-view'

type Plan = {
  id: string
  name: string
  monthly: number
  annual: number
  unit: string
  tagline: string
  features: string[]
  cta: string
  href: string
  popular: boolean
}

const plans: Plan[] = [
  {
    id: 'personal',
    name: 'Personal',
    monthly: 8,
    annual: 5,
    unit: '/mo',
    tagline: 'Everything you need to dictate faster.',
    features: [
      'Unlimited dictation',
      'All 3 formality levels',
      'Custom vocabulary',
      'Filler word removal',
      'Dictation history',
      '1 device',
    ],
    cta: 'Get Started',
    href: '#download',
    popular: false,
  },
  {
    id: 'pro',
    name: 'Pro',
    monthly: 12,
    annual: 8,
    unit: '/mo',
    tagline: 'Advanced features for power users.',
    features: [
      'Everything in Personal',
      'Per-app profiles',
      'Voice commands',
      'Priority model updates',
      '3 devices',
    ],
    cta: 'Get Started',
    href: '#download',
    popular: true,
  },
  {
    id: 'team',
    name: 'Team',
    monthly: 20,
    annual: 15,
    unit: '/seat/mo',
    tagline: 'Blurt for your whole organisation.',
    features: [
      'Everything in Pro',
      'Shared vocabulary across team',
      'Centralised billing',
      'Admin dashboard (coming soon)',
      'Priority support',
      'Unlimited devices',
    ],
    cta: 'Contact Us',
    href: '#download',
    popular: false,
  },
]

export function Pricing() {
  const [isAnnual, setIsAnnual] = useState(true)
  const { ref: headerRef, isInView: headerInView } = useInView()
  const { ref: gridRef,   isInView: gridInView   } = useInView()

  return (
    <section id="pricing" className="py-28 px-6 bg-black border-t border-white/[0.06]">
      <div className="max-w-6xl mx-auto">

        {/* Header */}
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 30 }}
          animate={headerInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-14"
        >
          <p className="text-sm font-medium text-primary uppercase tracking-widest mb-3">Pricing</p>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight text-white mb-4">
            Simple, honest pricing.
          </h2>
          <p className="text-lg text-muted-text max-w-md mx-auto mb-10">
            Start free. Upgrade when you&apos;re ready.
          </p>

          {/* Annual / monthly toggle */}
          <div className="flex items-center justify-center">
            <div className="pricing-toggle-track">
              <button
                onClick={() => setIsAnnual(true)}
                className={`pricing-toggle-option${isAnnual ? ' pricing-toggle-active' : ''}`}
              >
                Annual
                <span className="pricing-save-tag">Save 38%</span>
              </button>
              <button
                onClick={() => setIsAnnual(false)}
                className={`pricing-toggle-option${!isAnnual ? ' pricing-toggle-active' : ''}`}
              >
                Monthly
              </button>
            </div>
          </div>
        </motion.div>

        {/* Cards — single useInView on the grid drives staggered entrance */}
        <div
          ref={gridRef}
          className="grid md:grid-cols-3 gap-6 md:gap-8 items-center"
        >
          {plans.map((plan, i) => (
            <PlanCard
              key={plan.id}
              plan={plan}
              isAnnual={isAnnual}
              index={i}
              isVisible={gridInView}
            />
          ))}
        </div>

        {/* Footnote */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={gridInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 0.55 }}
          className="text-center mt-12 text-sm text-tertiary-text"
        >
          No credit card required to download. Payments coming soon.
        </motion.p>

      </div>
    </section>
  )
}

// ─── Plan card ────────────────────────────────────────────────

function PlanCard({
  plan,
  isAnnual,
  index,
  isVisible,
}: {
  plan: Plan
  isAnnual: boolean
  index: number
  isVisible: boolean
}) {
  const price = isAnnual ? plan.annual : plan.monthly

  const billingNote =
    plan.id === 'team'
      ? `Minimum 3 seats · ${isAnnual ? 'billed annually' : 'billed monthly'}`
      : isAnnual
      ? 'per month, billed annually'
      : 'per month, billed monthly'

  const cardBody = (
    <div className="p-8">
      {/* Name + tagline */}
      <p className="text-sm text-muted-text mb-1">{plan.tagline}</p>
      <h3 className="text-2xl font-bold text-white mb-6">{plan.name}</h3>

      {/* Price */}
      <div className="flex items-end gap-1 mb-1">
        <span className="text-[44px] font-black leading-none text-white tabular-nums">
          <AnimatePresence mode="wait">
            <motion.span
              key={`${plan.id}-${isAnnual ? 'a' : 'm'}`}
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              transition={{ duration: 0.18 }}
              className="inline-block"
            >
              ${price}
            </motion.span>
          </AnimatePresence>
        </span>
        <span className="text-sm text-muted-text mb-2.5">{plan.unit}</span>
      </div>
      <p className="text-xs text-tertiary-text mb-8">{billingNote}</p>

      {/* CTA */}
      <a
        href={plan.href}
        className={`block w-full text-center py-3 px-6 rounded-xl text-sm font-semibold transition-all duration-300 mb-8 ${
          plan.popular
            ? 'bg-primary hover:bg-primary-dark text-white shadow-lg shadow-primary/30 hover:shadow-primary/50 hover:-translate-y-0.5'
            : 'bg-white/[0.06] hover:bg-white/[0.1] text-foreground border border-white/[0.08] hover:border-white/[0.18]'
        }`}
      >
        {plan.cta}
      </a>

      {/* Feature list */}
      <ul className="space-y-3">
        {plan.features.map((feature) => (
          <li key={feature} className="flex items-start gap-3 text-sm text-muted-text">
            <Check
              size={15}
              className={`mt-0.5 shrink-0 ${plan.popular ? 'text-primary' : 'text-accent-purple'}`}
            />
            <span>{feature}</span>
          </li>
        ))}
      </ul>
    </div>
  )

  return (
    <motion.div
      initial={{ opacity: 0, y: 40 }}
      animate={isVisible ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5, ease: 'easeOut', delay: index * 0.12 }}
    >
      {plan.popular ? (
        <div className="pricing-popular-wrapper">
          {/* Badge sits between wrapper and inner so it's clipped out of inner but above the border */}
          <div className="pricing-popular-badge">MOST POPULAR</div>
          <div className="pricing-popular-inner">
            {cardBody}
          </div>
        </div>
      ) : (
        <div className="rounded-2xl bg-card border border-white/[0.06] overflow-hidden">
          {cardBody}
        </div>
      )}
    </motion.div>
  )
}
