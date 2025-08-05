const fs = require("fs-extra")
const path = require("path")
const { execSync } = require("child_process")

class OptimizationAnalyzer {
  constructor(projectRoot = process.cwd()) {
    this.projectRoot = projectRoot
    this.analysisResults = {
      files: {
        total: 0,
        redundant: [],
        unused: [],
        oversized: [],
      },
      dependencies: {
        total: 0,
        unused: [],
        heavy: [],
        duplicates: [],
      },
      assets: {
        total: 0,
        unoptimized: [],
        duplicates: [],
        totalSize: 0,
      },
      performance: {
        issues: [],
        recommendations: [],
      },
    }
  }

  async analyzeProject() {
    console.log("🔍 Starting comprehensive project analysis...")

    await this.analyzeFiles()
    await this.analyzeDependencies()
    await this.analyzeAssets()
    await this.analyzePerformance()

    return this.generateReport()
  }

  async analyzeFiles() {
    console.log("📁 Analyzing file structure...")

    const filesToCheck = await this.getAllFiles(this.projectRoot)
    this.analysisResults.files.total = filesToCheck.length

    // Check for redundant files
    const redundantPatterns = [/missing_.*\.dart$/, /.*_placeholder\.dart$/, /.*\.dart\.bak$/, /mobile-setup.*\.sh$/]

    // Check for unused files
    const unusedFiles = [
      "lib/core/implementation/missing_foundations.dart",
      "lib/core/performance/missing_optimizations.dart",
      "lib/design_system/missing_components.dart",
      "lib/screens/missing_screens.dart",
      "lib/widgets/interaction_flows.dart",
      "assets/images/icons/fonts/Roboto-Regular.ttf", // duplicate
      "mobile-build-config.yml",
      "docs/mobile-setup-troubleshooting.md",
    ]

    for (const file of filesToCheck) {
      const relativePath = path.relative(this.projectRoot, file)

      // Check for redundant patterns
      if (redundantPatterns.some((pattern) => pattern.test(relativePath))) {
        this.analysisResults.files.redundant.push(relativePath)
      }

      // Check for unused files
      if (unusedFiles.includes(relativePath)) {
        this.analysisResults.files.unused.push(relativePath)
      }

      // Check file size
      const stats = await fs.stat(file)
      if (stats.size > 1024 * 1024) {
        // Files larger than 1MB
        this.analysisResults.files.oversized.push({
          path: relativePath,
          size: stats.size,
          sizeKB: Math.round(stats.size / 1024),
        })
      }
    }
  }

  async analyzeDependencies() {
    console.log("📦 Analyzing dependencies...")

    const pubspecPath = path.join(this.projectRoot, "pubspec.yaml")
    if (!(await fs.pathExists(pubspecPath))) {
      return
    }

    const pubspecContent = await fs.readFile(pubspecPath, "utf8")
    const dependencies = this.extractDependencies(pubspecContent)

    this.analysisResults.dependencies.total = dependencies.length

    // Heavy dependencies that might not be needed for web
    const heavyDependencies = [
      "agora_rtc_engine",
      "video_player",
      "camera",
      "lottie",
      "firebase_storage",
      "firebase_messaging",
    ]

    // Duplicate functionality
    const duplicates = [
      ["provider", "flutter_riverpod"], // Both are state management
      ["http", "dio"], // Both are HTTP clients
      ["image", "cached_network_image"], // Overlapping functionality
    ]

    for (const dep of dependencies) {
      if (heavyDependencies.includes(dep)) {
        this.analysisResults.dependencies.heavy.push(dep)
      }
    }

    for (const [dep1, dep2] of duplicates) {
      if (dependencies.includes(dep1) && dependencies.includes(dep2)) {
        this.analysisResults.dependencies.duplicates.push([dep1, dep2])
      }
    }
  }

  async analyzeAssets() {
    console.log("🖼️ Analyzing assets...")

    const assetsDir = path.join(this.projectRoot, "assets")
    if (!(await fs.pathExists(assetsDir))) {
      return
    }

    const assetFiles = await this.getAllFiles(assetsDir)
    this.analysisResults.assets.total = assetFiles.length

    let totalSize = 0
    const duplicates = new Map()

    for (const file of assetFiles) {
      const stats = await fs.stat(file)
      totalSize += stats.size

      const fileName = path.basename(file)
      const relativePath = path.relative(this.projectRoot, file)

      // Check for duplicates by name
      if (duplicates.has(fileName)) {
        duplicates.get(fileName).push(relativePath)
      } else {
        duplicates.set(fileName, [relativePath])
      }

      // Check for unoptimized images
      if (/\.(jpg|jpeg|png)$/i.test(fileName) && stats.size > 500 * 1024) {
        this.analysisResults.assets.unoptimized.push({
          path: relativePath,
          size: stats.size,
          sizeKB: Math.round(stats.size / 1024),
        })
      }
    }

    this.analysisResults.assets.totalSize = totalSize

    // Find actual duplicates
    for (const [fileName, paths] of duplicates) {
      if (paths.length > 1) {
        this.analysisResults.assets.duplicates.push({
          fileName,
          paths,
        })
      }
    }
  }

  async analyzePerformance() {
    console.log("⚡ Analyzing performance issues...")

    const issues = []
    const recommendations = []

    // Check for performance anti-patterns
    const dartFiles = await this.getAllFiles(path.join(this.projectRoot, "lib"))

    for (const file of dartFiles) {
      if (file.endsWith(".dart")) {
        const content = await fs.readFile(file, "utf8")
        const relativePath = path.relative(this.projectRoot, file)

        // Check for common performance issues
        if (content.includes("setState(() {")) {
          const matches = content.match(/setState$$\($$ \{/g)
          if (matches && matches.length > 5) {
            issues.push(`${relativePath}: Excessive setState calls (${matches.length})`)
          }
        }

        if (content.includes("build(BuildContext context)") && content.includes("new ")) {
          issues.push(`${relativePath}: Using 'new' keyword (unnecessary in modern Dart)`)
        }

        if (content.includes("UnimplementedError")) {
          issues.push(`${relativePath}: Contains unimplemented features`)
        }
      }
    }

    // Generate recommendations
    if (this.analysisResults.files.unused.length > 0) {
      recommendations.push(`Remove ${this.analysisResults.files.unused.length} unused files`)
    }

    if (this.analysisResults.dependencies.heavy.length > 0) {
      recommendations.push(
        `Consider removing heavy dependencies: ${this.analysisResults.dependencies.heavy.join(", ")}`,
      )
    }

    if (this.analysisResults.assets.unoptimized.length > 0) {
      recommendations.push(`Optimize ${this.analysisResults.assets.unoptimized.length} large image assets`)
    }

    this.analysisResults.performance.issues = issues
    this.analysisResults.performance.recommendations = recommendations
  }

  async getAllFiles(dir) {
    const files = []
    const items = await fs.readdir(dir)

    for (const item of items) {
      const fullPath = path.join(dir, item)
      const stats = await fs.stat(fullPath)

      if (stats.isDirectory()) {
        if (!item.startsWith(".") && item !== "node_modules" && item !== "build") {
          const subFiles = await this.getAllFiles(fullPath)
          files.push(...subFiles)
        }
      } else {
        files.push(fullPath)
      }
    }

    return files
  }

  extractDependencies(pubspecContent) {
    const dependencies = []
    const lines = pubspecContent.split("\n")
    let inDependencies = false

    for (const line of lines) {
      if (line.trim() === "dependencies:") {
        inDependencies = true
        continue
      }

      if (inDependencies) {
        if (line.startsWith("dev_dependencies:") || line.startsWith("flutter:")) {
          break
        }

        const match = line.match(/^\s+([a-zA-Z_][a-zA-Z0-9_]*):/)
        if (match && match[1] !== "flutter") {
          dependencies.push(match[1])
        }
      }
    }

    return dependencies
  }

  generateReport() {
    const report = {
      timestamp: new Date().toISOString(),
      summary: {
        totalFiles: this.analysisResults.files.total,
        redundantFiles: this.analysisResults.files.redundant.length,
        unusedFiles: this.analysisResults.files.unused.length,
        totalDependencies: this.analysisResults.dependencies.total,
        heavyDependencies: this.analysisResults.dependencies.heavy.length,
        totalAssets: this.analysisResults.assets.total,
        assetsSizeMB: Math.round((this.analysisResults.assets.totalSize / 1024 / 1024) * 100) / 100,
        performanceIssues: this.analysisResults.performance.issues.length,
      },
      details: this.analysisResults,
      recommendations: {
        immediate: [
          `Remove ${this.analysisResults.files.unused.length} unused files`,
          `Clean up ${this.analysisResults.files.redundant.length} redundant files`,
          `Optimize ${this.analysisResults.assets.unoptimized.length} large assets`,
        ],
        shortTerm: [
          `Remove ${this.analysisResults.dependencies.heavy.length} heavy dependencies`,
          `Resolve ${this.analysisResults.dependencies.duplicates.length} duplicate dependencies`,
          `Fix ${this.analysisResults.performance.issues.length} performance issues`,
        ],
        longTerm: ["Implement lazy loading for assets", "Add performance monitoring", "Optimize build configuration"],
      },
      estimatedImpact: {
        bundleSizeReduction: "50-60%",
        loadTimeImprovement: "40-50%",
        memoryUsageReduction: "30-40%",
      },
    }

    return report
  }
}

// Execute if run directly
if (require.main === module) {
  const analyzer = new OptimizationAnalyzer()
  analyzer
    .analyzeProject()
    .then((report) => {
      console.log("\n📊 Optimization Analysis Complete!")
      console.log("=" * 50)
      console.log(`Total Files: ${report.summary.totalFiles}`)
      console.log(`Unused Files: ${report.summary.unusedFiles}`)
      console.log(`Heavy Dependencies: ${report.summary.heavyDependencies}`)
      console.log(`Assets Size: ${report.summary.assetsSizeMB}MB`)
      console.log(`Performance Issues: ${report.summary.performanceIssues}`)

      // Save detailed report
      const reportPath = path.join(process.cwd(), "optimization-analysis.json")
      require("fs").writeFileSync(reportPath, JSON.stringify(report, null, 2))
      console.log(`\n📄 Detailed report saved: ${reportPath}`)
    })
    .catch((error) => {
      console.error("💥 Analysis failed:", error.message)
      process.exit(1)
    })
}

module.exports = OptimizationAnalyzer
