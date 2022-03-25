//
//  ViewController.swift
//  MacOSCoreAnimationExample
//
//  Created by nenhall on 2022/3/24.
//

import Cocoa

class ViewController: NSViewController {

    let animationView = AnimationView()
    let animationView2 = AnimationView()
    @IBOutlet weak var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(animationView, positioned: .below, relativeTo: imageView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

//        view.addSubview(animationView2)
//        animationView2.layer?.backgroundColor = NSColor.lightGray.cgColor

    }

    override func viewDidLayout() {
        super.viewDidLayout()
        animationView2.frame = NSRect(x: view.bounds.width - 500, y: 20, width: 500, height: 600)

    }


    @IBAction func top(_ sender: NSButton?) {
//        imageView.image = imageView.image?.transform(orientation: .upMirrored)
        imageView.transformMirrorTheImage(.vertical)
    }

    @IBAction func bottom(_ sender: NSButton?) {
//        imageView.image = imageView.image?.transform(orientation: .downMirrored)
        imageView.transformMirrorTheImage(.horizontal)
    }

    @IBAction func left(_ sender: NSButton?) {
        imageView.image = imageView.image?.transform(orientation: .leftMirrored)
    }

    @IBAction func right(_ sender: NSButton?) {
        imageView.image = imageView.image?.transform(orientation: .rightMirrored)
    }

}

