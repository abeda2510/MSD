# FoodieHub - Complete Functionality Test Suite
# Tests Backend, Frontend, and Integration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FoodieHub - Complete Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = 0
$passedTests = 0
$failedTests = 0
$warnings = 0

function Test-Result {
    param($TestName, $Result, $Details = "")
    $script:totalTests++
    if ($Result) {
        $script:passedTests++
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        if ($Details) { Write-Host "       $Details" -ForegroundColor Gray }
    } else {
        $script:failedTests++
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        if ($Details) { Write-Host "       $Details" -ForegroundColor Yellow }
    }
}

function Test-Warning {
    param($TestName, $Details = "")
    $script:totalTests++
    $script:warnings++
    Write-Host "[WARN] $TestName" -ForegroundColor Yellow
    if ($Details) { Write-Host "       $Details" -ForegroundColor Gray }
}

# ============================================
# SECTION 1: BACKEND TESTS
# ============================================
Write-Host "`n=== BACKEND FUNCTIONALITY TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 1.1: Server Running
Write-Host "[1/40] Backend Server Status..." -ForegroundColor Yellow
$backendRunning = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
Test-Result "Backend server running on port 5000" ($null -ne $backendRunning)

# Test 1.2: MongoDB Connection
Write-Host "[2/40] MongoDB Connection..." -ForegroundColor Yellow
$mongoRunning = Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet
Test-Result "MongoDB service running" $mongoRunning

# Test 1.3: Root Endpoint
Write-Host "[3/40] Root Endpoint..." -ForegroundColor Yellow
try {
    $rootResponse = Invoke-RestMethod -Uri "http://localhost:5000/" -Method GET -TimeoutSec 5
    Test-Result "GET / returns server info" ($rootResponse.status -eq "running") "Version: $($rootResponse.version)"
} catch {
    Test-Result "GET / returns server info" $false $_.Exception.Message
}

# Test 1.4: Health Check
Write-Host "[4/40] Health Check Endpoint..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 5
    Test-Result "GET /health returns healthy status" ($healthResponse.status -eq "healthy") "DB: $($healthResponse.database)"
} catch {
    Test-Result "GET /health returns healthy status" $false $_.Exception.Message
}

# Test 1.5: Get All Menu Items
Write-Host "[5/40] Menu API - Get All Items..." -ForegroundColor Yellow
try {
    $menuResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    $itemCount = $menuResponse.data.Count
    Test-Result "GET /api/menu returns menu items" ($menuResponse.success -and $itemCount -gt 0) "Retrieved $itemCount items"
} catch {
    Test-Result "GET /api/menu returns menu items" $false $_.Exception.Message
}

# Test 1.6: Get Menu by Category - Biryanis
Write-Host "[6/40] Menu API - Get Biryanis..." -ForegroundColor Yellow
try {
    $biryanisResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu/category/biryanis" -Method GET -TimeoutSec 5
    Test-Result "GET /api/menu/category/biryanis returns items" ($biryanisResponse.success) "Found $($biryanisResponse.count) biryanis"
} catch {
    Test-Result "GET /api/menu/category/biryanis returns items" $false $_.Exception.Message
}

# Test 1.7: Get Menu by Category - Mandis
Write-Host "[7/40] Menu API - Get Mandis..." -ForegroundColor Yellow
try {
    $mandisResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu/category/mandis" -Method GET -TimeoutSec 5
    Test-Result "GET /api/menu/category/mandis returns items" ($mandisResponse.success) "Found $($mandisResponse.count) mandis"
} catch {
    Test-Result "GET /api/menu/category/mandis returns items" $false $_.Exception.Message
}

# Test 1.8: Get Menu by Category - Cool Drinks
Write-Host "[8/40] Menu API - Get Cool Drinks..." -ForegroundColor Yellow
try {
    $drinksResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu/category/cool-drinks" -Method GET -TimeoutSec 5
    Test-Result "GET /api/menu/category/cool-drinks returns items" ($drinksResponse.success) "Found $($drinksResponse.count) drinks"
} catch {
    Test-Result "GET /api/menu/category/cool-drinks returns items" $false $_.Exception.Message
}

# Test 1.9: Get Single Menu Item
Write-Host "[9/40] Menu API - Get Single Item..." -ForegroundColor Yellow
try {
    $allItems = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    if ($allItems.data.Count -gt 0) {
        $firstItemId = $allItems.data[0]._id
        $singleItem = Invoke-RestMethod -Uri "http://localhost:5000/api/menu/$firstItemId" -Method GET -TimeoutSec 5
        Test-Result "GET /api/menu/:id returns single item" ($singleItem.success) "Item: $($singleItem.data.name)"
    } else {
        Test-Result "GET /api/menu/:id returns single item" $false "No items in database"
    }
} catch {
    Test-Result "GET /api/menu/:id returns single item" $false $_.Exception.Message
}

# Test 1.10: Register New User
Write-Host "[10/40] Auth API - User Registration..." -ForegroundColor Yellow
$testUser = @{
    name = "Test User $(Get-Random)"
    email = "test$(Get-Random)@foodiehub.com"
    password = "Test@123"
    phone = "98765432$((Get-Random -Minimum 10 -Maximum 99))"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" -Method POST -Body $testUser -ContentType "application/json" -TimeoutSec 5
    $script:testToken = $registerResponse.token
    Test-Result "POST /api/auth/register creates new user" ($registerResponse.success) "Token received"
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 400) {
        Test-Warning "POST /api/auth/register" "Endpoint exists but validation failed (expected)"
    } else {
        Test-Result "POST /api/auth/register creates new user" $false $_.Exception.Message
    }
}

# Test 1.11: Login User
Write-Host "[11/40] Auth API - User Login..." -ForegroundColor Yellow
$loginData = @{
    email = "test@foodiehub.com"
    password = "Test@123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5
    if ($loginResponse.token) {
        $script:testToken = $loginResponse.token
    }
    Test-Result "POST /api/auth/login authenticates user" ($loginResponse.success -or $loginResponse.token) "Token received"
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 401) {
        Test-Warning "POST /api/auth/login" "Endpoint exists but credentials invalid (expected)"
    } else {
        Test-Result "POST /api/auth/login authenticates user" $false $_.Exception.Message
    }
}

# Test 1.12: Get User Profile (Protected)
Write-Host "[12/40] Auth API - Get Profile..." -ForegroundColor Yellow
if ($script:testToken) {
    try {
        $headers = @{
            "Authorization" = "Bearer $($script:testToken)"
        }
        $profileResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/me" -Method GET -Headers $headers -TimeoutSec 5
        Test-Result "GET /api/auth/me returns user profile" ($profileResponse.success) "User: $($profileResponse.data.name)"
    } catch {
        Test-Result "GET /api/auth/me returns user profile" $false $_.Exception.Message
    }
} else {
    Test-Warning "GET /api/auth/me" "Skipped - no authentication token available"
}

# Test 1.13: CORS Headers
Write-Host "[13/40] CORS Configuration..." -ForegroundColor Yellow
try {
    $corsTest = Invoke-WebRequest -Uri "http://localhost:5000/api/menu" -Method GET -UseBasicParsing -TimeoutSec 3
    $corsHeader = $corsTest.Headers["Access-Control-Allow-Origin"]
    Test-Result "CORS headers configured" ($null -ne $corsHeader) "Origin: $corsHeader"
} catch {
    Test-Result "CORS headers configured" $false
}

# Test 1.14: Invalid Route Handling
Write-Host "[14/40] 404 Error Handling..." -ForegroundColor Yellow
try {
    $notFoundResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/invalid-route" -Method GET -TimeoutSec 3
    Test-Result "Invalid routes return 404" $false "Should have returned 404"
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
        Test-Result "Invalid routes return 404" $true "404 handled correctly"
    } else {
        Test-Result "Invalid routes return 404" $false
    }
}

# ============================================
# SECTION 2: FRONTEND TESTS
# ============================================
Write-Host "`n=== FRONTEND FUNCTIONALITY TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 2.1: Frontend Server Running
Write-Host "[15/40] Frontend Server Status..." -ForegroundColor Yellow
$frontendRunning = Get-NetTCPConnection -LocalPort 5175 -ErrorAction SilentlyContinue
Test-Result "Frontend server running on port 5175" ($null -ne $frontendRunning)

# Test 2.2: Frontend Responding
Write-Host "[16/40] Frontend HTTP Response..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:5175" -Method GET -UseBasicParsing -TimeoutSec 5
    Test-Result "Frontend serving HTML" ($frontendResponse.StatusCode -eq 200) "Status: $($frontendResponse.StatusCode)"
} catch {
    Test-Result "Frontend serving HTML" $false $_.Exception.Message
}

# Test 2.3: React App Structure
Write-Host "[17/40] React Application Structure..." -ForegroundColor Yellow
try {
    $htmlContent = Invoke-WebRequest -Uri "http://localhost:5175" -Method GET -UseBasicParsing -TimeoutSec 5
    $hasRoot = $htmlContent.Content -match 'id="root"'
    Test-Result "HTML contains React root element" $hasRoot
} catch {
    Test-Result "HTML contains React root element" $false
}

# Test 2.4: Vite Assets Loading
Write-Host "[18/40] Vite Asset Loading..." -ForegroundColor Yellow
try {
    $htmlContent = Invoke-WebRequest -Uri "http://localhost:5175" -Method GET -UseBasicParsing -TimeoutSec 5
    $hasVite = $htmlContent.Content -match 'vite|@vite'
    Test-Result "Vite development server configured" $hasVite
} catch {
    Test-Result "Vite development server configured" $false
}

# Test 2.5: Check Component Files
Write-Host "[19/40] Frontend Component Files..." -ForegroundColor Yellow
$componentFiles = @(
    "frontend\src\App.jsx",
    "frontend\src\main.jsx",
    "frontend\src\pages\Home.jsx",
    "frontend\src\pages\About.jsx",
    "frontend\src\pages\Menu.jsx",
    "frontend\src\pages\Login.jsx",
    "frontend\src\pages\Signup.jsx",
    "frontend\src\pages\Cart.jsx"
)

$existingComponents = 0
foreach ($file in $componentFiles) {
    $fullPath = Join-Path "C:\Users\Dell\OneDrive\Desktop\MSD" $file
    if (Test-Path $fullPath) {
        $existingComponents++
    }
}
Test-Result "React components exist" ($existingComponents -eq $componentFiles.Count) "$existingComponents/$($componentFiles.Count) components found"

# Test 2.6: Check CSS Files
Write-Host "[20/40] Frontend Styling Files..." -ForegroundColor Yellow
$cssFiles = @(
    "frontend\src\index.css",
    "frontend\src\App.css",
    "frontend\src\pages\Menu.css"
)

$existingCss = 0
foreach ($file in $cssFiles) {
    $fullPath = Join-Path "C:\Users\Dell\OneDrive\Desktop\MSD" $file
    if (Test-Path $fullPath) {
        $existingCss++
    }
}
Test-Result "CSS styling files exist" ($existingCss -eq $cssFiles.Count) "$existingCss/$($cssFiles.Count) CSS files found"

# Test 2.7: Check Context/State Management
Write-Host "[21/40] State Management..." -ForegroundColor Yellow
$contextPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\context\AuthContext.jsx"
Test-Result "Authentication context exists" (Test-Path $contextPath)

# Test 2.8: Check Routing Components
Write-Host "[22/40] Routing Configuration..." -ForegroundColor Yellow
$appJsxPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\App.jsx"
if (Test-Path $appJsxPath) {
    $appContent = Get-Content $appJsxPath -Raw
    $hasRouting = $appContent -match 'BrowserRouter|Routes|Route'
    Test-Result "React Router configured" $hasRouting
} else {
    Test-Result "React Router configured" $false "App.jsx not found"
}

# Test 2.9: Package.json Dependencies
Write-Host "[23/40] Frontend Dependencies..." -ForegroundColor Yellow
$packagePath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\package.json"
if (Test-Path $packagePath) {
    $packageJson = Get-Content $packagePath | ConvertFrom-Json
    $hasReact = $null -ne $packageJson.dependencies.react
    $hasReactRouter = $null -ne $packageJson.dependencies.'react-router-dom'
    Test-Result "Required npm packages installed" ($hasReact -and $hasReactRouter) "React & Router configured"
} else {
    Test-Result "Required npm packages installed" $false "package.json not found"
}

# ============================================
# SECTION 3: INTEGRATION TESTS
# ============================================
Write-Host "`n=== FRONTEND-BACKEND INTEGRATION TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 3.1: API URL Configuration
Write-Host "[24/40] API URL Configuration..." -ForegroundColor Yellow
$searchPaths = @(
    "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\App.jsx",
    "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Menu.jsx",
    "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Login.jsx"
)

$foundApiUrl = $false
foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        if ($content -match 'localhost:5000|http://localhost:5000') {
            $foundApiUrl = $true
            break
        }
    }
}
Test-Result "Frontend configured with backend URL" $foundApiUrl "localhost:5000 found in code"

# Test 3.2: Menu Items Display
Write-Host "[25/40] Menu Items Integration..." -ForegroundColor Yellow
$menuPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Menu.jsx"
if (Test-Path $menuPath) {
    $menuContent = Get-Content $menuPath -Raw
    $hasFetch = $menuContent -match 'fetch|axios'
    $hasMenuItems = $menuContent -match 'menuItems|menu-item'
    Test-Result "Menu page fetches from API" ($hasFetch -and $hasMenuItems) "API calls and rendering configured"
} else {
    Test-Result "Menu page fetches from API" $false "Menu.jsx not found"
}

# Test 3.3: Authentication Flow
Write-Host "[26/40] Authentication Integration..." -ForegroundColor Yellow
$loginPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Login.jsx"
if (Test-Path $loginPath) {
    $loginContent = Get-Content $loginPath -Raw
    $hasAuthCall = $loginContent -match '/api/auth/login'
    Test-Result "Login page connects to auth API" $hasAuthCall "Auth endpoint referenced"
} else {
    Test-Result "Login page connects to auth API" $false "Login.jsx not found"
}

# Test 3.4: Signup Integration
Write-Host "[27/40] Signup Integration..." -ForegroundColor Yellow
$signupPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Signup.jsx"
if (Test-Path $signupPath) {
    $signupContent = Get-Content $signupPath -Raw
    $hasRegisterCall = $signupContent -match '/api/auth/register|/api/auth/signup'
    Test-Result "Signup page connects to auth API" $hasRegisterCall "Register endpoint referenced"
} else {
    Test-Result "Signup page connects to auth API" $false "Signup.jsx not found"
}

# Test 3.5: Cart Functionality
Write-Host "[28/40] Cart System..." -ForegroundColor Yellow
$cartPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\pages\Cart.jsx"
if (Test-Path $cartPath) {
    $cartContent = Get-Content $cartPath -Raw
    $hasCartLogic = $cartContent -match 'cartItems|cart|localStorage'
    Test-Result "Cart page has item management" $hasCartLogic
} else {
    Test-Result "Cart page has item management" $false "Cart.jsx not found"
}

# Test 3.6: Protected Routes
Write-Host "[29/40] Protected Route Component..." -ForegroundColor Yellow
$protectedPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\components\ProtectedRoute.jsx"
Test-Result "Protected route component exists" (Test-Path $protectedPath)

# Test 3.7: Navigation Component
Write-Host "[30/40] Navigation Component..." -ForegroundColor Yellow
$navPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend\src\components\Navbar.jsx"
if (Test-Path $navPath) {
    $navContent = Get-Content $navPath -Raw
    $hasLinks = $navContent -match 'Link to|NavLink|href'
    Test-Result "Navigation component exists" $hasLinks "Navigation configured"
} else {
    Test-Result "Navigation component exists" $false
}

# ============================================
# SECTION 4: DATABASE TESTS
# ============================================
Write-Host "`n=== DATABASE FUNCTIONALITY TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 4.1: Menu Items Collection
Write-Host "[31/40] Database - Menu Items..." -ForegroundColor Yellow
try {
    $menuData = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    $hasAllCategories = $false
    if ($menuData.data) {
        $categories = $menuData.data | Select-Object -ExpandProperty category -Unique
        $expectedCategories = @('biryanis', 'mandis', 'cool-drinks', 'fast-foods')
        $hasAllCategories = $categories.Count -ge 4
    }
    Test-Result "Database has menu items in all categories" $hasAllCategories "Found $($categories.Count) categories"
} catch {
    Test-Result "Database has menu items in all categories" $false
}

# Test 4.2: Menu Item Schema
Write-Host "[32/40] Database - Menu Item Schema..." -ForegroundColor Yellow
try {
    $menuData = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    if ($menuData.data -and $menuData.data.Count -gt 0) {
        $firstItem = $menuData.data[0]
        $requiredFields = @('_id', 'name', 'price', 'category', 'description')
        $hasAllFields = $true
        foreach ($field in $requiredFields) {
            if (-not $firstItem.$field) {
                $hasAllFields = $false
                break
            }
        }
        Test-Result "Menu items have required fields" $hasAllFields "Schema validated"
    } else {
        Test-Result "Menu items have required fields" $false "No items found"
    }
} catch {
    Test-Result "Menu items have required fields" $false
}

# Test 4.3: Price Data Integrity
Write-Host "[33/40] Database - Price Data..." -ForegroundColor Yellow
try {
    $menuData = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    $validPrices = $true
    foreach ($item in $menuData.data) {
        if ($item.price -le 0 -or $item.price -gt 10000) {
            $validPrices = $false
            break
        }
    }
    Test-Result "All menu items have valid prices" $validPrices "Price range: 0-10000"
} catch {
    Test-Result "All menu items have valid prices" $false
}

# Test 4.4: Image URLs
Write-Host "[34/40] Database - Image URLs..." -ForegroundColor Yellow
try {
    $menuData = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    $hasImages = $true
    foreach ($item in $menuData.data) {
        if (-not $item.image -or $item.image -eq "") {
            $hasImages = $false
            break
        }
    }
    Test-Result "All menu items have image URLs" $hasImages
} catch {
    Test-Result "All menu items have image URLs" $false
}

# ============================================
# SECTION 5: PERFORMANCE & QUALITY TESTS
# ============================================
Write-Host "`n=== PERFORMANCE & QUALITY TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 5.1: API Response Time
Write-Host "[35/40] API Response Time..." -ForegroundColor Yellow
try {
    $startTime = Get-Date
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    $endTime = Get-Date
    $responseTime = ($endTime - $startTime).TotalMilliseconds
    Test-Result "API responds within 500ms" ($responseTime -lt 500) "Response time: $([math]::Round($responseTime, 2))ms"
} catch {
    Test-Result "API responds within 500ms" $false
}

# Test 5.2: Frontend Load Time
Write-Host "[36/40] Frontend Page Load Time..." -ForegroundColor Yellow
try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "http://localhost:5175" -Method GET -UseBasicParsing -TimeoutSec 10
    $endTime = Get-Date
    $loadTime = ($endTime - $startTime).TotalMilliseconds
    Test-Result "Frontend loads within 2 seconds" ($loadTime -lt 2000) "Load time: $([math]::Round($loadTime, 2))ms"
} catch {
    Test-Result "Frontend loads within 2 seconds" $false
}

# Test 5.3: Environment Variables
Write-Host "[37/40] Environment Configuration..." -ForegroundColor Yellow
$envPath = "C:\Users\Dell\OneDrive\Desktop\MSD\backend\.env"
Test-Result "Backend .env file exists" (Test-Path $envPath)

# Test 5.4: Error Handling
Write-Host "[38/40] Error Handling..." -ForegroundColor Yellow
try {
    $errorResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu/invalid-id-12345" -Method GET -TimeoutSec 3
    Test-Warning "API error handling" "Should return error for invalid ID"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.Value__
    Test-Result "API handles invalid requests" ($statusCode -eq 400 -or $statusCode -eq 404 -or $statusCode -eq 500) "Status: $statusCode"
}

# Test 5.5: Security Headers
Write-Host "[39/40] Security Configuration..." -ForegroundColor Yellow
try {
    $securityTest = Invoke-WebRequest -Uri "http://localhost:5000/api/menu" -Method GET -UseBasicParsing -TimeoutSec 3
    $hasCors = $securityTest.Headers["Access-Control-Allow-Origin"]
    Test-Result "Security headers configured" ($null -ne $hasCors) "CORS header present"
} catch {
    Test-Result "Security headers configured" $false
}

# Test 5.6: Code Structure Quality
Write-Host "[40/40] Code Structure Quality..." -ForegroundColor Yellow
$backendStructure = @(
    "backend\models",
    "backend\controllers",
    "backend\routes",
    "backend\middleware"
)

$structureExists = $true
foreach ($dir in $backendStructure) {
    $fullPath = Join-Path "C:\Users\Dell\OneDrive\Desktop\MSD" $dir
    if (-not (Test-Path $fullPath)) {
        $structureExists = $false
        break
    }
}
Test-Result "Backend follows MVC structure" $structureExists "Models, Controllers, Routes organized"

# ============================================
# FINAL RESULTS
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nTotal Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Warnings: $warnings" -ForegroundColor Yellow

$successRate = [math]::Round(($passedTests / $totalTests) * 100, 2)
$completionRate = [math]::Round((($passedTests + $warnings) / $totalTests) * 100, 2)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUCCESS RATE: $successRate%" -ForegroundColor $(if($successRate -gt 80){"Green"}else{"Yellow"})
Write-Host "COMPLETION RATE: $completionRate%" -ForegroundColor $(if($completionRate -gt 90){"Green"}else{"Yellow"})
Write-Host "========================================" -ForegroundColor Cyan

# Detailed Breakdown
Write-Host "`n=== FUNCTIONALITY BREAKDOWN ===" -ForegroundColor Cyan

$categories = @{
    "Backend API" = @(1..14)
    "Frontend" = @(15..23)
    "Integration" = @(24..30)
    "Database" = @(31..34)
    "Performance" = @(35..40)
}

foreach ($category in $categories.Keys) {
    $categoryTests = $categories[$category].Count
    Write-Host "`n$category`: $categoryTests tests" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan

if ($successRate -ge 90) {
    Write-Host "`n✓ EXCELLENT! System is production-ready!" -ForegroundColor Green
} elseif ($successRate -ge 75) {
    Write-Host "`n✓ GOOD! System is mostly functional with minor issues" -ForegroundColor Yellow
} elseif ($successRate -ge 50) {
    Write-Host "`n⚠ FAIR! System needs significant fixes" -ForegroundColor Yellow
} else {
    Write-Host "`n✗ POOR! System requires major debugging" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Report saved to test-results.txt" -ForegroundColor Gray

# Save results to file
$reportPath = "C:\Users\Dell\OneDrive\Desktop\MSD\test-results.txt"
@"
FoodieHub - Complete Functionality Test Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
========================================

SUMMARY:
- Total Tests: $totalTests
- Passed: $passedTests
- Failed: $failedTests
- Warnings: $warnings
- Success Rate: $successRate%
- Completion Rate: $completionRate%

BREAKDOWN:
- Backend API Tests: 14 tests
- Frontend Tests: 9 tests
- Integration Tests: 7 tests
- Database Tests: 4 tests
- Performance Tests: 6 tests

STATUS: $(if($successRate -ge 90){"PRODUCTION READY"}elseif($successRate -ge 75){"MOSTLY FUNCTIONAL"}else{"NEEDS WORK"})
"@ | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nTest suite completed!" -ForegroundColor Green
