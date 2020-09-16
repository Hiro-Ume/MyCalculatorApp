//
//  CalculatorViewCell.swift
//  MyCalculatorApp
//
//  Created by 梅川浩明 on 2020/09/15.
//  Copyright © 2020 Hiroaki Umekawa. All rights reserved.
//

import Foundation
import UIKit


//UI部分の実装（ボタンのカラーやサイズ・形など）

class CalculatorViewCell: UICollectionViewCell {
    
    //押しているボタンを暗転させる→　直前に選択されたボタンを暗転し続けるようにしたい
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted{
                self.numberLabel.alpha = 0.3
            }else {
                self.numberLabel.alpha = 1
            }
        }
    }
    
    
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "1"
        label.font = .boldSystemFont(ofSize: 32)
        label.clipsToBounds = true
        label.backgroundColor = .orange
        return label
    }()
    
    override init(frame:CGRect){
        super.init(frame:frame)
        addSubview(numberLabel)
        
        numberLabel.frame.size = self.frame.size
        numberLabel.layer.cornerRadius = self.frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
