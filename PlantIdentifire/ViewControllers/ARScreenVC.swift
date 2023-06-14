//
//  ARScreenVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 08/06/23.
//


import ARKit
import Foundation
import SceneKit
import UIKit
import Photos

class ARScreenVC: UIViewController {
    
    //MARK: Outlates
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    //MARK: Mehtods
    
    func initView(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        sceneView.delegate = self
        sceneView.session.run(config)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
//        addBox()
    }
    
    func addBox(){
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.diffuse.contents = #imageLiteral(resourceName: "dummy")
        box.materials = [material]
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let pointOfView = sceneView.pointOfView   // Camera of SCNScene
        else { return }
        
        let cameraMatrix = pointOfView.transform
        
        let desiredVector = SCNVector3(cameraMatrix.m31 * -0.5,
                                       cameraMatrix.m32 * -0.5,
                                       cameraMatrix.m33 * -0.5)
        
        // What the extension SCNVector3 is for //
        let position = desiredVector//pointOfView.position + desiredVector
        
//        let sphereNode = SCNNode()
//        sphereNode.geometry = SCNSphere(radius: 0.05)
//        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
//        sphereNode.position = position
//        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        
//        let text = "Hello, Stack Overflow."
//        let font = UIFont.systemFont(ofSize: 20)
//        let width = 200.0
//        let height = 128.0
//
//        let fontAttrs: [NSAttributedString.Key: Any] =
//        [NSAttributedString.Key.font: font as UIFont]
//
//        let stringSize = text.size(withAttributes: fontAttrs)
//        let rect = CGRect.init(x: CGFloat((width / 2.0) - (stringSize.width/2.0)), y: CGFloat((height / 2.0) - (stringSize.height/2.0)), width: CGFloat(stringSize.width), height: CGFloat(stringSize.height))
//
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(width), height: CGFloat(height)))
//        let image = renderer.image { context in
//
//            let color = UIColor.blue.withAlphaComponent(CGFloat(0.5))
//
//            color.setFill()
//            context.fill(rect)
//
//            text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
//        }
        
        let customView = CustomView.instanceFromNib() as! CustomView
        customView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 80)
//        customView.transform = pointOfView.transform
        let plane = SCNPlane(width: CGFloat(0.26), height: CGFloat(0.1))
        plane.firstMaterial?.diffuse.contents = customView
        
        let box = SCNBox(width: 0.26, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.diffuse.contents = customView
        box.materials = [material]
        
        let sphereNode = SCNNode(geometry: plane)
        
//        sphereNode.geometry = SCNSphere(radius: 0.05)
//        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
//        sphereNode.position = position
//        sceneView.scene.rootNode.addChildNode(sphereNode)
    }

    
    //MARK: Btn Actions
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}

//MARK: ARSCNView Delegate

extension ARScreenVC : ARSCNViewDelegate{
    
}

extension SCNVector3 {
    
    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
}
