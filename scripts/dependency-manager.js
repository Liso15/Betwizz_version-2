const fs = require("fs-extra")
const path = require("path")
const { execSync } = require("child_process")

class DependencyManager {
  constructor(projectRoot = process.cwd()) {
    this.projectRoot = projectRoot
    this.pubspecPath = path.join(projectRoot, "pubspec.yaml")
    this.pubspecLockPath = path.join(projectRoot, "pubspec.lock")
    this.packageJsonPath = path.join(projectRoot, "package.json")
  }

  async validatePubspec() {
    console.log("📋 Validating pubspec.yaml...")

    if (!(await fs.pathExists(this.pubspecPath))) {
      throw new Error("pubspec.yaml not found")
    }

    const pubspecContent = await fs.readFile(this.pubspecPath, "utf8")

    // Basic validation
    if (!pubspecContent.includes("name:")) {
      throw new Error("Invalid pubspec.yaml: missing name field")
    }

    if (!pubspecContent.includes("flutter:")) {
      throw new Error("Invalid pubspec.yaml: missing flutter section")
    }

    console.log("✅ pubspec.yaml validation passed")
  }

  async installFlutterDependencies() {
    console.log("📦 Installing Flutter dependencies...")

    try {
      // Clean previous installations
      if (await fs.pathExists(path.join(this.projectRoot, ".dart_tool"))) {
        await fs.remove(path.join(this.projectRoot, ".dart_tool"))
      }

      // Run flutter pub get
      execSync("flutter pub get", {
        cwd: this.projectRoot,
        stdio: "inherit",
        env: { ...process.env, PUB_CACHE: "/opt/flutter/.pub-cache" },
      })

      // Verify pubspec.lock was created
      if (!(await fs.pathExists(this.pubspecLockPath))) {
        throw new Error("pubspec.lock was not generated")
      }

      console.log("✅ Flutter dependencies installed successfully")
    } catch (error) {
      console.error("❌ Flutter dependency installation failed:", error.message)
      throw error
    }
  }

  async installNodeDependencies() {
    console.log("📦 Installing Node.js dependencies...")

    if (!(await fs.pathExists(this.packageJsonPath))) {
      console.log("ℹ️ No package.json found, skipping Node dependencies")
      return
    }

    try {
      execSync("npm ci --only=dev", {
        cwd: this.projectRoot,
        stdio: "inherit",
      })

      console.log("✅ Node.js dependencies installed successfully")
    } catch (error) {
      console.error("❌ Node.js dependency installation failed:", error.message)
      throw error
    }
  }

  async auditDependencies() {
    console.log("🔍 Auditing dependencies...")

    const auditResults = {
      flutter: { packages: 0, vulnerabilities: 0 },
      node: { packages: 0, vulnerabilities: 0 },
    }

    // Audit Flutter dependencies
    try {
      const pubDepsOutput = execSync("flutter pub deps --json", {
        cwd: this.projectRoot,
        encoding: "utf8",
      })

      const pubDeps = JSON.parse(pubDepsOutput)
      auditResults.flutter.packages = Object.keys(pubDeps.packages || {}).length
    } catch (error) {
      console.warn("⚠️ Flutter dependency audit failed:", error.message)
    }

    // Audit Node dependencies
    if (await fs.pathExists(this.packageJsonPath)) {
      try {
        const npmAuditOutput = execSync("npm audit --json", {
          cwd: this.projectRoot,
          encoding: "utf8",
        })

        const npmAudit = JSON.parse(npmAuditOutput)
        auditResults.node.packages = npmAudit.metadata?.totalDependencies || 0
        auditResults.node.vulnerabilities = npmAudit.metadata?.vulnerabilities?.total || 0
      } catch (error) {
        console.warn("⚠️ Node.js dependency audit failed:", error.message)
      }
    }

    console.log("📊 Dependency Audit Results:")
    console.log(`  Flutter: ${auditResults.flutter.packages} packages`)
    console.log(`  Node.js: ${auditResults.node.packages} packages`)

    if (auditResults.node.vulnerabilities > 0) {
      console.warn(`⚠️ Found ${auditResults.node.vulnerabilities} Node.js vulnerabilities`)
    }

    return auditResults
  }

  async manageDependencies() {
    console.log("🔧 Starting dependency management...")

    await this.validatePubspec()
    await this.installFlutterDependencies()
    await this.installNodeDependencies()
    const auditResults = await this.auditDependencies()

    console.log("✅ Dependency management completed successfully")
    return auditResults
  }
}

// Execute if run directly
if (require.main === module) {
  const manager = new DependencyManager()
  manager.manageDependencies().catch((error) => {
    console.error("💥 Dependency management failed:", error)
    process.exit(1)
  })
}

module.exports = DependencyManager
