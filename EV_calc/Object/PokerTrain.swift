//
//  PokerTrain.swift
//  EV_calc
//
//  Created by Terrence Pramono on 11/05/22.
//

import Foundation

struct Player : Hashable {
    let hole_cards : [[Card]]
    var count_win : Int = 0
    var equity : Double = 0.0
    let priority : Double
    let idx : Int
}

class CheckWin {
    var players : [Player] = []
    var community_cards : [Card] = []
    var available_cards = Deck() // Delete nanti ini hanya untuk percobaan. Harusnya ada class poker train di atas Check Win
    
    init(players : [Player], community_cards : [Card]) {
        self.players = players
//        check_player_cards()
        self.community_cards = community_cards
        var temp_cards = self.available_cards.list_of_cards
//        for _ in 1...5 {
//            let temp = temp_cards.randomElement()!
//            community_cards.append(temp)
//            temp_cards.remove(temp)
//        }
//        community_cards = [
//            Card(suit: "C", value: "3"),
//            Card(suit: "H", value: "10"),
//            Card(suit: "S", value: "3"),
//            Card(suit: "H", value: "2"),
//            Card(suit: "D", value: "2")
//        ]
        temp_cards.subtract(community_cards)
//        for i in 5...9 {
//            community_cards.append(Card(suit: "C", value: String(i)))
//        }
        self.available_cards.list_of_cards = temp_cards
    }
    
//    private func check_player_cards() {
//        var allPlayerCards : [[Card]] = []
//        for player in self.players {
//            allPlayerCards += player.hole_cards
//        }
//        var countPlayerCards = allPlayerCards.reduce(into: [:]){$0[$1, default: 0] += 1}
//        countPlayerCards = countPlayerCards.filter({$0.value > 1})
//        print(countPlayerCards)
//
//    }
    
    func train(handler:@escaping (Double) ->()) {
        let random_cards_length = 5 - community_cards.count
        var available_cards_now : Set<Card>
        var community_cards_now : [Card]
        var total_error = 0
        var isBadInput = false
        let repeat_train = 100000
        for i in 1 ... repeat_train {
            available_cards_now = self.available_cards.list_of_cards
            community_cards_now = self.community_cards
            var isError = false
            var chosen_cards : [[Card]] = []
            if i == 1000 {
                if total_error > 750 {
                    isBadInput = true
                    break
                }
            }
            for player in self.players.sorted(by: {$0.priority > $1.priority}) {
                var temp_cards : [Card] = []
                if player.hole_cards.count == 1 {
                    temp_cards = player.hole_cards[0]
                } else {
                    temp_cards = player.hole_cards.randomElement()!
                }
                let similarChosenCards = chosen_cards.filter({$0.contains(temp_cards[0]) || $0.contains(temp_cards[1])})
                
                if similarChosenCards.count != 0 {
                    isError = true
                    total_error += 1
                    break
                }
                available_cards_now.subtract(temp_cards)
                chosen_cards.append(temp_cards)
            }
            if isError {
                continue
            }
            for _ in 0 ... random_cards_length {
                let temp = available_cards_now.randomElement()!
                community_cards_now.append(temp)
                available_cards_now.remove(temp)

            }
            var temp_points : [Int : Double] = [:]
            for i in 0 ... chosen_cards.count - 1 {
                let valued_cards = chosen_cards[i] + community_cards_now
                temp_points[i] = check(valued_cards: valued_cards)
            }
            let highest_point = temp_points.values.sorted(by: >)[0]
            temp_points = temp_points.filter { $0.value == highest_point}
            for (idx, _) in temp_points {
                self.players[idx].count_win += 1
            }
        }
        if isBadInput {
            handler( -100.0)
        } else {
            let total_imaginary = self.players.reduce(0, {partialResult, p in return partialResult + p.count_win })
            for i in 0 ... self.players.count - 1 {
                players[i].equity = Double(self.players[i].count_win) / Double(total_imaginary)
            }
            handler( round(1000 * self.players.filter({$0.idx == 0})[0].equity) / 1000)
        }
        
    }
    
    private func check(valued_cards : [Card]) -> Double {
        var points = 0.0
        let str_fl_pts = straight_flush(list_of_cards: valued_cards)
        if str_fl_pts > points {
            points = str_fl_pts
        }
        if points >= 900 {
            return points
        }
        let twins_pts = twins(list_of_cards: valued_cards)
        if twins_pts > points {
            points = twins_pts
        }
        if points > 0.0 {
            return points
        }
        return high_card(list_of_cards: valued_cards)
    }
    
    private func straight_flush(list_of_cards : [Card]) -> Double {
        var returned_points = 0.0
        let (flush_points, flush_cards) = flush(list_of_cards: list_of_cards)
        if flush_points != 0.0 {
            returned_points = flush_points
            let straight_points = straight(list_of_cards: flush_cards)
            if straight_points != 0.0 {
                returned_points = straight_points + 400.0
            }
        } else {
            returned_points = straight(list_of_cards: list_of_cards)
        }
        return returned_points
    }
    
    private func straight(list_of_cards : [Card]) -> Double {
        // $0 = setiap value dalam array $1 artinya element setelah $0 contoh di [0, 2] iterasi pertama $0 = 0, $1 = 2
        var points = 0.0
        var values : Set<Int> = []
        list_of_cards.forEach{values.insert($0.value_num)}
        if values.count < 5 {
            return points
        }
        let sort_values = Array(values).sorted()
        var count = 0
        //var value_set : Set<Int> = []
        if Set([2, 3, 4, 5]).isSubset(of: values) && values.contains(14){
            points = Double(500 + 15)
        }
        for val in sort_values {
            if count >= sort_values.count - 4 {
                break
            }
            let temp_set = Set([val , val + 1, val + 2, val + 3, val + 4])
            if temp_set.isSubset(of: values) {
                //value_set = temp_set
                let temp_points = Double(500 + temp_set.reduce(0, {partialResult, val in return partialResult + val}))
                if points < temp_points {
                    points = temp_points
                }
            }
            count += 1
        }
        // Input returned cards to be check is flush or not
//        var returned_cards : [Card] = []
//        if value_set.count > 0 {
//            for lc in list_of_cards {
//                if value_set.contains(lc.value_num) {
//                    returned_cards.append(lc)
//                    value_set.remove(lc.value_num)
//                }
//            }
//        }
        return points
    }
    
    private func scaling_value(value : Int) -> Int{
        let temp_value = value * 10
        let value_dbl : Double = Double((temp_value - 10) * 90 / 130)
        return Int(value_dbl)
    }
    
    private func flush(list_of_cards : [Card]) -> (Double, [Card]) {
        var suits : [String] = []
        list_of_cards.forEach {suits.append($0.suit)}
        var points = 0.0
        let counts = suits.reduce(into: [:]){$0[$1, default: 0] += 1}
        var returned_cards : [Card] = []
        for (c, val) in counts {
            if val >= 5 {
                //Mencari flush dengan nilai tertinggi untuk di return
                returned_cards = list_of_cards.filter {$0.suit == c }
                var returned_cards_pts : [Int] = []
                returned_cards.forEach {returned_cards_pts.append($0.value_num)}
                returned_cards_pts = returned_cards_pts.sorted(by: >)
                returned_cards_pts = Array(returned_cards_pts[0 ..< 5])
                //returned_cards = returned_cards.filter {returned_cards_pts.contains($0.value_num)}
                points = 600.0
                for i in 0 ... 4 {
                    points += Double(scaling_value(value: returned_cards_pts[i])) * pow(pow(10.0, -2.0), Double(i))
                }
                break
            }
        }
        return (points, returned_cards)
    }
    private func twins(list_of_cards : [Card]) -> Double {
        var values : [Int] = []
        var points = 0.0
        list_of_cards.forEach {values.append($0.value_num)}
        var counts_full = values.reduce(into: [:]){$0[$1, default: 0] += 1}
        //let total = counts.values.filter { val in return val > 1}
        var counts = counts_full.filter({ $0.value > 1})
        let pairs_identifier = counts.values.reduce(0, {partialResult, val in return partialResult + (val * val) })
        if counts.values.contains(4) {
            let fours = Double(counts.someKey(forValue: 4)!)
            counts_full.removeValue(forKey: Int(fours))
            points = 800.0 + Double(fours * 4)
            let high_cards = counts_full.keys.sorted(by: >)
            points += Double(high_cards[0]) * pow(10.0 , -2.0)
        } else if pairs_identifier == 18 {
            points = 700.0
            counts = counts.filter({ $0.value == 3})
            let threes = counts.keys.sorted(by: >)
            points += Double(threes[0] * 3) + (Double(threes[1] * 2) * pow(10.0, -2.0))
        } else if pairs_identifier == 17 {
            points = 700.0
            let threes = Double(counts.someKey(forValue: 3)!)
            points += Double(threes * 3)
            counts = counts.filter({ $0.value == 2})
            let pairs = counts.keys.sorted(by: >)
            points += Double(pairs[0] * 2) * pow(10.0, -2.0)
        } else if pairs_identifier == 13 {
            points = 700.0
            let threes = Double(counts.someKey(forValue: 3)!)
            points += Double(threes * 3)
            let pairs = Double(counts.someKey(forValue: 2)!)
            points += Double(pairs * 2) * pow(10.0, -2.0)
        } else if pairs_identifier == 9 {
            points = 400.0
            let threes = Double(counts.someKey(forValue: 3)!)
            points += Double(threes * 3)
            counts_full.removeValue(forKey: Int(threes))
            let high_cards = counts_full.keys.sorted(by: >)
            points += (Double(high_cards[0]) * pow(10.0 , -2.0)) + (Double(high_cards[1]) * pow(10.0 , -4.0))
        } else if pairs_identifier == 8 || pairs_identifier  == 12 {
            points = 300.0
            counts = counts.filter({ $0.value == 2})
            let pairs = counts.keys.sorted(by: >)
            points += Double(pairs[0] * 2) + (Double(pairs[1] * 2) * pow(10.0, -2.0))
            counts_full.removeValue(forKey: pairs[0])
            counts_full.removeValue(forKey: pairs[1])
            let high_cards = counts_full.keys.sorted(by: >)
            points += (Double(high_cards[0]) * pow(10.0 , -4.0))
        } else if pairs_identifier == 4 {
            points = 200.0
            let pairs = Double(counts.someKey(forValue: 2)!)
            points += Double(pairs * 2)
            counts_full.removeValue(forKey: Int(pairs))
            let high_cards = counts_full.keys.sorted(by: >)
            points += (Double(high_cards[0]) * pow(10.0 , -2.0)) + (Double(high_cards[1]) * pow(10.0 , -4.0)) + (Double(high_cards[2]) * pow(10.0 , -6.0))
        }
        return points
    }
    
    private func high_card(list_of_cards : [Card]) -> Double {
        var card_values : [Int] = []
        var points = 100.0
        list_of_cards.forEach { card_values.append($0.value_num)}
        card_values = card_values.sorted(by: >)
        for i in 0 ... 4 {
            points += Double(card_values[i]) * pow(pow(10.0, -2.0), Double(i))
        }
        return points
    }
}


extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
