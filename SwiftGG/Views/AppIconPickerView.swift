import SwiftUI

struct AppIconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIcon: AppIcon = .current
    @State private var isChanging = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            List(AppIcon.allCases) { icon in
                HStack {
                    icon.preview
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading) {
                        Text(icon.displayName)
                            .font(.headline)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    if selectedIcon == icon {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedIcon != icon {
                        changeAppIcon(to: icon)
                    }
                }
            }
            .navigationTitle("更换应用图标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isChanging {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .alert("更换图标失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text("请稍后再试")
            }
        }
    }
    
    private func changeAppIcon(to icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        isChanging = true
        Task {
            do {
                try await AppIcon.setIcon(icon)
                selectedIcon = icon
            } catch {
                showError = true
                print("Error changing app icon: \(error.localizedDescription)")
            }
            isChanging = false
        }
    }
} 