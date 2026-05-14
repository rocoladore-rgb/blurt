'use client'

import { motion } from 'framer-motion'

interface FnKeyProps {
  size?: 'default' | 'large'
}

export function FnKey({ size = 'default' }: FnKeyProps) {
  const isLarge = size === 'large'

  return (
    <div className="flex items-center justify-center gap-3">
      {/* Key cap */}
      <motion.div
        whileHover={{ scale: 1.05 }}
        className={`relative flex items-center justify-center rounded-xl
          ${isLarge ? 'w-20 h-20' : 'w-14 h-14'}
          bg-gradient-to-b from-[#2A2A2A] to-[#1A1A1A]
          border border-white/10 shadow-[0_4px_0_rgba(0,0,0,0.5),0_0_20px_rgba(110,86,207,0.15)]
          select-none cursor-default`}
      >
        <span
          className={`font-semibold text-[#F5F5F7] tracking-tight
            ${isLarge ? 'text-[22px]' : 'text-[16px]'}`}
          style={{ fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif' }}
        >
          fn
        </span>
        {/* Subtle inner glow */}
        <div className="absolute inset-0 rounded-xl bg-gradient-to-t from-transparent to-white/[0.03]" />
      </motion.div>

      {/* Hold indicator */}
      {isLarge && (
        <div className="flex flex-col gap-1">
          <div className="flex items-center gap-1.5">
            <div className="w-1.5 h-1.5 rounded-full bg-[#6E56CF] animate-pulse" />
            <span className="text-xs text-[#A1A1A6]">Hold to record</span>
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-1.5 h-1.5 rounded-full bg-white/20" />
            <span className="text-xs text-[#6E6E73]">Release to transcribe</span>
          </div>
        </div>
      )}
    </div>
  )
}
