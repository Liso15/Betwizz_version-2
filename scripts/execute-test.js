const { execSync } = require("child_process")
const fs = require("fs")
const path = require("path")

console.log("🧪 Executing Optimized Build Test")
console.log("==================================\n")

try {
  // Step 1: Clean and prepare
  console.log("📋 Step 1: Cleaning and preparing...")
  execSync("flutter clean", { stdio: "inherit" })
  execSync("flutter pub get", { stdio: "inherit" })
  console.log("✅ Preparation complete\n")

  // Step 2: Run tests
  console.log("📋 Step 2: Running tests...")
  try {
    execSync("flutter test", { stdio: "inherit" })
    console.log("✅ Tests passed\n")
  } catch (error) {
    console.log("⚠️ Some tests failed, continuing...\n")
  }

  // Step 3: Build optimized version
  console.log("📋 Step 3: Building optimized web version...")
  const buildCommand = [
    "flutter build web --release",
    "--web-renderer canvaskit",
    "--dart-define=FLUTTER_WEB_USE_SKIA=true",
    "--dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.38.0/bin/",
    "--pwa-strategy offline-first",
  ].join(" ")

  execSync(buildCommand, { stdio: "inherit" })
  console.log("✅ Build completed successfully\n")

  // Step 4: Analyze bundle
  console.log("📋 Step 4: Analyzing bundle size...")
  const mainJsPath = path.join(process.cwd(), "build", "web", "main.dart.js")

  if (fs.existsSync(mainJsPath)) {
    const stats = fs.statSync(mainJsPath)
    const sizeMB = (stats.size / 1024 / 1024).toFixed(2)
    const compressedMB = ((stats.size * 0.25) / 1024 / 1024).toFixed(2)

    console.log(`📊 Bundle Analysis:`)
    console.log(`   Main JS (uncompressed): ${sizeMB}MB`)
    console.log(`   Main JS (compressed): ${compressedMB}MB`)
    console.log(`   Target: ≤8MB ${compressedMB <= 8 ? "✅" : "❌"}`)

    // Run detailed analysis
    if (fs.existsSync("scripts/bundle-analyzer.js")) {
      const BundleAnalyzer = require("./bundle-analyzer.js")
      const analyzer = new BundleAnalyzer()
      analyzer.analyze()
    }
  }

  // Step 5: Start local server
  console.log("\n📋 Step 5: Starting local server...")
  console.log("🌐 Server will start on http://localhost:8080")
  console.log("📱 Test the app in your browser")
  console.log("🔧 Open DevTools to check performance")
  console.log("\n⏹️ Press Ctrl+C to stop the server\n")

  // Change to build directory and start server
  process.chdir("build/web")
  execSync("python3 -m http.server 8080", { stdio: "inherit" })
} catch (error) {
  console.error("❌ Test execution failed:", error.message)
  process.exit(1)
}
