const fs = require("fs-extra")
const path = require("path")

class SEOGenerator {
  constructor(buildDir, config = {}) {
    this.buildDir = buildDir || path.join(process.cwd(), "build", "web")
    this.config = {
      baseUrl: config.baseUrl || "https://betwizz.vercel.app",
      siteName: config.siteName || "Betwizz",
      description:
        config.description || "Smart betting companion app with AI chat, receipt scanning, and channel management",
      keywords: config.keywords || ["betting", "sports", "AI", "South Africa", "flutter", "web app"],
      author: config.author || "Betwizz Team",
      language: config.language || "en",
      ...config,
    }
  }

  async generateSitemap() {
    console.log("🗺️ Generating sitemap.xml...")

    const pages = [
      {
        url: "/",
        priority: "1.0",
        changefreq: "daily",
        lastmod: new Date().toISOString().split("T")[0],
      },
      {
        url: "/channels",
        priority: "0.9",
        changefreq: "hourly",
        lastmod: new Date().toISOString().split("T")[0],
      },
      {
        url: "/ai-chat",
        priority: "0.8",
        changefreq: "daily",
        lastmod: new Date().toISOString().split("T")[0],
      },
      {
        url: "/scanner",
        priority: "0.7",
        changefreq: "weekly",
        lastmod: new Date().toISOString().split("T")[0],
      },
      {
        url: "/profile",
        priority: "0.6",
        changefreq: "monthly",
        lastmod: new Date().toISOString().split("T")[0],
      },
    ]

    const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
${pages
  .map(
    (page) => `  <url>
    <loc>${this.config.baseUrl}${page.url}</loc>
    <lastmod>${page.lastmod}</lastmod>
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
  </url>`,
  )
  .join("\n")}
</urlset>`

    const sitemapPath = path.join(this.buildDir, "sitemap.xml")
    await fs.writeFile(sitemapPath, sitemap)
    console.log(`✅ Sitemap generated: ${sitemapPath}`)

    return pages.length
  }

  async generateRobotsTxt() {
    console.log("🤖 Generating robots.txt...")

    const robots = `User-agent: *
Allow: /

# Sitemaps
Sitemap: ${this.config.baseUrl}/sitemap.xml

# Crawl-delay
Crawl-delay: 1

# Disallow admin areas (if any)
Disallow: /admin/
Disallow: /api/
Disallow: /*.json$

# Allow specific bots
User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

# Social media bots
User-agent: facebookexternalhit
Allow: /

User-agent: Twitterbot
Allow: /`

    const robotsPath = path.join(this.buildDir, "robots.txt")
    await fs.writeFile(robotsPath, robots)
    console.log(`✅ Robots.txt generated: ${robotsPath}`)
  }

  async generateStructuredData() {
    console.log("📋 Generating structured data...")

    const structuredData = {
      "@context": "https://schema.org",
      "@type": "WebApplication",
      name: this.config.siteName,
      description: this.config.description,
      url: this.config.baseUrl,
      applicationCategory: "SportsApplication",
      operatingSystem: "Web Browser",
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "ZAR",
      },
      author: {
        "@type": "Organization",
        name: this.config.author,
      },
      inLanguage: this.config.language,
      keywords: this.config.keywords.join(", "),
      screenshot: `${this.config.baseUrl}/assets/images/app-screenshot.png`,
      softwareVersion: "1.0.0",
      datePublished: new Date().toISOString(),
      dateModified: new Date().toISOString(),
    }

    const structuredDataPath = path.join(this.buildDir, "structured-data.json")
    await fs.writeJson(structuredDataPath, structuredData, { spaces: 2 })
    console.log(`✅ Structured data generated: ${structuredDataPath}`)

    return structuredData
  }

  async updateIndexHtml() {
    console.log("📝 Updating index.html with SEO meta tags...")

    const indexPath = path.join(this.buildDir, "index.html")

    if (!(await fs.pathExists(indexPath))) {
      console.warn("⚠️ index.html not found, skipping meta tag injection")
      return
    }

    let indexContent = await fs.readFile(indexPath, "utf8")

    // SEO meta tags to inject
    const metaTags = `
  <!-- SEO Meta Tags -->
  <meta name="description" content="${this.config.description}">
  <meta name="keywords" content="${this.config.keywords.join(", ")}">
  <meta name="author" content="${this.config.author}">
  <meta name="robots" content="index, follow">
  <meta name="language" content="${this.config.language}">
  
  <!-- Open Graph Meta Tags -->
  <meta property="og:title" content="${this.config.siteName}">
  <meta property="og:description" content="${this.config.description}">
  <meta property="og:type" content="website">
  <meta property="og:url" content="${this.config.baseUrl}">
  <meta property="og:image" content="${this.config.baseUrl}/assets/images/og-image.png">
  <meta property="og:site_name" content="${this.config.siteName}">
  <meta property="og:locale" content="en_ZA">
  
  <!-- Twitter Card Meta Tags -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${this.config.siteName}">
  <meta name="twitter:description" content="${this.config.description}">
  <meta name="twitter:image" content="${this.config.baseUrl}/assets/images/twitter-card.png">
  
  <!-- Mobile Meta Tags -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="default">
  <meta name="apple-mobile-web-app-title" content="${this.config.siteName}">
  
  <!-- Favicon Links -->
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="192x192" href="/icons/icon-192x192.png">
  <link rel="icon" type="image/png" sizes="512x512" href="/icons/icon-512x512.png">
  
  <!-- Canonical URL -->
  <link rel="canonical" href="${this.config.baseUrl}">
  
  <!-- Structured Data -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "${this.config.siteName}",
    "description": "${this.config.description}",
    "url": "${this.config.baseUrl}",
    "applicationCategory": "SportsApplication",
    "operatingSystem": "Web Browser"
  }
  </script>`

    // Inject meta tags before closing </head>
    if (indexContent.includes("</head>")) {
      indexContent = indexContent.replace("</head>", `${metaTags}\n</head>`)
    } else {
      console.warn("⚠️ Could not find </head> tag in index.html")
    }

    await fs.writeFile(indexPath, indexContent)
    console.log("✅ SEO meta tags injected into index.html")
  }

  async generateSecurityTxt() {
    console.log("🔒 Generating security.txt...")

    const securityTxt = `Contact: mailto:security@betwizz.com
Expires: ${new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString()}
Preferred-Languages: en
Canonical: ${this.config.baseUrl}/.well-known/security.txt
Policy: ${this.config.baseUrl}/security-policy`

    const wellKnownDir = path.join(this.buildDir, ".well-known")
    await fs.ensureDir(wellKnownDir)

    const securityTxtPath = path.join(wellKnownDir, "security.txt")
    await fs.writeFile(securityTxtPath, securityTxt)
    console.log(`✅ Security.txt generated: ${securityTxtPath}`)
  }

  async generateManifestJson() {
    console.log("📱 Updating manifest.json...")

    const manifestPath = path.join(this.buildDir, "manifest.json")

    const manifest = {
      name: this.config.siteName,
      short_name: "Betwizz",
      description: this.config.description,
      start_url: "/",
      display: "standalone",
      background_color: "#1E88E5",
      theme_color: "#1E88E5",
      orientation: "portrait-primary",
      categories: ["sports", "entertainment", "utilities"],
      lang: this.config.language,
      icons: [
        {
          src: "/icons/icon-192x192.png",
          sizes: "192x192",
          type: "image/png",
          purpose: "any maskable",
        },
        {
          src: "/icons/icon-512x512.png",
          sizes: "512x512",
          type: "image/png",
          purpose: "any maskable",
        },
      ],
      screenshots: [
        {
          src: "/assets/images/screenshot-mobile.png",
          sizes: "390x844",
          type: "image/png",
          form_factor: "narrow",
        },
        {
          src: "/assets/images/screenshot-desktop.png",
          sizes: "1920x1080",
          type: "image/png",
          form_factor: "wide",
        },
      ],
    }

    await fs.writeJson(manifestPath, manifest, { spaces: 2 })
    console.log(`✅ Manifest.json updated: ${manifestPath}`)
  }

  async generateSEOFiles() {
    console.log("🚀 Starting SEO file generation...")

    const results = {
      sitemap: await this.generateSitemap(),
      structuredData: await this.generateStructuredData(),
    }

    await this.generateRobotsTxt()
    await this.updateIndexHtml()
    await this.generateSecurityTxt()
    await this.generateManifestJson()

    console.log("✅ SEO file generation completed!")
    console.log(`📊 Generated sitemap with ${results.sitemap} pages`)

    return results
  }
}

// Execute if run directly
if (require.main === module) {
  const generator = new SEOGenerator()
  generator.generateSEOFiles().catch((error) => {
    console.error("💥 SEO generation failed:", error)
    process.exit(1)
  })
}

module.exports = SEOGenerator
