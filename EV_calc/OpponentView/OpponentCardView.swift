//
//  OpponentCardView.swift
//  EV_calc
//
//  Created by Terrence Pramono on 02/05/22.
//

import UIKit

class InputCardView: UIView {
    
    let suit = ["s", "h", "d", "c"]
    let value = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
    
    @IBOutlet var label_text : UILabel!
    @IBOutlet var opponent_text_field : UITextField!
    @IBOutlet var closeButton : closeViewButton!
    @IBOutlet var cardPickerButton : CardButton!
    @IBOutlet var removeLastCardButton : CardButton!
    var id = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "OpponentCardView") else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    func set_id(cnt:Int) {
        self.id = "View" + String(cnt)
        self.cardPickerButton.id = "Btn" + String(cnt)
        if cnt > 2 {
            self.closeButton.id = "BtnClose" + String(cnt)
        }
        self.removeLastCardButton.id = "BtnRemove" + String(cnt)
    }
    

}
