const { SitemapStream, streamToPromise } = require("sitemap")
const { createWriteStream } = require("fs")
const path = require("path")

/**
 * Sitemap Generation Script for Betwizz Flutter Web
 * Generates XML sitemap for better SEO
 */

const DOMAIN = "https://betwizz.vercel.app"
const BUILD_DIR = "build/web"

const routes = [
  {
    url: "/",
    changefreq: "daily",
    priority: 1.0,
    lastmod: new Date().toISOString(),
  },
  {
    url: "/channels",
    changefreq: "hourly",
    priority: 0.9,
    lastmod: new Date().toISOString(),
  },
  {
    url: "/scanner",
    changefreq: "weekly",
    priority: 0.8,
    lastmod: new Date().toISOString(),
  },
  {
    url: "/ai-chat",
    changefreq: "daily",
    priority: 0.8,
    lastmod: new Date().toISOString(),
  },
  {
    url: "/profile",
    changefreq: "weekly",
    priority: 0.7,
    lastmod: new Date().toISOString(),
  },
]

async function generateSitemap() {
  console.log("🗺️  Generating sitemap...")

  try {
    const sitemap = new SitemapStream({ hostname: DOMAIN })
    const writeStream = createWriteStream(path.join(BUILD_DIR, "sitemap.xml"))

    sitemap.pipe(writeStream)

    routes.forEach((route) => {
      sitemap.write(route)
    })

    sitemap.end()

    await streamToPromise(sitemap)

    console.log("✅ Sitemap generated successfully")
    console.log(`   📍 ${routes.length} routes included`)
    console.log(`   🌐 Domain: ${DOMAIN}`)
  } catch (error) {
    console.error("❌ Sitemap generation failed:", error)
  }
}

if (require.main === module) {
  generateSitemap()
}

module.exports = { generateSitemap }
