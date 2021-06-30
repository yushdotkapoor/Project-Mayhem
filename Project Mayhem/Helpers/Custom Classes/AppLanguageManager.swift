//
//  AppLanguageManager.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 6/29/21.
//

import Foundation


final class AppLanguageManager {
    static let shared = AppLanguageManager()

    private(set) var currentLanguage: String
    private(set) var currentBundle: Bundle = Bundle.main
    var bundle: Bundle {
        return currentBundle
    }

    private init() {
        if let appLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            currentLanguage = appLanguage
        } else {
            currentLanguage = Locale.current.languageCode!
        }
    }

    func setAppLanguage(_ languageCode: String) {
        setCurrentLanguage(languageCode)
        setCurrentBundlePath(languageCode)
    }

    func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.setValue(languageCode,
                                       forKey: "AppLanguage")
    }

    func setCurrentBundlePath(_ languageCode: String) {
       
        let file = getLocalizationFile(code: languageCode)
        print("beluga get local file \(file)")
        
        guard let langBundle = Bundle(path: file) else {
            print("NO BELUGA NOT WERKIN")
            currentBundle = Bundle.main
            return
        }
        currentBundle = langBundle
    }
    
    func getLocalizationFile(code: String) -> String {
        let fileManager = FileManager.default
        let path = (getDirectoryPath() as NSString).appendingPathComponent("\(code)-fire.lproj")
        print("Pathfinder \(path)")
        var isDirectory:ObjCBool = true
        if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
            return path
        } else{
            print("No Folder Exists")
            return ""
        }
    }
}
