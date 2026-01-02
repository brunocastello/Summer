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
        
        let launchDaemonsDir = NSHomeDirectory() + "/Library/LaunchDaemons"
        let plistPath = launchDaemonsDir + "/com.brunocastello.Summer.plist"
        
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.brunocastello.Summer</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(smcPath)</string>
            </array>
            <key>RunAtLoad</key>
            <false/>
            <key>KeepAlive</key>
            <false/>
        </dict>
        </plist>
        """
        
        let script = """
        #!/bin/bash
        set -e
        mkdir -p "\(launchDaemonsDir)"
        cat > "\(plistPath)" << 'PLIST_END'
        \(plistContent)
        PLIST_END
        chmod 644 "\(plistPath)"
        """
        
        let tempDir = NSTemporaryDirectory()
        let scriptPath = (tempDir as NSString).appendingPathComponent("install-summer-helper.sh")
        
        // 1. Escreve o script temporário
        try script.write(toFile: scriptPath, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
        
        // 2. Preparar o comando AppleScript para pedir privilégios
        let appleScriptCommand = "do shell script \"'\(scriptPath)'\" with administrator privileges"
        
        // 3. EXCUÇÃO VIA PROCESS (Para matar o Purple Warning)
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
            // Limpa o script temporário sempre
            try? FileManager.default.removeItem(atPath: scriptPath)
        }
    }
    
    static func shouldRedeploy() -> Bool {
        let plistPath = NSHomeDirectory() + "/Library/LaunchDaemons/com.brunocastello.Summer.plist"
        
        // Se não existe, com certeza precisa instalar
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: plistPath)),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let arguments = plist["ProgramArguments"] as? [String],
              let installedSmcPath = arguments.first else {
            return true
        }
        
        // O ponto crítico: O caminho do binário no disco mudou?
        // (Ex: Usuário moveu o app de Downloads para Applications)
        guard let currentSmcPath = Bundle.main.path(forResource: "smc", ofType: nil) else { return false }
        
        return installedSmcPath != currentSmcPath
    }
}
