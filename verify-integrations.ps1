# 🧪 Integration Verification Script
# Tests all 4 integration points

Write-Host "`n==============================================`n" -ForegroundColor Cyan
Write-Host "   INTEGRATION VERIFICATION TEST   " -ForegroundColor Yellow
Write-Host "`n==============================================`n" -ForegroundColor Cyan

$results = @()
$passed = 0
$failed = 0

# Test 1: Backend Health Check
Write-Host "[1/4] Testing Backend Connection..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/health" -TimeoutSec 5
    if ($response.status -eq "healthy") {
        Write-Host "✅ Backend is running and healthy" -ForegroundColor Green
        $results += "✅ Backend Health: PASS"
        $passed++
    } else {
        Write-Host "❌ Backend unhealthy" -ForegroundColor Red
        $results += "❌ Backend Health: FAIL"
        $failed++
    }
} catch {
    Write-Host "❌ Backend not responding" -ForegroundColor Red
    $results += "❌ Backend Health: FAIL - Not responding"
    $failed++
}

# Test 2: Menu API Integration
Write-Host "`n[2/4] Testing Menu API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -TimeoutSec 5
    if ($response.success -and $response.data.Count -gt 0) {
        $itemCount = $response.data.Count
        Write-Host "✅ Menu API working - $itemCount items loaded" -ForegroundColor Green
        $results += "✅ Menu API: PASS - $itemCount items"
        $passed++
    } else {
        Write-Host "❌ Menu API not returning data" -ForegroundColor Red
        $results += "❌ Menu API: FAIL"
        $failed++
    }
} catch {
    Write-Host "❌ Menu API not responding" -ForegroundColor Red
    $results += "❌ Menu API: FAIL - Not responding"
    $failed++
}

# Test 3: Login API Endpoint
Write-Host "`n[3/4] Testing Login API Endpoint..." -ForegroundColor Yellow
try {
    # Test with invalid credentials (should return error but endpoint should work)
    $body = @{
        email = "test@test.com"
        password = "wrongpassword"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 5 `
        -ErrorAction SilentlyContinue
    
    # If we get here, endpoint is working (even if login fails)
    Write-Host "✅ Login API endpoint is responding" -ForegroundColor Green
    $results += "✅ Login API: PASS - Endpoint functional"
    $passed++
} catch {
    # Check if it's a 401 error (which means endpoint is working, just auth failed)
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Login API endpoint is responding (auth validation working)" -ForegroundColor Green
        $results += "✅ Login API: PASS - Endpoint functional"
        $passed++
    } else {
        Write-Host "❌ Login API not responding" -ForegroundColor Red
        $results += "❌ Login API: FAIL - Not responding"
        $failed++
    }
}

# Test 4: Signup API Endpoint
Write-Host "`n[4/4] Testing Signup API Endpoint..." -ForegroundColor Yellow
try {
    # Test with incomplete data (should return error but endpoint should work)
    $body = @{
        email = "test@test.com"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 5 `
        -ErrorAction SilentlyContinue
    
    Write-Host "✅ Signup API endpoint is responding" -ForegroundColor Green
    $results += "✅ Signup API: PASS - Endpoint functional"
    $passed++
} catch {
    # Check if it's a validation error (which means endpoint is working)
    if ($_.Exception.Response.StatusCode -eq 400 -or $_.Exception.Response.StatusCode -eq 422) {
        Write-Host "✅ Signup API endpoint is responding (validation working)" -ForegroundColor Green
        $results += "✅ Signup API: PASS - Endpoint functional"
        $passed++
    } else {
        Write-Host "❌ Signup API not responding" -ForegroundColor Red
        $results += "❌ Signup API: FAIL - Not responding"
        $failed++
    }
}

# Summary
Write-Host "`n==============================================`n" -ForegroundColor Cyan
Write-Host "          TEST SUMMARY          " -ForegroundColor Yellow
Write-Host "`n==============================================`n" -ForegroundColor Cyan

foreach ($result in $results) {
    Write-Host $result
}

Write-Host "`n----------------------------------------------" -ForegroundColor Cyan
$total = $passed + $failed
$percentage = [math]::Round(($passed / $total) * 100, 1)

Write-Host "`nTotal Tests: $total" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "Success Rate: $percentage%" -ForegroundColor $(if ($percentage -eq 100) { "Green" } else { "Yellow" })

Write-Host "`n----------------------------------------------`n" -ForegroundColor Cyan

# Frontend Check
Write-Host "Frontend Status:" -ForegroundColor Yellow
try {
    $frontendPorts = Get-NetTCPConnection -LocalPort 5173,5174,5175 -State Listen -ErrorAction SilentlyContinue
    if ($frontendPorts) {
        $port = $frontendPorts[0].LocalPort
        Write-Host "✅ Frontend running on port $port" -ForegroundColor Green
        Write-Host "   URL: http://localhost:$port" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Frontend not running" -ForegroundColor Yellow
        Write-Host "   Run: cd frontend; npm run dev" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Could not detect frontend" -ForegroundColor Yellow
}

Write-Host "`n==============================================`n" -ForegroundColor Cyan

if ($percentage -eq 100) {
    Write-Host "🎉 ALL INTEGRATIONS VERIFIED! 🎉" -ForegroundColor Green
    Write-Host "`nYour application is ready for:" -ForegroundColor White
    Write-Host "  1. End-to-end user testing" -ForegroundColor Cyan
    Write-Host "  2. Production build (npm run build)" -ForegroundColor Cyan
    Write-Host "  3. Deployment to hosting platform" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Some tests failed. Please check errors above." -ForegroundColor Yellow
}

Write-Host "`n==============================================`n" -ForegroundColor Cyan
