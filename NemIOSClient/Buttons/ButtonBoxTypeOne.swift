import UIKit

class ButtonBoxTypeOne: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if let imageView = self.imageView {
            imageView.frame = CGRect(x: self.frame.width / 6, y: self.frame.height / 2 - 10, width: 20, height: 20)
        }
        
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame.origin.x = imageView!.frame.origin.x + imageView!.frame.width + 10
            titleLabel.frame.origin.y = (self.frame.height - titleLabel.frame.height) / 2
        }
    }
}
