//
//  StackCell.swift
//  SmartStackUI
//
//  Created by shiba on 2020/11/15.
//

import UIKit

class StackCell: UICollectionViewCell {

    static let reuseIdentifier = "StackCell"

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ text: String) {
        label.text = text
        label.textColor = .white
    }
}
