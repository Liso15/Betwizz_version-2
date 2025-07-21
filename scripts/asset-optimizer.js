const fs = require("fs-extra")
const path = require("path")
const sharp = require("sharp")
const imagemin = require("imagemin")
const imageminPngquant = require("imagemin-pngquant")
const imageminMozjpeg = require("imagemin-mozjpeg")
const imageminWebp = require("imagemin-webp")

class AssetOptimizer {
  constructor(buildDir) {
    this.buildDir = buildDir || path.join(process.cwd(), "build", "web")
    this.assetsDir = path.join(this.buildDir, "assets")
    this.optimizationReport = {
      images: { processed: 0, saved: 0 },
      fonts: { processed: 0, saved: 0 },
      total: { originalSize: 0, optimizedSize: 0 },
    }
  }

  async optimizeImages() {
    console.log("🖼️ Optimizing images...")

    if (!(await fs.pathExists(this.assetsDir))) {
      console.log("No assets directory found, skipping image optimization")
      return
    }

    // Find all image files
    const imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".svg"]
    const imageFiles = []

    const findImages = async (dir) => {
      const items = await fs.readdir(dir)

      for (const item of items) {
        const fullPath = path.join(dir, item)
        const stats = await fs.stat(fullPath)

        if (stats.isDirectory()) {
          await findImages(fullPath)
        } else if (imageExtensions.some((ext) => item.toLowerCase().endsWith(ext))) {
          imageFiles.push(fullPath)
        }
      }
    }

    await findImages(this.assetsDir)
    console.log(`Found ${imageFiles.length} images to optimize`)

    // Optimize each image
    for (const imagePath of imageFiles) {
      await this.optimizeImage(imagePath)
    }

    console.log(`✅ Optimized ${this.optimizationReport.images.processed} images`)
    console.log(`💾 Saved ${(this.optimizationReport.images.saved / 1024).toFixed(2)} KB`)
  }

  async optimizeImage(imagePath) {
    try {
      const originalStats = await fs.stat(imagePath)
      const originalSize = originalStats.size
      const ext = path.extname(imagePath).toLowerCase()

      let optimized = false

      if (ext === ".png") {
        // Optimize PNG
        const result = await imagemin([imagePath], {
          plugins: [imageminPngquant({ quality: [0.6, 0.8] })],
        })

        if (result.length > 0 && result[0].data.length < originalSize) {
          await fs.writeFile(imagePath, result[0].data)
          optimized = true
        }
      } else if (ext === ".jpg" || ext === ".jpeg") {
        // Optimize JPEG
        const result = await imagemin([imagePath], {
          plugins: [imageminMozjpeg({ quality: 85 })],
        })

        if (result.length > 0 && result[0].data.length < originalSize) {
          await fs.writeFile(imagePath, result[0].data)
          optimized = true
        }
      }

      if (optimized) {
        const newStats = await fs.stat(imagePath)
        const saved = originalSize - newStats.size

        this.optimizationReport.images.processed++
        this.optimizationReport.images.saved += saved
        this.optimizationReport.total.originalSize += originalSize
        this.optimizationReport.total.optimizedSize += newStats.size

        console.log(`  ✅ ${path.basename(imagePath)}: ${(saved / 1024).toFixed(2)} KB saved`)
      }

      // Generate WebP version for modern browsers
      if (ext === ".jpg" || ext === ".jpeg" || ext === ".png") {
        await this.generateWebP(imagePath)
      }
    } catch (error) {
      console.warn(`⚠️ Failed to optimize ${path.basename(imagePath)}: ${error.message}`)
    }
  }

  async generateWebP(imagePath) {
    try {
      const webpPath = imagePath.replace(/\.(jpg|jpeg|png)$/i, ".webp")

      await sharp(imagePath).webp({ quality: 80 }).toFile(webpPath)

      console.log(`  📸 Generated WebP: ${path.basename(webpPath)}`)
    } catch (error) {
      console.warn(`⚠️ Failed to generate WebP for ${path.basename(imagePath)}: ${error.message}`)
    }
  }

  async generateResponsiveImages() {
    console.log("📱 Generating responsive images...")

    const imageFiles = []
    const findImages = async (dir) => {
      if (!(await fs.pathExists(dir))) return

      const items = await fs.readdir(dir)
      for (const item of items) {
        const fullPath = path.join(dir, item)
        const stats = await fs.stat(fullPath)

        if (stats.isDirectory()) {
          await findImages(fullPath)
        } else if (/\.(jpg|jpeg|png)$/i.test(item)) {
          imageFiles.push(fullPath)
        }
      }
    }

    await findImages(this.assetsDir)

    const sizes = [320, 640, 960, 1280, 1920]

    for (const imagePath of imageFiles) {
      try {
        const image = sharp(imagePath)
        const metadata = await image.metadata()

        // Only generate responsive versions for large images
        if (metadata.width > 640) {
          for (const size of sizes) {
            if (size < metadata.width) {
              const ext = path.extname(imagePath)
              const baseName = path.basename(imagePath, ext)
              const dir = path.dirname(imagePath)
              const responsivePath = path.join(dir, `${baseName}-${size}w${ext}`)

              await image.resize(size, null, { withoutEnlargement: true }).toFile(responsivePath)
            }
          }
          console.log(`  📐 Generated responsive versions for ${path.basename(imagePath)}`)
        }
      } catch (error) {
        console.warn(`⚠️ Failed to generate responsive images for ${path.basename(imagePath)}: ${error.message}`)
      }
    }
  }

  async optimizeFonts() {
    console.log("🔤 Optimizing fonts...")

    // Find font files
    const fontFiles = []
    const findFonts = async (dir) => {
      if (!(await fs.pathExists(dir))) return

      const items = await fs.readdir(dir)
      for (const item of items) {
        const fullPath = path.join(dir, item)
        const stats = await fs.stat(fullPath)

        if (stats.isDirectory()) {
          await findFonts(fullPath)
        } else if (/\.(ttf|otf|woff|woff2)$/i.test(item)) {
          fontFiles.push(fullPath)
        }
      }
    }

    await findFonts(this.assetsDir)

    if (fontFiles.length === 0) {
      console.log("No font files found to optimize")
      return
    }

    // Log font information
    for (const fontPath of fontFiles) {
      const stats = await fs.stat(fontPath)
      console.log(`  📝 ${path.basename(fontPath)}: ${(stats.size / 1024).toFixed(2)} KB`)
      this.optimizationReport.fonts.processed++
    }

    console.log(`✅ Analyzed ${fontFiles.length} font files`)
  }

  async generateFavicons() {
    console.log("🎯 Generating favicons...")

    const logoPath = path.join(process.cwd(), "assets", "images", "betwizz_logo.png")

    if (!(await fs.pathExists(logoPath))) {
      console.log("Logo file not found, skipping favicon generation")
      return
    }

    const sizes = [16, 32, 48, 96, 144, 192, 256, 512]
    const iconsDir = path.join(this.buildDir, "icons")

    await fs.ensureDir(iconsDir)

    try {
      for (const size of sizes) {
        const outputPath = path.join(iconsDir, `icon-${size}x${size}.png`)

        await sharp(logoPath)
          .resize(size, size, { fit: "contain", background: { r: 255, g: 255, b: 255, alpha: 0 } })
          .png()
          .toFile(outputPath)
      }

      // Generate favicon.ico (32x32)
      await sharp(logoPath).resize(32, 32).png().toFile(path.join(this.buildDir, "favicon.png"))

      // Generate Apple touch icon
      await sharp(logoPath).resize(180, 180).png().toFile(path.join(this.buildDir, "apple-touch-icon.png"))

      console.log(`✅ Generated ${sizes.length + 2} favicon variants`)
    } catch (error) {
      console.error("❌ Favicon generation failed:", error.message)
    }
  }

  async generateOptimizationReport() {
    const report = {
      ...this.optimizationReport,
      timestamp: new Date().toISOString(),
      savings: {
        bytes: this.optimizationReport.total.originalSize - this.optimizationReport.total.optimizedSize,
        percentage:
          this.optimizationReport.total.originalSize > 0
            ? (
                ((this.optimizationReport.total.originalSize - this.optimizationReport.total.optimizedSize) /
                  this.optimizationReport.total.originalSize) *
                100
              ).toFixed(2)
            : 0,
      },
    }

    const reportPath = path.join(this.buildDir, "optimization-report.json")
    await fs.writeJson(reportPath, report, { spaces: 2 })

    console.log("📊 Optimization Report:")
    console.log(`  Images processed: ${report.images.processed}`)
    console.log(`  Fonts processed: ${report.fonts.processed}`)
    console.log(`  Total savings: ${(report.savings.bytes / 1024).toFixed(2)} KB (${report.savings.percentage}%)`)
    console.log(`  Report saved: ${reportPath}`)

    return report
  }

  async optimizeAssets() {
    console.log("🚀 Starting asset optimization...")

    await this.optimizeImages()
    await this.generateResponsiveImages()
    await this.optimizeFonts()
    await this.generateFavicons()
    const report = await this.generateOptimizationReport()

    console.log("✅ Asset optimization completed!")
    return report
  }
}

// Execute if run directly
if (require.main === module) {
  const optimizer = new AssetOptimizer()
  optimizer.optimizeAssets().catch((error) => {
    console.error("💥 Asset optimization failed:", error)
    process.exit(1)
  })
}

module.exports = AssetOptimizer
