

import UIKit
public final class StarReview: UIControl {
    public var starCount:Int = 5 {
        didSet {
            maxmunValue = Float(starCount)
            setNeedsDisplay()
        }
    }
    public var starFillColor:UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    public var starBackgroundColor:UIColor = UIColor.gray {
        didSet{
            setNeedsDisplay()
        }
    }
    public var allowEdit:Bool = true
    public var allowAccruteStars:Bool = false {
        didSet{
            setNeedsDisplay()
        }
    }
    public var starMarginScale:Float = 0.3 {
        didSet{
            if starMarginScale > 0.9
            {
                starMarginScale = 0.9
            }
            if starMarginScale < 0.1 {
                starMarginScale = 0.1
            }
            setNeedsDisplay()
        }
    }
    public var value:Float {
        get{
            if allowAccruteStars {
                let index = getStarIndex()
                if index.0 != -1 {
                    let a = Float((1 + starMarginScale) * Float(starRadius) * (Float(index.0) - 1))
                    return  (Float(starPixelValue * (1 + starMarginScale) * starRadius) - a) / Float(starRadius) + Float(index.0) - 1
                }
                else {
                    return Float(index.1 + 1)
                }
                
            }
            else {
                return starPixelValue
            }
        }
        set {
            if newValue > Float(starCount) {
                starPixelValue  = Float(starCount)
            }
            else  if newValue < 0{
                starPixelValue  = 0
            }
            else {
                if allowAccruteStars {
                    
                    let intPart = Int(newValue)
                    let floatPart = newValue - Float(intPart)
                    let x = (1 + starMarginScale) * starRadius * Float(intPart) + starRadius * Float(floatPart)
                    starPixelValue = x / starRadius / (1 + starMarginScale)
                }
                else {
                    starPixelValue = Float(lroundf(newValue))
                }
            }
            
        }
    }
    public var maxmunValue:Float = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    public  var minimunValue:Float = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var starRadius:Float = 0.0;
    fileprivate weak var target:AnyObject?
    fileprivate var selector:Selector?
    fileprivate var event:UIControlEvents?
    
    fileprivate var offsetX:Float {
        get {
            return 0.0
        }
    }
    
    fileprivate var offsetY:Float {
        get {
            return ratio < startReviewWidthScale ? (Float(self.frame.height)  - starRadius) / 2 : 0.0
        }
    }
    
    fileprivate var ratio:Float {
        get {
            return Float(self.frame.width) / Float(self.frame.height)
        }
    }
    fileprivate var startReviewWidthScale:Float {
        get {
            return Float(starCount) + Float((starCount - 1)) * starMarginScale
        }
    }
    
    fileprivate var starPixelValue:Float = 0.0 {
        didSet {
            if starPixelValue > Float(starCount) {
                starPixelValue = Float(starCount)
            }
            if starPixelValue < 0 {
                starPixelValue = 0
            }
            setNeedsDisplay()
            if target != nil && event != nil {
                if event == UIControlEvents.valueChanged {
                    self.sendAction(selector!, to: target, for: nil)
                }
            }
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        starRadius = Float(self.frame.size.height) - Float(layer.borderWidth * 2)
        if ratio < startReviewWidthScale{
            starRadius = Float(self.frame.width) / startReviewWidthScale - Float(layer.borderWidth * 2)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        starRadius = Float(self.frame.size.height) - Float(layer.borderWidth * 2)
        if ratio < startReviewWidthScale{
            starRadius = Float(self.frame.width) / startReviewWidthScale - Float(layer.borderWidth * 2)
        }
    }
    override public func draw(_ rect: CGRect) {
        
        clipsToBounds = false
        starRadius = Float(self.frame.size.height) - Float(layer.borderWidth * 2)
        if ratio < startReviewWidthScale {
            starRadius = Float(self.frame.width) / startReviewWidthScale - Float(layer.borderWidth * 2)
        }
        let ctx = UIGraphicsGetCurrentContext()
        for s in 0...(starCount-1) {
            let x = starMarginScale * Float(s) * starRadius + starRadius * (0.5 + Float(s))
            var starCenter = CGPoint(x: CGFloat(x), y: (self.frame.height) / 2)
            if ratio > startReviewWidthScale {
                starCenter = CGPoint(x: CGFloat(x)+CGFloat(offsetX), y: self.frame.height / 2)
            }
            
            let radius = starRadius / 2
            
            let p1 = CGPoint(x: starCenter.x, y: starCenter.y - CGFloat(radius)) //
            
            ctx?.setFillColor(starBackgroundColor.cgColor)
            ctx?.setStrokeColor(starBackgroundColor.cgColor)
            ctx?.setLineCap(CGLineCap.butt)
            ctx?.move(to: CGPoint(x: p1.x, y: p1.y))
            let angle = Float(4 * M_PI / 5)
            for i in 1...5{
                let x = Float(starCenter.x) - sinf(angle * Float(i)) * Float(radius)
                let y = Float(starCenter.y) - cosf(angle * Float(i)) * Float(radius)
                ctx?.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
            }
            ctx?.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        ctx?.setFillColor(starFillColor.cgColor)
        ctx?.setBlendMode(CGBlendMode.sourceIn)
        let temp = starRadius * ( 1 + starMarginScale) * starPixelValue
        ctx?.fill(CGRect(x: CGFloat(offsetX), y: CGFloat(offsetY), width: CGFloat(temp), height: CGFloat(starRadius)))
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch:UITouch = touches.first{
            let point = touch.location(in: self)
            let temp = (Float(point.x) - offsetX) / (starRadius * ( 1 + starMarginScale))
            if allowAccruteStars{
                starPixelValue = temp
            }
            else{
                starPixelValue = Float(Int(temp) + 1)
            }
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if allowEdit == false {
            self.isUserInteractionEnabled = false
            return
        } else {
            if let touch:UITouch = touches.first{
                let point = touch.location(in: self)
                let temp = (Float(point.x) - offsetX) / (starRadius * ( 1 + starMarginScale))
                if allowAccruteStars{
                    starPixelValue = temp
                }
                else{
                    starPixelValue = Float(Int(temp) + 1)
                }
            }
        }
    }
    
    override public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        self.target = target as AnyObject?
        self.selector = action
        self.event = controlEvents
    }
    
    fileprivate func getStarIndex()->(Int,Int) {
        let i = Int(starPixelValue)
        if  starPixelValue - Float(i) <= 1 / (1 + starMarginScale)
        {
            return (i + 1,-1)
        }
        else{
            return (-1, i)
        }
    }
}
