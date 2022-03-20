//
//  CameraViewController.swift
//  Instagram
//
//  Created by LYON on 3/20/22.
//

import UIKit
import Parse
import PhotosUI
import AlamofireImage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSubmit(_ sender: Any) {
        
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        
        post["image"] = file
        
        post.saveInBackground { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            } else {
                print("error!")
            }
        }
    }
    
    @IBAction func onCamera(_ sender: Any) {
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
                }
            }
        }
    }
    
//    Old imagePickerController
    
//    @IBAction func onCamera(_ sender: Any) {

//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.allowsEditing = true
//
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                picker.sourceType = .camera
//            } else {
//                picker.sourceType = .photoLibrary
//            }
//
//            present(picker, animated: true, completion: nil)
//    }

//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        let image = info[.editedImage] as! UIImage
//
//        let size = CGSize(width: 300, height: 300)
//        let scaledImage = image.af.imageScaled(to: size)
//
//        imageView.image = scaledImage
//
//        dismiss(animated: true, completion: nil)
//    }
//}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}