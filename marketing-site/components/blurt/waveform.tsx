'use client'

import { motion } from 'framer-motion'

interface WaveformProps {
  barCount?: number
  className?: string
}

// Gaussian bell curve so edge bars are shorter than centre bars.
function bellHeight(i: number, total: number): number {
  const centre = (total - 1) / 2
  const sigma  = total / 3.5
  const bell   = Math.exp(-Math.pow(i - centre, 2) / (2 * sigma * sigma))
  return Math.max(0.25, bell)
}

export function Waveform({ barCount = 24, className }: WaveformProps) {
  const bars = Array.from({ length: barCount }, (_, i) => bellHeight(i, barCount))

  return (
    <div className={`flex items-end gap-[3px] h-10 ${className ?? ''}`}>
      {bars.map((maxRatio, i) => {
        const delay = (i / barCount) * 1.2
        const minH  = 3
        const maxH  = 40 * maxRatio

        return (
          <motion.div
            key={i}
            className="w-[2.5px] rounded-full flex-shrink-0"
            style={{
              background: 'linear-gradient(to top, #6E56CF, #8B5CF6)',
              height: minH,
            }}
            animate={{ height: [minH, maxH, minH] }}
            transition={{
              duration: 1.3,
              repeat: Infinity,
              delay,
              ease: 'easeInOut',
            }}
          />
        )
      })}
    </div>
  )
}
