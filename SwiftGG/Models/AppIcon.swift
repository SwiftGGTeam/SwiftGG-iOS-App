import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case `default` = "AppIcon"
    case translationGroup = "TranslationGroup"
    
    var id: String { rawValue }
    
    var name: String? {
        switch self {
        case .default:
            return nil
        case .translationGroup:
            return "TranslationGroup"
        }
    }
    
    var displayName: String {
        switch self {
        case .default:
            return "SwiftGG"
        case .translationGroup:
            return "SwiftGG 翻译组"
        }
    }
    
    var preview: Image {
        // 使用专门的预览图片
        switch self {
        case .default:
            if let previewImage = UIImage(named: "AppIconPreview") {
                return Image(uiImage: previewImage)
            }
        case .translationGroup:
            if let previewImage = UIImage(named: "TranslationGroupPreview") {
                return Image(uiImage: previewImage)
            }
        }
        
        print("Failed to load preview for icon: \(rawValue), using fallback")
        return Image(systemName: "app.fill")
    }
    
    static var current: AppIcon {
        if let iconName = UIApplication.shared.alternateIconName,
           let icon = AppIcon(rawValue: iconName) {
            return icon
        }
        return .default
    }
    
    @MainActor
    static func setIcon(_ icon: AppIcon) async throws {
        // 打印调试信息
        print("Attempting to set icon: \(icon.rawValue)")
        print("Icon name: \(String(describing: icon.name))")
        
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any] {
            print("Available icons in Info.plist: \(icons)")
        }
        
        // 在主线程执行图标切换
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                UIApplication.shared.setAlternateIconName(icon.name) { error in
                    if let error = error {
                        print("Error setting icon: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("Successfully set icon to: \(String(describing: icon.name))")
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }
} 