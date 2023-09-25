//
//  Source.swift
//  VideoLab
//
//  Created by Bear on 2020/8/29.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation

public protocol Rateable {
    // 变速
    var rate:Float64 {get}
    var ratedDuration: CMTime {get}
    
    func setRate(_ speed: Float64)
}

public protocol Source {
    var selectedTimeRange: CMTimeRange { get set }
    var duration: CMTime { get set }
    var isLoaded: Bool { get set }
    
    func load(completion: @escaping (NSError?) -> Void)
    func tracks(for type: AVMediaType) -> [AVAssetTrack]
    func texture(at time: CMTime) -> Texture?
    
    func canBeConvertedToVideo() -> Bool
}

extension Source {
    public func texture(at time: CMTime) -> Texture? {
        return nil
    }
    public func canBeConvertedToVideo() -> Bool {
        return false
    }
}
