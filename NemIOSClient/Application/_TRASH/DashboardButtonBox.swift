import UIKit

class DashboardButtonBox: UIButton {
    
    override func layoutSubviews(){
        super.layoutSubviews()
    
        if let imageView = self.imageView {
            imageView.contentMode =  UIViewContentMode.scaleAspectFit
            imageView.frame = CGRect(x: self.frame.width / 4, y: 10, width: self.frame.width / 2, height: self.frame.height / 2 - 5)
        }
        
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame.origin.x = (self.frame.width - titleLabel.frame.width) / 2
            titleLabel.frame.origin.y = imageView!.frame.origin.y + imageView!.frame.height + 5
        }
    }
}
