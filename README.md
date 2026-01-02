# Summer

Hardware temperature and fan speed monitor for Apple Silicon Macs.

## Features

- Real-time CPU temperature monitoring
- GPU temperature tracking  
- Battery, Enclosure, Wi-Fi, Storage sensors
- Fan speed display
- Native ARM64 performance
- Optimized for M1/M2/M3/M4

## Requirements

- macOS 13.0+
- Apple Silicon Mac (M1/M2/M3/M4)
- Xcode 15+

## Installation

1. Clone repository
2. Open `Summer.xcodeproj`
3. Select your Team in Signing & Capabilities
4. Build (⌘B) and Run (⌘R)

## First Launch

On first launch, Summer will request permission to install a helper:

1. Click "Install" when prompted
2. Enter your administrator password
3. Helper installs `~/Library/LaunchDaemons/com.brunocastello.Summer.plist`
4. Sensors appear automatically

The helper authorizes the SMC binary to run with elevated privileges, allowing hardware sensor access.

## How It Works

- **Build**: Compiles ARM64 SMC binary from source
- **Launch Daemon**: Authorizes SMC binary to access sensors
- **Sensors**: Reads temperature and fan data via SMC
- **UI**: SwiftUI displays real-time hardware stats

## License

- App code: MIT
- SMC binary: GPL v2 (from smcFanControl project)

## Credits & License

This project interfaces with Apple's System Management Controller using a binary tool based on the original `smc` utility.

* **SMC Tool**: Original implementation by **devnull** (2006).
* **Contributions**: Portions Copyright (C) 2013 **Michael Wilber**.
* **License**: This component is licensed under the **GNU General Public License (GPL) version 2** or later. 

Special thanks to the open-source community and the authors of [smcFanControl](https://github.com/hholtmann/smcFanControl) for maintaining and distributing these tools over the years.
