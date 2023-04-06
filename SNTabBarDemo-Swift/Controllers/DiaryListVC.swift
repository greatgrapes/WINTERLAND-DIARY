//
//  DiaryListVC.swift
//  winterland
//
//  Created by 박진성 on 2023/02/16.
//

import UIKit
import CoreData

class DiaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
   
    
}


class DiaryListVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
 
    
    var diaryData: [NSManagedObject] = []
    var dates: [Date] = []
    var diaryDataByDate: [Date: [NSManagedObject]] = [:]
        
        lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        tableView.reloadData()
    }
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.delegate = self
            tableView.dataSource = self
            
        }
        
    func loadData() {
        // CoreData에서 DiaryData 엔티티 가져오기
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
           let managedContext = appDelegate.persistentContainer.viewContext
           
           // CoreData에서 DiaryData 가져오기
           let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiaryData")
           
        do {
            diaryData = try managedContext.fetch(fetchRequest)
            
            // 날짜 기준으로 정렬
            diaryData.sort { ($0.value(forKeyPath: "date") as? Date ?? Date()) > ($1.value(forKeyPath: "date") as? Date ?? Date()) }
            
            // 날짜별로 그룹화하여 Dictionary 구성
            diaryDataByDate.removeAll()
            dates.removeAll()
            for data in diaryData {
                if let date = data.value(forKeyPath: "date") as? Date {
                    if diaryDataByDate[date] != nil {
                        diaryDataByDate[date]?.append(data)
                    } else {
                        diaryDataByDate[date] = [data]
                        dates.append(date)
                    }
                }
            }
            tableView.reloadData()
           } catch let error as NSError {
               print("Could not fetch. \(error), \(error.userInfo)")
           }
        
    }
        // MARK: - TableViewDataSource
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return dates.count
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let date = dates[section]
            return diaryDataByDate[date]?.count ?? 0
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "diaryCell", for: indexPath) as! DiaryTableViewCell
        
        let date = dates[indexPath.section]
        if let data = diaryDataByDate[date]?[indexPath.row],
           let content = data.value(forKeyPath: "content") as? String {
            cell.contentLabel.text = content
        }
        
        return cell
    }
    

        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 30))
        label.font = UIFont(name: "GyeonggiBatangOTF", size: 15)
        label.text = dateFormatter.string(from: dates[section])
        
        
        view.addSubview(label)
        
        return view
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 30
        }
    
    //삭제코드
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // CoreData에서 해당 데이터 삭제
            let data = diaryDataByDate[dates[indexPath.section]]![indexPath.row]
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(data)
            
            do {
                try managedContext.save() // 변경사항저장
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            // 데이터 소스에서 해당 데이터 삭제
            diaryDataByDate[dates[indexPath.section]]?.remove(at: indexPath.row)
            if diaryDataByDate[dates[indexPath.section]]?.isEmpty ?? false {
                diaryDataByDate.removeValue(forKey: dates[indexPath.section])
                dates.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
     }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           return .delete
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 셀의 데이터 가져오기
        let selectedData = diaryDataByDate[dates[indexPath.section]]![indexPath.row]
        let selectedDate = selectedData.value(forKeyPath: "date") as? Date ?? Date()
        let selectedContent = selectedData.value(forKeyPath: "content") as? String ?? ""

        // 다음 뷰컨트롤러에 데이터 전달
        let vc = storyboard?.instantiateViewController(withIdentifier: "DiaryDetailVC") as! DiaryDetailVC
        vc.selectedDate = selectedDate
        vc.selectedContent = selectedContent
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}




    

