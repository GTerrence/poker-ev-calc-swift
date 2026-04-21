//
//  ViewController.swift
//  EV_calc
//
//  Created by Terrence Pramono on 26/04/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var opponentCardView : InputCardView!
    @IBOutlet var playerCardView : InputCardView!
    @IBOutlet var componentStack : UIStackView!
    @IBOutlet var flopCardView : InputCardView!
    @IBOutlet var turnCardView : InputCardView!
    @IBOutlet var riverCardView : InputCardView!
    @IBOutlet var expProfit : UITextField!
    @IBOutlet var expLoss : UITextField!
    @IBOutlet var blurView : UIVisualEffectView!
    @IBOutlet var resultView : UIView!
    @IBOutlet var resultLabel : UILabel!
    @IBOutlet var resultImage : UIImageView!
    @IBOutlet var resultMessage : UILabel!
    @IBOutlet var progressView : UIView!
    @IBOutlet var spinnerProgress : UIActivityIndicatorView!
    
    
    
    let suit = ["d", "c", "h", "s"]
    let suitImage = [
        UIImage(named: "red diamond"),
        UIImage(named: "black club"),
        UIImage(named: "red heart"),
        UIImage(named: "black spade")
    ]
    let value = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var customViewCount = 3
    
    var opponentInput : [Int:[[String]]] = [:]
    var flopCards : [String] = []
    var turnCards : [String] = []
    var riverCards : [String] = []
    //Testing
//    var playerCards : [String] = ["As", "Ad"]
    var playerCards : [String] = []
    var communityCards : [String] = []
    
    let textProfit = "Your Expected Value (EV) is positive. You are expected to gain profit in the long run. It is a good idea to go for it!"
    let textLoss = "Your Expected Value (EV) is negative. You are expected to loss in the long run. It is a good idea to avoid it"
    var equity = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Preparation of the result pop up
        blurView.bounds = self.view.bounds
        resultView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: self.view.bounds.height * 0.3)
        progressView.bounds = self.view.bounds
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        // initialize opponent Card View id from StoryBoard
        self.flopCardView.set_id(cnt: -2)
        self.flopCardView.cardPickerButton.addTarget(self, action: #selector(displayPlayerCardPicker(_:)), for: .touchUpInside)
        self.flopCardView.removeLastCardButton.addTarget(self, action: #selector(removeLastInput(sender:)), for: .touchUpInside)
        self.turnCardView.set_id(cnt: -1)
        self.turnCardView.cardPickerButton.addTarget(self, action: #selector(displayPlayerCardPicker(_:)), for: .touchUpInside)
        self.turnCardView.removeLastCardButton.addTarget(self, action: #selector(removeLastInput(sender:)), for: .touchUpInside)
        self.riverCardView.set_id(cnt: 0)
        self.riverCardView.cardPickerButton.addTarget(self, action: #selector(displayPlayerCardPicker(_:)), for: .touchUpInside)
        self.riverCardView.removeLastCardButton.addTarget(self, action: #selector(removeLastInput(sender:)), for: .touchUpInside)
        self.playerCardView.set_id(cnt: 1)
        self.playerCardView.cardPickerButton.addTarget(self, action: #selector(displayPlayerCardPicker(_:)), for: .touchUpInside)
        self.playerCardView.removeLastCardButton.addTarget(self, action: #selector(removeLastInput(sender:)), for: .touchUpInside)
        self.opponentCardView.set_id(cnt: 2)
        // Testing
//        self.opponentInput[2] = [["Ac", "Jc"]]
        self.opponentInput[2] = []
        self.opponentCardView.cardPickerButton.addTarget(self, action: #selector(displayPlayerCardPicker(_:)), for: .touchUpInside)
        self.opponentCardView.removeLastCardButton.addTarget(self, action: #selector(removeLastInput(sender:)), for: .touchUpInside)
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(closeModal(_:)))
        blurView.addGestureRecognizer(closeTap)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func calculate(_ sender:Any)  {
        //        let opView = componentStack.subviews.compactMap{$0 as? OpponentCardView}
                
                var players : [Player] = []
                if checkInput() {
        //
        //
                    //        var countPlayer = 0
                    //        for v in opView {
                    //            let input = v.opponent_text_field.text
                    //            if input != nil {
                    ////                players.append(Player(hole_cards: [translate(inCard: input!)]))
                    //                self.checkedCards[countPlayer] = input?.components(separatedBy: ";")
                    //                countPlayer += 1
                    //            } else {
                    //                print("empty value")
                    //            }
                    //        }
                self.communityCards = flopCards + turnCards + riverCards
                if (self.communityCards + self.playerCards).count != Set(self.communityCards + self.playerCards).count {
                    let alert2 = UIAlertController(title: "Error", message: "Duplicate Cards detected in your cards or community cards", preferredStyle: .alert)
                    alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }
                let (status, prioritizePlayer) = checkCards(checkedCards: opponentInput)
                if status == 0 {
                    let alert2 = UIAlertController(title: "Error", message: "Some cards from the opponent cards has been picked either in your cards or community cards", preferredStyle: .alert)
                    alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                } else {
                    //Append person card
                    players.append(Player(hole_cards: [[translate(inCard: self.playerCards[0]), translate(inCard: self.playerCards[1])]], priority: 99999.99, idx: 0))
                    var playerIdx = 1
                    for (key, val) in self.opponentInput {
                        var playersCard : [[Card]] = []
                        for cardSets in val {
                            var tempCardSet : [Card] = []
                            for c in cardSets {
                                tempCardSet.append(translate(inCard: c))
                            }
                            playersCard.append(tempCardSet)
                        }
                        players.append(Player(hole_cards: playersCard, priority: prioritizePlayer[key]!, idx: playerIdx))
                        playerIdx += 1
                    }
                    var tempCommunityCards : [Card] = []
                    for t in self.communityCards {
                        tempCommunityCards.append(translate(inCard: t))
                    }
                    let check = CheckWin(players: players, community_cards: tempCommunityCards)
                    self.animateIn(desiredView: self.progressView)
                    self.spinnerProgress.startAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let equity2 =  check.train { hasil in
                            self.equity = hasil
                            print(hasil)
                            self.spinnerProgress.stopAnimating()
                            self.animateOut(desiredView: self.progressView)
                            print("apa")
                        }
                        if self.equity == -100.0 {
                            let alert2 = UIAlertController(title: "Error", message: "Bad Input Cards", preferredStyle: .alert)
                            alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                            self.present(alert2, animated: true, completion: nil)
                        } else {
                            self.animateIn(desiredView: self.blurView)
                            let ev = round((Double(self.expProfit.text!)! * self.equity - Double(self.expLoss.text!)! * (1 - self.equity)) * 1000) / 1000
                            if ev >= 0 {
                                self.resultLabel.text = "+" + String(ev)
                                self.resultLabel.textColor = .green
                                self.resultImage.tintColor = .green
                                self.resultImage.image = UIImage(systemName: "arrow.up")
                                self.resultMessage.text = self.textProfit
                            } else {
                                self.resultLabel.text = String(ev)
                                self.resultLabel.textColor = .red
                                self.resultImage.tintColor = .red
                                self.resultImage.image = UIImage(systemName: "arrow.down")
                                self.resultMessage.text = self.textLoss
                            }
                            self.animateIn(desiredView: self.resultView)
                        }
                    }
                    
        //
                }
            }

    }
    
    //Animate Pop Up
    func animateIn(desiredView : UIView) {
        let backgroundView = self.view!
        
        backgroundView.addSubview(desiredView)
        
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0.8
        desiredView.center = backgroundView.center
        //UIView.animate(withDuration: 0.3, animations: <#T##() -> Void#>)
    }
    
    @objc func closeModal(_ sender: Any) {
        animateOut(desiredView: resultView)
        animateOut(desiredView: blurView)
    }
    
    func animateOut(desiredView : UIView) {
        desiredView.removeFromSuperview()
    }
    
    func checkInput() -> Bool {
        var errorMessage = ""
        if expLoss.text == "" {
            errorMessage = "You need to fill the expected loss"
        } else if expProfit.text == "" {
            errorMessage = "You need to fill the expected profit"
        } else if playerCards.count == 0 {
            errorMessage = "You need to fill your Card"
        } else if opponentInput.count == 1 && opponentInput[2]!.count == 0 {
            errorMessage = "You need at least 2 people to play poker"
        } else if opponentInput.filter({$0.value.count == 0}).count != 0{
            errorMessage = "Please fill all the opponent card or remove them instead"
        }
        if errorMessage != "" {
            let alert2 = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
            self.present(alert2, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func checkCards(checkedCards : [Int:[[String]]]) -> (Int,[Int:Double]) {
        var allCards : [String] = []
        var countPlayerCard : [Int:Double] = [:]
        var newCheckedCards : [Int: [String : Int]] = [:]
        for (key, cCards) in checkedCards {
            var temp_cards : [String] = []
            for c in cCards {
//                temp_cards.append(String(c[0..<2]))
//                temp_cards.append(String(c[2..<4]))
                temp_cards += c
            }
            if Set(temp_cards).isDisjoint(with: Set(self.communityCards)) && Set(temp_cards).isDisjoint(with: Set(self.playerCards)) {
                allCards += temp_cards
                newCheckedCards[key] = temp_cards.reduce(into : [:]) {$0[$1, default: 0] += 1}
                countPlayerCard[key] = 0.0
            } else {
                return (0, countPlayerCard)
            }
            
            
        }
        var countedAllCards = allCards.reduce(into: [:]) {$0[$1, default: 0] += 1}
        countedAllCards = countedAllCards.filter({$0.value > 1})
        
        if countedAllCards.count == 0 {
//            print(0)
            for key in countPlayerCard.keys {
                countPlayerCard[key] = 0.0
            }
            return (1,countPlayerCard)
        }
        for (dCard, countCard) in countedAllCards {
            for (pIdx, pCard) in newCheckedCards {
                if pCard.keys.contains(dCard) {
                    countPlayerCard[pIdx]! += Double(countCard) - Double(pCard[dCard]!)
                }
            }
        }
        for (key, val) in countPlayerCard {
            let zeroCard = checkedCards[key]!.filter({countedAllCards.keys.contains($0[0]) || countedAllCards.keys.contains($0[1])})
            let temp_val = val * Double(zeroCard.count) / Double(newCheckedCards[key]!.count)
            countPlayerCard[key] = temp_val
        }
        return (1,countPlayerCard)
//        let alertPlayer = countPlayerCard.filter({$0.value == 1.0}).keys
//        if alertPlayer.count <= 1 {
////            print(1)
//            return true
//        }
//        var alertPlayerCard : [[String]] = []
//        for (key, val) in checkedCards {
//            if alertPlayer.contains(key) {
//                alertPlayerCard.append(val)
//            }
//        }
//        var countedAlertPlayerCards = alertPlayerCard.reduce(into: [:]) {$0[$1, default: 0] += 1}
//        countedAlertPlayerCards = countedAlertPlayerCards.filter({$0.value > $0.key.count})
//        if countedAlertPlayerCards.count == 0 {
////            print(2)
//            return true
//        }
//        return false
    }
    
    func translate(inCard : String) -> Card{
        let returnedCard = Card(suit: String(inCard[1]), value: String(inCard[0]))
        return returnedCard
    }
    
    @IBAction func addNewElement() {
        let opView = componentStack.subviews.compactMap{$0 as? InputCardView}
        if opView.count >= 9 {
            let alert2 = UIAlertController(title: "Error", message: "Maximum 6 players is allowed", preferredStyle: .alert)
            alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
            self.present(alert2, animated: true, completion: nil)
        } else {
            let view = InputCardView().loadViewFromNib(nibName: "OpponentCardView") as! InputCardView
            view.set_id(cnt: customViewCount)
            opponentInput[customViewCount] = []
            customViewCount += 1
            view.heightAnchor.constraint(equalToConstant: 110).isActive = true
            view.widthAnchor.constraint(equalToConstant: 414).isActive = true
            view.closeButton.addTarget(self, action: #selector(removeViewElement(sender:)), for: .touchUpInside)
            view.cardPickerButton.addTarget(self, action: #selector(displayPlayerCardPicker(_:)), for: .touchUpInside)
            view.removeLastCardButton.addTarget(self, action: #selector(removeLastInput(sender:)), for: .touchUpInside)
            componentStack.insertArrangedSubview(view, at: componentStack.arrangedSubviews.count - 1)
        }
    }
    
    @objc func removeViewElement(sender : closeViewButton) {
        let idx = String(sender.id[8..<sender.id.count])
        let opView = componentStack.subviews.compactMap{$0 as? InputCardView}
        let view = opView.filter{$0.id == "View" + idx}[0]
        opponentInput.removeValue(forKey: Int(String(idx))!)
        componentStack.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    @objc func removeLastInput(sender : CardButton) {
        let idx = String(sender.id[9..<sender.id.count])
        let opView = componentStack.subviews.compactMap{$0 as? InputCardView}
        let view = opView.filter{$0.id == "View" + idx}[0]
        if Int(idx)! >= 2 {
            if view.opponent_text_field.text!.count == 4 {
                view.opponent_text_field.text = ""
                opponentInput[Int(idx)!]?.removeLast()
                
            } else if view.opponent_text_field.text! != "" {
                view.opponent_text_field.text = String(view.opponent_text_field.text![0..<view.opponent_text_field.text!.count - 5])
                opponentInput[Int(idx)!]?.removeLast()
            }
        } else if idx == "1" {
            view.opponent_text_field.text = ""
            playerCards = []
        }
        else {
            var removedViewText : [InputCardView]
            if idx == "-2" {
                removedViewText = opView.filter({ Int($0.id[4..<$0.id.count])! <= 0})
                flopCards = []
                turnCards = []
                riverCards = []
            } else if idx == "-1" {
                removedViewText = opView.filter({ Int($0.id[4..<$0.id.count])! == 0 || Int($0.id[4..<$0.id.count])! == -1})
                turnCards = []
                riverCards = []
            } else {
                removedViewText = opView.filter({ Int($0.id[4..<$0.id.count])! == 0})
                riverCards = []
            }
            for v in removedViewText {
                v.opponent_text_field.text = ""
            }
        }
        
    }
    
    @IBAction func displayPlayerCardPicker(_ sender: CardButton) {
        let vc = ModalViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        picker.dataSource = self
        picker.delegate = self
        vc.view.addSubview(picker)
        picker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        picker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        //Get Index from button ID
        let idx = String(sender.id[3..<sender.id.count])
        
        // Get all component from stack and change it to OpponentCardView with CompactMap
        let opView = componentStack.subviews.compactMap{$0 as? InputCardView}
        let view = opView.filter{$0.id == "View" + idx}[0]
        
        // Different Treatment for every type of card input
        if idx == "-2" {
            picker.tag = 1
        } else if idx == "-1" {
            if flopCards.count == 0 {
                let alert2 = UIAlertController(title: "Error", message: "Cannot pick turn cards before flop cards", preferredStyle: .alert)
                alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            } else {
                picker.tag = 2
            }
        } else if idx == "0" {
            if flopCards.count == 0 || turnCards.count == 0 {
                let alert2 = UIAlertController(title: "Error", message: "Cannot pick river cards before flop cards and turn cards", preferredStyle: .alert)
                alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            } else {
                picker.tag = 2
            }
        }
        else {
            picker.tag = 3
        }
        
        if picker.tag != 0 {
            let alert = UIAlertController(title: "Select Card", message: "", preferredStyle: .actionSheet)
            
            alert.popoverPresentationController?.sourceView = view.cardPickerButton
            alert.popoverPresentationController?.sourceRect = view.cardPickerButton.bounds

            alert.setValue(vc, forKey: "contentViewController")

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in}))
            alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
                if picker.tag == 3 {
                    let firstCard = self.value[picker.selectedRow(inComponent: 0)] + self.suit[picker.selectedRow(inComponent: 1)]
                    let secondCard = self.value[picker.selectedRow(inComponent: 2)] + self.suit[picker.selectedRow(inComponent: 3)]
                    if firstCard == secondCard {
                        let alert2 = UIAlertController(title: "Error", message: "Cannot pick 2 of the same cards", preferredStyle: .alert)
                        alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                        self.present(alert2, animated: true, completion: nil)
                    } else if self.opponentInput[Int(idx)!]?.contains([firstCard, secondCard]) == true  || self.opponentInput[Int(idx)!]?.contains([secondCard, firstCard]) == true{
                        let alert2 = UIAlertController(title: "Error", message: "You have already pick these cards", preferredStyle: .alert)
                        alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                        self.present(alert2, animated: true, completion: nil)
                    }
                    else {
                        if idx == "1" {
                            view.opponent_text_field.text! = firstCard + secondCard
                            self.playerCards = [firstCard, secondCard]
                        } else {
                            if view.opponent_text_field.text! != "" {
                                view.opponent_text_field.text! += ";"
                            }
                            view.opponent_text_field.text! += firstCard + secondCard
                            self.opponentInput[Int(idx)!]?.append([firstCard, secondCard])
                        }            }
                } else if picker.tag == 1 {
                    let firstCard = self.value[picker.selectedRow(inComponent: 0)] + self.suit[picker.selectedRow(inComponent: 1)]
                    let secondCard = self.value[picker.selectedRow(inComponent: 2)] + self.suit[picker.selectedRow(inComponent: 3)]
                    let thirdCard = self.value[picker.selectedRow(inComponent: 4)] + self.suit[picker.selectedRow(inComponent: 5)]
                    if firstCard == secondCard || firstCard == thirdCard || secondCard == thirdCard {
                        let alert2 = UIAlertController(title: "Error", message: "Cannot pick the same cards more than 1 time", preferredStyle: .alert)
                        alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: UIKit.UIAlertAction.Style.default, handler: nil))
                        self.present(alert2, animated: true, completion: nil)
                    } else {
                        view.opponent_text_field.text! = firstCard + secondCard + thirdCard
                        self.flopCards = [firstCard, secondCard, thirdCard]
                    }
                } else {
                    let firstCard = self.value[picker.selectedRow(inComponent: 0)] + self.suit[picker.selectedRow(inComponent: 1)]
                    view.opponent_text_field.text! = firstCard
                    if idx == "-1" {
                        self.turnCards = [firstCard]
                    }else {
                        self.riverCards = [firstCard]
                    }
                }
                
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }
}


