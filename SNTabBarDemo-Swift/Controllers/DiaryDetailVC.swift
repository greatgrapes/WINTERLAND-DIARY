//
//  DiaryDetailVC.swift
//  winterland
//
//  Created by 박진성 on 2023/02/28.
//

import UIKit
import CoreData

class DiaryDetailVC: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    private var diaryData: [NSManagedObject] = []
    var selectedDate: Date?
    var selectedContent: String?

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) /// 화면을 누르면 키보드 내려가게 하는 것

    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 선택된 데이터를 화면에 표시
        if let selectedDate = selectedDate {
            dateLabel.text = dateFormatter.string(from: selectedDate)
        }
        textView.text = selectedContent
        
        
        }
        
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // CoreData에서 데이터 업데이트하기
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let selectedDate = selectedDate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiaryData")
        fetchRequest.predicate = NSPredicate(format: "date == %@", selectedDate as CVarArg)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let data = result.first {
                data.setValue(textView.text, forKey: "content")
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        // 이전 화면
        if let vc = navigationController?.viewControllers.first(where: { $0 is DiaryListVC }) {
            navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    
    
    
}
