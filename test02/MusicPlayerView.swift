import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    @Binding var showPlayer: Bool
    @State private var isPlaying = false
    @State private var progress: Double = 0.0
    @State private var currentTime: Double = 0.0
    @State private var timer: Timer?
    @State private var totalDuration: Double = 0.0  // 改为 State 变量
    @State private var rotationDegree: Double = 0
    @State private var rotationTimer: Timer? = nil
    
    private let audioPlayer: AVAudioPlayer? = {
        guard let path = Bundle.main.path(forResource: "song", ofType: "mp3") else { return nil }
        let url = URL(fileURLWithPath: path)
        return try? AVAudioPlayer(contentsOf: url)
    }()
    
    private func initializePlayer() {
        if let player = audioPlayer {
            totalDuration = player.duration  // 获取实际音频长度
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if currentTime < totalDuration {
                currentTime += 1
                progress = currentTime / totalDuration
            } else {
                stopPlayback()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startPlayback() {
        // 确保音频播放器的 currentTime 与 UI 进度同步
        audioPlayer?.currentTime = currentTime
        audioPlayer?.play()
        startTimer()
        isPlaying = true
    }
    
    private func stopPlayback() {
        audioPlayer?.pause()
        stopTimer()
        isPlaying = false
    }
    
    private func resetPlayback() {
        currentTime = 0
        progress = 0
        audioPlayer?.currentTime = 0
    }

    private func startRotation() {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            // 每秒转一圈则每次加 360/50，慢速可调小
            rotationDegree += 0.36 // 10秒一圈
            if rotationDegree >= 360 { rotationDegree -= 360 }
        }
    }

    private func stopRotation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                // 光盘播放器
                ZStack {
                    // 外圈白色唱片
                    Circle()
                        .stroke(Color.black, lineWidth:1)
                        .frame(width: 224, height: 224)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 8)
                    
                    // 唱片纹理
                    ForEach(0..<8) { index in
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                            .frame(width: CGFloat(200 - index * 20), height: CGFloat(200 - index * 20))
                    }
                    
                    // 专辑封面
                    Image(uiImage: UIImage(named: "albumCover") ?? UIImage(systemName: "music.note")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                    
                    // 中心小圆点
                    Circle()
                        .fill(Color.silver)
                        .frame(width: 20, height: 20)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                }
                .rotationEffect(.degrees(rotationDegree))
                .onChange(of: isPlaying) { playing in
                    if playing {
                        startRotation()
                    } else {
                        stopRotation()
                    }
                }
                .onDisappear {
                    stopRotation()
                }
                // 控制按钮
                HStack(spacing: 40) {
                    Button(action: {
                        resetPlayback()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        isPlaying ? stopPlayback() : startPlayback()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        resetPlayback()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                }
                // 进度条
                VStack {
                    Slider(value: $progress)
                        .onChange(of: progress) { newValue in
                            currentTime = newValue * totalDuration
                            audioPlayer?.currentTime = currentTime
                        }
                    HStack {
                        Text(formatTime(currentTime))
                            .font(.caption)
                        Spacer()
                        Text(formatTime(totalDuration))  // 显示实际时长
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("播放器", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                showPlayer = false
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("返回")
                    .foregroundColor(.blue)
            })
        }
        .onAppear {
            initializePlayer()  // 视图出现时初始化播放器
        }
        .onDisappear {
            stopPlayback()
        }
    }
}

// 添加自定义颜色扩展
extension Color {
    static let silver = Color(red: 192/255, green: 192/255, blue: 192/255)
}
