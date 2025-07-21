const fs = require("fs")
const path = require("path")

const buildDir = path.join(__dirname, "..", "build", "web")
const requiredFiles = ["index.html", "main.dart.js", "flutter_service_worker.js", "manifest.json"]

console.log("🔍 Verifying Flutter web build...")

// Check if build directory exists
if (!fs.existsSync(buildDir)) {
  console.error("❌ Build directory not found:", buildDir)
  process.exit(1)
}

// Check required files
let allFilesExist = true
requiredFiles.forEach((file) => {
  const filePath = path.join(buildDir, file)
  if (fs.existsSync(filePath)) {
    const stats = fs.statSync(filePath)
    console.log(`✅ ${file} (${(stats.size / 1024).toFixed(2)} KB)`)
  } else {
    console.error(`❌ Missing required file: ${file}`)
    allFilesExist = false
  }
})

// Check assets directory
const assetsDir = path.join(buildDir, "assets")
if (fs.existsSync(assetsDir)) {
  const assetFiles = fs.readdirSync(assetsDir, { recursive: true })
  console.log(`✅ Assets directory (${assetFiles.length} files)`)
} else {
  console.error("❌ Assets directory not found")
  allFilesExist = false
}

// Verify index.html content
const indexPath = path.join(buildDir, "index.html")
if (fs.existsSync(indexPath)) {
  const indexContent = fs.readFileSync(indexPath, "utf8")
  if (indexContent.includes("<title>Betwizz</title>")) {
    console.log("✅ Index.html has correct title")
  } else {
    console.warn("⚠️ Index.html title may need updating")
  }

  if (indexContent.includes("flutter")) {
    console.log("✅ Index.html contains Flutter references")
  } else {
    console.error("❌ Index.html missing Flutter references")
    allFilesExist = false
  }
}

if (allFilesExist) {
  console.log("🎉 Build verification successful!")
  process.exit(0)
} else {
  console.error("💥 Build verification failed!")
  process.exit(1)
}
