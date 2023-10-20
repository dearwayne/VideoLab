
import UIKit

enum UIImageResizeMode {
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    case scaleToCenter
}


extension UIImage {
    /// Extension to fix orientation of an UIImage without EXIF
    func fixOrientation() -> UIImage {
        
        guard let cgImage = cgImage else { return self }
        
        if imageOrientation == .up { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            
        case .up, .upMirrored:
            break
        default:
            break
        }
        
        switch imageOrientation {
            
        case .upMirrored, .downMirrored:
            let _ = transform.translatedBy(x: size.width, y: 0)
            let _ = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            let _ = transform.translatedBy(x: size.height, y: 0)
            let _ = transform.scaledBy(x: -1, y: 1)
            
        case .up, .down, .left, .right:
            break
        default:
            break
        }
        
        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            
            ctx.concatenate(transform)
            
            switch imageOrientation {
                
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }
        
        // something failed -- return original
        return self
    }
    ///限定图片在固定尺寸内，如果超过了，就缩小，如果没超，返回原图
    func resize(maxSize:CGSize,opaque:Bool = false) -> UIImage {
        return autoreleasepool {
            var newSize = self.size
            
            // 如果超宽了
            if newSize.width > maxSize.width {
                let newHeight = newSize.height / newSize.width * maxSize.width
                newSize = CGSize(width: maxSize.width, height: newHeight)
            }
            
            // 如果超高了
            if newSize.height > maxSize.height {
                let newWidth = newSize.width / newSize.height * maxSize.height
                newSize = CGSize(width: newWidth, height: maxSize.height)
            }
            
            guard newSize != size else {
                return self
            }
            
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, opaque, 1)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }
    
    func resize(to size:CGSize,opaque:Bool = false,contentMode:UIImageResizeMode = .scaleToCenter) -> UIImage {
        return autoreleasepool {
            guard self.size != size
            else { return self }
            
            var newSize = self.size
            
            // 如果超宽了
            if newSize.width > size.width {
                let newHeight = newSize.height / newSize.width * size.width
                newSize = CGSize(width: size.width, height: newHeight)
            }
            
            // 如果超高了
            if newSize.height > size.height {
                let newWidth = newSize.width / newSize.height * size.height
                newSize = CGSize(width: newWidth, height: size.height)
            }
            
            let rect:CGRect
            switch contentMode {
            case .scaleToFill:
                rect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
            case .scaleAspectFit:
                let aspectFitSize = newSize.maxSize(inside: size)
                rect = CGRect(x: (size.width - aspectFitSize.width) / 2.0,
                              y: (size.height - aspectFitSize.height) / 2.0,
                              width: aspectFitSize.width,
                              height: aspectFitSize.height)
            case .scaleAspectFill:
                let aspectFitSize = newSize.minSize(inner: size)
                rect = CGRect(x: (size.width - aspectFitSize.width) / 2.0,
                              y: (size.height - aspectFitSize.height) / 2.0,
                              width: aspectFitSize.width,
                              height: aspectFitSize.height)
            case .scaleToCenter:
                rect = CGRect(x: (size.width - newSize.width) / 2.0,
                              y: (size.height - newSize.height) / 2.0,
                              width: newSize.width,
                              height: newSize.height)
            }
            
            UIGraphicsBeginImageContextWithOptions(size, opaque, 1)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }
    
    // 截取部分图片
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
