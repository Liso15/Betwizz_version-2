const fs = require("fs-extra")
const path = require("path")

async function verifyBuild() {
  console.log("🔍 Verifying Flutter web build...")

  const buildDir = path.join(process.cwd(), "build", "web")
  const requiredFiles = ["index.html", "main.dart.js", "flutter_service_worker.js", "manifest.json"]

  let allFilesExist = true

  // Check if build directory exists
  if (!(await fs.pathExists(buildDir))) {
    console.error("❌ Build directory does not exist")
    process.exit(1)
  }

  // Check required files
  for (const file of requiredFiles) {
    const filePath = path.join(buildDir, file)
    if (!(await fs.pathExists(filePath))) {
      console.error(`❌ Required file missing: ${file}`)
      allFilesExist = false
    } else {
      console.log(`✅ Found: ${file}`)
    }
  }

  // Check assets directory
  const assetsDir = path.join(buildDir, "assets")
  if (!(await fs.pathExists(assetsDir))) {
    console.error("❌ Assets directory missing")
    allFilesExist = false
  } else {
    console.log("✅ Assets directory exists")
  }

  // Check index.html content
  const indexPath = path.join(buildDir, "index.html")
  if (await fs.pathExists(indexPath)) {
    const indexContent = await fs.readFile(indexPath, "utf8")
    if (indexContent.includes("<title>Betwizz</title>")) {
      console.log("✅ Index.html has correct title")
    } else {
      console.warn("⚠️  Index.html title may be incorrect")
    }
  }

  // Calculate build size
  const stats = await fs.stat(buildDir)
  console.log(`📊 Build directory size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`)

  if (allFilesExist) {
    console.log("✅ Build verification successful!")
    process.exit(0)
  } else {
    console.error("❌ Build verification failed!")
    process.exit(1)
  }
}

verifyBuild().catch((error) => {
  console.error("❌ Verification error:", error)
  process.exit(1)
})
