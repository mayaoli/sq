//
//  EmployeesViewController.swift
//  Employees
//
//  Created by YM on 2020-02-08.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import UIKit

class EmployeesViewController: UIViewController {

  @IBOutlet weak var collectionVW: UICollectionView!
  
  var employeeVM: EmployeeViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.title = "Employee List"
    self.navigationController?.navigationBar.barStyle = .black
    
    self.collectionVW.register(UINib(nibName: "EmployeeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "employee")
    
    self.navigationItem.rightBarButtonItem = {
      let temp = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .done, target: self, action: #selector(self.tappedRefreshButton))
      temp.accessibilityIdentifier = "refresh_button"
      temp.accessibilityLabel = "refresh"
      return temp
    }()
    
    self.bindData()
  }

  func bindData() {
    self.employeeVM = EmployeeViewModel()
    
    self.employeeVM.employeeList.bind { [weak self] list in
      guard let strongSelf = self else {
        return
      }
      
      strongSelf.collectionVW.dataSource = strongSelf
      strongSelf.collectionVW.delegate = strongSelf
      strongSelf.collectionVW.reloadData()
    }
    
    self.employeeVM.loading()
    
    self.employeeVM.fetchData { error in
      guard error == nil else {
        if error == .unknown {
          self.showMessage(title: "Error", message: "We are experiencing an technical issue, please use refresh button to reload ...")
        } else {
          self.showMessage(title: "Error", message: error!.localizedDescription)
        }
        return
      }
      
      //self.employeeVM.cacheImages()
    }
    
  }
  
  private func showMessage(title: String?, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    
    if let previousAlertController = self.presentedViewController as? UIAlertController {
      // Dismiss that alert and show a new one
      previousAlertController.dismiss(animated: true, completion: {
        self.present(alertController, animated: true, completion: nil)
      })
    } else {
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  @objc private func tappedRefreshButton() {
    self.bindData()
  }
}


extension EmployeesViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // let cell = collectionView.cellForItem(at: indexPath)
    
    // Do some here, ex. show details
    print(indexPath)
  }
}

extension EmployeesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.employeeVM.getEmployeeNumbers()
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "employee", for: indexPath) as? EmployeeCollectionCell {
      if let ep = self.employeeVM.getEmployee(atIndex: indexPath.row) {
        cell.setContent(ep)
      }
      return cell
    }
    
    return UICollectionViewCell()
  }
  
}

extension EmployeesViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return CGSize(width: 270.0, height: 160.0)
   
  }
}
