# Comprehensive Installation Guide for Smart Site Task Manager

To develop and run the full stack (Mobile App + Backend) on Windows, you need the following tools installed.

## 1. Core Development Tools (Automatable)
These can be installed via command line (I have provided a script `setup_dev_env.ps1`).

*   **Flutter SDK**: The framework for the mobile app.
*   **Java JDK 17**: Required for building Android apps.
*   **Git**: For version control (likely already installed).
*   **Android Studio**: The IDE that provides the **Android Emulator** and SDK tools.

## 2. Manual Post-Installation Steps (Crucial)
After the tools are installed, you **MUST** perform these manual steps because they require clicking through UI wizards:

### A. Setup Android Studio
1.  Open **Android Studio** from your Start Menu.
2.  Follow the **Setup Wizard**.
3.  **Important**: Ensure **"Android SDK"** and **"Android Virtual Device"** are checked during setup.
4.  Once open, go to **More Actions > Virtual Device Manager**.
5.  Create a new device (e.g., Pixel 6) and download the system image (click the 'Download' arrow next to the recommended Release Name).
6.  Press **Play** to launch the Emulator.

### B. Configure Flutter
1.  Open a new PowerShell terminal (Run as Administrator).
2.  Run: `flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"`
3.  Run: `flutter doctor --android-licenses` (Type 'y' to accept all).
4.  Run: `flutter doctor` to confirm everything is green.

## 3. Verify
Once steps 1 and 2 are done, you can run the app:
```powershell
cd frontend
flutter pub get
flutter run
```
