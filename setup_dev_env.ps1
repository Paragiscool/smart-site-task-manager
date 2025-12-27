Write-Host ">>> STARTING SMART SITE ENVIRONMENT SETUP <<<" -ForegroundColor Cyan

# 1. Install Java JDK 17 (Required for Android)
Write-Host "1. Installing Java JDK 17..." -ForegroundColor Yellow
winget install Microsoft.OpenJDK.17 --accept-source-agreements --accept-package-agreements

# 2. Install Flutter SDK
Write-Host "2. Installing Flutter SDK..." -ForegroundColor Yellow
winget install Google.Flutter --accept-source-agreements --accept-package-agreements

# 3. Install Android Studio
Write-Host "3. Installing Android Studio..." -ForegroundColor Yellow
winget install Google.AndroidStudio --accept-source-agreements --accept-package-agreements

# 4. Refresh Environment Variables
Write-Host ">>> INSTALLATION COMPLETE <<<" -ForegroundColor Green
Write-Host "PLEASE NOTE:" -ForegroundColor White
Write-Host "1. You MUST close this terminal and open a NEW one for the 'flutter' command to work."
Write-Host "2. Open 'Android Studio' from your Start Menu to install the Android SDK and Emulator."
Write-Host "3. Read 'INSTALLATION_GUIDE.md' for the final configuration steps."
