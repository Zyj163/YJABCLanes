//
//  ViewController.swift
//  YJABCLanes
//
//  Created by Zyj163 on 07/25/2017.
//  Copyright (c) 2017 Zyj163. All rights reserved.
//

import UIKit
import YJABCLanes

struct TestModel: YJABCProtocol {
	var beginTime: TimeInterval
	var liveTime: TimeInterval
	
	var title: String
}

class TestView: YJABCView {
	let label = UILabel()
	
	required init(_ frame: CGRect, reuseIdentifer: String) {
		super.init(frame, reuseIdentifer: reuseIdentifer)
		addSubview(label)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

var t: TimeInterval = 0
class ViewController: UIViewController {

	let abcLanesView = YJABCLanesView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		abcLanesView.delegate = self
		view.addSubview(abcLanesView)
		abcLanesView.frame = CGRect(x: 0, y: 30, width: view.bounds.width, height: 300)
		abcLanesView.backgroundColor = .orange
    }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let m = TestModel(beginTime: t, liveTime: 3, title: "我就是这么屌")
		let m2 = TestModel(beginTime: t + 1, liveTime: 2, title: "屌炸天")
		
		abcLanesView.pushABCs([m, m2])
	}

	@IBAction func resume(_ sender: Any) {
		abcLanesView.resume()
	}
	@IBAction func pause(_ sender: Any) {
		abcLanesView.pause()
	}
}

extension ViewController: YJABCLanesViewProtocol {
	var currentTime: TimeInterval {
		t += 1
		return t
	}
	
	var laneHeigh: CGFloat {
		return 44
	}
	
	var mimusSpaceBetweenABCViews: CGFloat {
		return 10
	}
	
	func abcViewAndWidth(lanesView: YJABCLanesView, forABC abc: YJABCProtocol) -> (YJABCView, CGFloat) {
		
		let abc = abc as! TestModel
		var v = lanesView.dequeue(identifer: "YJABCView") as? TestView
		
		if v == nil {
			v = TestView(CGRect.zero, reuseIdentifer: "YJABCView")
		}
		
		v?.label.text = abc.title
		v?.label.sizeToFit()
		
		return (v!, v!.label.bounds.width)
	}
}








