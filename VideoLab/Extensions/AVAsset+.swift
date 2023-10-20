import AVFoundation

extension AVAsset {
    var size:CGSize? {
        var videoSize:CGSize?
        if let videoTrack = tracks(withMediaType: .video).first {
            let transform = videoTrack.preferredTransform
            videoSize = videoTrack.naturalSize.applying(transform)
            if let width = videoSize?.width,let height = videoSize?.height {
                videoSize = CGSize(width: abs(width), height: abs(height))
            }
        }
        return videoSize
    }
}

