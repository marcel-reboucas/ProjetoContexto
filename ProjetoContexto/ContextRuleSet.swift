//
//  ContextRuleSet.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 12/12/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation

class ContextRuleSet : NSObject {

    var rules : [ContextRuleProtocol]
    var rulesAreTrueCallback: (() -> ())?
    var rulesAreFalseCallback: (() -> ())?
    
    init(rules: [ContextRuleProtocol],
         rulesAreTrueCallback: (() -> ())?,
         rulesAreFalseCallback: (() -> ())?) {
        
        self.rules = rules
        self.rulesAreTrueCallback = rulesAreTrueCallback
        self.rulesAreFalseCallback = rulesAreFalseCallback
        
        super.init()
    }
    
    func applies() -> Bool {
        
        for rule in rules {
            
            if !rule.applies() {
                return false
            }
        }
        return true
    }
}
