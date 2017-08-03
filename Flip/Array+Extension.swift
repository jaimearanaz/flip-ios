//
//  Array+Extension.swift
//  Flip
//
// https://stackoverflow.com/questions/27259332/get-random-elements-from-array-in-swift
//

import Foundation

extension Array {
    
    /// Picks `n` random elements (partial Fisher-Yates shuffle approach)
    subscript (randomPick n: Int) -> [Element] {
        
        var copy = self
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            if j != i {
                swap(&copy[i], &copy[j])
            }
        }
        return Array(copy.suffix(n))
    }
}
