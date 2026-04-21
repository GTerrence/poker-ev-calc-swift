//
//  PickerViewExt.swift
//  EV_calc
//
//  Created by Terrence Pramono on 15/05/22.
//

import Foundation
import UIKit

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        
        if component == 0 || component == 2 || component ==  4{
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 2, height: 30))
            label.text = value[row]
            label.sizeToFit()
            return label
        }else {
            let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageV.image = suitImage[row]
            return imageV
        }
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 {
            return 6
        } else if pickerView.tag == 2 {
            return 2
        } else {
            return 4
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 || component == 2 || component == 4{
            return value.count
        }else {
            return suit.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 || component == 2 || component == 4{
            return value[row]
        } else {
            return suit[row]
        }
    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if component == 0 {
//            pickerView.reloadComponent(1)
//        }
//    }
    
    
}
