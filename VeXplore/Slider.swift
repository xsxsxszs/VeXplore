//
//  Slider.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


protocol SliderDelegate: class
{
    func didSelect(at index: Int)
}

class Slider: UIView
{
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.axis = .horizontal
        
        return view
    }()
    
    private lazy var hLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .note
        
        return view
    }()
    
    private lazy var circle: CircleView = {
        let view = CircleView()
        view.radius = 20.0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var options: [String]? {
        didSet
        {
            if let options = options
            {
                scaleLabels.removeAll()
                for vLine in vLines
                {
                    stackView.removeArrangedSubview(vLine)
                }
                vLines.removeAll()
                
                for text in options
                {
                    let vLine: UIView = {
                        let view = UIView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.backgroundColor = .note
                        
                        return view
                    }()
                    vLines.append(vLine)
                    stackView.addArrangedSubview(vLine)
                    vLine.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
                    vLine.heightAnchor.constraint(equalToConstant: 7.0).isActive = true

                    let label: UILabel = {
                        let label = UILabel()
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.font = R.Font.ExtraSmall
                        label.textColor = .note
                        label.text = text
                        
                        return label
                    }()
                    scaleLabels.append(label)
                    addSubview(label)
                    label.centerXAnchor.constraint(equalTo: vLine.centerXAnchor).isActive = true
                    label.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10.0).isActive = true
                    label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
                }
            }
        }
    }
    
    var selectedIndex: Int = -1 {
        didSet
        {
            guard stackView.arrangedSubviews.count > selectedIndex else {
                return
            }
            let selectedView = stackView.arrangedSubviews[selectedIndex]
            layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {
                self.circleCenterX.isActive = false
                self.circleCenterX = self.circle.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor, constant: 0.0)
                self.circleCenterX.isActive = true
                self.layoutIfNeeded()
            }
        }
    }
    
    private var vLines = [UIView]()
    private var scaleLabels = [UILabel]()
    private var circleCenterX: NSLayoutConstraint!
    weak var delegate: SliderDelegate?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(hLine)
        addSubview(stackView)
        addSubview(circle)
        hLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0).isActive = true
        hLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0).isActive = true
        hLine.topAnchor.constraint(equalTo: topAnchor, constant: 12.0).isActive = true
        hLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 9.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: hLine.leadingAnchor, constant: 0.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: hLine.trailingAnchor, constant: 0.0).isActive = true
        circle.centerYAnchor.constraint(equalTo: hLine.centerYAnchor, constant: 0.0).isActive = true
        circleCenterX = circle.centerXAnchor.constraint(equalTo: hLine.centerXAnchor, constant: 0.0)
        circleCenterX.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let point = touches.first?.location(in: stackView)
        {
            var min = CGFloat.greatestFiniteMagnitude
            var pointIndex = 0
            for (index, view) in stackView.arrangedSubviews.enumerated()
            {
                if abs(view.center.x - point.x) < min
                {
                    pointIndex = index
                    min = abs(view.center.x - point.x)
                }
            }
            selectedIndex = pointIndex
            delegate?.didSelect(at: selectedIndex)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let point = touches.first?.location(in: stackView)
        {
            var min = CGFloat.greatestFiniteMagnitude
            var pointIndex = 0
            for (index, view) in stackView.arrangedSubviews.enumerated()
            {
                if abs(view.center.x - point.x) < min
                {
                    pointIndex = index
                    min = abs(view.center.x - point.x)
                }
            }
            selectedIndex = pointIndex
            delegate?.didSelect(at: selectedIndex)
        }
    }
    
    func prepareForReuse()
    {
        for scaleLabel in scaleLabels
        {
            scaleLabel.font = R.Font.ExtraSmall
        }
    }
    
}


class CircleView: UIView
{
    var radius: CGFloat? {
        didSet
        {
            if let radius = radius, radius > 0
            {
                if circleLayer != nil
                {
                    circleLayer!.removeFromSuperlayer()
                }
                circleLayer = CAShapeLayer()
                circleLayer!.path = UIBezierPath(ovalIn: CGRect(x: -radius * 0.5, y: -radius * 0.5, width: radius, height: radius)).cgPath
                circleLayer!.lineWidth = 0.5
                circleLayer!.shadowColor = UIColor.black.cgColor
                circleLayer!.shadowOpacity = 0.3
                circleLayer?.shadowOffset = CGSize(width: 0, height: 0.1 * radius)
                circleLayer!.strokeColor = UIColor.border.cgColor
                circleLayer!.fillColor = UIColor.background.cgColor
                layer.addSublayer(circleLayer!)
            }
        }
    }
    
    private var circleLayer: CAShapeLayer?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}
