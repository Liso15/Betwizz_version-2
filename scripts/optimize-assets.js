const fs = require("fs-extra")
const path = require("path")
const sharp = require("sharp")
const imagemin = require("imagemin")
const imageminPngquant = require("imagemin-pngquant")
const imageminMozjpeg = require("imagemin-mozjpeg")

const buildDir = path.join(__dirname, "..", "build", "web")
const assetsDir = path.join(buildDir, "assets")

async function optimizeImages() {
  console.log("🖼️ Optimizing images...")

  if (!fs.existsSync(assetsDir)) {
    console.log("No assets directory found, skipping image optimization")
    return
  }

  try {
    const files = await imagemin([`${assetsDir}/**/*.{jpg,jpeg,png}`], {
      destination: assetsDir,
      plugins: [imageminMozjpeg({ quality: 85 }), imageminPngquant({ quality: [0.6, 0.8] })],
    })

    console.log(`✅ Optimized ${files.length} images`)
  } catch (error) {
    console.warn("⚠️ Image optimization failed:", error.message)
  }
}

async function generateFavicons() {
  console.log("🎯 Generating favicons...")

  const logoPath = path.join(__dirname, "..", "assets", "images", "betwizz_logo.png")
  const iconsDir = path.join(buildDir, "icons")

  if (!fs.existsSync(logoPath)) {
    console.log("Logo not found, skipping favicon generation")
    return
  }

  await fs.ensureDir(iconsDir)

  const sizes = [16, 32, 48, 96, 144, 192, 512]

  try {
    for (const size of sizes) {
      await sharp(logoPath)
        .resize(size, size)
        .png()
        .toFile(path.join(iconsDir, `icon-${size}x${size}.png`))
    }

    // Generate favicon.ico
    await sharp(logoPath).resize(32, 32).png().toFile(path.join(buildDir, "favicon.png"))

    console.log(`✅ Generated ${sizes.length} favicon sizes`)
  } catch (error) {
    console.warn("⚠️ Favicon generation failed:", error.message)
  }
}

async function optimizeAssets() {
  console.log("🚀 Starting asset optimization...")

  await optimizeImages()
  await generateFavicons()

  console.log("✅ Asset optimization complete!")
}

optimizeAssets().catch(console.error)
