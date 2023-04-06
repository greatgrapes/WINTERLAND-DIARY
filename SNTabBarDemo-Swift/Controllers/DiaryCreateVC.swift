//
//  DiaryCreateVC.swift
//  winterland
//
//  Created by 박진성 on 2023/02/20.
//

import UIKit
import CoreData


class DiaryCreateVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{

    // MARK: - Properties
    @IBOutlet weak var clearButtonTapped: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var attachImageButton:
    UIButton!
    @IBOutlet weak var subView: UIView!

    
    private let image = UIImage(systemName: "cloud.snow")
    
    // 포토탭 뷰 컨트롤러에 전달할 이미지 데이터 배열
    private var photoimages: [UIImage] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        subView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(subView)
        
        let imageSubview = UIImageView()
        imageSubview.translatesAutoresizingMaskIntoConstraints = false
        subView.addSubview(imageSubview)
        
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            subView.topAnchor.constraint(equalTo: imageView.topAnchor),
            subView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            imageSubview.leadingAnchor.constraint(equalTo: subView.leadingAnchor),
               imageSubview.trailingAnchor.constraint(equalTo: subView.trailingAnchor),
               imageSubview.topAnchor.constraint(equalTo: subView.topAnchor),
               imageSubview.bottomAnchor.constraint(equalTo: subView.bottomAnchor)
        ])
        
        // 템플릿이미지를 넣어서 시스템사진의 색깔을 검은색으로 만듬..
        let templateImage = image?.withRenderingMode(.alwaysTemplate)
        imageSubview.image = templateImage
        imageSubview.tintColor = .black
        imageSubview.contentMode = .scaleAspectFit
        imageSubview.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow2), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide2), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textBox.font = UIFont(name: "gyeonggiTitle", size: 17)
        
        
        mainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textBox.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) /// 화면을 누르면 키보드 내려가게 하는 것

    }
    

    // MARK: - Actions
    
    @objc func keyboardWillShow(notification: Notification) {
    if let userInfo = notification.userInfo,
    let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
    // Get the height of the keyboard
    let keyboardHeight = keyboardFrame.height
                
    // Adjust the position of the button's container view
        attachImageButton.frame.origin.y = view.bounds.height - keyboardHeight - attachImageButton.frame.height
            }
        }
                                               
    // Selector method for keyboardWillHideNotification
    @objc func keyboardWillHide(notification: Notification) {
    // Reset the position of the button's container view
            attachImageButton.frame.origin.y = view.bounds.height - attachImageButton.frame.height
        }

    
    @objc func keyboardWillShow2(notification: Notification) {
    if let userInfo = notification.userInfo,
    let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
    // Get the height of the keyboard
    let keyboardHeight = keyboardFrame.height
                
    // Adjust the position of the button's container view
        clearButtonTapped.frame.origin.y = view.bounds.height - keyboardHeight - clearButtonTapped.frame.height
            }
        }
    
    @objc func keyboardWillHide2(notification: Notification) {
    // Reset the position of the button's container view
        if let button = clearButtonTapped {
            button.frame.origin.y = view.bounds.height - button.frame.height
        }
    }
    
    // MARK: - Helpers
    func mainUI() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
               
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        dateLabel.text = dateString
        
        let attributedString = NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        dateLabel.attributedText = attributedString
        dateLabel.font = UIFont(name: "GyeonggiTitleVOTF", size: 15)
        
        textBox.delegate = self
        textBox.backgroundColor = .white
        
    }
    

   
    
    
    @IBAction func exitButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        // 사용자가 입력한 정보 가져오기
         let date = Date()
         let content = textBox.text ?? ""
         let photo = imageView.image?.jpegData(compressionQuality: 1.0)
        
        if content.isEmpty && photo == nil {
                // 텍스트와 이미지 둘 다 없으면 저장하지 않고 화면 닫기
                self.dismiss(animated: true, completion: nil)
                return
            }
            // 코어 데이터에 저장
            saveDiaryData(date: date, content: content)
            saveDiaryPhoto(photo: photo)
    
           // 저장 완료 - 화면창 닫기
           self.dismiss(animated: true)
        
    }
   
    
    func saveDiaryData(date: Date, content: String){
      // 코어 데이터에서 사용할 NSManagedObjectContext 객체 가져오기
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext = appDelegate.persistentContainer.viewContext
      
      // DiaryData 엔티티를 코어 데이터에 추가하기
      guard let entity = NSEntityDescription.entity(forEntityName: "DiaryData", in: managedContext) else {
        return
      }
      let diaryData = NSManagedObject(entity: entity, insertInto: managedContext)
      
      
      // DiaryData 엔티티의 각 속성에 값을 할당하기
      diaryData.setValue(date, forKeyPath: "date")
      diaryData.setValue(content, forKeyPath: "content")
      
      // 코어 데이터에 변경 사항 저장하기
      do {
        try managedContext.save()
        print("Diary data saved successfully")
          
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    
    
    func saveDiaryPhoto(photo: Data?) {
      // 코어 데이터에서 사용할 NSManagedObjectContext 객체 가져오기
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext = appDelegate.persistentContainer.viewContext
      
      // DiaryData 엔티티를 코어 데이터에 추가
      guard let entity = NSEntityDescription.entity(forEntityName: "DiaryPhoto", in: managedContext) else {
        return
      }
      let diaryPhoto = NSManagedObject(entity: entity, insertInto: managedContext)
      
      
      // DiaryData 엔티티의 각 속성에 값을 할당
        if let photoData = photo {
             diaryPhoto.setValue(photoData, forKeyPath: "photo")
        } else{
        }
      
      // 코어 데이터에 변경 사항 저장
      do {
        try managedContext.save()
        print("Diary data saved successfully")
          
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    @IBAction func attachImageButtonPressed(_ sender: UIButton) { let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.image = image
            }
            dismiss(animated: true, completion: nil)
        subView.isHidden = true
        }

}


extension DiaryCreateVC {
//
//    func textViewDidChange(_ textView: UITextView) {
//        /// 글자 수 제한
//        if textBox.text.count > 150 {
//            textBox.deleteBackward()
//        }
//
//        //        /// 아래 글자 수 표시되게 하기
//        //        letterNumLabel.text = "\(textBox.text.count)/150"
//        //
//        //        /// 글자 수 부분 색상 변경
//        //        let attributedString = NSMutableAttributedString(string: "\(textBox.text.count)/150")
//        //        attributedString.addAttribute(.foregroundColor, value: UIColor.systemPink, range: ("\(textBox.text.count)/150" as NSString).range(of:"\(textBox.text.count)"))
//        //        letterNumLabel.attributedText = attributedString
//        //    }
//        //}
    
}

