import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Blurt — Hold. Speak. Done.',
  description: 'Local voice dictation for Mac. Hold a key, speak, release. Blurt transcribes your voice and types it anywhere — fast, private, and completely on-device.',
  keywords: ['voice dictation', 'mac dictation', 'whisper', 'voice to text', 'offline transcription'],
  openGraph: {
    title: 'Blurt — Hold. Speak. Done.',
    description: 'Local voice dictation for Mac. 100% on-device, no internet required.',
    type: 'website',
    siteName: 'Blurt',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Blurt — Hold. Speak. Done.',
    description: 'Local voice dictation for Mac. 100% on-device, no internet required.',
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="scroll-smooth">
      <body className="bg-background text-foreground antialiased">{children}</body>
    </html>
  )
}
