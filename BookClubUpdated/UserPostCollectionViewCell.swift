//
//  UserPostCollectionViewCell.swift
//  BookClubUpdated
//
//  Created by Felicity Johnson on 11/29/16.
//  Copyright © 2016 FJ. All rights reserved.
//

import UIKit

class UserPostCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        
    }
    
    private func commonInit() {
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
    }

    
    
}
