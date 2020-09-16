//
//  ViewController.swift
//  MyCalculatorApp
//
//  Created by 梅川浩明 on 2020/09/08.
//  Copyright © 2020 Hiroaki Umekawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum CalculateStatus {
        case none, plus, minus, multiplication, division
    }
       
    var firstNumber = ""
    var secondNumber = ""
    var calculateStatus: CalculateStatus = .none
    
    let numbers = [
        ["C", "%", "$", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]
    
    let cellID = "cellID"
    
    @IBOutlet weak var calculatorCollectionView: UICollectionView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var calculatorHeightConstrait: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    func setupViews(){
        calculatorCollectionView.delegate = self
        calculatorCollectionView.dataSource = self
        calculatorCollectionView.register(CalculatorViewCell.self, forCellWithReuseIdentifier: cellID)
        calculatorHeightConstrait.constant  = view.frame.width * 1.4
        calculatorCollectionView.backgroundColor = .clear
        view.backgroundColor = .black
        calculatorCollectionView.contentInset = .init(top: 0, left: 14, bottom: 0, right: 14)
        
        numberLabel.text = "0"
    }
    
    //クリアを押したときの処理
    func clear(){
        firstNumber = ""
        secondNumber = ""
        numberLabel.text = "0"
        calculateStatus = .none
    }
}


// MARK: -UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0
        
        //セル自体の大きさは・・・（横幅全体からセル間の隙間３つ分の10pxを引いた数）を４分割した数字＝width
        width = ((collectionView.frame.width - 10) - 14 * 5) / 4
        
        let height = width
    
        if indexPath.section == 4 && indexPath.row == 0 {
            width = width * 2 + 14 + 9
        }
        
        //widthとheightをwidthで揃えることによって正方形ができる(以降のborderRadiusで丸形にしている)
        return .init(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calculatorCollectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CalculatorViewCell
        cell.numberLabel.text = numbers[indexPath.section][indexPath.row]
        
        numbers[indexPath.section][indexPath.row].forEach{(numberString) in
            if "0"..."9" ~= numberString || numberString.description == "." {
                cell.numberLabel.backgroundColor = .darkGray
            } else if numberString == "C" || numberString == "%" || numberString == "$"{
                cell.numberLabel.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
                cell.numberLabel.textColor = .black
            }
        }
        
        
        return cell
    }
    
    //四則計算の機能
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let number = numbers[indexPath.section][indexPath.row]
        
        switch calculateStatus {
        case .none:
            handleFirstNumberSelected(number: number)
        case .plus, .minus, .multiplication, .division:
            handleSecondNumberSelected(number: number)
            
        }
    }
    
    private func handleFirstNumberSelected(number: String){
        switch number {
        case "0"..."9":
            firstNumber += number
            numberLabel.text = firstNumber
            //はじめに0が追加されないようにする
            if firstNumber.hasPrefix("0"){
                firstNumber = ""
            }
        case ".":
            if !confirmIncludeDesimaklPoint(numberString: firstNumber){
                firstNumber += number
                numberLabel.text = firstNumber
            }
        case "+":
            calculateStatus = .plus
        case "-":
            calculateStatus = .minus
        case "×":
            calculateStatus = .multiplication
        case "÷":
            calculateStatus = .division
            
        case "C":
            clear()
        default:
            break
        }
    }
    
    private func handleSecondNumberSelected(number: String){
        switch number {
        case "0"..."9":
            secondNumber += number
            numberLabel.text = secondNumber
            
            if secondNumber.hasPrefix("0"){
                secondNumber = ""
            }
        case ".":
            if !confirmIncludeDesimaklPoint(numberString: secondNumber){
                secondNumber += number
                numberLabel.text = secondNumber
            }
        case "=":
           calculateResultNumber()
            
        case "C":
            clear()
        default:
            break
        }
    }
    
    private func calculateResultNumber(){
        let firstNum = Double(firstNumber) ?? 0
        let secondNum = Double(secondNumber) ?? 0
        
        var resultString : String?
        
        switch calculateStatus {
        case .plus:
            resultString = String(firstNum + secondNum)
        case .minus:
            resultString = String(firstNum - secondNum)
        case .multiplication:
            resultString = String(firstNum * secondNum)
        case .division:
            resultString = String(firstNum / secondNum)
        default:
            break
        }
        
        if let result = resultString, result.hasSuffix (".0") {
            resultString = result.replacingOccurrences(of: ".0", with: "")
        }
        
        numberLabel.text = resultString
        firstNumber = ""
        secondNumber = ""
        
        firstNumber += resultString ?? ""
        calculateStatus = .none
    }
    
    private func confirmIncludeDesimaklPoint(numberString: String) -> Bool{
        if numberString.range(of: ".") != nil || numberString.count == 0{
            return true
        } else{
            return false
        }
    }
}

