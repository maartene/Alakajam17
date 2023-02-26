//
//  File.swift
//  
//
//  Created by Maarten Engels on 01/11/2021.
//

import Foundation

enum Verb {
    case illegal
    case empty
    
    // known commands
    case close
    case createUser(username: String, password: String)
    case login(username: String, password: String)
    case status
    case setWaterflow(flowControl: Turbine.WaterFlowControlState)
    case setPoweroutput(outsidePowerOpened: Bool)
    case wait
    case help
    case reset
    
    var requiredLogin: Bool {
        switch self {
        case .close:
            return false
        case .createUser:
            return false
        case .login:
            return false
        case .help:
            return false
        default:
            return true
        }
    
    }
    
    static func expectedWordCount(verb: String) -> Int {
        switch verb.uppercased() {
        case "CREATE_USER":
            return 3
        case "LOGIN":
            return 3
        case "SET_WATERFLOW":
            return 2
        case "SET_POWEROUTPUT":
            return 2
        default:
            return 1
        }
    }
    
    static func createVerb(from str: String) -> Verb {
        let trimmedString = str.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let parts = trimmedString.split(separator: " ")
        
        guard parts.count >= 1 && parts[0] != "" else {
            return .empty
        }
    
        guard parts.count >= Self.expectedWordCount(verb: String(parts[0])) else {
            return .illegal
        }
        
        switch parts[0].uppercased() {
        case "CLOSE":
            return .close
        case "CREATE_USER":
            return .createUser(username: String(parts[1]), password: String(parts[2]))
        case "LOGIN":
            return .login(username: String(parts[1]), password: String(parts[2]))
        case "STATUS":
            return .status
        case "SET_WATERFLOW":
            if let intendedFlowControlString = Turbine.WaterFlowControlState.getWaterFlowControlState(from: String(parts[1])) {
                return .setWaterflow(flowControl: intendedFlowControlString)
            } else {
                return .illegal
            }
        case "SET_POWEROUTPUT":
            switch String(parts[1].uppercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
            case "ENABLED":
                return .setPoweroutput(outsidePowerOpened: true)
            case "DISABLED":
                return .setPoweroutput(outsidePowerOpened: false)
            default:
                return .illegal
            }
        case "WAIT":
            return .wait
        case "HELP":
            return .help
        case "RESET":
            return .reset
        default:
            return .illegal
        }
    }
}
