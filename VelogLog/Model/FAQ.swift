//
//  FAQ.swift
//  VelogLog
//
//  Created by 장세희 on 7/19/24.
//

import Foundation

struct FAQModel: Identifiable {
    var id = UUID()
    var question: String
    var answer: String
    
    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
