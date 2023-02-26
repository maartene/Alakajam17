//
//  AnsiFormatter.swift
//  File
//
//  Created by Maarten Engels on 18/07/2021.
//

import Foundation

protocol Formatter {
    associatedtype Output
    
    func format(_ input: String) -> Output
}

struct AnsiFormatter: Formatter {
    static var main = AnsiFormatter()
    
    typealias Output = String
    
    var resetToCode = "\u{1B}[34m"
    
    func format(_ input: String) -> String {
        // output text is green by default
        //var output = "\u{1B}[32m\(input)\u{1B}[0m"
        
        // output text is blue by default
        var output = "\u{1B}[34m\(input)\u{1B}[0m"
        
        output = output.replacingOccurrences(of: "<B>", with: "\u{1B}[1m")
        output = output.replacingOccurrences(of: "</B>", with: "\u{1B}[0m" + resetToCode)
        
        output = output.replacingOccurrences(of: "<I>", with: "\u{1B}[3m")
        output = output.replacingOccurrences(of: "</I>", with: "\u{1B}[0m" + resetToCode)
        
        output = output.replacingOccurrences(of: "<WARNING>", with: "\u{1B}[33m")
        output = output.replacingOccurrences(of: "</WARNING>", with: "\u{1B}[0m" + resetToCode)
        
        output = output.replacingOccurrences(of: "<ERROR>", with: "\u{1B}[31m")
        output = output.replacingOccurrences(of: "</ERROR>", with: "\u{1B}[0m" + resetToCode)
        
        output = output.replacingOccurrences(of: "<OK>", with: "\u{1B}[32m")
        output = output.replacingOccurrences(of: "</OK>", with: "\u{1B}[0m" + resetToCode)
        
        output = output.replacingOccurrences(of: "<INFO>", with: "\u{1B}[34m")
        output = output.replacingOccurrences(of: "</INFO>", with: "\u{1B}[0m" + resetToCode)
        
        return output
    }
    
    
}
