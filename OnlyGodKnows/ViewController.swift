//
//  ViewController.swift
//  OnlyGodKnows
//
//  Created by first on 2021/03/18.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    var pieChartsView = PieChartView()
    // グラフに表示するデータのタイトルと値
    var dataEntries = [
        PieChartDataEntry(value: 40, label: "A"),
        PieChartDataEntry(value: 35, label: "B"),
        PieChartDataEntry(value: 25, label: "C")
    ]
    var dataSet = PieChartDataSet()
    
    var isStop = true
    var controllButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title(for: .highlighted)
        button.setTitle("start", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    var registerButton:UIButton = {
        let button = UIButton()
        button.setTitle("登録", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapRegisterButton), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        return button
    }()
    
    var indicatorImage:UIImageView = {
        var image = UIImageView(image: UIImage(systemName: "shift.fill"))
        image.backgroundColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .black
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 円グラフの中心に表示するタイトル
        self.pieChartsView.centerText = "テストデータ"
        dataSet = PieChartDataSet(entries: dataEntries, label: "テストデータ")


        dataSet.notifyDataSetChanged()
        self.pieChartsView.notifyDataSetChanged()
        pieChartsView.data?.notifyDataChanged()
        // グラフの色
        dataSet.colors = ChartColorTemplates.vordiplom()
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.black
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black
        pieChartsView.rotationEnabled = false
        pieChartsView.drawHoleEnabled = false
        pieChartsView.highlightPerTapEnabled = false
        self.pieChartsView.data = PieChartData(dataSet: dataSet)
        pieChartsView.backgroundColor = .white
        view.backgroundColor = .white
        pieChartsView.legend.enabled = false
        pieChartsView.translatesAutoresizingMaskIntoConstraints = false
        
        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        self.pieChartsView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        self.pieChartsView.usePercentValuesEnabled = true
        
        view.addSubview(self.pieChartsView)
        view.addSubview(self.indicatorImage)
        view.addSubview(self.controllButton)
        view.addSubview(self.registerButton)
        pieChartsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        pieChartsView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pieChartsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height / 3).isActive = true
        
        indicatorImage.topAnchor.constraint(equalTo: pieChartsView.bottomAnchor,constant: -140 ).isActive = true
        indicatorImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width / 3).isActive = true
        indicatorImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width / 3).isActive = true
        indicatorImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        controllButton.topAnchor.constraint(equalTo: indicatorImage.bottomAnchor, constant: 10 ).isActive = true
        controllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width / 3).isActive = true
        controllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width / 3).isActive = true
        controllButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        registerButton.topAnchor.constraint(equalTo: controllButton.bottomAnchor, constant: 10 ).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width / 3).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width / 3).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    
    
    @objc func didTapButton(){
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        if isStop {
            controllButton.setTitle("stop", for: .normal)
            pieChartsView.layer.speed = 2.0
            animation.toValue = .pi / 2.0
            animation.duration = 0.1
            animation.repeatCount = MAXFLOAT
            animation.isCumulative = true
            pieChartsView.layer.add(animation, forKey: "ImageViewRotation")
            isStop = false
        } else {
            controllButton.setTitle("start", for: .normal)
            let pausedTime = pieChartsView.layer.convertTime(CACurrentMediaTime(), from: nil)
            pieChartsView.layer.speed = 0.0
            pieChartsView.layer.timeOffset = pausedTime
            isStop = true
            
            // 現在の回転角度を得る
            if let transform = pieChartsView.layer.presentation()?.transform {
                let angle = atan2(transform.m12, transform.m11)
                var testAngle = (angle * 180) / CGFloat.pi

                // 逆回転として考える（矢印の方が回転したと考える）
                if testAngle < 0 {
                    // マイナスならプラスにする
                    testAngle.negate()
                } else {
                    testAngle = 360 - testAngle
                }

                // 矢印の位置
                print("final: \(testAngle)º")

                // 360° = 100% とした時の割合
                let per = Int((testAngle) / 3.60)
                print("per: \(per)")

                // 40:35:25 のグラフであれば、
                // 0..<40 -> A
                // 40..<75 -> B
                // 75...100 -> C
                // 一般化するにはもう一工夫必要
                if per < 40 {
                    print("A")
                } else if per < 40 + 35 {
                    print("B")
                } else {
                    print("C")
                }
            }
        }
        
    }
        @objc func tapRegisterButton() {
            let alert = UIAlertController(title: "登録",message: "選択肢を決めてください",preferredStyle: .alert)
            alert.view.tintColor = UIColor.brown
            alert.view.backgroundColor = UIColor.lightGray
            alert.view.layer.cornerRadius = 25
            var percentage = 0
            setSelections{ selectNum in
                print(selectNum)
                
                for i in 0..<selectNum {
                    
                    percentage = 100 *  1 / selectNum
                    alert.addTextField { (textField: UITextField) in
                        textField.keyboardAppearance = .dark
                        textField.keyboardType = .default
                        textField.autocorrectionType = .default
                        textField.placeholder = "\(i) + 番目"
                    }
                }
                print(percentage)
                let OkALert = UIAlertAction(title: "登録", style: .default) { [self] action in
                    print(dataEntries)
                    self.dataEntries.removeAll()
                    print(dataEntries)
                    for i in 0..<selectNum {
                        var inputText = alert.textFields![i].text
                        print(inputText!)
                        self.dataEntries.append(PieChartDataEntry(value:Double(percentage) , label:inputText))
                        
                    }
                    print(dataEntries)
                    dataSet = PieChartDataSet(entries: dataEntries, label: "テストデータ")
                    print(dataSet)
                    self.pieChartsView.data = PieChartData(dataSet: dataSet)
                    // グラフの色
                    dataSet.colors = ChartColorTemplates.colorful()
                    dataSet.notifyDataSetChanged()
                    
                    self.pieChartsView.notifyDataSetChanged()
                    pieChartsView.data?.notifyDataChanged()
                    
                    
                }
                alert.addAction(OkALert)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    func setSelections(handler:@escaping(Int)-> Void) {
        let alert =  UIAlertController(title: "いくつ？",message: "",preferredStyle: .alert)
        alert.view.tintColor = UIColor.brown
        alert.view.backgroundColor = UIColor.lightGray
        alert.view.layer.cornerRadius = 25
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .numberPad
            textField.autocorrectionType = .default
            textField.placeholder = "数"
        }
        let OkALert = UIAlertAction(title: "決定", style: .default) { action in
            handler(Int( alert.textFields![0].text!)!)
        }
        alert.addAction(OkALert)
        self.present(alert, animated: true, completion: nil)
    }
    
}
