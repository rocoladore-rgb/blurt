import { Navigation }    from '@/components/blurt/navigation'
import { Hero }           from '@/components/blurt/hero'
import { SocialProof }    from '@/components/blurt/social-proof'
import { HowItWorks }     from '@/components/blurt/how-it-works'
import { Features }       from '@/components/blurt/features'
import { Testimonials }   from '@/components/blurt/testimonials'
import { Pricing }        from '@/components/blurt/pricing'
import { DownloadCTA }    from '@/components/blurt/download-cta'
import { Footer }         from '@/components/blurt/footer'

export default function BlurtPage() {
  return (
    <main className="min-h-screen bg-background overflow-x-hidden">
      <Navigation />
      <Hero />
      <SocialProof />
      <HowItWorks />
      <Features />
      <Testimonials />
      <Pricing />
      <DownloadCTA />
      <Footer />
    </main>
  )
}
