
import Foundation

extension CGSize {
    func maxSize(inside maxSize:CGSize) -> CGSize {
        guard self.width > 0,self.height > 0 else { return self }
        let minRate = min(maxSize.width / self.width,maxSize.height / self.height)
        return CGSize(width: self.width * minRate, height: self.height * minRate)
    }
    
    func minSize(inner size:CGSize) -> CGSize {
        guard self.width > 0,self.height > 0 else { return self }
        let maxRate = max(size.width / self.width,size.height / self.height)
        return CGSize(width: self.width * maxRate, height: self.height * maxRate)
    }
}

