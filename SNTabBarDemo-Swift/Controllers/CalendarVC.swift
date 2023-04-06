//
//  CalendarVC.swift
//  winterland
//
//  Created by 박진성 on 2023/02/16.
//

import UIKit
import FSCalendar

class CalendarVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
  
    // MARK: - Properties
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate: Date = Date()
    private var dateFormatter = DateFormatter()
    private var tasks = [Task]() {
        didSet {    //tasks 배열에 할일이 추가 될 때마다 유저 디폴트에 저장되게
            self.saveTasks()
        }
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTasks()
        // 네비게이션 바 선 없애기
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        setupCanlendarUI()
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "버킷리스트", message: "살면서 이건 꼭 할거야!", preferredStyle: .alert)
               let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
                   guard let title = alert.textFields?[0].text else { return }
                   let task = Task(title: title, done: false)
                   self?.tasks.append(task)
                   //등록버튼을 눌렀을때 텍스트필드에 있는 값을 가져올 수 있다.
                   // textFields는 배열인데, 하나만 넣어놨기 때문에 [0]로 접근했음.
                   self?.tableView.reloadData() // add된 할일들을 테이블뷰에 새로새로 업로드해주는 것
               })
               let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
               alert.addAction(cancelButton)
               alert.addAction(registerButton)
               alert.addTextField(configurationHandler: { textField in
                   textField.placeholder = "하고 싶은 것" })
               self.present(alert, animated: true, completion: nil)
           
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return self.tasks.count
           }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
           // 사용하지 않는 메모리를 낭비하지 않기 위해서 dequeueResusableCell을 이용해서 셀을 재사용 하는 것
           let task = self.tasks[indexPath.row]
           cell.textLabel?.text = task.title
           cell.textLabel?.font = UIFont(name: "gyeonggiBatangOTF", size: 15)
           return cell
       }
    
    func saveTasks() {
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark { // 체크 표시가 있는 경우
                cell.accessoryType = .none // 체크 표시 제거
            } else { // 체크 표시가 없는 경우
                cell.accessoryType = .checkmark // 체크 표시 추가
            }
        }
        tableView.deselectRow(at: indexPath, animated: true) // 선택 해제
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
        
    }
    

    func setupCanlendarUI() {
        
        //모서리깎기
        calendarView.layer.cornerRadius = 20
        
        // 달에 유효하지않은 날짜 지우기
        calendarView.placeholderType = .none
        
        // 달력의 년월 글자 바꾸기
        calendarView.appearance.headerDateFormat = "< YYYY년 M월 >"
        
        calendarView.appearance.headerTitleColor = .gray
        // 달력의 요일 글자 바꾸는 방법
        calendarView.locale = Locale(identifier: "ko_KR")
        // 선택된 날짜의 모서리 설정 ( 0으로 하면 사각형으로 표시 )
        // calendarView.appearance.borderRadius = 0
        // 타이틀 컬러
        calendarView.appearance.titleSelectionColor = .black
        // 서브 타이틀 컬러
        calendarView.appearance.subtitleSelectionColor = .black
        // 달력의 평일 날짜 색깔
        calendarView.appearance.titleDefaultColor = .black
        // 달력의 토,일 날짜 색깔
        calendarView.appearance.titleWeekendColor = .red
        // 달력의 맨 위의 년도, 월의 색깔
        calendarView.appearance.headerTitleColor = .black
        // 달력의 요일 글자 색깔
        calendarView.appearance.weekdayTextColor = .orange
        // 년월에 흐릿하게 보이는 애들 없애기
        calendarView.appearance.headerMinimumDissolvedAlpha = 0
        // 선택한 날짜 색
        calendarView.appearance.selectionColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)
        // 오늘 날짜 색
        calendarView.appearance.todayColor = UIColor(red: 188/255, green: 224/255, blue: 253/255, alpha: 1)
        
        // 배경색
        calendarView.backgroundColor = .clear
        calendarView.appearance.headerTitleColor = .black
        
        // 폰트
        calendarView.appearance.headerTitleFont = UIFont(name: "gyeonggiBatangOTF", size: 18)
        calendarView.appearance.weekdayFont = UIFont(name: "gyeonggiBatangOTF", size: 15)
        // 스와이프 스크롤 작동 여부 ( 활성화하면 좌측 우측 상단에 다음달 살짝 보임, 비활성화하면 사라짐 )
        calendarView.scrollEnabled = true
        
        // 스와이프 스크롤 방향 ( 버티칼로 스와이프 설정하면 좌측 우측 상단 다음달 표시 없어짐, 호리젠탈은 보임 )
        calendarView.scrollDirection = .vertical
        
    }
    
    
}


    extension CalendarVC: FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance{
        
        func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
            switch dateFormatter.string(from: date) {
            case dateFormatter.string(from: Date()):
                return "오늘"
            default:
                return nil
            }
        }
        
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            let alertController = UIAlertController(title: "오늘의 기분☃️", message: "하루 끝, 당신의 기분을 이모티콘으로 표현해보세요.", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "☺️🥹😌😂"
            }
            let saveAction = UIAlertAction(title: "저장", style: .default) { (_) in
                if let text = alertController.textFields?.first?.text {
                    UserDefaults.standard.set(text, forKey: "\(date)")
                    calendar.reloadData()
                    calendar.select(date)
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
        func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
            return UserDefaults.standard.string(forKey: "\(date)")
        }
}
