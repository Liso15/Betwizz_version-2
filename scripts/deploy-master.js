const DependencyManager = require("./dependency-manager")
const WebBuilder = require("./web-builder")
const AssetOptimizer = require("./asset-optimizer")
const SEOGenerator = require("./seo-generator")
const BuildVerifier = require("./build-verifier")
const path = require("path")

class DeploymentMaster {
  constructor(config = {}) {
    this.config = {
      projectRoot: config.projectRoot || process.cwd(),
      buildDir: config.buildDir || "build/web",
      skipLighthouse: config.skipLighthouse || true,
      ...config,
    }

    this.buildDir = path.join(this.config.projectRoot, this.config.buildDir)
  }

  async executeDeployment() {
    console.log("🚀 Starting comprehensive Flutter web deployment...")
    console.log("=" * 60)

    const startTime = Date.now()
    const deploymentLog = {
      startTime: new Date().toISOString(),
      phases: [],
      errors: [],
      warnings: [],
    }

    try {
      // Phase 1: Environment Setup & Dependencies
      console.log("\n📦 Phase 1: Environment Setup & Dependencies")
      console.log("-" * 40)

      const dependencyManager = new DependencyManager(this.config.projectRoot)
      const depResults = await dependencyManager.manageDependencies()

      deploymentLog.phases.push({
        name: "Dependencies",
        status: "SUCCESS",
        duration: Date.now() - startTime,
        details: depResults,
      })

      // Phase 2: Web Application Build
      console.log("\n🏗️ Phase 2: Web Application Build")
      console.log("-" * 40)

      const phaseStartTime = Date.now()
      const webBuilder = new WebBuilder(this.config.projectRoot)
      const buildResults = await webBuilder.buildWebApplication()

      deploymentLog.phases.push({
        name: "Build",
        status: "SUCCESS",
        duration: Date.now() - phaseStartTime,
        details: buildResults,
      })

      // Phase 3: Asset Optimization
      console.log("\n🎨 Phase 3: Asset Optimization")
      console.log("-" * 40)

      const assetStartTime = Date.now()
      const assetOptimizer = new AssetOptimizer(this.buildDir)
      const optimizationResults = await assetOptimizer.optimizeAssets()

      deploymentLog.phases.push({
        name: "Optimization",
        status: "SUCCESS",
        duration: Date.now() - assetStartTime,
        details: optimizationResults,
      })

      // Phase 4: SEO & PWA Enhancement
      console.log("\n🔍 Phase 4: SEO & PWA Enhancement")
      console.log("-" * 40)

      const seoStartTime = Date.now()
      const seoGenerator = new SEOGenerator(this.buildDir, {
        baseUrl: "https://betwizz.vercel.app",
        siteName: "Betwizz",
        description: "Smart betting companion app with AI chat and receipt scanning",
      })
      const seoResults = await seoGenerator.generateSEOFiles()

      deploymentLog.phases.push({
        name: "SEO",
        status: "SUCCESS",
        duration: Date.now() - seoStartTime,
        details: seoResults,
      })

      // Phase 5: Build Verification
      console.log("\n✅ Phase 5: Build Verification")
      console.log("-" * 40)

      const verificationStartTime = Date.now()
      const buildVerifier = new BuildVerifier(this.buildDir)
      const verificationResults = await buildVerifier.verifyBuild()

      deploymentLog.phases.push({
        name: "Verification",
        status: "SUCCESS",
        duration: Date.now() - verificationStartTime,
        details: verificationResults,
      })
    } catch (error) {
      console.error("❌ Deployment failed:", error)
      deploymentLog.errors.push({
        message: error.message,
        stack: error.stack,
      })
    }

    console.log("\nDeployment Log:", JSON.stringify(deploymentLog, null, 2))
  }
}
