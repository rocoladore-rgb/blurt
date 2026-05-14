'use client'

const testimonials = [
  {
    quote: "Blurt has completely changed how I write. I dictate Slack messages, emails, even code comments. It's faster than typing and cleaner than I expected.",
    name: 'Marcus T.',
    role: 'Software Engineer',
    initials: 'MT',
  },
  {
    quote: "I was sceptical about on-device transcription but the accuracy is genuinely impressive. And knowing nothing leaves my machine is huge for client work.",
    name: 'Sarah K.',
    role: 'Product Designer',
    initials: 'SK',
  },
  {
    quote: "The filler word removal is underrated. My transcriptions come out cleaner than when I type. The formal mode is perfect for drafting emails.",
    name: 'James R.',
    role: 'Founder',
    initials: 'JR',
  },
  {
    quote: "Hold. Speak. Done. That tagline is not marketing — it's literally what happens. Under a second from release to text appearing.",
    name: 'Nina L.',
    role: 'Writer',
    initials: 'NL',
  },
  {
    quote: "I work in sensitive environments where cloud transcription is a non-starter. Blurt solves that completely. Local, fast, free.",
    name: 'David C.',
    role: 'Security Consultant',
    initials: 'DC',
  },
  {
    quote: "The pill animation is such a nice touch. Feels genuinely native — not like a port or an Electron app. Proper macOS.",
    name: 'Lena M.',
    role: 'iOS Developer',
    initials: 'LM',
  },
]

export function Testimonials() {
  return (
    <section id="testimonials" className="py-28 px-6">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-16">
          <p className="text-sm font-medium text-primary uppercase tracking-widest mb-3">What people say</p>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight text-white">
            Loved by people<br />who live in their keyboard.
          </h2>
        </div>

        <div className="columns-1 md:columns-2 lg:columns-3 gap-5 space-y-5">
          {testimonials.map(({ quote, name, role, initials }) => (
            <div key={name} className="break-inside-avoid p-6 rounded-2xl border-subtle bg-card">
              <p className="text-[15px] text-foreground leading-relaxed mb-5">&ldquo;{quote}&rdquo;</p>
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-full bg-primary/20 flex items-center justify-center text-xs font-bold text-primary shrink-0">
                  {initials}
                </div>
                <div>
                  <p className="text-sm font-medium text-white">{name}</p>
                  <p className="text-xs text-muted-text">{role}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
