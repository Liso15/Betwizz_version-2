const sharp = require("sharp")
const imagemin = require("imagemin")
const imageminPngquant = require("imagemin-pngquant")
const imageminMozjpeg = require("imagemin-mozjpeg")
const fs = require("fs-extra")
const path = require("path")
const { glob } = require("glob")

async function optimizeAssets() {
  console.log("🎨 Starting asset optimization...")

  const buildDir = path.join(process.cwd(), "build", "web")
  const assetsDir = path.join(buildDir, "assets")

  if (!(await fs.pathExists(assetsDir))) {
    console.log("⚠️  No assets directory found, skipping optimization")
    return
  }

  try {
    // Find all image files
    const imageFiles = await glob("**/*.{png,jpg,jpeg}", {
      cwd: assetsDir,
      absolute: true,
    })

    console.log(`📸 Found ${imageFiles.length} images to optimize`)

    let totalSavings = 0

    for (const imagePath of imageFiles) {
      const originalSize = (await fs.stat(imagePath)).size

      try {
        // Optimize with imagemin
        const optimized = await imagemin([imagePath], {
          plugins: [imageminMozjpeg({ quality: 85 }), imageminPngquant({ quality: [0.6, 0.8] })],
        })

        if (optimized.length > 0) {
          await fs.writeFile(imagePath, optimized[0].data)
          const newSize = optimized[0].data.length
          const savings = originalSize - newSize
          totalSavings += savings

          console.log(`✅ Optimized ${path.basename(imagePath)}: ${(savings / 1024).toFixed(1)}KB saved`)
        }
      } catch (error) {
        console.warn(`⚠️  Could not optimize ${path.basename(imagePath)}: ${error.message}`)
      }
    }

    console.log(`🎉 Asset optimization complete! Total savings: ${(totalSavings / 1024).toFixed(1)}KB`)
  } catch (error) {
    console.error("❌ Asset optimization failed:", error)
    throw error
  }
}

// Generate optimized favicon
async function generateFavicon() {
  const logoPath = path.join(process.cwd(), "assets", "images", "betwizz_logo.png")
  const buildDir = path.join(process.cwd(), "build", "web")

  if (await fs.pathExists(logoPath)) {
    try {
      // Generate different favicon sizes
      const sizes = [16, 32, 48, 64, 128, 256]

      for (const size of sizes) {
        const outputPath = path.join(buildDir, `favicon-${size}x${size}.png`)
        await sharp(logoPath).resize(size, size).png({ quality: 90 }).toFile(outputPath)
      }

      // Generate main favicon
      await sharp(logoPath).resize(32, 32).png({ quality: 90 }).toFile(path.join(buildDir, "favicon.png"))

      console.log("✅ Generated optimized favicons")
    } catch (error) {
      console.warn("⚠️  Could not generate favicons:", error.message)
    }
  }
}

async function main() {
  await optimizeAssets()
  await generateFavicon()
}

if (require.main === module) {
  main().catch((error) => {
    console.error("❌ Optimization failed:", error)
    process.exit(1)
  })
}

module.exports = { optimizeAssets, generateFavicon }
