//
//  card_deck.swift
//  EV_calc
//
//  Created by Terrence Pramono on 11/05/22.
//

import Foundation

struct Card : Equatable, Hashable {
    let suit: String
    let value:String
    let value_num: Int
    
    init(suit : String, value : String) {
        self.suit = suit.uppercased()
        self.value = value
        let list_value_num = ["2" : 2, "3" : 3, "4" : 4, "5" : 5, "6" : 6, "7" : 7, "8" : 8, "9" : 9, "T" : 10, "J" : 11, "Q" : 12, "K" : 13, "A" : 14]
        self.value_num = list_value_num[value]!
    }
}

class Deck {
    var list_of_cards : Set<Card> = []
    
    init() {
        let list_value = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
        let list_suit = ["S", "D", "H", "C"]
        
        for ls in list_suit {
            for i in 0...list_value.count - 1 {
                self.list_of_cards.insert(Card(suit: ls, value: list_value[i]))
            }
        }
    }
    
    func print_value() {
//        for loc in list_of_cards {
//            print(loc)
//        }
        print(self.list_of_cards.count)
    }
    
}
