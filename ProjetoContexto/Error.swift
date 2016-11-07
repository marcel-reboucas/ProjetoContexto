//
//  Error.swift
//  Spacy
//
//  Created by Marcel de Siqueira Campos Rebouças on 4/27/16.
//  Copyright © 2016 Bacon-Softworks. All rights reserved.
//

import Foundation

struct Error: ErrorType {

    var code: Int
    var message: String

    init(code: Int? = 0, message: String? = "") {

        self.code = code ?? 0
        self.message = message ?? ""
    }

    func toString() -> String {
        return message
    }
}

func ==(lhs: Error, rhs: Error) -> Bool {
    return lhs.code == rhs.code
}
