//
//  ViewController.swift
//  SCNTextDemo
//
//  Created by Pawel Leszkiewicz on 20/10/2020.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    private var arView: ARSCNView!
    private var rootNode: SCNNode {
        return arView.scene.rootNode
    }
    
    override var shouldAutorotate: Bool { return true }
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = setupARView()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arView.session.run(ARWorldTrackingConfiguration(), options: [])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    fileprivate func setupARView() -> ARSCNView {
        var options: [String : Any] = [:]
    #if targetEnvironment(simulator)
        // We need to set openGLES API explicitely in iOS 14, otherwise the app crashes
        options[SCNView.Option.preferredRenderingAPI.rawValue] = NSNumber(value: SCNRenderingAPI.openGLES2.rawValue)
    #endif
        
        let arView = ARSCNView(frame: CGRect.zero, options: options)
    #if targetEnvironment(simulator)
        // This line is needed in iOS 14, otherwise we will get a blank screen
        arView.scene = SCNScene()
    #endif
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        arView.backgroundColor = .clear//UIColor(white: 55.0 / 255.0, alpha: 1.0)
        arView.rendersContinuously = true
        arView.scene.rootNode.name = "root"
        
        // Add AR view as a child
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        NSLayoutConstraint.activate([
            arView.leftAnchor.constraint(equalTo: view.leftAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.rightAnchor.constraint(equalTo: view.rightAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    #if targetEnvironment(simulator)
        arView.allowsCameraControl = true
        arView.defaultCameraController.interactionMode = SCNInteractionMode.orbitTurntable
        arView.defaultCameraController.maximumVerticalAngle = 45
        arView.defaultCameraController.inertiaEnabled = true
        arView.defaultCameraController.translateInCameraSpaceBy(x: 0.0, y: 0.0, z: 1.5)
    #endif

        // Set camera's range
        arView.pointOfView?.camera?.zNear = 0.001
        arView.pointOfView?.camera?.zFar = 10

        return arView
    }

    private func setupScene() {
        let fontSize: CGFloat = 20.0
        let z: CGFloat = -1
        let suffix: String =  "abcdefghijklmnopqrstuvwxyz:123456789"
        let regularFont: UIFont = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
//        let regularFont: UIFont = UIFont(name: "HelveticaNeue", size: fontSize)!  // this works
        rootNode.addChildNode(createTextNode(text: "[regular]: " + suffix, font: regularFont, position: SCNVector3(0, 0.1, z)))
        
        let boldFont: UIFont = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)
//        let boldFont: UIFont = UIFont(name: "HelveticaNeue-Bold", size: fontSize)! // this works
        rootNode.addChildNode(createTextNode(text: "[bold]: " + suffix, font: boldFont, position: SCNVector3(0, 0, z)))
        
        let italicFont: UIFont = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular).with(traits: .traitItalic)
        rootNode.addChildNode(createTextNode(text: "[italic]: " + suffix, font: italicFont, position: SCNVector3(0, -0.1, z)))
    }
    
    private func createTextNode(text: String, font: UIFont, position: SCNVector3) -> SCNNode {
        let attributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: font
        ]
        let string = NSAttributedString(string: text, attributes: attributes)
        let textGeometry = SCNText(string: string, extrusionDepth: 0.1)
        textGeometry.flatness = 0.5
        textGeometry.firstMaterial?.lightingModel = .constant
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        
        let scale: CGFloat = 0.05 / font.pointSize
        textNode.scale = SCNVector3(scale, scale, scale)
        return textNode
    }
}

extension UIFont {
    public func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: 0)
    }
}

