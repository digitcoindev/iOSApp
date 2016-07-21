import UIKit

class NEMLabel: UILabel
{
    var copylable :UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
        
        let recogniser :UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(NEMLabel.longPressDetected))
        recogniser.minimumPressDuration = 0.5
        self.addGestureRecognizer(recogniser)
        
        copylable = UILabel()
        copylable.text = "COPIED".localized()
        copylable.hidden = true
        copylable.font = UIFont(name: copylable.font.fontName, size: 17)
        copylable.sizeToFit()
        copylable.frame.size = CGSize(width: copylable.frame.size.width + 10, height: copylable.frame.size.height + 10)
        copylable.textColor = UIColor.whiteColor()
        copylable.textAlignment = NSTextAlignment.Center
        copylable.backgroundColor = UIColor.blackColor()
        copylable.clipsToBounds = true
        copylable.layer.cornerRadius = 5.0
        
        self.addSubview(copylable)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.frame.origin.y > (copylable.frame.height + 5) {
            copylable.frame.origin.y = -copylable.frame.height - 5
            copylable.frame.origin.x = (self.frame.width - copylable.frame.width) / 2
        } else {
            copylable.frame.origin.y = self.frame.height + 5
            copylable.frame.origin.x = (self.frame.width - copylable.frame.width) / 2
        }
    }
    
    final func longPressDetected() {
        let pasteBoard :UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = self.text
        copylable.hidden = false
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(NEMLabel.hideCopyLable), userInfo: nil, repeats: false)
    }
    
    func hideCopyLable() {
        copylable.hidden = true
    }
}
