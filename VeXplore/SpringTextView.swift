//
//  SpringTextView.swift
//  VeXplore
//
//  Copyright © 2016 Jimmy. All rights reserved.
//


class SpringTextView: UIView
{
    private lazy var animateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.StaticMedium
        label.textColor = .highlight
        
        return label
    }()
    
    private lazy var staticLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.Font.StaticMedium
        label.textColor = .desc
        label.text = R.String.CurrentPage
        
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        addSubview(animateLabel)
        addSubview(staticLabel)
        let bindings = [
            "animateLabel": animateLabel,
            "staticLabel": staticLabel
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[staticLabel][animateLabel]", metrics: nil, views: bindings))
        addConstraint(NSLayoutConstraint(item: animateLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: staticLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(_ value: String, animated: Bool)
    {
        guard animateLabel.text != value else {
            return
        }
        
        if animated
        {
            let duration = 0.3
            let shakeDistance: CGFloat = animateLabel.frame.height * 0.2
            UIView.animateKeyframes(withDuration: duration * 0.5, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0 / 3.0, animations: {
                    let translate = CGAffineTransform(translationX: 0.0, y: -shakeDistance)
                    let scale = CGAffineTransform(scaleX: 1.0, y: 1.1)
                    self.animateLabel.transform = translate.concatenating(scale)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1.0 / 3.0, relativeDuration: 1.0 / 3.0, animations: {
                    let translate = CGAffineTransform(translationX: 0.0, y: 0.0)
                    let scale = CGAffineTransform.identity
                    self.animateLabel.transform = translate.concatenating(scale)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 2.0 / 3.0, relativeDuration: 1.0 / 3.0, animations: {
                    let translate = CGAffineTransform(translationX: 0.0, y: shakeDistance)
                    let scale = CGAffineTransform(scaleX: 1.0, y: 0.9)
                    self.animateLabel.transform = translate.concatenating(scale)
                })
                
                }, completion: { (_) in
                    self.animateLabel.text = value
                    UIView.animateKeyframes(withDuration: duration * 0.5, delay: 0, options: .calculationModeCubic, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0 / 3.0, animations: {
                            let translate = CGAffineTransform(translationX: 0.0, y: 0.0)
                            let scale = CGAffineTransform.identity
                            self.animateLabel.transform = translate.concatenating(scale)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 1.0 / 3.0, relativeDuration: 1.0 / 3.0, animations: {
                            let translate = CGAffineTransform(translationX: 0.0, y: -shakeDistance)
                            let scale = CGAffineTransform(scaleX: 1.0, y: 1.2)
                            self.animateLabel.transform = translate.concatenating(scale)
                        })
                        
                        UIView.addKeyframe(withRelativeStartTime: 2.0 / 3.0, relativeDuration: 1.0 / 3.0, animations: {
                            let translate = CGAffineTransform(translationX: 0.0, y: 0.0)
                            let scale = CGAffineTransform.identity
                            self.animateLabel.transform = translate.concatenating(scale)
                        })
                        }, completion: nil)
                    
            })
            let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
            alphaAnimation.values = [1, 1, 0, 1, 1]
            let keyTimes = [
                0,
                2.0/6.0,
                3.0/6.0,
                4.0/6.0,
                1
            ]
            alphaAnimation.keyTimes = keyTimes as [NSNumber]?
            alphaAnimation.duration = duration
            animateLabel.layer.add(alphaAnimation, forKey: nil)
        }
        else
        {
            animateLabel.text = value
        }
    }

}
