import { Button, buttonVariants } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import Image from 'next/image'
import Link from 'next/link'

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-start p-24">
      <Link className={cn(buttonVariants({ variant: 'outline' }))} href={'/image-classification'}>Upload Image</Link>
    </main>
  )
}
