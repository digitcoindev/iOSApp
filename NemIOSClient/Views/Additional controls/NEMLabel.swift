import UIKit

class NEMLabel: UILabel
{
    var copylable :UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
        
        var recogniser :UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressDetected")
        recogniser.minimumPressDuration = 1
        self.addGestureRecognizer(recogniser)
        
        copylable = UILabel(frame: CGRectMake(self.frame.width - 40, self.frame.height - 10, 40, 10))
        copylable.text = "copied"
        copylable.hidden = true
        copylable.font = UIFont(name: copylable.font.fontName, size: 10)
        copylable.textColor = UIColor.whiteColor()
        copylable.textAlignment = NSTextAlignment.Center
        copylable.backgroundColor = UIColor.blackColor()
        copylable.clipsToBounds = true
        copylable.layer.cornerRadius = 5.0
        self.addSubview(copylable)
    }
    
    final func longPressDetected() {
        var pasteBoard :UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = self.text
        copylable.hidden = false
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hideCopyLable"), userInfo: nil, repeats: false)
    }
    
    func hideCopyLable() {
        copylable.hidden = true
    }
}
