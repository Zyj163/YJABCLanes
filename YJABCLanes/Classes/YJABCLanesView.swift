//
//  YJABCLanesView.swift
//  YJABCLanes
//
//  Created by ddn on 2017/7/25.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

public protocol YJABCProtocol {
	
	/// 弹幕最早可以出现的时间
	var beginTime: TimeInterval {get}
	
	/// 弹幕展示时间
	var liveTime: TimeInterval {get}
}

public protocol YJABCLanesViewProtocol: class {
	
	/// 当前时间
	var currentTime: TimeInterval {get}
	
	/// 每个航道的高度（航道个数会自动通过该属性及视图高度做计算）
	var laneHeigh: CGFloat {get}
	
	/// 每个弹幕之间的最小间距（开始）
	var mimusSpaceBetweenABCViews: CGFloat {get}
	
	/// 提供弹幕视图，及所占宽度
	///
	/// - Parameters:
	///   - lanesView: 弹幕视图
	///   - abc: 弹幕模型
	/// - Returns: 弹幕视图，及所占宽度
	func abcViewAndWidth(lanesView: YJABCLanesView, forABC abc: YJABCProtocol) -> (YJABCView, CGFloat)
}

private enum YJABCLanesStatus {
	case waitting
	case paused
	case going
}

open class YJABCView: UIView {
	fileprivate var moveSpeed: CGFloat = 0
	
	/// 复用池标记
	public var reuseIdentifer: String = "YJABCView"
	
	required public init(_ frame: CGRect, reuseIdentifer: String) {
		super.init(frame: frame)
		self.reuseIdentifer = reuseIdentifer
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

open class YJABCLanesView: UIView {
	
	fileprivate lazy var abcs: [YJABCProtocol] = [YJABCProtocol]()
	
	fileprivate lazy var abcViews: [Int: [YJABCView]] = [Int: [YJABCView]]()
	
	fileprivate var status: YJABCLanesStatus = .waitting
	
	fileprivate lazy var abcViewsPool: [YJABCView] = [YJABCView]()
	
	/// 代理
	public weak var delegate: YJABCLanesViewProtocol?
	
	fileprivate weak var _timer: Timer?
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	override open func removeFromSuperview() {
		super.removeFromSuperview()
		invalidate()
	}
}

extension YJABCLanesView {
	fileprivate func setup() {
		layer.masksToBounds = true
	}
	
	@discardableResult
	fileprivate func timer() -> Timer {
		if _timer == nil {
			let timer = Timer(timeInterval: 1, target: self, selector: #selector(followTimer), userInfo: nil, repeats: true)
			_timer = timer
			RunLoop.current.add(timer, forMode: .commonModes)
		}
		return _timer!
	}
	
	func followTimer() {
		guard case .going = status else { return }
		
		guard let _ = superview else { return }
		
		guard abcs.count > 0 else { return }
		
		guard let delegate = delegate else { return }
		
		var deleteAbcs = [Int]()
		for (i, abc) in abcs.enumerated() {
			let beginTime = abc.beginTime
			let currentTime = delegate.currentTime
			
			if beginTime > currentTime { break }
			
			if check(abc) { deleteAbcs.append(i) }
		}
		deleteAbcs.reversed().forEach{ abcs.remove(at: $0) }
		if abcs.count == 0 {
			invalidate()
			status = .waitting
		}
	}
	
	private func check(_ abc: YJABCProtocol) -> Bool {
		
		guard let delegate = delegate else { return false }
		
		let laneHeight = delegate.laneHeigh
		
		if laneHeight <= 0 { return false }
		
		let laneCount = Int(bounds.height / laneHeight)
		
		for i in 0..<laneCount {
			
			var leftTimeC: CGFloat = 0.0
			if let currentAbcView = abcViews[i]?.last {
				var maxX: CGFloat = 0
				if let presentLayer = currentAbcView.layer.presentation() {
					maxX = presentLayer.frame.maxX
				}
				if maxX == 0 {
					continue
				}
				if maxX <= bounds.width - delegate.mimusSpaceBetweenABCViews {
					let speedC = currentAbcView.moveSpeed
					leftTimeC = maxX / speedC
				} else {
					continue
				}
			}
			let (abcView, width) = delegate.abcViewAndWidth(lanesView:self, forABC: abc)
			let speedN = (bounds.width + width) / CGFloat(abc.liveTime)
			abcView.moveSpeed = speedN
			
			
			let distanceNInLeftTimeC = speedN * leftTimeC
			if distanceNInLeftTimeC  > bounds.width { continue }
			
			if abcViews[i] == nil {
				abcViews[i] = [YJABCView]()
			}
			
			abcViews[i]?.append(abcView)
			let y = laneHeight * CGFloat(i)
			abcView.frame = CGRect(x: bounds.width, y: y, width: width, height: laneHeight)
			addSubview(abcView)
			
			UIView.animate(withDuration: abc.liveTime, delay: 0, options: .curveLinear, animations: { 
				abcView.frame.origin.x = -abcView.bounds.width
			}, completion: { (_) in
				abcView.removeFromSuperview()
				if let _ = self.dequeue(identifer: abcView.reuseIdentifer, removeFromPool: false) {}
				else { self.abcViewsPool.append(abcView) }
				
				self.abcViews[i] = self.abcViews[i]?.filter{ $0 != abcView }
			})
			
			return true
		}
		return false
	}
}

extension YJABCLanesView {
	
	/// 从复用池中获取弹幕视图
	///
	/// - Parameters:
	///   - identifer: 标志符
	///   - removeFromPool: 是否从复用池中移除
	/// - Returns: 弹幕视图
	public func dequeue(identifer: String, removeFromPool: Bool = true) -> YJABCView? {
		let view = abcViewsPool.first { $0.reuseIdentifer == identifer }
		if removeFromPool {
			abcViewsPool = abcViewsPool.filter { $0.reuseIdentifer != identifer }
		}
		return view
	}
	
	/// 添加弹幕模型，如果处于等待状态，会自动resume
	///
	/// - Parameter abcs: 弹幕模型数组
	public func pushABCs(_ abcs: [YJABCProtocol]) {
		self.abcs.append(contentsOf: abcs)
		self.abcs.sort { $0.beginTime < $1.beginTime }
		
		if case .waitting = status { resume() }
	}
	
	/// 继续
	public func resume() {
		if case .going = status { return }
		
		abcViews.values.forEach { $0.forEach{ $0.layer.resumeAnimate() } }
		timer()
		status = .going
	}
	
	/// 暂停
	public func pause() {
		if case .paused = status { return }
		
		abcViews.values.forEach { $0.forEach{ $0.layer.pauseAnimate() } }
		invalidate()
		status = .paused
	}
	
	fileprivate func invalidate() {
		_timer?.invalidate()
		_timer = nil
		status = .waitting
	}
}

extension CALayer {
	
	/// 暂停动画
	public func pauseAnimate() {
		if speed == 0 { return }
		let pauseTime = convertTime(CACurrentMediaTime(), from: nil)
		speed = 0
		timeOffset = pauseTime
	}
	
	/// 继续动画
	public func resumeAnimate() {
		if speed == 1 { return }
		let pauseTime = timeOffset
		speed = 1
		timeOffset = 0
		beginTime = 0
		let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pauseTime
		beginTime = timeSincePause
	}
}


















