const fs = require("fs")
const path = require("path")
const { execSync } = require("child_process")

class BundleAnalyzer {
  constructor() {
    this.buildPath = path.join(process.cwd(), "build", "web")
    this.targetSizeMB = 8
    this.warningThresholdMB = 7
  }

  async analyze() {
    console.log("🔍 Analyzing Betwizz Web Bundle")
    console.log("================================\n")

    if (!fs.existsSync(this.buildPath)) {
      console.error('❌ Build directory not found. Run "flutter build web --release" first.')
      return
    }

    const analysis = this.performAnalysis()
    this.generateReport(analysis)
    this.checkSizeConstraints(analysis)

    return analysis
  }

  performAnalysis() {
    const files = this.getWebFiles()
    const analysis = {
      totalSize: 0,
      totalSizeCompressed: 0,
      files: [],
      categories: {
        javascript: { size: 0, compressed: 0, files: [] },
        assets: { size: 0, compressed: 0, files: [] },
        fonts: { size: 0, compressed: 0, files: [] },
        images: { size: 0, compressed: 0, files: [] },
        other: { size: 0, compressed: 0, files: [] },
      },
      timestamp: new Date().toISOString(),
    }

    files.forEach((file) => {
      const filePath = path.join(this.buildPath, file)
      const stats = fs.statSync(filePath)
      const size = stats.size
      const compressedSize = this.estimateCompressedSize(size, file)

      const fileInfo = {
        name: file,
        size: size,
        sizeFormatted: this.formatBytes(size),
        compressed: compressedSize,
        compressedFormatted: this.formatBytes(compressedSize),
        compressionRatio: (((size - compressedSize) / size) * 100).toFixed(1),
      }

      analysis.files.push(fileInfo)
      analysis.totalSize += size
      analysis.totalSizeCompressed += compressedSize

      // Categorize files
      const category = this.categorizeFile(file)
      analysis.categories[category].size += size
      analysis.categories[category].compressed += compressedSize
      analysis.categories[category].files.push(fileInfo)
    })

    // Sort files by compressed size (largest first)
    analysis.files.sort((a, b) => b.compressed - a.compressed)

    return analysis
  }

  getWebFiles() {
    const files = []

    const scanDirectory = (dir, prefix = "") => {
      const items = fs.readdirSync(path.join(this.buildPath, dir))

      items.forEach((item) => {
        const itemPath = path.join(dir, item)
        const fullPath = path.join(this.buildPath, itemPath)
        const stat = fs.statSync(fullPath)

        if (stat.isDirectory()) {
          scanDirectory(itemPath, prefix)
        } else {
          files.push(itemPath)
        }
      })
    }

    scanDirectory("")
    return files
  }

  categorizeFile(filename) {
    const ext = path.extname(filename).toLowerCase()
    const basename = path.basename(filename).toLowerCase()

    if (ext === ".js" || ext === ".mjs") return "javascript"
    if (ext === ".woff" || ext === ".woff2" || ext === ".ttf" || ext === ".otf") return "fonts"
    if ([".png", ".jpg", ".jpeg", ".webp", ".svg", ".ico"].includes(ext)) return "images"
    if ([".css", ".html", ".json", ".txt", ".md"].includes(ext)) return "assets"

    return "other"
  }

  estimateCompressedSize(size, filename) {
    const ext = path.extname(filename).toLowerCase()

    // Compression ratios based on file type
    const compressionRatios = {
      ".js": 0.25, // JavaScript compresses very well
      ".mjs": 0.25,
      ".css": 0.3,
      ".html": 0.35,
      ".json": 0.2,
      ".txt": 0.4,
      ".woff": 0.95, // Already compressed
      ".woff2": 0.95,
      ".png": 0.9, // Already compressed
      ".jpg": 0.95,
      ".jpeg": 0.95,
      ".webp": 0.9,
      ".svg": 0.5, // XML compresses well
    }

    const ratio = compressionRatios[ext] || 0.6
    return Math.round(size * ratio)
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"

    const k = 1024
    const sizes = ["B", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  }

  generateReport(analysis) {
    console.log("📊 Bundle Size Analysis")
    console.log("=======================\n")

    // Overall statistics
    console.log("📈 Overall Statistics:")
    console.log(`   Total Size (uncompressed): ${this.formatBytes(analysis.totalSize)}`)
    console.log(`   Total Size (compressed):   ${this.formatBytes(analysis.totalSizeCompressed)}`)
    console.log(
      `   Compression Ratio:         ${(((analysis.totalSize - analysis.totalSizeCompressed) / analysis.totalSize) * 100).toFixed(1)}%`,
    )
    console.log(`   Number of Files:           ${analysis.files.length}\n`)

    // Category breakdown
    console.log("📂 Category Breakdown:")
    Object.entries(analysis.categories).forEach(([category, data]) => {
      if (data.files.length > 0) {
        console.log(`   ${category.toUpperCase()}:`)
        console.log(`     Files: ${data.files.length}`)
        console.log(`     Size: ${this.formatBytes(data.compressed)} (compressed)`)
        console.log(`     Percentage: ${((data.compressed / analysis.totalSizeCompressed) * 100).toFixed(1)}%`)
        console.log("")
      }
    })

    // Largest files
    console.log("📋 Largest Files (Top 10):")
    analysis.files.slice(0, 10).forEach((file, index) => {
      console.log(`   ${index + 1}. ${file.name}`)
      console.log(`      Size: ${file.compressedFormatted} (${file.compressionRatio}% compression)`)
    })
    console.log("")

    // Performance estimates
    this.generatePerformanceEstimates(analysis)
  }

  generatePerformanceEstimates(analysis) {
    console.log("⚡ Performance Estimates:")
    console.log("========================\n")

    const sizeMB = analysis.totalSizeCompressed / (1024 * 1024)

    // Network speed estimates (in KB/s)
    const networkSpeeds = {
      "3G Slow": 50,
      "3G Fast": 150,
      "4G": 500,
      WiFi: 2000,
      Fiber: 10000,
    }

    console.log("📡 Download Time Estimates:")
    Object.entries(networkSpeeds).forEach(([network, speedKBps]) => {
      const timeSeconds = analysis.totalSizeCompressed / 1024 / speedKBps
      const timeFormatted =
        timeSeconds < 60
          ? `${timeSeconds.toFixed(1)}s`
          : `${Math.floor(timeSeconds / 60)}m ${(timeSeconds % 60).toFixed(0)}s`

      console.log(`   ${network.padEnd(10)}: ${timeFormatted}`)
    })

    console.log("\n🎯 Performance Targets:")
    console.log(`   Target Size: ${this.targetSizeMB}MB`)
    console.log(`   Current Size: ${sizeMB.toFixed(2)}MB`)
    console.log(`   Status: ${sizeMB <= this.targetSizeMB ? "✅ PASS" : "❌ FAIL"}`)

    if (sizeMB > this.warningThresholdMB) {
      console.log(`   Warning: Approaching size limit (${this.warningThresholdMB}MB threshold)`)
    }

    console.log("\n📱 Mobile Performance:")
    const mobileLoadTime = analysis.totalSizeCompressed / 1024 / 150 // 3G speed
    console.log(`   3G Load Time: ${mobileLoadTime.toFixed(1)}s`)
    console.log(`   Target: <3s ${mobileLoadTime <= 3 ? "✅" : "❌"}`)

    console.log("\n💾 Cache Efficiency:")
    const jsSize = analysis.categories.javascript.compressed
    const assetSize = analysis.totalSizeCompressed - jsSize
    console.log(`   JavaScript (cacheable): ${this.formatBytes(jsSize)}`)
    console.log(`   Assets (cacheable): ${this.formatBytes(assetSize)}`)
    console.log(`   Cache Hit Ratio: ~85% (estimated)`)
  }

  checkSizeConstraints(analysis) {
    console.log("\n🚨 Size Constraint Check:")
    console.log("=========================\n")

    const sizeMB = analysis.totalSizeCompressed / (1024 * 1024)
    const targetMet = sizeMB <= this.targetSizeMB
    const ciLimitMB = 8.5
    const ciLimitMet = sizeMB <= ciLimitMB

    console.log(`Bundle Size: ${sizeMB.toFixed(2)}MB`)
    console.log(`Target (${this.targetSizeMB}MB): ${targetMet ? "✅ PASS" : "❌ FAIL"}`)
    console.log(`CI Limit (${ciLimitMB}MB): ${ciLimitMet ? "✅ PASS" : "❌ FAIL"}`)

    if (!targetMet) {
      console.log("\n⚠️ Optimization Recommendations:")
      this.generateOptimizationRecommendations(analysis)
    }

    if (!ciLimitMet) {
      console.log("\n❌ CI BUILD WILL FAIL - Bundle exceeds 8.5MB limit!")
      process.exit(1)
    }

    // Save analysis to file
    this.saveAnalysisReport(analysis)
  }

  generateOptimizationRecommendations(analysis) {
    const recommendations = []

    // Check JavaScript size
    const jsSize = analysis.categories.javascript.compressed / (1024 * 1024)
    if (jsSize > 4) {
      recommendations.push("• Consider code splitting to reduce main bundle size")
      recommendations.push("• Enable tree shaking for unused code elimination")
    }

    // Check asset size
    const assetSize = analysis.categories.assets.compressed / (1024 * 1024)
    if (assetSize > 2) {
      recommendations.push("• Optimize images with WebP format")
      recommendations.push("• Implement lazy loading for non-critical assets")
    }

    // Check font size
    const fontSize = analysis.categories.fonts.compressed / (1024 * 1024)
    if (fontSize > 0.5) {
      recommendations.push("• Use system fonts or subset custom fonts")
      recommendations.push("• Convert fonts to WOFF2 format")
    }

    // Check for large individual files
    const largeFiles = analysis.files.filter((f) => f.compressed > 1024 * 1024) // >1MB
    if (largeFiles.length > 0) {
      recommendations.push("• Review large files for optimization opportunities:")
      largeFiles.forEach((file) => {
        recommendations.push(`  - ${file.name} (${file.compressedFormatted})`)
      })
    }

    recommendations.forEach((rec) => console.log(rec))
  }

  saveAnalysisReport(analysis) {
    const reportPath = path.join(process.cwd(), "bundle-analysis-report.json")

    const report = {
      ...analysis,
      metadata: {
        targetSizeMB: this.targetSizeMB,
        warningThresholdMB: this.warningThresholdMB,
        buildPath: this.buildPath,
        analyzedAt: new Date().toISOString(),
        version: "1.0.0",
      },
    }

    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2))
    console.log(`\n📄 Detailed report saved to: ${reportPath}`)
  }
}

// Export for use in other scripts
module.exports = BundleAnalyzer

// Run directly if called from command line
if (require.main === module) {
  const analyzer = new BundleAnalyzer()
  analyzer.analyze().catch(console.error)
}
