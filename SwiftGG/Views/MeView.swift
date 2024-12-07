import SwiftUI

struct MeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = ContributorsService.shared
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @State private var showingIconPicker = false
    
    // 社交媒体数据
    let socialLinks = [
        (icon: "github", name:"Github", url: "https://github.com/SwiftGGTeam", color: Color(red: 51/255, green: 51/255, blue: 51/255)),
        (icon: "twitterx", name:"X（Twitter）", url: "https://twitter.com/SwiftGGTeam", color: Color(red: 0/255, green: 0/255, blue: 0/255)),
        (icon: "weibo", name:"新浪微博", url: "https://weibo.com/swiftguide", color: Color(red: 230/255, green: 22/255, blue: 45/255)),
        (icon: "xiaohongshu", name:"小红书", url: "https://www.xiaohongshu.com/user/profile/5e8c6c83000000000100104b", color: Color(red: 255/255, green: 72/255, blue: 92/255))
    ]
    
    // 图标视图组件
    struct IconView: View {
        let systemName: String
        let color: Color
        
        var body: some View {
            Image(systemName: systemName)
                .foregroundStyle(.white)
                .imageScale(.medium)
                .frame(width: 21, height: 21)
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.8))
                )
        }
    }
    
    // 头像视图组件
    struct AvatarView: View {
        let avatar: String?
        let size: CGFloat = 40
        
        var body: some View {
            if let avatarURL = avatar, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // 加载中状态
                        defaultAvatar
                            .overlay {
                                ProgressView()
                                    .scaleEffect(0.5)
                            }
                    case .success(let image):
                        // 加载成功
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    case .failure(_):
                        // 加载失���
                        defaultAvatar
                    @unknown default:
                        defaultAvatar
                    }
                }
            } else {
                // 没有头像URL
                defaultAvatar
            }
        }
        
        // 默认头像视图
        private var defaultAvatar: some View {
            Image(systemName: "person.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.gray)
                .frame(width: size * 0.6, height: size * 0.6)
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
    
    // 添加一个新的视图组件来统一行的显示
    struct ContributorRow: View {
        let contributor: Contributor
        
        var body: some View {
            HStack(spacing: 15) {
                AvatarView(avatar: contributor.avatar)
                VStack(alignment: .leading) {
                    Text(contributor.name)
                    Text(contributor.role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // 如果有URL，显示外链���标
                if contributor.url != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundColor(.primary)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // 关于我们和社交媒体
                Section(content: {
                    // 官网链接
                    Link(destination: URL(string: "https://swiftgg.org")!) {
                        HStack(spacing: 15) {
                            IconView(systemName: "globe", color: ThemeColors.iconColors.website)
                            Text("SwiftGG 官网")
                            Spacer()
                        }
                        .foregroundColor(.primary)
                    }
                    
                    // 社交媒体链接
                    ForEach(socialLinks, id: \.icon) { social in
                        Link(destination: URL(string: social.url)!) {
                            HStack(spacing: 15) {
                                Image(social.icon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 21, height: 21)
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(social.color)
                                    )
                                Text(social.name)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                }, header: {
                    Text("关于SwiftGG")
                }, footer: {
                    HStack {
                        Spacer()
                        Text("粤ICP备2023104442号-2")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                })
                
                // 版本信息
                Section("应用信息") {
                    HStack(spacing: 15) {
                        IconView(systemName: "info.circle.fill", color: ThemeColors.iconColors.info)
                        Text("当前版本")
                        Spacer()
                        Text(AppInfo.versionAndBuild)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack(spacing: 15) {
                            // 修改应用图标的显示方式，移除多余的背景
                            AppIcon.current.preview
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 27, height: 27) // 稍微增大尺寸以配其他图标
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Text("应用图标")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(AppIcon.current.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 贡献者列表
                Section("翻译组成员") {
                    if !networkMonitor.isConnected {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                Text("连接互联网查看成员信息")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    } else if service.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("加载中...")
                            Spacer()
                        }
                        .padding(.vertical, 20)
                    } else if !service.contributors.isEmpty {
                        ForEach(service.contributors) { contributor in
                            if let url = contributor.url {
                                Link(destination: URL(string: url)!) {
                                    ContributorRow(contributor: contributor)
                                }
                            } else {
                                ContributorRow(contributor: contributor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if networkMonitor.isConnected {
                    Task {
                        await service.fetchContributors()
                    }
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                AppIconPickerView()
            }
        }
    }
}

