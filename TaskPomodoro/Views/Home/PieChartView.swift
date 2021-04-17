//
//  PieChartView.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/17.
//

import UIKit

@IBDesignable class PieChartView : UIView {
    
    // MARK: Public Inspectable Properties
    
    @IBInspectable var maxValue: CGFloat = 1500.0 {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var value: CGFloat = 0 {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var barWidth: CGFloat = 10 {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var barPadding: CGFloat = 0 {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var chartBackgroundColor: UIColor = UIColor.rgb(red: 248, green: 248, blue: 248,alpha: 0.2) {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var chartTintColor: UIColor = .white {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var animationDuration: Double = 2.8
     
    // MARK: Public Functions
    
    func set(value: CGFloat, maxValue: CGFloat, animated: Bool = true) {
        set(rect: centerSquareRect(bounds), value: value, maxValue: maxValue, animated: animated)
    }    

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Draw
    
    override func draw(_ rect: CGRect) {
        let pieChartRect = centerSquareRect(rect)
        setChartBackground(rect: pieChartRect)
        set(rect: pieChartRect, value: value, maxValue: maxValue, animated: false)
    }
    
    // MARK: Private Properties
    
    private var tintShapeLayer: CAShapeLayer?
    
    private let pi = CGFloat(Double.pi)
    
    // MARK: Private Functions
    
    private func set(rect: CGRect, value: CGFloat, maxValue: CGFloat, animated: Bool = true) {
        tintShapeLayer?.removeFromSuperlayer()
        tintShapeLayer = createTintShapeLayer(rect: rect, value: value, maxValue: maxValue)
        layer.addSublayer(tintShapeLayer!)
        
        if animated {
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            animation.duration = CFTimeInterval(animationDuration)
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            tintShapeLayer!.add(animation, forKey: "pieChartAnimation")
        }
    }
        
    private func setup() {
        set(value: value, maxValue: maxValue, animated: false)
    }
    
    private func pieChartPath(rect: CGRect, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(
            arcCenter: centerPoint(of: rect),
            radius: (max(rect.width, rect.height) / 2) - (barWidth / 2),
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
    }
    
    private func setChartBackground(rect: CGRect) {
        let path = pieChartPath(
            rect: rect,
            startAngle: 0,
            endAngle: pi * 2
        )
        path.lineWidth = barWidth
        chartBackgroundColor.setStroke()
        path.stroke()
    }
    
    private func createTintShapeLayer(rect: CGRect, value: CGFloat, maxValue: CGFloat) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = rect
        shapeLayer.lineWidth = barWidth - (barPadding * 2)
        shapeLayer.strokeColor = chartTintColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        let percentage = calculatePercentage(numerator: value, denominator: maxValue)
        let start = 3 * pi / 2
        let end = start + (percentage * 2 * pi)
        
        shapeLayer.path = pieChartPath(
            rect: centerSquareRect(rect),
            startAngle: start,
            endAngle: end
        ).cgPath
        
        return shapeLayer
    }
    
    private func centerSquareRect(_ rect: CGRect) -> CGRect {
        let sideWidth = min(rect.width, rect.height)
        return CGRect(
            x: (rect.width - sideWidth) / 2,
            y: (rect.height - sideWidth) / 2,
            width: sideWidth,
            height: sideWidth
        )
    }
    
    private func centerPoint(of rect: CGRect) -> CGPoint {
        return CGPoint(
            x: rect.minX + (rect.width / 2),
            y: rect.minY + (rect.height / 2)
        )
    }
    
    private func calculatePercentage(numerator: CGFloat, denominator: CGFloat) -> CGFloat {
        if numerator <= 0 || denominator <= 0 {
            return 0.0
        } else if numerator >= denominator {
            return 1.0
        } else {
            return numerator / denominator
        }
    }
}

