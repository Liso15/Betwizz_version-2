const fs = require("fs")
const path = require("path")
const chalk = require("chalk")

/**
 * Build Verification Script for Betwizz Flutter Web
 * Verifies that the build output is correct and complete
 */

const BUILD_DIR = "build/web"
const REQUIRED_FILES = ["index.html", "main.dart.js", "flutter_service_worker.js", "manifest.json"]

const REQUIRED_DIRECTORIES = ["assets", "icons"]

function verifyBuild() {
  console.log(chalk.blue("🔍 Verifying build output..."))

  // Check if build directory exists
  if (!fs.existsSync(BUILD_DIR)) {
    console.error(chalk.red("❌ Build directory not found:", BUILD_DIR))
    process.exit(1)
  }

  // Check required files
  const missingFiles = []
  REQUIRED_FILES.forEach((file) => {
    const filePath = path.join(BUILD_DIR, file)
    if (!fs.existsSync(filePath)) {
      missingFiles.push(file)
    } else {
      const stats = fs.statSync(filePath)
      if (stats.size === 0) {
        missingFiles.push(`${file} (empty)`)
      }
    }
  })

  // Check required directories
  const missingDirs = []
  REQUIRED_DIRECTORIES.forEach((dir) => {
    const dirPath = path.join(BUILD_DIR, dir)
    if (!fs.existsSync(dirPath)) {
      missingDirs.push(dir)
    }
  })

  // Report results
  if (missingFiles.length > 0) {
    console.error(chalk.red("❌ Missing required files:"))
    missingFiles.forEach((file) => console.error(chalk.red(`   - ${file}`)))
  }

  if (missingDirs.length > 0) {
    console.error(chalk.red("❌ Missing required directories:"))
    missingDirs.forEach((dir) => console.error(chalk.red(`   - ${dir}`)))
  }

  if (missingFiles.length > 0 || missingDirs.length > 0) {
    console.error(chalk.red("\n💥 Build verification failed!"))
    console.error(chalk.yellow("🔧 Try running: flutter clean && flutter build web"))
    process.exit(1)
  }

  // Check index.html content
  const indexPath = path.join(BUILD_DIR, "index.html")
  const indexContent = fs.readFileSync(indexPath, "utf8")

  if (!indexContent.includes("flutter_bootstrap.js") && !indexContent.includes("main.dart.js")) {
    console.error(chalk.red("❌ index.html appears to be invalid (missing Flutter bootstrap)"))
    process.exit(1)
  }

  // Check main.dart.js size
  const mainJsPath = path.join(BUILD_DIR, "main.dart.js")
  if (fs.existsSync(mainJsPath)) {
    const stats = fs.statSync(mainJsPath)
    const sizeMB = (stats.size / 1024 / 1024).toFixed(2)

    if (stats.size < 100000) {
      // Less than 100KB is suspicious
      console.warn(chalk.yellow(`⚠️  main.dart.js seems small (${sizeMB}MB) - build might be incomplete`))
    } else {
      console.log(chalk.green(`✅ main.dart.js size: ${sizeMB}MB`))
    }
  }

  // List all files for debugging
  console.log(chalk.blue("\n📁 Build directory contents:"))
  const files = fs.readdirSync(BUILD_DIR)
  files.forEach((file) => {
    const filePath = path.join(BUILD_DIR, file)
    const stats = fs.statSync(filePath)
    const type = stats.isDirectory() ? "DIR" : "FILE"
    const size = stats.isDirectory() ? "" : ` (${(stats.size / 1024).toFixed(1)}KB)`
    console.log(chalk.gray(`   ${type}: ${file}${size}`))
  })

  console.log(chalk.green("\n✅ Build verification passed!"))
}

if (require.main === module) {
  verifyBuild()
}

module.exports = { verifyBuild }
