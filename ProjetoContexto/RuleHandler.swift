//
//  RuleHandler.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 12/12/16.
//  Copyright © 2016 mscr. All rights reserved.
//


import Foundation
import UIKit

protocol RuleHandlerDelegate {
    func rulesChangedToTrue(rules : [ContextRuleSet])
    func rulesChangedToFalse(rules : [ContextRuleSet])
}

class RuleHandler: NSObject {
    
    // Singleton
    static let sharedInstance = RuleHandler()
    private var rules = [ContextRuleSet]()
    private var rulesStatuses = [ContextRuleSet : Bool]()
    
    var delegates = [RuleHandlerDelegate]()
   
    private var timedUpdates : NSTimer?
    var timeBetweenUpdates : NSTimeInterval = 3.0
    
    private override init() {
        
        super.init()
        
        updateCurrentRuleSet()
        
        timedUpdates = NSTimer.scheduledTimerWithTimeInterval(timeBetweenUpdates, target: self, selector:  #selector(RuleHandler.updateCurrentRuleSet), userInfo: nil, repeats: true)
    
        print("Starting RuleHandler")
        
    }
    
    deinit {
        timedUpdates?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addRuleSet(ruleSet: ContextRuleSet) {
        rules.append(ruleSet)
        rulesStatuses[ruleSet] = false
    }
    
    func removeRuleSet(ruleSet: ContextRuleSet) {
        rules.removeObject(ruleSet)
        rulesStatuses[ruleSet] = false
    }
    
    func updateCurrentRuleSet() {
        
        // gets all rules that are currently true
        let trueRules = rules.filter({$0.applies()})
        let falseRules = rules.filter({!trueRules.contains($0)})
        
        var rulesThatBecameTrue = [ContextRuleSet]()
        var rulesThatBecameFalse = [ContextRuleSet]()
        
        //if was already true before
        for rule in trueRules {
            if rulesStatuses[rule] == false {
                //Rule was false before, and became true - should tell delegates
                rulesThatBecameTrue.append(rule)
            }
            rulesStatuses[rule] = true
        }

        //if was already true before
        for rule in falseRules {
            if rulesStatuses[rule] == true {
                //Rule was true before, and became false - should tell delegates
                rulesThatBecameFalse.append(rule)
            }
            rulesStatuses[rule] = false
        }

        if !rulesThatBecameTrue.isEmpty {
            print("A rule became true")
            for delegate in delegates { delegate.rulesChangedToTrue(rulesThatBecameTrue)}
        }
        
        if !rulesThatBecameFalse.isEmpty {
            print("A rule became false")
            for delegate in delegates { delegate.rulesChangedToFalse(rulesThatBecameFalse)}
        }
    }
}

