//
//  HelperInstaller.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import Foundation

class HelperInstaller {
    
    static func isInstalled() -> Bool {
        let plistPath = NSHomeDirectory() + "/Library/LaunchDaemons/com.brunocastello.Summer.plist"
        return FileManager.default.fileExists(atPath: plistPath)
    }
    
    static func install() throws {
        guard let smcPath = Bundle.main.path(forResource: "smc", ofType: nil) else {
            throw NSError(domain: "HelperInstaller", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "SMC binary not found in bundle"
            ])
        }
        
        guard let plistPath = Bundle.main.path(forResource: "com.brunocastello.Summer", ofType: "plist", inDirectory: "Resources/LaunchDaemons") else {
            throw NSError(domain: "HelperInstaller", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "LaunchDaemon plist not found in bundle"
            ])
        }
        
        guard var plistContent = try? String(contentsOfFile: plistPath, encoding: .utf8) else {
            throw NSError(domain: "HelperInstaller", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Could not read plist file"
            ])
        }
        
        plistContent = plistContent.replacingOccurrences(
            of: "chmod +x ~/Library/Application\\ Support/Summer/smc",
            with: "chmod +x \(smcPath)"
        )
        
        let launchDaemonsDir = NSHomeDirectory() + "/Library/LaunchDaemons"
        let destPlistPath = launchDaemonsDir + "/com.brunocastello.Summer.plist"
        
        let script = """
        #!/bin/bash
        set -e
        mkdir -p "\(launchDaemonsDir)"
        cat > "\(destPlistPath)" << 'PLIST_END'
        \(plistContent)
        PLIST_END
        chmod 644 "\(destPlistPath)"
        """
        
        let tempDir = NSTemporaryDirectory()
        let scriptPath = (tempDir as NSString).appendingPathComponent("install-summer-helper.sh")
        
        try script.write(toFile: scriptPath, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
        
        let appleScriptCommand = "do shell script \"'\(scriptPath)'\" with administrator privileges"
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", appleScriptCommand]
        
        let errorPipe = Pipe()
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "HelperInstaller", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            print("✅ Helper instalado com sucesso via Process")
        } catch {
            throw error
        }; do {
            try? FileManager.default.removeItem(atPath: scriptPath)
        }
    }
    
    static func shouldRedeploy() -> Bool {
        let plistPath = NSHomeDirectory() + "/Library/LaunchDaemons/com.brunocastello.Summer.plist"
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: plistPath)),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let arguments = plist["ProgramArguments"] as? [String],
              let installedSmcPath = arguments.first else {
            return true
        }

        guard let currentSmcPath = Bundle.main.path(forResource: "smc", ofType: nil) else { return false }
        
        return installedSmcPath != currentSmcPath
    }
}
