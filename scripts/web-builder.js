const fs = require("fs-extra")
const path = require("path")
const { execSync } = require("child_process")

class WebBuilder {
  constructor(projectRoot = process.cwd()) {
    this.projectRoot = projectRoot
    this.buildDir = path.join(projectRoot, "build", "web")
    this.assetsDir = path.join(this.buildDir, "assets")
  }

  async validateEnvironment() {
    console.log("🔍 Validating build environment...")

    // Check Flutter installation
    try {
      const flutterVersion = execSync("flutter --version", { encoding: "utf8" })
      console.log("✅ Flutter SDK:", flutterVersion.split("\n")[0])
    } catch (error) {
      throw new Error("Flutter SDK not found or not properly installed")
    }

    // Check web support
    try {
      const flutterConfig = execSync("flutter config", { encoding: "utf8" })
      if (!flutterConfig.includes("enable-web: true")) {
        throw new Error("Flutter web support is not enabled")
      }
      console.log("✅ Flutter web support enabled")
    } catch (error) {
      throw new Error("Failed to verify Flutter web support")
    }

    // Check project structure
    const requiredFiles = ["pubspec.yaml", "lib/main.dart", "web/index.html"]
    for (const file of requiredFiles) {
      const filePath = path.join(this.projectRoot, file)
      if (!(await fs.pathExists(filePath))) {
        throw new Error(`Required file missing: ${file}`)
      }
    }
    console.log("✅ Project structure validated")
  }

  async cleanBuild() {
    console.log("🧹 Cleaning previous build...")

    if (await fs.pathExists(this.buildDir)) {
      await fs.remove(this.buildDir)
    }

    // Clean Flutter cache
    try {
      execSync("flutter clean", { cwd: this.projectRoot, stdio: "inherit" })
      console.log("✅ Build directory cleaned")
    } catch (error) {
      console.warn("⚠️ Flutter clean failed:", error.message)
    }
  }

  async buildWeb() {
    console.log("🏗️ Building Flutter web application...")

    const buildCommand = [
      "flutter build web",
      "--release",
      "--web-renderer html",
      "--base-href /",
      "--source-maps",
      "--dart-define=FLUTTER_WEB_USE_SKIA=false",
    ].join(" ")

    try {
      execSync(buildCommand, {
        cwd: this.projectRoot,
        stdio: "inherit",
        env: {
          ...process.env,
          FLUTTER_WEB_AUTO_DETECT: "false",
        },
      })

      console.log("✅ Flutter web build completed")
    } catch (error) {
      console.error("❌ Flutter web build failed:", error.message)
      throw error
    }
  }

  async analyzeBuild() {
    console.log("📊 Analyzing build output...")

    if (!(await fs.pathExists(this.buildDir))) {
      throw new Error("Build directory not found")
    }

    const analysis = {
      files: [],
      totalSize: 0,
      jsFiles: [],
      assetFiles: [],
      largeFiles: [],
    }

    // Recursively analyze files
    const analyzeDirectory = async (dir, relativePath = "") => {
      const items = await fs.readdir(dir)

      for (const item of items) {
        const fullPath = path.join(dir, item)
        const relativeFilePath = path.join(relativePath, item)
        const stats = await fs.stat(fullPath)

        if (stats.isDirectory()) {
          await analyzeDirectory(fullPath, relativeFilePath)
        } else {
          const fileInfo = {
            path: relativeFilePath,
            size: stats.size,
            sizeKB: Math.round((stats.size / 1024) * 100) / 100,
          }

          analysis.files.push(fileInfo)
          analysis.totalSize += stats.size

          // Categorize files
          if (item.endsWith(".js")) {
            analysis.jsFiles.push(fileInfo)
          } else if (relativeFilePath.startsWith("assets/")) {
            analysis.assetFiles.push(fileInfo)
          }

          // Flag large files (>1MB)
          if (stats.size > 1024 * 1024) {
            analysis.largeFiles.push(fileInfo)
          }
        }
      }
    }

    await analyzeDirectory(this.buildDir)

    // Sort by size
    analysis.files.sort((a, b) => b.size - a.size)
    analysis.jsFiles.sort((a, b) => b.size - a.size)

    // Log analysis
    console.log(`📈 Build Analysis:`)
    console.log(`  Total files: ${analysis.files.length}`)
    console.log(`  Total size: ${(analysis.totalSize / 1024 / 1024).toFixed(2)} MB`)
    console.log(`  JavaScript files: ${analysis.jsFiles.length}`)
    console.log(`  Asset files: ${analysis.assetFiles.length}`)

    if (analysis.largeFiles.length > 0) {
      console.log(`  Large files (>1MB): ${analysis.largeFiles.length}`)
      analysis.largeFiles.forEach((file) => {
        console.log(`    ${file.path}: ${file.sizeKB} KB`)
      })
    }

    // Save analysis report
    const reportPath = path.join(this.buildDir, "build-analysis.json")
    await fs.writeJson(reportPath, analysis, { spaces: 2 })
    console.log(`📄 Build analysis saved to: ${reportPath}`)

    return analysis
  }

  async optimizeBuild() {
    console.log("⚡ Optimizing build output...")

    // Compress main.dart.js if it exists
    const mainJsPath = path.join(this.buildDir, "main.dart.js")
    if (await fs.pathExists(mainJsPath)) {
      const stats = await fs.stat(mainJsPath)
      console.log(`📦 main.dart.js size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`)
    }

    // Create .htaccess for Apache servers
    const htaccessContent = `
# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>

# Set cache headers
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
`.trim()

    await fs.writeFile(path.join(this.buildDir, ".htaccess"), htaccessContent)
    console.log("✅ Created .htaccess for optimization")
  }

  async buildWebApplication() {
    console.log("🚀 Starting web application build process...")

    await this.validateEnvironment()
    await this.cleanBuild()
    await this.buildWeb()
    const analysis = await this.analyzeBuild()
    await this.optimizeBuild()

    console.log("🎉 Web application build completed successfully!")
    return analysis
  }
}

// Execute if run directly
if (require.main === module) {
  const builder = new WebBuilder()
  builder.buildWebApplication().catch((error) => {
    console.error("💥 Web build failed:", error)
    process.exit(1)
  })
}

module.exports = WebBuilder
