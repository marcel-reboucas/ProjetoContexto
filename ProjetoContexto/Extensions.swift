//
//  Extensions.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }