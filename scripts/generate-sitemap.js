const fs = require("fs")
const path = require("path")

const buildDir = path.join(__dirname, "..", "build", "web")
const baseUrl = "https://betwizz.vercel.app" // Update with your actual domain

const pages = [
  { url: "/", priority: "1.0", changefreq: "daily" },
  { url: "/channels", priority: "0.9", changefreq: "hourly" },
  { url: "/ai-chat", priority: "0.8", changefreq: "daily" },
  { url: "/scanner", priority: "0.7", changefreq: "weekly" },
  { url: "/profile", priority: "0.6", changefreq: "monthly" },
]

function generateSitemap() {
  console.log("🗺️ Generating sitemap...")

  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${pages
  .map(
    (page) => `  <url>
    <loc>${baseUrl}${page.url}</loc>
    <lastmod>${new Date().toISOString().split("T")[0]}</lastmod>
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
  </url>`,
  )
  .join("\n")}
</urlset>`

  fs.writeFileSync(path.join(buildDir, "sitemap.xml"), sitemap)
  console.log("✅ Sitemap generated")
}

function generateRobotsTxt() {
  console.log("🤖 Generating robots.txt...")

  const robots = `User-agent: *
Allow: /

Sitemap: ${baseUrl}/sitemap.xml`

  fs.writeFileSync(path.join(buildDir, "robots.txt"), robots)
  console.log("✅ Robots.txt generated")
}

function generateSEOFiles() {
  console.log("🔍 Generating SEO files...")

  generateSitemap()
  generateRobotsTxt()

  console.log("✅ SEO files generation complete!")
}

generateSEOFiles()
