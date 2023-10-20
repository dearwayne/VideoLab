//
//  ImageSource.swift
//  VideoLab
//
//  Created by Bear on 2020/8/1.
//

import AVFoundation
import UIKit
import MetalPerformanceShaders

public class ImageSource: Source,ScaleTransformable {
    public var scaleTransform: MPSScaleTransform? {
        didSet {
            isLoaded = false
        }
    }
    public var renderSize: CGSize = .zero {
        didSet {
            isLoaded = false
            updateScaleTransform()
        }
    }
    
    public var renderImage:UIImage? {
        var _renderImage = image
        if let image = image,let scaleTransform = scaleTransform {
            let size = image.size
            let newSize = CGSize(width: size.width * scaleTransform.scaleX, height: size.height * scaleTransform.scaleY)
            let newImage = image.resize(to: newSize,contentMode: .scaleToFill)
            let renderRect = CGRect(origin: CGPoint(x: scaleTransform.translateX, y: scaleTransform.translateY), size: renderSize)
            _renderImage = newImage.crop(rect: renderRect)
        }
        return _renderImage
    }
    
    private func updateScaleTransform() {
        guard let size = image?.size,
              size.width > 0,
              size.height > 0,
              renderSize != size
        else { return }
        
        let scale = max(renderSize.width / size.width,renderSize.height / size.width)
        let translateX = (size.width * scale - renderSize.width) / 2
        let translateY = (size.height * scale - renderSize.height) / 2
        
        scaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: translateX, translateY: translateY)
    }

    public var cgImage: CGImage? {
        didSet {
            isLoaded = false
            updateScaleTransform()
        }
    }
    
    public var image:UIImage? {
        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    var texture: Texture?

    public init(cgImage: CGImage?) {
        self.cgImage = cgImage
        duration = CMTime(seconds: 3, preferredTimescale: 600) // Default duration
        selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        renderSize = image?.size ?? .zero
    }
    
    public init() {
        duration = CMTime(seconds: 3, preferredTimescale: 600) // Default duration
        selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
    }

    // MARK: - Source
    public var selectedTimeRange: CMTimeRange
    
    public var duration: CMTime
    
    public var isLoaded: Bool = false
    
    public func load(completion: @escaping (NSError?) -> Void) {
        guard let cgImage = cgImage else {
            let error = NSError.init(domain: "com.source.load",
                                     code: 0,
                                     userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Image is nil", comment: "")])
            completion(error)
            isLoaded = true
            return
        }
        
        Texture.makeTexture(cgImage: cgImage) { [weak self] (texture) in
            guard let self = self else { return }
            
            self.texture = texture
            self.isLoaded = true
            completion(nil)
        }
    }
    
    public func tracks(for type: AVMediaType) -> [AVAssetTrack] {
        return []
    }
    
    public func texture(at time: CMTime) -> Texture? {
        if isLoaded {
            return texture
        }
        
        defer {
            isLoaded = true
        }
        
        guard let cgimage = renderImage?.cgImage else {
            return nil
        }
        
        texture = Texture.makeTexture(cgImage: cgimage)
        return texture
    }
}

