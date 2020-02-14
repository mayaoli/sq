//
//  EmployeeCollectionCell.swift
//  Employees
//
//  Created by RBC on 2020-02-08.
//  Copyright © 2020 Yaoli.Ma. All rights reserved.
//

import UIKit
import Shimmer

class EmployeeCollectionCell: UICollectionViewCell {

  @IBOutlet weak var imageContainerView: UIView!
  @IBOutlet weak var photoThumbImageView: UIImageView!
  
  @IBOutlet weak var employeeIDLabel: UILabel!
  @IBOutlet weak var fullNameLabel: UILabel!
  @IBOutlet weak var teamLabel: UILabel!
  
  private var shimmeringView = FBShimmeringView()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.shimmeringView.contentView = self.photoThumbImageView
    self.shimmeringView.frame = self.photoThumbImageView.frame
    self.imageContainerView.addSubview(self.shimmeringView)
    
    self.bringSubviewToFront(self.photoThumbImageView)
    self.bringSubviewToFront(self.shimmeringView)
  }
  
//  override func updateConstraints() {
//
//    let top = NSLayoutConstraint(item: shimmeringView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 8)
//    let left = NSLayoutConstraint(item: shimmeringView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 8)
//    
//    contentView.addConstraints([top, left])
//    super.updateConstraints()
//  }
  
  func setContent(_ employee: Employee) {
    self.photoThumbImageView.imageFromUrl(employee.photoSmall ?? "")
    self.employeeIDLabel.text = "ID: " + employee.employeeID
    self.fullNameLabel.text = employee.fullName
    self.teamLabel.text = employee.team
    
    switch employee.employeeType {
    case .CONTRACTOR:
      self.imageContainerView.backgroundColor = .yellow
    case .FULL_TIME:
      self.imageContainerView.backgroundColor = .cyan
    case .PART_TIME:
      self.imageContainerView.backgroundColor = .orange
    default:
      self.imageContainerView.backgroundColor = .lightGray
    }
    
    self.updateConstraints()
    
    if employee.photoSmall == nil {
      self.teamLabel.text = "Loading ..."
      self.shimmeringView.isShimmering = true
    } else {
      self.shimmeringView.isShimmering = false
      
    }
  }

}
