import Foundation

let center = DistributedNotificationCenter.default()

center.addObserver(
    forName: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
    object: nil,
    queue: .main
) { _ in
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/sh")
    task.arguments = ["-c", "sketchybar --trigger spotify_change"]
    task.environment = ["PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"]
    try? task.run()
}

RunLoop.main.run()
