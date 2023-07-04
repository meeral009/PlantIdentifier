//
//  CameraVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi's iMac on 01/05/23.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {

    // OUTLET
    @IBOutlet weak var imgCaptureImage: UIImageView!
    @IBOutlet weak var btnFlipCamera: UIButton!
    @IBOutlet weak var viewCameraPreview: UIView!
    
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var imgScanner: UIImageView! {
        didSet {
            if UIDevice.current.isPhone {
                imgScanner.image = UIImage.init(named: "scanne-iPhone")
            } else { // iPad
                imgScanner.image = UIImage.init(named: "scanne-iPad")
            }
        }
    }
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewTop: UIView!
    
    
    
    // VARIABLE
    var captureSession: AVCaptureSession!
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    var backInput: AVCaptureInput!
    var frontInput: AVCaptureInput!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!
    
    var takePicture = false
    var backCameraOn = true
    
    var dismissDelegate: DismissViewControllerDelegate?
    var topVC = UITabBarController()
    var plantModel = PlantModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.viewTop.round(corners: [.bottomLeft,.bottomRight], radius: 24)
            self.viewBottom.round(corners: [.topLeft,.topRight], radius: 24)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PermissionManager().checkCameraPermission {
            self.setupAndStartCaptureSession()
        }
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        if !UIDevice.current.hasNotch && UIDevice.current.userInterfaceIdiom != .pad{
            self.bottomViewHeight.constant = 100
            self.topViewHeight.constant = 80
        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
    }
    
    // MARK: - Cameras Methods
    
    
    // Permissions
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
            case .authorized:
            return
            
            case .denied:
            abort()
            
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (authorized) in
                        if(!authorized){
                            abort()
                    }
                })
            
            case .restricted:
                abort()
            
            @unknown default:
                fatalError()
        }
    }
    
    // Camera Setup
    func setupAndStartCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = false
            self.setupInputs()
            
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
            
            self.setupOutput()
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func setupInputs(){
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            displayToast("No back camera")
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            displayToast("No front camera")
        }
        
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            displayToast("Could not create input device from back camera")
            return
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            displayToast("Could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            displayToast("Could not create input device from front camera")
            return
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            displayToast("Could not add front camera input to capture session")
        }
        
        // connect back camera input to session
        captureSession.addInput(backInput)
    }
    
    func setupOutput(){
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            displayToast("Could not add video output")
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.layer.frame // self.view.layer.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        viewCameraPreview.layer.insertSublayer(previewLayer, below: viewCameraPreview.layer)
       
    }
    
    func switchCameraInput(){
        btnFlipCamera.isUserInteractionEnabled = false
        // reconfigure the input
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        captureSession.commitConfiguration()
        btnFlipCamera.isUserInteractionEnabled = true
    }
    
    // MARK: - Methods -
    func searchStone(img: UIImage) {
        self.dismissDelegate?.dismiss(mode: "camera", img: img)
        self.dismiss(animated: true)
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    // MARK: - Button Click
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFlipCameraClicked(_ sender: Any) {
        switchCameraInput()
    }
    
    @IBAction func btnFlashClicked(_ sender: UIButton) {
        sender.isSelected.toggle()
        toggleTorch(on: sender.isSelected)
    }
    
    @IBAction func btnCaptureImageClicked(_ sender: Any) {
        takePicture = true
    }
    
    @IBAction func actionGallery(_ sender: UIButton) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        self.present(imagePickerVC, animated: true)
    }
   
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate -
extension CameraVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !takePicture {
            return
        }
        
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        takePicture = false
        DispatchQueue.main.async {
            self.captureSession.stopRunning()

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CropImageVC") as! CropImageVC
            vc.image = uiImage
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CropImageVC") as! CropImageVC
            vc.image = image
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
       
    }
}
