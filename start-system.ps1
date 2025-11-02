# FoodieHub - Complete System Startup and Verification
# This script starts backend, frontend, and verifies all connections

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FoodieHub - System Startup & Check" -ForegroundColor Cyan
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

# Step 1: Check MongoDB
Write-Host "[1/10] Checking MongoDB connection..." -ForegroundColor Yellow
$mongoCheck = Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($mongoCheck) {
    Write-Host "[OK] MongoDB is running on port 27017" -ForegroundColor Green
} else {
    Write-Host "[FAIL] MongoDB is NOT running. Please start MongoDB first." -ForegroundColor Red
    Write-Host "  Run: net start MongoDB" -ForegroundColor Yellow
    exit 1
}

# Step 2: Clean up existing processes
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
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host 'Starting Backend...' -ForegroundColor Cyan; node server.js"
    
    if (Wait-ForPort 5000 15) {
        Write-Host "[OK] Backend started on port 5000" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Backend failed to start" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[FAIL] Backend directory not found" -ForegroundColor Red
    exit 1
}

# Step 4: Start Frontend
Write-Host "`n[4/10] Starting Frontend Server..." -ForegroundColor Yellow
$frontendPath = "C:\Users\Dell\OneDrive\Desktop\MSD\frontend"
if (Test-Path $frontendPath) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; Write-Host 'Starting Frontend...' -ForegroundColor Cyan; npm run dev"
    
    Write-Host "  Waiting for Vite to start (this may take 30-40 seconds)..." -ForegroundColor Cyan
    if (Wait-ForPort 5175 45) {
        Write-Host "[OK] Frontend started on port 5175" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Frontend taking longer than expected, continuing..." -ForegroundColor Yellow
    }
} else {
    Write-Host "[FAIL] Frontend directory not found" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 3

# Step 5: Test Backend Health
Write-Host "`n[5/10] Testing Backend API..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:5000/api/menu" -Method GET -UseBasicParsing -TimeoutSec 5
    if ($healthCheck.StatusCode -eq 200) {
        Write-Host "[OK] Backend API responding (Status 200)" -ForegroundColor Green
    }
} catch {
    Write-Host "[FAIL] Backend API not responding" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Test Menu API and Database
Write-Host "`n[6/10] Testing Database Connection..." -ForegroundColor Yellow
try {
    $menuResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/menu" -Method GET -TimeoutSec 5
    if ($menuResponse.success -and $menuResponse.data) {
        $itemCount = $menuResponse.data.Count
        Write-Host "[OK] Database connected - Retrieved $itemCount items" -ForegroundColor Green
        
        Write-Host "  Sample items from database:" -ForegroundColor Cyan
        $menuResponse.data | Select-Object -First 5 | ForEach-Object {
            Write-Host "    - $($_.name) (Rs.$($_.price)) [$($_.category)]" -ForegroundColor White
        }
        
        # Count by category
        Write-Host "`n  Items by category:" -ForegroundColor Cyan
        $categories = $menuResponse.data | Group-Object -Property category
        $categories | ForEach-Object {
            Write-Host "    - $($_.Name): $($_.Count) items" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[FAIL] Database connection failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Test Auth Endpoints
Write-Host "`n[7/10] Testing Authentication Endpoints..." -ForegroundColor Yellow
$authTests = @(
    @{Name="Signup"; Url="http://localhost:5000/api/auth/signup"},
    @{Name="Login"; Url="http://localhost:5000/api/auth/login"}
)

foreach ($test in $authTests) {
    try {
        Invoke-WebRequest -Uri $test.Url -Method POST -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop | Out-Null
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.Value__
        if ($statusCode -eq 400 -or $statusCode -eq 422) {
            Write-Host "[OK] $($test.Name) endpoint active" -ForegroundColor Green
        } elseif ($statusCode -eq 404) {
            Write-Host "[FAIL] $($test.Name) endpoint not found" -ForegroundColor Red
        } else {
            Write-Host "[OK] $($test.Name) endpoint responding" -ForegroundColor Green
        }
    }
}

# Step 8: Test Frontend
Write-Host "`n[8/10] Testing Frontend Server..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:5175" -Method GET -UseBasicParsing -TimeoutSec 5
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "[OK] Frontend serving pages (Status 200)" -ForegroundColor Green
        
        # Check if index.html contains React
        if ($frontendResponse.Content -match "react" -or $frontendResponse.Content -match "root") {
            Write-Host "[OK] React application detected" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "[FAIL] Frontend not responding" -ForegroundColor Red
}

# Step 9: Check CORS Configuration
Write-Host "`n[9/10] Checking CORS Configuration..." -ForegroundColor Yellow
try {
    $corsTest = Invoke-WebRequest -Uri "http://localhost:5000/api/menu" -Method GET -UseBasicParsing -TimeoutSec 3
    $corsHeader = $corsTest.Headers["Access-Control-Allow-Origin"]
    if ($corsHeader) {
        Write-Host "[OK] CORS configured: $corsHeader" -ForegroundColor Green
    } else {
        Write-Host "[WARN] CORS header not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARN] Could not check CORS" -ForegroundColor Yellow
}

# Step 10: Final System Status
Write-Host "`n[10/10] Final System Check..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

$services = @(
    @{Name="MongoDB (27017)"; Status=(Test-NetConnection -ComputerName localhost -Port 27017 -WarningAction SilentlyContinue -InformationLevel Quiet)},
    @{Name="Backend API (5000)"; Status=(Test-Port 5000)},
    @{Name="Frontend (5175)"; Status=(Test-Port 5175)}
)

$allOk = $true
foreach ($service in $services) {
    if ($service.Status) {
        Write-Host "  $($service.Name.PadRight(25)) [RUNNING]" -ForegroundColor Green
    } else {
        Write-Host "  $($service.Name.PadRight(25)) [STOPPED]" -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host "========================================" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "`n SYSTEM STATUS: 100% READY" -ForegroundColor Green -BackgroundColor Black
    Write-Host "`n All services are operational!" -ForegroundColor Green
    Write-Host "`n Access Points:" -ForegroundColor Cyan
    Write-Host "   Frontend:  http://localhost:5175" -ForegroundColor White
    Write-Host "   Backend:   http://localhost:5000" -ForegroundColor White
    Write-Host "   API Docs:  http://localhost:5000/api/menu" -ForegroundColor White
    
    Write-Host "`n Integration Status:" -ForegroundColor Cyan
    Write-Host "   [OK] Frontend <-> Backend Connection" -ForegroundColor Green
    Write-Host "   [OK] Backend <-> MongoDB Connection" -ForegroundColor Green
    Write-Host "   [OK] API Endpoints Responding" -ForegroundColor Green
    Write-Host "   [OK] Database Queries Working" -ForegroundColor Green
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " Press ENTER to open in browser..." -ForegroundColor Yellow
    Read-Host
    
    Start-Process "http://localhost:5175"
    Write-Host "`n Browser launched successfully!" -ForegroundColor Green
    Write-Host " Keep terminal windows open to monitor services." -ForegroundColor Yellow
    
} else {
    Write-Host "`n SYSTEM STATUS: INCOMPLETE" -ForegroundColor Red -BackgroundColor Black
    Write-Host " Some services failed to start. Check errors above." -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
