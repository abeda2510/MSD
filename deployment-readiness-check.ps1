# Deployment Readiness Check Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT READINESS CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$readyCount = 0
$notReadyCount = 0
$warningCount = 0

function Check-Ready {
    param($Item, $Status, $Details = "")
    if ($Status) {
        $script:readyCount++
        Write-Host "[READY] $Item" -ForegroundColor Green
        if ($Details) { Write-Host "        $Details" -ForegroundColor Gray }
    } else {
        $script:notReadyCount++
        Write-Host "[NOT READY] $Item" -ForegroundColor Red
        if ($Details) { Write-Host "            $Details" -ForegroundColor Yellow }
    }
}

function Check-Warning {
    param($Item, $Details = "")
    $script:warningCount++
    Write-Host "[WARNING] $Item" -ForegroundColor Yellow
    if ($Details) { Write-Host "          $Details" -ForegroundColor Gray }
}

# 1. SERVER STATUS
Write-Host "`n=== SERVER STATUS ===" -ForegroundColor Cyan
$backend = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
Check-Ready "Backend server running" ($null -ne $backend) "Port 5000"

$frontend = Get-NetTCPConnection -LocalPort 5175 -ErrorAction SilentlyContinue
Check-Ready "Frontend server running" ($null -ne $frontend) "Port 5175"

$mongo = Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet
Check-Ready "MongoDB service running" $mongo "Port 27017"

# 2. API HEALTH
Write-Host "`n=== API HEALTH ===" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5000/health" -TimeoutSec 3
    Check-Ready "Backend API responding" ($health.status -eq "healthy") "Status: $($health.status)"
} catch {
    Check-Ready "Backend API responding" $false "Cannot connect"
}

try {
    $menu = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -TimeoutSec 3
    Check-Ready "Menu API working" ($menu.success) "$($menu.count) items"
} catch {
    Check-Ready "Menu API working" $false "Cannot fetch menu"
}

# 3. ENVIRONMENT CONFIGURATION
Write-Host "`n=== ENVIRONMENT CONFIGURATION ===" -ForegroundColor Cyan
$envPath = "C:\Users\Dell\OneDrive\Desktop\MSD\backend\.env"
Check-Ready "Backend .env file exists" (Test-Path $envPath)

if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    Check-Ready ".env has MONGODB_URI" ($envContent -match "MONGODB_URI")
    Check-Ready ".env has JWT_SECRET" ($envContent -match "JWT_SECRET")
    Check-Ready ".env has PORT" ($envContent -match "PORT")
}

# 4. PRODUCTION BUILD
Write-Host "`n=== PRODUCTION BUILD ===" -ForegroundColor Cyan
$distPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\dist"
if (Test-Path $distPath) {
    Check-Ready "Frontend production build exists" $true "dist folder found"
} else {
    Check-Ready "Frontend production build exists" $false "Need to run: npm run build"
}

# 5. PACKAGE.JSON
Write-Host "`n=== DEPENDENCIES ===" -ForegroundColor Cyan
$backendPackage = "C:\Users\Dell\OneDrive\Desktop\MSD\backend\package.json"
Check-Ready "Backend package.json exists" (Test-Path $backendPackage)

$frontendPackage = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\package.json"
Check-Ready "Frontend package.json exists" (Test-Path $frontendPackage)

$nodeModules = "C:\Users\Dell\OneDrive\Desktop\MSD\backend\node_modules"
Check-Ready "Backend dependencies installed" (Test-Path $nodeModules)

$frontendModules = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\node_modules"
Check-Ready "Frontend dependencies installed" (Test-Path $frontendModules)

# 6. SECURITY
Write-Host "`n=== SECURITY CHECKS ===" -ForegroundColor Cyan
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    if ($envContent -match "JWT_SECRET=.*[a-zA-Z0-9]{32,}") {
        Check-Ready "JWT secret is strong" $true "32+ characters"
    } else {
        Check-Warning "JWT secret strength" "Should be 32+ random characters"
    }
}

$gitignorePath = "C:\Users\Dell\OneDrive\Desktop\MSD\backend\.gitignore"
if (Test-Path $gitignorePath) {
    $gitignore = Get-Content $gitignorePath -Raw
    Check-Ready ".env in .gitignore" ($gitignore -match "\.env")
} else {
    Check-Ready ".gitignore exists" $false "Create to protect secrets"
}

# 7. DATABASE
Write-Host "`n=== DATABASE ===" -ForegroundColor Cyan
try {
    $menu = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -TimeoutSec 3
    $itemCount = $menu.data.Count
    if ($itemCount -gt 0) {
        Check-Ready "Database has menu items" $true "$itemCount items"
    } else {
        Check-Ready "Database has menu items" $false "Database is empty"
    }
} catch {
    Check-Ready "Database connection" $false "Cannot verify"
}

# 8. CORS CONFIGURATION
Write-Host "`n=== CORS & SECURITY HEADERS ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/api/menu" -UseBasicParsing -TimeoutSec 3
    $cors = $response.Headers["Access-Control-Allow-Origin"]
    if ($cors -eq "*") {
        Check-Warning "CORS allows all origins" "Change to specific domain in production"
    } else {
        Check-Ready "CORS configured" $true "Origin: $cors"
    }
} catch {
    Check-Ready "CORS configured" $false
}

# 9. ERROR HANDLING
Write-Host "`n=== ERROR HANDLING ===" -ForegroundColor Cyan
try {
    $error = Invoke-WebRequest -Uri "http://localhost:5000/api/invalid-endpoint" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
        Check-Ready "404 error handling" $true "Returns proper 404"
    } else {
        Check-Ready "404 error handling" $false
    }
}

# 10. FRONTEND FILES
Write-Host "`n=== FRONTEND FILES ===" -ForegroundColor Cyan
$requiredPages = @(
    "frontend\src\pages\Home.jsx",
    "frontend\src\pages\About.jsx",
    "frontend\src\pages\Menu.jsx",
    "frontend\src\pages\Login.jsx",
    "frontend\src\pages\Signup.jsx",
    "frontend\src\pages\Cart.jsx"
)

$missingPages = 0
foreach ($page in $requiredPages) {
    $fullPath = Join-Path "C:\Users\Dell\OneDrive\Desktop\MSD" $page
    if (-not (Test-Path $fullPath)) {
        $missingPages++
    }
}
Check-Ready "All frontend pages exist" ($missingPages -eq 0) "$($requiredPages.Count - $missingPages)/$($requiredPages.Count) pages"

# 11. API INTEGRATION
Write-Host "`n=== API INTEGRATION ===" -ForegroundColor Cyan
$menuJsx = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Menu.jsx"
if (Test-Path $menuJsx) {
    $content = Get-Content $menuJsx -Raw
    $hasApiCall = $content -match "fetch|axios|menuAPI"
    if ($hasApiCall) {
        Check-Ready "Menu page has API integration" $true
    } else {
        Check-Ready "Menu page has API integration" $false "Using static data"
    }
}

$loginJsx = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Login.jsx"
if (Test-Path $loginJsx) {
    $content = Get-Content $loginJsx -Raw
    $hasApiCall = $content -match "authAPI\.login|fetch.*auth/login"
    if ($hasApiCall) {
        Check-Ready "Login page has API integration" $true
    } else {
        Check-Ready "Login page has API integration" $false "Not connected to backend"
    }
}

# 12. PRODUCTION CHECKLIST
Write-Host "`n=== PRODUCTION READINESS ITEMS ===" -ForegroundColor Cyan
Check-Warning "Environment variables" "Update for production (DB URL, secrets)"
Check-Warning "API URLs" "Change localhost to production domain"
Check-Warning "CORS origin" "Restrict to production domain only"
Check-Warning "Error logging" "Set up error monitoring (Sentry, etc.)"
Check-Warning "SSL certificate" "Enable HTTPS for production"
Check-Warning "Database backup" "Set up automated backups"
Check-Warning "Rate limiting" "Add API rate limiting"
Check-Warning "Input validation" "Verify all user inputs sanitized"

# FINAL SUMMARY
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT READINESS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalChecks = $readyCount + $notReadyCount
$readyPercent = [math]::Round(($readyCount / $totalChecks) * 100, 1)

Write-Host "`nStatus Breakdown:" -ForegroundColor Yellow
Write-Host "  Ready:       $readyCount" -ForegroundColor Green
Write-Host "  Not Ready:   $notReadyCount" -ForegroundColor Red
Write-Host "  Warnings:    $warningCount" -ForegroundColor Yellow
Write-Host "  Total:       $totalChecks" -ForegroundColor White

Write-Host "`nReadiness Score: $readyPercent%" -ForegroundColor $(if($readyPercent -ge 80){"Green"}else{"Yellow"})

Write-Host "`n========================================" -ForegroundColor Cyan

if ($notReadyCount -eq 0 -and $readyPercent -ge 90) {
    Write-Host "STATUS: READY FOR DEPLOYMENT ✓" -ForegroundColor Green -BackgroundColor Black
    Write-Host "`nYour application is ready for deployment!" -ForegroundColor Green
    Write-Host "Address the warnings for production best practices." -ForegroundColor Yellow
} elseif ($notReadyCount -le 2 -and $readyPercent -ge 80) {
    Write-Host "STATUS: MOSTLY READY ⚠" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "`nYour application is mostly ready." -ForegroundColor Yellow
    Write-Host "Fix the $notReadyCount item(s) marked 'NOT READY' before deployment." -ForegroundColor Yellow
} else {
    Write-Host "STATUS: NOT READY FOR DEPLOYMENT ✗" -ForegroundColor Red -BackgroundColor Black
    Write-Host "`nYour application needs more work before deployment." -ForegroundColor Red
    Write-Host "Fix the $notReadyCount item(s) marked 'NOT READY'." -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan

# Save report
$reportPath = "C:\Users\Dell\OneDrive\Desktop\MSD\deployment-readiness-report.txt"
$status = if($notReadyCount -eq 0 -and $readyPercent -ge 90){"READY FOR DEPLOYMENT"}elseif($notReadyCount -le 2 -and $readyPercent -ge 80){"MOSTLY READY"}else{"NOT READY"}
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$reportContent = "DEPLOYMENT READINESS REPORT`n"
$reportContent += "Generated: $timestamp`n"
$reportContent += "========================================`n`n"
$reportContent += "SUMMARY:`n"
$reportContent += "Ready: $readyCount`n"
$reportContent += "Not Ready: $notReadyCount`n"
$reportContent += "Warnings: $warningCount`n"
$reportContent += "Readiness Score: $readyPercent%`n`n"
$reportContent += "STATUS: $status`n"

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "Report saved to deployment-readiness-report.txt" -ForegroundColor Gray
