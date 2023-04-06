//
//  PhotoVC.swift
//  winterland
//
//  Created by 박진성 on 2023/02/16.
//
import Foundation
import UIKit
import CoreData


class PhotoCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: UIImageView!
    // 이미지 데이터를 이용해 이미지 뷰 설정
        
      func configure(with image: UIImage) {
          imageView.image = image
    }
    
}


class PhotoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  UIScrollViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    var diaryDataArray = [DiaryPhoto]()
    
    // 이미지 데이터 배열
    var photoimages: [UIImage] = []
    
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self ,action: #selector(deleteButtonTapped))
        return button
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        self.collectionView.reloadData()
        // 콜렉션 뷰 리로드
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
       
        
    }
    
  
    
    
    func loadData() {
        
        // 코어 데이터에서 이미지 데이터 UIImage 배열에 추가하기
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiaryPhoto")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            diaryDataArray = result as! [DiaryPhoto]
            
            // photoimages 배열에 이미지 데이터 추가하기
            photoimages.removeAll()
            for i in 0..<diaryDataArray.count {
                if let imageData = diaryDataArray[i].photo {
                    if let image = UIImage(data: imageData) {
                        photoimages.append(image)
                    }
                }
            }
        } catch {
            print("Failed to fetch data")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoimages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        DispatchQueue.main.async {
            if indexPath.item < self.photoimages.count {
                // photoimages 배열에 이미지가 있는 경우에만 설정
                cell.imageView.image = self.photoimages[indexPath.item]
            } else {
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택된 셀의 이미지 가져오기
        var selectedImage: UIImage?
        if indexPath.item < self.photoimages.count {
            // photoimages 배열에 이미지가 있는 경우에만 설정
            selectedImage = self.photoimages[indexPath.item]
        }
        
        // 이미지를 풀스크린으로 보여주는 뷰 컨트롤러 생성
        let fullscreenVC = UIViewController()
        fullscreenVC.view.backgroundColor = .black
        
        let imageView = UIImageView(image: selectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 네비게이션 바 아이탬 생성
        fullscreenVC.navigationItem.rightBarButtonItem = deleteButton
        
        
        
        fullscreenVC.view.addSubview(imageView)
        
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: fullscreenVC.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: fullscreenVC.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: fullscreenVC.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: fullscreenVC.view.trailingAnchor),
           
        ])
        
        
        show(fullscreenVC, sender: self)
        
    }
    
    
    @objc func deleteButtonTapped() {
        let alert1Controller = UIAlertController(title: "확인", message: "이미지를 삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            // 선택된 셀의 indexPath.row 값을 가져오기
            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
            let selectedRow = selectedIndexPath.row
            
            // photoimages 배열에서 해당 indexPath.row에 해당하는 이미지 데이터를 삭제
            self.photoimages.remove(at: selectedRow)
            
            // 코어 데이터에서 해당 indexPath.row에 해당하는 DiaryPhoto 객체를 삭제
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let selectedObject = self.diaryDataArray[selectedRow]
            managedContext.delete(selectedObject)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error deleting DiaryPhoto object: \(error.localizedDescription)")
            }
            
            // 컬렉션뷰에서 선택된 셀을 삭제
            self.collectionView.deleteItems(at: [selectedIndexPath])
            
            // 컬렉션뷰 리로드
            self.collectionView.reloadData()
            
            // 네비게이션 컨트롤러 -> 화면 사라지게 pop
            self.navigationController?.popViewController(animated: true)
        }
        
        alert1Controller.addAction(cancelAction)
        alert1Controller.addAction(deleteAction)
        
        self.present(alert1Controller, animated: true, completion: nil)
        
    }
    
    
    
}
    
    
   
    // 레이아웃 지정
extension PhotoVC: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let width = (collectionView.frame.width - spacing * 3 - 10) / 4 // 좌측 inset 값만큼 빼줌
        let height = width
        return CGSize(width: width, height: height)
        
        
    }
    
}

