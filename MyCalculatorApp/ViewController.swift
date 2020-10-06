//
//  ViewController.swift
//  MyCalculatorApp
//
//  Created by Hiro-Ume on 2020/09/08.
//  Copyright © 2020 Hiro Ume. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum CalculateStatus {
        case none, plus, minus, multiplication, division, percentage
    }
       
    var firstNumber = ""
    var secondNumber = ""
    var calculateStatus: CalculateStatus = .none
    
    let numbers = [
        ["C", "M", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]
    
    let cellID = "cellID"
    
    @IBOutlet weak var calculatorCollectionView: UICollectionView!
    @IBOutlet weak var memoryLabel: UILabel!
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
        memoryLabel.text = "0"
    }
    
    //クリアを押したときの処理
    func clear(){
        if firstNumber == "" &&
        secondNumber == "" &&
        numberLabel.text == "0" &&
        calculateStatus == .none {
            memoryLabel.text = "0"
        }
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
            } else if numberString == "C" || numberString == "M" || numberString == "%"{
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
        case .plus, .minus, .multiplication, .division, .percentage:
            handleSecondNumberSelected(number: number)
        }
    }
    
    private func handleFirstNumberSelected(number: String){
        switch number {
        case "0"..."9":
            firstNumber += number
            numberLabel.text = firstNumber
            //はじめに0が追加されないようにする
            //before　hasprefixは文字列が含まれていればtrueを返す
//            if firstNumber.hasPrefix("0"){
//                firstNumber = ""
//            }
            //after
            if firstNumber == "0"{
                firstNumber = ""
            }
        case ".":
            //小数点を打ったときにまず何も文字列が入っていなければ0を入れる
            if firstNumber == ""{
                firstNumber = "0"
            }
            //小数点が入っていないまたは数字が0のときは小数点を追加する
            if !confirmIncludeDesimalPoint(numberString: firstNumber){
                firstNumber += number
                numberLabel.text = firstNumber
            }
        case "%":
            if firstNumber != ""{
            calculateStatus = .percentage
            calculateResultNumber()
            }
        case "M":
            memoryLabel.text = firstNumber
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
            
            if secondNumber == "0"{
                secondNumber = ""
            }
        case ".":
            if secondNumber == ""{
                secondNumber = "0"
            }
            
            if !confirmIncludeDesimalPoint(numberString: secondNumber){
                secondNumber += number
                numberLabel.text = secondNumber
            }
        case "%":
            calculateStatus = .percentage
            calculateResultNumber()
        case "M":
            memoryLabel.text = secondNumber
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
        //％の計算(下記のままだとfirstNumの値しか取れないのでsecondNumの計算ができない）
        case .percentage:
            resultString = String(firstNum * 0.01)
        
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
    
    
    //小数点が入っていないまたは数字が0のときはtrueを返す
    private func confirmIncludeDesimalPoint(numberString: String) -> Bool{
        if numberString.range(of: ".") != nil || numberString.count == 0{
            return true
        } else{
            return false
        }
    }
}

