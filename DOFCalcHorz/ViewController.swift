//
//  ViewController.swift
//  DOFCalcHorz
//
//  Created by Adam Wayland on 3/2/17.
//  Copyright © 2017 Adam Wayland. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource {
    
    @IBOutlet var pickerView1: AKPickerView!
    @IBOutlet var pickerView2: AKPickerView!
    @IBOutlet var pickerView3: AKPickerView!
    @IBOutlet var DOFLabel: UILabel!
    @IBOutlet var farPointLabel: UILabel!
    @IBOutlet var nearPointLabel: UILabel!
    @IBOutlet var hyperfocalLabel: UILabel!
    
    //MARK: Model

    let fStopArr = [1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2.0, 2.5, 2.8, 3.2, 3.5, 4.0, 4.5, 5.0, 5.6, 6.3, 7.1, 8.0, 9.0, 10, 11, 13, 14, 16, 18, 20, 22]
    
    let focalLengthArr = [14, 17, 20, 24, 35, 40, 50, 70, 85, 105, 135, 200, 250, 300]
    
    let distanceArr = [1,2,3,4,5,6,7,8,9,10,11,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,132,144,156,168,180,192,204,216,228,240,300,360,420,540,600]
    
    var fStop: Double = 1.0
    var fStopIdx = 0
    var focalLength = 14
    var focalLengthIdx = 0
    var distance = 1
    var distanceIdx = 0
    var totalDOF: Double {
        get{
            return fStop * Double(focalLength)
        }
    }
    
    //Circle of Confusion for various sensors in Millimeters
    var CoC: Double? = nil
    let CoC_fourThirds = 0.014
    let CoC_APS_C = 0.0185
    let CoC_35mm = 0.029
    
    //hyperFocal in Millimeters
    var hyperFocal: Double {
        get {
            if CoC != nil {
                return Double(focalLength * focalLength) / (fStop * CoC!)
            } else {
                return 0.0
            }
            
        }
    }
    
    var nearPoint: Double {
        get {
            return (hyperFocal * Double(convertInToMM(inches: distance))) / (hyperFocal + (convertInToMM(inches: distance) - Double(focalLength)))
        }
    }
    
    var farPoint: Double {
        get {
            return (hyperFocal * Double(convertInToMM(inches: distance))) / (hyperFocal - (convertInToMM(inches: distance) - Double(focalLength)))
        }
    }
    
    var DOF: Double {
        get {
            return farPoint - nearPoint
        }
    }
    
    func convertMMToFt(mm: Double) -> Double {
        return mm / 304.8
    }
    
    func convertInToMM(inches: Int) -> Double {
        return 25.4 * Double(inches)
    }
    
    func getDistString(inches: Int) -> String {
        var distStr = ""
        if inches <= 11 {
            distStr = String(inches) + "in"
        } else {
            if inches % 12 == 0 {
                distStr = String(inches / 12) + "ft"
            } else {
                distStr = String(Double(inches) / 12.0) + "ft"
            }
        }
        return distStr
    }
    
    //MARK: PickerViews
    
    func setupPickerView(_ pickerView: AKPickerView) {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 60)!
        pickerView.highlightedFont = UIFont(name: "HelveticaNeue-Light", size: 60)!
        pickerView.pickerViewStyle = .wheel
        pickerView.interitemSpacing = 30
        pickerView.maskDisabled = false
        pickerView.textColor = UIColor.white
        pickerView.highlightedTextColor = UIColor.white
        pickerView.backgroundColor = UIColor.black
        pickerView.reloadData()
    }
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        if pickerView == pickerView1 {
            return self.fStopArr.count
        } else if pickerView == pickerView2 {
            return self.focalLengthArr.count
        } else {
            return self.distanceArr.count
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == pickerView1 {
            return String(format: "f/%.01f", self.fStopArr[item])
        } else if pickerView == pickerView2 {
            return String(format: "%dmm", self.focalLengthArr[item])
        } else {
            return getDistString(inches: distanceArr[item])
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        if pickerView == pickerView1 {
            self.fStop = self.fStopArr[item]
        } else if pickerView == pickerView2 {
            self.focalLength = self.focalLengthArr[item]
        } else {
            self.distance = self.distanceArr[item]
        }
        if DOF >= 0 {
            DOFLabel.text = String(format: "%.1f", convertMMToFt(mm: DOF))
        } else {
            if farPoint - nearPoint < 0.01 && farPoint > 0.0 {
                DOFLabel.text = "0.0"
            } else {
                DOFLabel.text = "\u{221E}"
            }
        }
        self.nearPointLabel.text = String(format: "%.1f ft", convertMMToFt(mm: self.nearPoint))
        if farPoint >= 0 {
            farPointLabel.text = String(format: "%.1fft", convertMMToFt(mm: farPoint))
        } else {
            farPointLabel.text = "\u{221E}"
        }
        self.hyperfocalLabel.text = String(format: "%.01f ft", convertMMToFt(mm: self.hyperFocal))
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView(pickerView1)
        setupPickerView(pickerView2)
        setupPickerView(pickerView3)
        self.CoC = CoC_35mm
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

