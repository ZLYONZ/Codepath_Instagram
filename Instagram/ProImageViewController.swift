//
//  ProImageViewController.swift
//  Instagram
//
//  Created by LYON on 4/1/22.
//

import UIKit
import Parse
import PhotosUI
import MBProgressHUD
import AlamofireImage

class ProImageViewController: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let profile = PFObject(className: "Profile")
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        profile["image"] = file
        profile["author"] = PFUser.current()!
        
        //user.add(profile, forKey: "profiles")
        
        profile.saveInBackground { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved!")
                MBProgressHUD.hide(for: self.view, animated: true)
            } else {
                print("error!")
            }
        }
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                
        dismiss(animated: true, completion: nil)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    
                    let size = CGSize(width: 300, height: 300)
                    let scaledImage = image.af.imageAspectScaled(toFill: size)
                    
                    self.imageView.image = scaledImage
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
