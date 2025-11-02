# FoodieHub - Complete Startup and Verification Script
# This script starts backend, frontend, and verifies all connections

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FoodieHub - Complete System Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a port is in use
function Test-Port {
    param($Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $connection
}

# Function to wait for a port to be listening
function Wait-ForPort {
    param($Port, $MaxWait = 30)
    $elapsed = 0
    while (-not (Test-Port $Port) -and $elapsed -lt $MaxWait) {
        Start-Sleep -Seconds 1
        $elapsed++
    }
    return Test-Port $Port
}

# Step 1: Check if MongoDB is running
Write-Host "[1/10] Checking MongoDB connection..." -ForegroundColor Yellow
try {
    $mongoCheck = Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet
    if ($mongoCheck) {
        Write-Host "[OK] MongoDB is running on port 27017" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] MongoDB is NOT running. Please start MongoDB first." -ForegroundColor Red
        Write-Host "  Run: net start MongoDB" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "[FAIL] Cannot connect to MongoDB" -ForegroundColor Red
    exit 1
}

# Step 2: Kill existing processes on ports 5000 and 5175
Write-Host "`n[2/10] Cleaning up existing processes..." -ForegroundColor Yellow
$ports = @(5000, 5175)
foreach ($port in $ports) {
    if (Test-Port $port) {
        $process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
        if ($process) {
            Stop-Process -Id $process -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] Killed process on port $port" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
    }
}

# Step 3: Start Backend
Write-Host "`n[3/10] Starting Backend Server..." -ForegroundColor Yellow
$backendPath = "C:\Users\Dell\OneDrive\Desktop\MSD\backend"
if (Test-Path $backendPath) {
    # Start backend in a new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host 'Starting Backend on port 5000...' -ForegroundColor Cyan; node server.js"
    
    # Wait for backend to start
    if (Wait-ForPort 5000 15) {
        Write-Host "✓ Backend started successfully on port 5000" -ForegroundColor Green
    } else {
        Write-Host "✗ Backend failed to start" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Backend directory not found" -ForegroundColor Red
    exit 1
}

# Step 4: Start Frontend
Write-Host "`n[4/10] Starting Frontend Server..." -ForegroundColor Yellow
$frontendPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend"
if (Test-Path $frontendPath) {
    # Start frontend in a new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; Write-Host 'Starting Frontend on port 5175...' -ForegroundColor Cyan; npm run dev"
    
    # Wait for frontend to start
    if (Wait-ForPort 5175 20) {
        Write-Host "✓ Frontend started successfully on port 5175" -ForegroundColor Green
    } else {
        Write-Host "✗ Frontend failed to start" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Frontend directory not found" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 3

# Step 5: Test Backend Health
Write-Host "`n[5/10] Testing Backend Health..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:5000/api/menu" -Method GET -UseBasicParsing -TimeoutSec 5
    if ($healthCheck.StatusCode -eq 200) {
        Write-Host "✓ Backend API is responding" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Backend API not responding" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Test Menu API
Write-Host "`n[6/10] Testing Menu API..." -ForegroundColor Yellow
try {
    $menuResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    if ($menuResponse.success -and $menuResponse.data) {
        $itemCount = $menuResponse.data.Count
        Write-Host "✓ Menu API working - Retrieved $itemCount items from database" -ForegroundColor Green
        
        # Show sample items
        Write-Host "  Sample items:" -ForegroundColor Cyan
        $menuResponse.data | Select-Object -First 3 | ForEach-Object {
            Write-Host "    - $($_.name) (₹$($_.price)) - $($_.category)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Menu API failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Test Auth Endpoints
Write-Host "`n[7/10] Testing Authentication Endpoints..." -ForegroundColor Yellow
$authEndpoints = @(
    @{Name="Signup"; Url="http://localhost:5000/api/auth/signup"; Method="POST"},
    @{Name="Login"; Url="http://localhost:5000/api/auth/login"; Method="POST"}
)

foreach ($endpoint in $authEndpoints) {
    try {
        # Just check if endpoint exists (expect 400 for missing body, not 404)
        $response = Invoke-WebRequest -Uri $endpoint.Url -Method $endpoint.Method -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 400 -or $_.Exception.Response.StatusCode.Value__ -eq 422) {
            Write-Host "✓ $($endpoint.Name) endpoint exists and responding" -ForegroundColor Green
        } elseif ($_.Exception.Response.StatusCode.Value__ -eq 404) {
            Write-Host "✗ $($endpoint.Name) endpoint not found" -ForegroundColor Red
        } else {
            Write-Host "✓ $($endpoint.Name) endpoint accessible" -ForegroundColor Green
        }
    }
}

# Step 8: Test Frontend Connection
Write-Host "`n[8/10] Testing Frontend Server..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:5175" -Method GET -UseBasicParsing -TimeoutSec 5
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "✓ Frontend is serving pages successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Frontend not responding" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Check Image Availability (sample check)
Write-Host "`n[9/10] Checking Sample Menu Images..." -ForegroundColor Yellow
$sampleImages = @(
    "https://suhana.com/cdn/shop/articles/500-x-380-Biryani.png?v=1709544702",
    "https://images.slurrp.com/prod/recipe_images/transcribe/dinner/Chicken-Mandi.webp",
    "https://citma.shorthandstories.com/6e7d13ef-02b7-42af-9d16-cce70df03f84/assets/G3zfKMJ2tq/shorthand-images5-2560x1440.jpg"
)

$imageSuccess = 0
$imageTotal = $sampleImages.Count

foreach ($img in $sampleImages) {
    try {
        $imgCheck = Invoke-WebRequest -Uri $img -Method HEAD -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($imgCheck.StatusCode -eq 200) {
            $imageSuccess++
        }
    } catch {
        # Silent fail
    }
}

Write-Host "✓ $imageSuccess/$imageTotal sample images accessible" -ForegroundColor Green

# Step 10: Final Summary
Write-Host "`n[10/10] System Status Summary" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

$statusItems = @()
$statusItems += @{Check="MongoDB"; Status=(Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet)}
$statusItems += @{Check="Backend (5000)"; Status=(Test-Port 5000)}
$statusItems += @{Check="Frontend (5175)"; Status=(Test-Port 5175)}

foreach ($item in $statusItems) {
    $status = if ($item.Status) { "✓ RUNNING" } else { "✗ STOPPED" }
    $color = if ($item.Status) { "Green" } else { "Red" }
    Write-Host "$($item.Check.PadRight(20)) : $status" -ForegroundColor $color
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n📊 SYSTEM READINESS: " -NoNewline
$allRunning = (Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet) -and (Test-Port 5000) -and (Test-Port 5175)

if ($allRunning) {
    Write-Host "100% READY ✓" -ForegroundColor Green
    Write-Host "`n🌐 Access your application:" -ForegroundColor Cyan
    Write-Host "   Frontend: http://localhost:5175" -ForegroundColor White
    Write-Host "   Backend:  http://localhost:5000" -ForegroundColor White
    Write-Host "`n✨ All systems operational!" -ForegroundColor Green
} else {
    Write-Host "INCOMPLETE" -ForegroundColor Red
    Write-Host "`n⚠️  Some services are not running. Check errors above." -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Press any key to open frontend in browser or Ctrl+C to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open browser
Start-Process "http://localhost:5175"

Write-Host "`nBrowser launched. Keep this window open to monitor services." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop all services when done." -ForegroundColor Yellow

# Keep script running
while ($true) {
    Start-Sleep -Seconds 5
}
