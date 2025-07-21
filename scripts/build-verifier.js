const fs = require("fs-extra")
const path = require("path")
const { execSync } = require("child_process")

class BuildVerifier {
  constructor(buildDir) {
    this.buildDir = buildDir || path.join(process.cwd(), "build", "web")
    this.verificationResults = {
      files: { passed: 0, failed: 0, details: [] },
      integrity: { passed: 0, failed: 0, details: [] },
      performance: { passed: 0, failed: 0, details: [] },
      security: { passed: 0, failed: 0, details: [] },
    }
  }

  async verifyRequiredFiles() {
    console.log("📋 Verifying required files...")

    const requiredFiles = [
      { path: "index.html", critical: true, description: "Main HTML file" },
      { path: "main.dart.js", critical: true, description: "Flutter compiled JavaScript" },
      { path: "flutter_service_worker.js", critical: true, description: "Service worker for caching" },
      { path: "manifest.json", critical: true, description: "PWA manifest" },
      { path: "assets", critical: true, description: "Assets directory", isDirectory: true },
      { path: "favicon.png", critical: false, description: "Favicon" },
      { path: "sitemap.xml", critical: false, description: "SEO sitemap" },
      { path: "robots.txt", critical: false, description: "Robots.txt for SEO" },
    ]

    for (const file of requiredFiles) {
      const filePath = path.join(this.buildDir, file.path)
      const exists = await fs.pathExists(filePath)

      if (exists) {
        const stats = await fs.stat(filePath)
        const isDirectory = stats.isDirectory()

        if (file.isDirectory && !isDirectory) {
          this.addResult("files", false, `${file.path} should be a directory but is a file`)
        } else if (!file.isDirectory && isDirectory) {
          this.addResult("files", false, `${file.path} should be a file but is a directory`)
        } else {
          const size = isDirectory ? "directory" : `${(stats.size / 1024).toFixed(2)} KB`
          this.addResult("files", true, `${file.path} exists (${size}) - ${file.description}`)
        }
      } else {
        const severity = file.critical ? "CRITICAL" : "WARNING"
        this.addResult("files", !file.critical, `${severity}: ${file.path} missing - ${file.description}`)
      }
    }
  }

  async verifyFileIntegrity() {
    console.log("🔍 Verifying file integrity...")

    // Check index.html content
    const indexPath = path.join(this.buildDir, "index.html")
    if (await fs.pathExists(indexPath)) {
      const indexContent = await fs.readFile(indexPath, "utf8")

      // Check for essential elements
      const checks = [
        { test: indexContent.includes("<title>"), message: "HTML title tag present" },
        { test: indexContent.includes("flutter"), message: "Flutter references found" },
        { test: indexContent.includes("main.dart.js"), message: "Main Dart JS referenced" },
        { test: indexContent.includes("manifest.json"), message: "Manifest linked" },
        { test: indexContent.includes('meta name="viewport"'), message: "Viewport meta tag present" },
      ]

      checks.forEach((check) => {
        this.addResult("integrity", check.test, check.message)
      })
    } else {
      this.addResult("integrity", false, "index.html not found for integrity check")
    }

    // Check main.dart.js
    const mainJsPath = path.join(this.buildDir, "main.dart.js")
    if (await fs.pathExists(mainJsPath)) {
      const stats = await fs.stat(mainJsPath)
      const sizeKB = stats.size / 1024

      if (sizeKB > 0) {
        this.addResult("integrity", true, `main.dart.js has content (${sizeKB.toFixed(2)} KB)`)
      } else {
        this.addResult("integrity", false, "main.dart.js is empty")
      }

      // Check if file is minified (basic check)
      const content = await fs.readFile(mainJsPath, "utf8")
      const isMinified = !content.includes("\n  ") && content.length > 1000
      this.addResult("integrity", isMinified, `main.dart.js appears ${isMinified ? "minified" : "not minified"}`)
    }

    // Check service worker
    const swPath = path.join(this.buildDir, "flutter_service_worker.js")
    if (await fs.pathExists(swPath)) {
      const swContent = await fs.readFile(swPath, "utf8")
      const hasCache = swContent.includes("cache") || swContent.includes("Cache")
      this.addResult("integrity", hasCache, `Service worker ${hasCache ? "includes" : "missing"} caching logic`)
    }
  }

  async verifyPerformance() {
    console.log("⚡ Verifying performance characteristics...")

    // Check file sizes
    const sizeChecks = [
      { file: "main.dart.js", maxSizeMB: 10, description: "Main JavaScript bundle" },
      { file: "index.html", maxSizeKB: 50, description: "HTML file" },
      { file: "manifest.json", maxSizeKB: 10, description: "PWA manifest" },
    ]

    for (const check of sizeChecks) {
      const filePath = path.join(this.buildDir, check.file)
      if (await fs.pathExists(filePath)) {
        const stats = await fs.stat(filePath)
        const sizeKB = stats.size / 1024
        const sizeMB = sizeKB / 1024

        let passed = true
        let message = ""

        if (check.maxSizeMB && sizeMB > check.maxSizeMB) {
          passed = false
          message = `${check.file} too large: ${sizeMB.toFixed(2)} MB (max: ${check.maxSizeMB} MB)`
        } else if (check.maxSizeKB && sizeKB > check.maxSizeKB) {
          passed = false
          message = `${check.file} too large: ${sizeKB.toFixed(2)} KB (max: ${check.maxSizeKB} KB)`
        } else {
          const size = sizeMB > 1 ? `${sizeMB.toFixed(2)} MB` : `${sizeKB.toFixed(2)} KB`
          message = `${check.file} size acceptable: ${size}`
        }

        this.addResult("performance", passed, message)
      }
    }

    // Check asset optimization
    const assetsDir = path.join(this.buildDir, "assets")
    if (await fs.pathExists(assetsDir)) {
      const assetFiles = await this.getFilesRecursively(assetsDir)
      const imageFiles = assetFiles.filter((f) => /\.(jpg|jpeg|png|gif|webp)$/i.test(f))

      this.addResult("performance", true, `Found ${imageFiles.length} image assets`)

      // Check for WebP versions
      const webpFiles = imageFiles.filter((f) => f.endsWith(".webp"))
      if (webpFiles.length > 0) {
        this.addResult("performance", true, `${webpFiles.length} WebP optimized images found`)
      }
    }
  }

  async verifySecurity() {
    console.log("🔒 Verifying security configurations...")

    // Check index.html for security headers
    const indexPath = path.join(this.buildDir, "index.html")
    if (await fs.pathExists(indexPath)) {
      const indexContent = await fs.readFile(indexPath, "utf8")

      const securityChecks = [
        {
          test: indexContent.includes("Content-Security-Policy") || indexContent.includes("CSP"),
          message: "Content Security Policy configured",
          critical: false,
        },
        {
          test: !indexContent.includes("eval(") && !indexContent.includes("innerHTML"),
          message: "No dangerous JavaScript patterns detected",
          critical: true,
        },
        {
          test: indexContent.includes("https://") && !indexContent.includes("http://"),
          message: "HTTPS URLs used (no HTTP)",
          critical: false,
        },
      ]

      securityChecks.forEach((check) => {
        this.addResult("security", check.test, check.message)
      })
    }

    // Check for security.txt
    const securityTxtPath = path.join(this.buildDir, ".well-known", "security.txt")
    const hasSecurityTxt = await fs.pathExists(securityTxtPath)
    this.addResult("security", hasSecurityTxt, `Security.txt ${hasSecurityTxt ? "present" : "missing"}`)

    // Check robots.txt
    const robotsPath = path.join(this.buildDir, "robots.txt")
    if (await fs.pathExists(robotsPath)) {
      const robotsContent = await fs.readFile(robotsPath, "utf8")
      const hasDisallows = robotsContent.includes("Disallow:")
      this.addResult(
        "security",
        hasDisallows,
        `Robots.txt ${hasDisallows ? "includes" : "missing"} security directives`,
      )
    }
  }

  async runLighthouseAudit() {
    console.log("🚨 Running Lighthouse audit...")

    try {
      // Start a simple HTTP server for testing
      const serverProcess = require("child_process").spawn("python", ["-m", "http.server", "8080"], {
        cwd: this.buildDir,
        stdio: "pipe",
      })

      // Wait for server to start
      await new Promise((resolve) => setTimeout(resolve, 2000))

      // Run Lighthouse
      const lighthouseResult = execSync(
        'lighthouse http://localhost:8080 --output=json --quiet --chrome-flags="--headless --no-sandbox"',
        { encoding: "utf8", timeout: 60000 },
      )

      const audit = JSON.parse(lighthouseResult)
      const scores = audit.lhr.categories

      // Check scores
      const scoreChecks = [
        { category: "performance", score: scores.performance?.score * 100, threshold: 70 },
        { category: "accessibility", score: scores.accessibility?.score * 100, threshold: 90 },
        { category: "best-practices", score: scores["best-practices"]?.score * 100, threshold: 80 },
        { category: "seo", score: scores.seo?.score * 100, threshold: 85 },
      ]

      scoreChecks.forEach((check) => {
        if (check.score !== undefined) {
          const passed = check.score >= check.threshold
          this.addResult(
            "performance",
            passed,
            `Lighthouse ${check.category}: ${check.score.toFixed(0)}/100 (threshold: ${check.threshold})`,
          )
        }
      })

      serverProcess.kill()
    } catch (error) {
      console.warn("⚠️ Lighthouse audit failed:", error.message)
      this.addResult("performance", false, "Lighthouse audit could not be completed")
    }
  }

  async getFilesRecursively(dir) {
    const files = []
    const items = await fs.readdir(dir)

    for (const item of items) {
      const fullPath = path.join(dir, item)
      const stats = await fs.stat(fullPath)

      if (stats.isDirectory()) {
        const subFiles = await this.getFilesRecursively(fullPath)
        files.push(...subFiles)
      } else {
        files.push(fullPath)
      }
    }

    return files
  }

  addResult(category, passed, message) {
    this.verificationResults[category].details.push({ passed, message })
    if (passed) {
      this.verificationResults[category].passed++
    } else {
      this.verificationResults[category].failed++
    }
  }

  async generateVerificationReport() {
    const report = {
      timestamp: new Date().toISOString(),
      buildDirectory: this.buildDir,
      summary: {
        totalTests: 0,
        totalPassed: 0,
        totalFailed: 0,
        overallStatus: "UNKNOWN",
      },
      categories: this.verificationResults,
    }

    // Calculate summary
    Object.values(this.verificationResults).forEach((category) => {
      report.summary.totalTests += category.passed + category.failed
      report.summary.totalPassed += category.passed
      report.summary.totalFailed += category.failed
    })

    // Determine overall status
    const criticalFailures = this.verificationResults.files.failed + this.verificationResults.integrity.failed
    if (criticalFailures === 0) {
      report.summary.overallStatus = report.summary.totalFailed === 0 ? "PASS" : "PASS_WITH_WARNINGS"
    } else {
      report.summary.overallStatus = "FAIL"
    }

    const reportPath = path.join(this.buildDir, "verification-report.json")
    await fs.writeJson(reportPath, report, { spaces: 2 })

    return report
  }

  async printResults() {
    console.log("\n📊 Build Verification Results:")
    console.log("=" * 50)

    Object.entries(this.verificationResults).forEach(([category, results]) => {
      const total = results.passed + results.failed
      const passRate = total > 0 ? ((results.passed / total) * 100).toFixed(1) : 0

      console.log(`\n${category.toUpperCase()}: ${results.passed}/${total} passed (${passRate}%)`)

      results.details.forEach((detail) => {
        const icon = detail.passed ? "✅" : "❌"
        console.log(`  ${icon} ${detail.message}`)
      })
    })
  }

  async verifyBuild() {
    console.log("🚀 Starting comprehensive build verification...")

    if (!(await fs.pathExists(this.buildDir))) {
      throw new Error(`Build directory not found: ${this.buildDir}`)
    }

    await this.verifyRequiredFiles()
    await this.verifyFileIntegrity()
    await this.verifyPerformance()
    await this.verifySecurity()

    // Optional: Run Lighthouse audit (can be slow)
    if (process.env.RUN_LIGHTHOUSE === "true") {
      await this.runLighthouseAudit()
    }

    const report = await this.generateVerificationReport()
    await this.printResults()

    console.log(`\n📄 Verification report saved: ${path.join(this.buildDir, "verification-report.json")}`)
    console.log(`🎯 Overall Status: ${report.summary.overallStatus}`)

    if (report.summary.overallStatus === "FAIL") {
      throw new Error("Build verification failed with critical errors")
    }

    return report
  }
}

// Execute if run directly
if (require.main === module) {
  const verifier = new BuildVerifier()
  verifier.verifyBuild().catch((error) => {
    console.error("💥 Build verification failed:", error.message)
    process.exit(1)
  })
}

module.exports = BuildVerifier
