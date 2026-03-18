import { HeroSection } from "@/components/hero-section"
import { ProductDemoSection } from "@/components/product-demo-section"
import { WidgetsSection } from "@/components/widgets-section"
import { PricingSection } from "@/components/pricing-section"
import { Footer } from "@/components/footer"

export default function Home() {
  return (
    <main className="relative min-h-screen">
      <HeroSection />
      <ProductDemoSection />
      <WidgetsSection />
      <PricingSection />
      <Footer />
    </main>
  )
}
