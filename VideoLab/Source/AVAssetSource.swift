//
//  AVAssetSource.swift
//  VideoLab
//
//  Created by Bear on 2020/8/29.
//

import AVFoundation
import MetalPerformanceShaders

public class AVAssetSource: Source,Rateable,ScaleTransformable {
    public var scaleTransform: MPSScaleTransform?
    
    public private(set) var rate: Float64 = 1.0
    public var ratedDuration: CMTime = .zero
    
    private var isMuted = false
    
    public func setRate(_ rate: Float64) {
        guard rate > 0 else { return }
        self.rate = rate
        ratedDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / rate)
    }
    
    public private(set) var asset: AVAsset?
    
    public init(asset: AVAsset) {
        self.asset = asset
        duration = asset.duration
        ratedDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / rate)
        selectedTimeRange = CMTimeRange(start: .zero, duration: duration)
    }
    
    // 视频静音
    public func setMute(_ mute:Bool) {
        self.isMuted = mute
    }
    
    // MARK: - Source
    public var selectedTimeRange: CMTimeRange
    
    public var duration: CMTime {
        didSet {
            ratedDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / rate)
        }
    }
    
    public var isLoaded: Bool = false
    
    public func load(completion: @escaping (NSError?) -> Void) {
        guard let asset = asset else {
            let error = NSError.init(domain: "com.source.load",
                                     code: 0,
                                     userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Asset is nil", comment: "")])
            completion(error)
            return
        }

        asset.loadValuesAsynchronously(forKeys: ["tracks", "duration"]) { [weak self] in
            guard let self = self else { return }
            
            defer {
                self.isLoaded = true
            }
            
            var error: NSError?
            let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            if tracksStatus != .loaded {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            
            let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
            if durationStatus != .loaded {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            
            if let videoTrack = self.tracks(for: .video).first {
                // Make sure source's duration not beyond video track's duration
                self.duration = videoTrack.timeRange.duration
            } else {
                self.duration = asset.duration
            }
            self.selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: self.duration)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    public func tracks(for type: AVMediaType) -> [AVAssetTrack] {
        guard let asset = asset else { return [] }
        // 视频静音
        if isMuted,type == .audio { return [] }
        return asset.tracks(withMediaType: type)
    }
}
