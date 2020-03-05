//
//  JournalCell.swift
//  March3FinalPhotoJournal
//
//  Created by Margiett Gil on 3/3/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import UIKit
// step 1: creating custom delegation - define protocol
protocol JournalCollectionDelegate: AnyObject { // AnyObject requires ImageCellDelegate only works with class types
    
    // list required functions, initializers, variables
    func clickCell(index: Int, photoCell: JournalCell)
}

class JournalCell: UICollectionViewCell {
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy, hh:mm a"
        formatter.timeZone = .current
        return formatter
    }()
     // step 2: creating custom delegation - define optional delegate variable
    var cellDelegate: JournalCollectionDelegate?
    var index: IndexPath?
    
    func configureCell(for photo: ImageObject) {
        layer.cornerRadius = 20
        descriptionLabel.text = photo.description
        dateLabel.text = dateFormatter.string(from: photo.date)
        // converting Data to UIImage
        guard let image = UIImage(data: photo.imageData) else {
            return
        }
        photoImage.image = image
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        cellDelegate?.clickCell(index: (index?.row)!, photoCell: self)
    }
    
}
