//
//  MacOSUtil.swift
//  editorCC
//
//  Created by diogo henrique on 01/03/2016.
//

import Cocoa
import AVFoundation


class MacOSUtil {
    
    
    func openPaneltoChooseAVideo(){
        
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mp4","mov"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        panel.beginWithCompletionHandler{ (result: Int) -> Void in if result == NSFileHandlingPanelOKButton{
            let exportedFileURL = panel.URL
            print(exportedFileURL)
            
            }
            
        }
        
        
    }
    
    /**
     Show a default alert
     */
    func showMessage(let value: String){
        let alert = NSAlert.init()
        alert.messageText = value
        alert.addButtonWithTitle("Ok")
        alert.runModal()
    }
    
    /**
     Method to format CMTime. The output format is HH:mm:ss
     */
    func formatTime(let value: CMTime)-> String{
        let durationSeconds: Int = Int(CMTimeGetSeconds(value))
        let hours: Int = Int(durationSeconds / 3600)
        let minutes: Int = Int(durationSeconds % 3600 / 60)
        let seconds: Int = Int(durationSeconds % 3600 % 60)
        let time2: String = String(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
        return time2
    }
    
    
    
    /**
     Method cut a video/audio using AVFoundation.
     
     The startTime and endTime are in seconds.
     
     */
    func exportAndCutAsset(asset:AVAsset, fileName:String, start: CMTime, end: CMTime, onlyAudio: Bool) {
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let trimmedFileURL = documentsDirectory.URLByAppendingPathComponent(fileName)
        //print("saving to \(trimmedFileURL.absoluteString)")
        
        let filemanager = NSFileManager.defaultManager()
        if !filemanager.fileExistsAtPath(trimmedFileURL.absoluteString) {
            //print("no exists")
            
            let exporter = AVAssetExportSession(asset: asset, presetName:  onlyAudio ? AVAssetExportPresetAppleM4A : AVAssetExportPreset640x480)
            exporter!.outputFileType = onlyAudio ? AVFileTypeAppleM4A : AVFileTypeMPEG4
            exporter!.outputURL = trimmedFileURL
            
            // length of time
            let exportTimeRange = CMTimeRangeFromTimeToTime(start, end)
            exporter!.timeRange = exportTimeRange
            
            // do it
            exporter!.exportAsynchronouslyWithCompletionHandler({
                switch exporter!.status {
                case  AVAssetExportSessionStatus.Failed:
                    print("export failed \(exporter!.error)")
                case AVAssetExportSessionStatus.Cancelled:
                    print("export cancelled \(exporter!.error)")
                default:
                    print("export complete")
                }
            })
            
            
        }
        
      
    }
    
     /**
     Method to execture ffmpeg commands
     
     Make sure that you have the ffmpeg file on your project
     
     */
    func execFFmpeg(commandLine: String) -> Int32 {
        
        if let path = NSBundle.mainBundle().pathForResource("ffmpeg", ofType:"") {
            return system("\(path) \(commandLine)")
        }else{
            print("no path")
            return 999
        }
    }
    
    
    /**
     Method to generate a thumbnail from url. The url can be from the internet or a local file.
     
     Ex: myUtils.generateThumbnail(NSURL(string: localVideo!)!, timeTo: startTime)
     
     */
    func generateThumbnail(url : NSURL, timeTo: CMTime) -> NSImage{
        let asset = AVAsset(URL: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var thumbnail : CGImageRef!
        
        do{
            thumbnail = try assetImgGenerate.copyCGImageAtTime(timeTo, actualTime: nil)
            
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        return NSImage.init(CGImage: thumbnail, size: NSZeroSize)
    }
    
    
    /**
     Method to generate a png image from a NSImage. The fileName must have the type as well...example: test.png
     */
    func saveNSImageIntoDisk(image: NSImage, fileName: String) -> String{
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let trimmedFileURL = documentsDirectory.URLByAppendingPathComponent(fileName)
        let aa = image.TIFFRepresentation
        
        if aa!.writeToFile(trimmedFileURL.path!, atomically: true){
            return trimmedFileURL.path!
        }else{
            return ""
        }
        
        
    }
    
    /**
     Method to remove file from main document folder.
     */
    func removeVideo(fileName: String) {
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let trimmedFileURL = documentsDirectory.URLByAppendingPathComponent(fileName)
        let filemanager = NSFileManager.defaultManager()
        
        do{
            try filemanager.removeItemAtURL(trimmedFileURL)
        }catch{
            print("previous file doesn't exist")
        }
        
    }
    
     /**
     Method to animate a view.
     */
    func animView(view:NSView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.10
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue =  NSValue(point: CGPointMake(view.frame.origin.x - 10, view.frame.origin.y ))
        animation.toValue =  NSValue(point: CGPointMake(view.frame.origin.x + 10, view.frame.origin.y ))
        view.layer?.addAnimation(animation, forKey: "position")
    }
    
     /**
     Get the video CGSize
     
        * Example: 640:360
    */
    func resolutionSizeForVideo(url:NSURL) -> CGSize? {
        guard let track = AVAsset(URL: url).tracksWithMediaType(AVMediaTypeVideo).first else { return nil }
        let size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    
}
