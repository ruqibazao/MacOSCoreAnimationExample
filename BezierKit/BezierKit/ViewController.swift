//
//  ViewController.swift
//  BezierKit
//
//  Created by ws on 2021/7/28.
//

import Cocoa

class ViewController: NSViewController {
 
    var mainView: CurveDrawView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.wantsLayer = true
        
        createDrawView()
        view.window?.styleMask = [.titled, .closable, .miniaturizable, .texturedBackground, .unifiedTitleAndToolbar]

       
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func createDrawView() {
        let mainView = CurveDrawView()
        mainView.autoUpdatePoint = true
        mainView.wantsLayer = true
        mainView.layer?.cornerRadius = 50
        self.mainView = mainView
        mainView.wantsLayer = true
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        mainView.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        mainView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        guard let mainView = mainView else { return }
        mainView.clearCurvePoints()
        var tempPoints = [CGPoint]()
        let bounds = mainView.bounds
        for index in 0 ..< 6  {
            let width = bounds.width > 0 ? bounds.width : mainView.defaultSize.width
            let height = bounds.height > 0 ? bounds.height : mainView.defaultSize.height
            let x = Float(width) * (Float(index) / Float(6))
            let y = Int(arc4random() % UInt32(height))
            let point = CGPoint(x: Int(x), y: y)
            tempPoints.append(point)
        }
        mainView.createCurvePoints(tempPoints)
    }
   

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

