//
//  LocalizationManager.swift
//  FloraList
//
//  Created by User on 6/17/25.
//

import Foundation
import SwiftUI

@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()
    
    private static let languageKey = "FloraListAppLanguage"

    enum SupportedLanguage: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case german = "de"

        var displayName: LocalizedStringResource {
            switch self {
            case .english: return .english
            case .spanish: return .spanish
            case .german: return .german
            }
        }

        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            case .spanish: return "🇪🇸"
            case .german: return "🇩🇪"
            }
        }
        
        var locale: Locale {
            Locale(identifier: rawValue)
        }
    }

    private(set) var currentLanguage: SupportedLanguage

    private init() {
        self.currentLanguage = Self.loadSavedLanguage()
    }
    
    private static func loadSavedLanguage() -> SupportedLanguage {
        if let systemLanguages = UserDefaults.standard.array(forKey: languageKey) as? [String],
           let firstLanguage = systemLanguages.first,
           let language = SupportedLanguage(rawValue: firstLanguage) {
            return language
        }
        
        let systemLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return SupportedLanguage(rawValue: systemLanguageCode) ?? .english
    }

    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        UserDefaults.standard.set([language.rawValue], forKey: Self.languageKey)
    }
}
