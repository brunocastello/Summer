# Summer

Hardware temperature and fan speed monitor for Apple Silicon Macs. Summer is still under development.

## Features

- Real-time CPU temperature monitoring
- GPU temperature tracking  
- Battery, Enclosure, Wi-Fi, Storage sensors
- Fan speed display
- Native Universal (ARM64 and Intel) performance
- Optimized for M1/M2/M3/M4

## Requirements

- macOS 13.0+
- Apple Silicon Mac (M1/M2/M3/M4) or Intel Mac
- Xcode 15+

## Installation

1. Clone repository
2. Open `Summer.xcodeproj`
3. Select your Team in Signing & Capabilities
4. Build (⌘B) and Run (⌘R)

## How It Works

- **Build**: Compiles Universal SMC binary from source
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
