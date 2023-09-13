//
//  Extensions.swift
//  NetFlixClone
//
//  Created by window1 on 2023/01/06.
//

import Foundation

extension String {
    func capitalizeFristLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
