const imagemin = require("imagemin")
const imageminPngquant = require("imagemin-pngquant")
const imageminMozjpeg = require("imagemin-mozjpeg")
const fs = require("fs")
const path = require("path")

/**
 * Asset Optimization Script for Betwizz Flutter Web
 * Optimizes images, compresses files, and prepares assets for deployment
 */

const BUILD_DIR = "build/web"
const ASSETS_DIR = path.join(BUILD_DIR, "assets")

async function optimizeImages() {
  console.log("🖼️  Optimizing images...")

  try {
    // Optimize PNG images
    await imagemin([`${ASSETS_DIR}/**/*.png`], {
      destination: ASSETS_DIR,
      plugins: [
        imageminPngquant({
          quality: [0.6, 0.8],
          strip: true,
        }),
      ],
    })

    // Optimize JPEG images
    await imagemin([`${ASSETS_DIR}/**/*.{jpg,jpeg}`], {
      destination: ASSETS_DIR,
      plugins: [
        imageminMozjpeg({
          quality: 85,
          progressive: true,
        }),
      ],
    })

    console.log("✅ Image optimization completed")
  } catch (error) {
    console.error("❌ Image optimization failed:", error)
  }
}

function generateAssetManifest() {
  console.log("📋 Generating asset manifest...")

  const manifest = {
    version: require("../package.json").version,
    buildTime: new Date().toISOString(),
    assets: [],
  }

  function scanDirectory(dir, baseDir = "") {
    const items = fs.readdirSync(dir)

    items.forEach((item) => {
      const fullPath = path.join(dir, item)
      const relativePath = path.join(baseDir, item)
      const stats = fs.statSync(fullPath)

      if (stats.isDirectory()) {
        scanDirectory(fullPath, relativePath)
      } else {
        manifest.assets.push({
          path: relativePath.replace(/\\/g, "/"),
          size: stats.size,
          modified: stats.mtime.toISOString(),
        })
      }
    })
  }

  if (fs.existsSync(ASSETS_DIR)) {
    scanDirectory(ASSETS_DIR)
  }

  fs.writeFileSync(path.join(BUILD_DIR, "asset-manifest.json"), JSON.stringify(manifest, null, 2))

  console.log(`✅ Asset manifest generated with ${manifest.assets.length} files`)
}

function optimizeServiceWorker() {
  console.log("⚙️  Optimizing service worker...")

  const swPath = path.join(BUILD_DIR, "flutter_service_worker.js")

  if (fs.existsSync(swPath)) {
    let swContent = fs.readFileSync(swPath, "utf8")

    // Add custom caching strategies
    const customCaching = `
// Custom caching for Betwizz assets
const BETWIZZ_CACHE = 'betwizz-v1';
const STATIC_ASSETS = [
  '/assets/images/betwizz_logo.png',
  '/assets/images/betwizz_logo_white.png',
  '/assets/fonts/Roboto-Regular.ttf'
];

// Cache static assets on install
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(BETWIZZ_CACHE).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
});

// Serve from cache with network fallback
self.addEventListener('fetch', (event) => {
  if (event.request.destination === 'image') {
    event.respondWith(
      caches.match(event.request).then((response) => {
        return response || fetch(event.request);
      })
    );
  }
});
`

    swContent += customCaching
    fs.writeFileSync(swPath, swContent)
    console.log("✅ Service worker optimized")
  } else {
    console.log("⚠️  Service worker not found, skipping optimization")
  }
}

function generateBuildReport() {
  console.log("📊 Generating build report...")

  const report = {
    buildTime: new Date().toISOString(),
    version: require("../package.json").version,
    files: {},
    totalSize: 0,
  }

  function calculateSize(dir, prefix = "") {
    const items = fs.readdirSync(dir)

    items.forEach((item) => {
      const fullPath = path.join(dir, item)
      const relativePath = prefix ? `${prefix}/${item}` : item
      const stats = fs.statSync(fullPath)

      if (stats.isDirectory()) {
        calculateSize(fullPath, relativePath)
      } else {
        report.files[relativePath] = {
          size: stats.size,
          sizeFormatted: formatBytes(stats.size),
        }
        report.totalSize += stats.size
      }
    })
  }

  if (fs.existsSync(BUILD_DIR)) {
    calculateSize(BUILD_DIR)
  }

  report.totalSizeFormatted = formatBytes(report.totalSize)
  report.fileCount = Object.keys(report.files).length

  fs.writeFileSync(path.join(BUILD_DIR, "build-report.json"), JSON.stringify(report, null, 2))

  console.log(`✅ Build report generated:`)
  console.log(`   📁 Total files: ${report.fileCount}`)
  console.log(`   📦 Total size: ${report.totalSizeFormatted}`)

  // Log largest files
  const sortedFiles = Object.entries(report.files)
    .sort(([, a], [, b]) => b.size - a.size)
    .slice(0, 5)

  console.log("   🔝 Largest files:")
  sortedFiles.forEach(([file, info]) => {
    console.log(`      ${file}: ${info.sizeFormatted}`)
  })
}

function formatBytes(bytes) {
  if (bytes === 0) return "0 Bytes"
  const k = 1024
  const sizes = ["Bytes", "KB", "MB", "GB"]
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
}

async function main() {
  console.log("🚀 Starting asset optimization for Betwizz...")

  if (!fs.existsSync(BUILD_DIR)) {
    console.error("❌ Build directory not found. Run flutter build web first.")
    process.exit(1)
  }

  try {
    await optimizeImages()
    generateAssetManifest()
    optimizeServiceWorker()
    generateBuildReport()

    console.log("🎉 Asset optimization completed successfully!")
  } catch (error) {
    console.error("❌ Asset optimization failed:", error)
    process.exit(1)
  }
}

if (require.main === module) {
  main()
}

module.exports = { optimizeImages, generateAssetManifest, optimizeServiceWorker, generateBuildReport }
