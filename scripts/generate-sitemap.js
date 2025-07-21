const fs = require("fs-extra")
const path = require("path")

async function generateSitemap() {
  console.log("🗺️  Generating sitemap...")

  const buildDir = path.join(process.cwd(), "build", "web")
  const sitemapPath = path.join(buildDir, "sitemap.xml")

  const baseUrl = "https://betwizz.vercel.app"
  const currentDate = new Date().toISOString().split("T")[0]

  const pages = [
    { url: "/", priority: "1.0", changefreq: "daily" },
    { url: "/channels", priority: "0.9", changefreq: "hourly" },
    { url: "/ai-chat", priority: "0.8", changefreq: "daily" },
    { url: "/scanner", priority: "0.7", changefreq: "weekly" },
    { url: "/profile", priority: "0.6", changefreq: "monthly" },
  ]

  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${pages
  .map(
    (page) => `  <url>
    <loc>${baseUrl}${page.url}</loc>
    <lastmod>${currentDate}</lastmod>
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
  </url>`,
  )
  .join("\n")}
</urlset>`

  await fs.writeFile(sitemapPath, sitemap)
  console.log("✅ Sitemap generated successfully")

  // Generate robots.txt
  const robotsPath = path.join(buildDir, "robots.txt")
  const robots = `User-agent: *
Allow: /

Sitemap: ${baseUrl}/sitemap.xml`

  await fs.writeFile(robotsPath, robots)
  console.log("✅ Robots.txt generated successfully")
}

if (require.main === module) {
  generateSitemap().catch((error) => {
    console.error("❌ Sitemap generation failed:", error)
    process.exit(1)
  })
}

module.exports = { generateSitemap }
