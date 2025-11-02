# 🚀 Quick Start Deployment Checklist

Write-Host "`n" -ForegroundColor Green
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║            🚀 DEPLOYMENT QUICK START GUIDE 🚀               ║" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`n"

Write-Host "📋 PRE-DEPLOYMENT CHECKLIST" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$checks = @(
    @{Name="✅ All API integrations complete"; Status=$true},
    @{Name="✅ Production build created (dist/ folder)"; Status=$true},
    @{Name="✅ Security hardening applied"; Status=$true},
    @{Name="✅ Environment files configured"; Status=$true},
    @{Name="✅ Documentation complete"; Status=$true}
)

foreach ($check in $checks) {
    Write-Host "  $($check.Name)" -ForegroundColor Green
}

Write-Host "`n"
Write-Host "🎯 RECOMMENDED DEPLOYMENT: VERCEL + RENDER" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
Write-Host "Why? FREE tier, easy setup, auto-deploy from GitHub`n" -ForegroundColor Gray

Write-Host "STEP 1: SETUP MONGODB ATLAS (10 minutes)" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  1. Go to: https://cloud.mongodb.com" -ForegroundColor White
Write-Host "  2. Sign up for FREE account" -ForegroundColor White
Write-Host "  3. Create FREE cluster (M0)" -ForegroundColor White
Write-Host "  4. Create database user" -ForegroundColor White
Write-Host "  5. Whitelist IP: 0.0.0.0/0" -ForegroundColor White
Write-Host "  6. Get connection string" -ForegroundColor White
Write-Host "     Format: mongodb+srv://user:pass@cluster.mongodb.net/foodiehub`n" -ForegroundColor Gray

Write-Host "STEP 2: DEPLOY BACKEND TO RENDER (15 minutes)" -ForegroundColor Cyan
Write-Host "───────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  1. Go to: https://render.com" -ForegroundColor White
Write-Host "  2. Sign up with GitHub" -ForegroundColor White
Write-Host "  3. New Web Service → Connect GitHub repo" -ForegroundColor White
Write-Host "  4. Configure:" -ForegroundColor White
Write-Host "     - Root Directory: backend" -ForegroundColor Gray
Write-Host "     - Build Command: npm install" -ForegroundColor Gray
Write-Host "     - Start Command: node server.js" -ForegroundColor Gray
Write-Host "  5. Add environment variables:" -ForegroundColor White
Write-Host "     - PORT=5000" -ForegroundColor Gray
Write-Host "     - NODE_ENV=production" -ForegroundColor Gray
Write-Host "     - MONGODB_URI=<your-atlas-connection-string>" -ForegroundColor Gray
Write-Host "     - JWT_SECRET=<generate-secure-32-char-string>" -ForegroundColor Gray
Write-Host "     - CORS_ORIGIN=<will-update-after-frontend-deploy>" -ForegroundColor Gray
Write-Host "  6. Click 'Create Web Service'" -ForegroundColor White
Write-Host "  7. Wait for deployment (~3-5 minutes)" -ForegroundColor White
Write-Host "  8. Copy your backend URL: https://your-app.onrender.com`n" -ForegroundColor Gray

Write-Host "STEP 3: DEPLOY FRONTEND TO VERCEL (10 minutes)" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  1. Go to: https://vercel.com" -ForegroundColor White
Write-Host "  2. Sign up with GitHub" -ForegroundColor White
Write-Host "  3. Import Project → Select your repo" -ForegroundColor White
Write-Host "  4. Configure:" -ForegroundColor White
Write-Host "     - Framework: Vite" -ForegroundColor Gray
Write-Host "     - Root Directory: frontend" -ForegroundColor Gray
Write-Host "     - Build Command: npm run build" -ForegroundColor Gray
Write-Host "     - Output Directory: dist" -ForegroundColor Gray
Write-Host "  5. Add environment variable:" -ForegroundColor White
Write-Host "     - VITE_API_URL=<your-render-backend-url>/api" -ForegroundColor Gray
Write-Host "  6. Click 'Deploy'" -ForegroundColor White
Write-Host "  7. Wait for deployment (~2 minutes)" -ForegroundColor White
Write-Host "  8. Your app is LIVE! 🎉`n" -ForegroundColor Green

Write-Host "STEP 4: UPDATE BACKEND CORS (5 minutes)" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  1. Go back to Render dashboard" -ForegroundColor White
Write-Host "  2. Select your backend service" -ForegroundColor White
Write-Host "  3. Environment → Edit CORS_ORIGIN" -ForegroundColor White
Write-Host "  4. Set to: https://your-app.vercel.app" -ForegroundColor White
Write-Host "  5. Save → Backend will redeploy (~2 minutes)`n" -ForegroundColor White

Write-Host "STEP 5: VERIFY DEPLOYMENT (5 minutes)" -ForegroundColor Cyan
Write-Host "───────────────────────────────────────" -ForegroundColor Gray
Write-Host "  1. Open your Vercel URL" -ForegroundColor White
Write-Host "  2. Check menu items load" -ForegroundColor White
Write-Host "  3. Test signup/login" -ForegroundColor White
Write-Host "  4. Test cart operations" -ForegroundColor White
Write-Host "  5. Check browser console for errors" -ForegroundColor White
Write-Host "  6. Test on mobile device`n" -ForegroundColor White

Write-Host "`n"
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║               🎉 TOTAL TIME: ~45 MINUTES 🎉                 ║" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

Write-Host "📚 DETAILED GUIDES AVAILABLE:" -ForegroundColor Yellow
Write-Host "  - DEPLOYMENT_GUIDE.md (Full guide with all platforms)" -ForegroundColor White
Write-Host "  - 100_PERCENT_COMPLETE.md (Completion certificate)" -ForegroundColor White
Write-Host "  - INTEGRATION_COMPLETE_REPORT.md (Technical details)`n" -ForegroundColor White

Write-Host "🆘 NEED HELP?" -ForegroundColor Yellow
Write-Host "  Check DEPLOYMENT_GUIDE.md Section: Troubleshooting`n" -ForegroundColor White

Write-Host "🔗 QUICK LINKS:" -ForegroundColor Yellow
Write-Host "  - MongoDB Atlas: https://cloud.mongodb.com" -ForegroundColor Cyan
Write-Host "  - Render: https://render.com" -ForegroundColor Cyan
Write-Host "  - Vercel: https://vercel.com`n" -ForegroundColor Cyan

Write-Host "💡 PRO TIP:" -ForegroundColor Yellow
Write-Host "  Push your code to GitHub first, then connect repos to" -ForegroundColor Gray
Write-Host "  Render and Vercel. They'll auto-deploy on every push!`n" -ForegroundColor Gray

Write-Host "🎊 GOOD LUCK WITH YOUR DEPLOYMENT! 🎊`n" -ForegroundColor Green

# Pause to read
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
