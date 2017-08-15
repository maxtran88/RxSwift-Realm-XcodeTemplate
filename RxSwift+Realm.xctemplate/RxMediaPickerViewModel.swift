//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import RxSwift
import RxMediaPicker
import AVFoundation

class RxMediaPickerViewModel: NSObject {
    
    private var picker: RxMediaPicker!
    private(set) var selectedImage: Variable<UIImage?> = Variable(nil)
    fileprivate(set) var selectedVideoURL: Variable<URL?> = Variable(nil)
    
    private(set) var error: Variable<Error?> = Variable(nil)
    
    var navigationController: UINavigationController?
    override init() {
        super.init()
        picker = RxMediaPicker(delegate: self)
    }
    
    convenience init(navigationController: UINavigationController?) {
        self.init()
        self.navigationController = navigationController
    }
    
    func showImagePicker(editable: Bool) {

        let source = picker.selectImage(source: UIImagePickerControllerSourceType.photoLibrary, editable: editable)
        _ = source.subscribe(onNext: { (image: (originalImage: UIImage, editImage: UIImage?)) in
            if editable {
                self.selectedImage.value = image.editImage
            } else {
                self.selectedImage.value = image.originalImage
            }

        }, onError: { (err: Error) in
            self.error.value = err
        })
    }
    
    func showCamera(editable: Bool) {
        
        let source = picker.takePhoto(device: UIImagePickerControllerCameraDevice.rear, flashMode: UIImagePickerControllerCameraFlashMode.auto, editable: editable)
        _ = source.subscribe(onNext: { (image: (originalImage: UIImage, editImage: UIImage?)) in
            if editable {
                self.selectedImage.value = image.editImage
            } else {
                self.selectedImage.value = image.originalImage
            }
            
        }, onError: { (error: Error) in
            self.error.value = error
        })
    }
    
    func showMoviePicker(editable: Bool) {
        let source = picker.selectVideo(source: UIImagePickerControllerSourceType.photoLibrary, maximumDuration: 30, editable: editable)
        _ = source.subscribe(onNext: { (videoURL: URL) in
            self.selectedVideoURL.value = videoURL
        }, onError: { (error: Error) in
            self.error.value = error
        })
    }
    
    func getVideoThumbnail(url: URL) -> UIImage {
        
        let asset = AVAsset(url: url)
    
        let sec = 0.5
        guard sec >= 0 && asset.duration.seconds > sec else {
            return UIImage()
        }
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore  = kCMTimeZero
        generator.requestedTimeToleranceAfter   = kCMTimeZero
        generator.maximumSize = CGSize(width: 1000, height: 1000)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let assetTransform = assetTrack.preferredTransform
        
        do {
            let capImage = try generator.copyCGImage(at: CMTimeMakeWithSeconds(sec, Int32(NSEC_PER_SEC)), actualTime: nil)
            
            if assetTransform.c == -1.0 {
                
                return UIImage(cgImage: capImage, scale: 1.0, orientation: .right)
            } else {
            
                return UIImage(cgImage: capImage)
            }
        } catch {
            print("error")
        }
        
        return UIImage()
    }
    
    public static func convertMp4Video(url: URL, callback: @escaping ((URL) -> Void)) {
        let videoAsset = AVURLAsset(url: url)
        convertMp4Video(videoAsset) { (url) in
            callback(url)
        }
    }
    
    public static func convertMp4Video(_ asset: AVAsset!,
                                       outputPresetName: String = AVAssetExportPresetMediumQuality,
                                       callback:@escaping ((URL) -> Void)) {
        var exportSsn: AVAssetExportSession?
        let exportDocsStr: NSString
        let exportFileStr: NSString
        let exportFileUrl: URL
        
        exportDocsStr = (NSHomeDirectory() as NSString).appendingPathComponent("Documents") as NSString
        exportFileStr = NSString(string: "\(exportDocsStr)/upLoad_movieFile.mp4")
        exportFileUrl = URL(fileURLWithPath: exportFileStr as String)
        
        if FileManager.default.fileExists(atPath: exportFileStr as String) {
            do {
                try FileManager.default.removeItem(atPath: exportFileStr as String)
            } catch {
            }
        }
        
        exportSsn = AVAssetExportSession(asset: asset, presetName: outputPresetName)
        exportSsn!.outputURL = exportFileUrl
        exportSsn!.outputFileType = AVFileTypeMPEG4
        exportSsn!.shouldOptimizeForNetworkUse = true
        //exportSsn!.videoComposition = videoComposition;
        exportSsn!.exportAsynchronously(completionHandler: {
            switch exportSsn!.status {
            case AVAssetExportSessionStatus.cancelled:
                //print("canceled")
                break
            case AVAssetExportSessionStatus.failed:
                //print("failed")
                break
            case AVAssetExportSessionStatus.completed:
                let compredData: Data = try! Data(contentsOf: (exportSsn?.outputURL)!)
                
                //data size > 20MB
                if compredData.count >= 30 * 1000 * 1000 {
                    convertMp4Video(asset, outputPresetName: AVAssetExportPreset1280x720, callback: callback)
                    return
                }
                
                DispatchQueue.main.sync {
                    callback(exportSsn!.outputURL!)
                }
                break
            case AVAssetExportSessionStatus.unknown:
                //print("uncknow")
                break
            case AVAssetExportSessionStatus.exporting:
                //print("exporting")
                break
            case AVAssetExportSessionStatus.waiting:
                //print("waiting")
                break
            }
        })
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
}

extension RxMediaPickerViewModel: RxMediaPickerDelegate {
    
    func present(picker: UIImagePickerController) {
        
        picker.navigationBar.tintColor = UIColor.lightGray
        
        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(pickerSkipped))
        skipButton.tintColor = UIColor.black
        picker.navigationItem.setLeftBarButton(skipButton, animated: false)
        picker.navigationController?.navigationItem.setLeftBarButton(skipButton, animated: false)
        
        if let nav = self.navigationController {
            nav.present(picker, animated: true, completion: nil)
            return
        }
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.navigationController?.present(picker, animated: true, completion: nil)
    }
    
    @objc func pickerSkipped(_ picker: UIImagePickerController) {
        self.dismiss(picker: picker)
    }
    
    @objc func dismiss(picker: UIImagePickerController) {
        if let nav = self.navigationController {
            nav.dismiss(animated: true, completion: nil)
            return
        }
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.navigationController?.viewControllers.last?.dismiss(animated: true, completion: nil)
    }
}
