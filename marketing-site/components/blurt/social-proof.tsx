'use client'

const stats = [
  { value: '< 1s',   label: 'Transcription time'     },
  { value: '100%',   label: 'On-device processing'   },
  { value: '0 MB/s', label: 'Data sent to servers'   },
  { value: 'Free',   label: 'Forever, no limits'     },
]

export function SocialProof() {
  return (
    <section className="py-16 border-y border-white/[0.06] bg-surface">
      <div className="max-w-5xl mx-auto px-6">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 md:gap-0 md:divide-x divide-white/[0.06]">
          {stats.map(({ value, label }) => (
            <div key={label} className="flex flex-col items-center text-center px-6">
              <span className="text-3xl md:text-4xl font-bold text-white tracking-tight">{value}</span>
              <span className="mt-1.5 text-sm text-muted-text">{label}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
