//
//  Pump.swift
//  
//
//  Created by Maarten Engels on 25/02/2023.
//

import Foundation

struct Turbine: Codable {
    enum GameState: Codable {
        case running
        case tooLongWithoutPower
        case villageFlood
        case villageSaved
    }
    
    enum WaterFlowControlState: String, Codable {
        case closed = "Closed"
        case halfOpened = "Half opened"
        case fullyOpened = "Fully opened"
        
        static func getWaterFlowControlState(from string: String) -> WaterFlowControlState? {
            let trimmedString = string.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch trimmedString {
            case "CLOSED":
                return .closed
            case "HALF":
                return .halfOpened
            case "FULL":
                return .fullyOpened
            default:
                return nil
            }
        }
    }
    
    var outsidePowerOpened = true
    var flowControl = WaterFlowControlState.halfOpened
    var waterPressure = 0.5
    var batteryCharge = 0.2
    var timeWithoutPower = 0
    
    var gameState: GameState {
        if timeWithoutPower >= 10 {
            return .tooLongWithoutPower
        }
        
        if waterPressure > 1.0 {
            return .villageFlood
        }
        
        if outsidePowerOpened && flowControl == .fullyOpened {
            return .villageSaved
        }
        
        return .running
    }
    
    var waterPressureDescription: String {
        switch waterPressure {
        case 0.5 ..< 0.9:
            return "<WARNING>Water pressure elevated</WARNING>\n"
        case 0.9... :
            return "<ERROR>Water pressure critical</ERROR>\n"
        default:
            return ""
        }
    }
    
    var withoutPowerWarning: String {
        switch timeWithoutPower {
        case 5...7:
            return "<WARNING>Colonists are annoyed by the lack of power.</WARNING>\n"
        case 8...9:
            return "<ERROR>Colonists are threatening to leave because of lack of power.</ERROR>\n"
        default:
            return ""
        }
    }
    
    var status: String {
        """
        Current date/time: \(Date())
        
        Flow control: \(flowControl.rawValue)
        Power delivery: \(outsidePowerOpened ? "Enabled" : "Disabled (Colony without power: \(timeWithoutPower))")
        Water pressure: \(waterPressure)
        Battery charge: \(batteryCharge * 100.0)%
        """
    }
    
    var warnings: String {
        let powerDeliveryWarning = outsidePowerOpened ? "" : "<WARNING>Power delivery cut</WARNING>\n"
        let waterPressureWarning = waterPressureDescription
        let batteryChargeWarning = batteryCharge <= 0.2 ? "<WARNING>Battery power low</WARNING>\n" : ""
        
        if powerDeliveryWarning == "" && waterPressureWarning == "" && batteryChargeWarning == "" {
            return ""
        } else {
            return """
            <WARNING>WARNINGS</WARNING>
            ================================================================================
            \(powerDeliveryWarning + waterPressureWarning + batteryChargeWarning + withoutPowerWarning)
            """
        }
    }
    
    func update() -> Turbine {
        var updatedTurbine = self
        
        guard gameState == .running else {
            return self
        }
        
        updatedTurbine.updateWaterPressure()
        updatedTurbine.updateBatteryCharge()
        
        return updatedTurbine
    }
    
    mutating private func updateWaterPressure() {
        switch flowControl {
        case .closed:
            waterPressure += 0.1
        case .halfOpened:
            waterPressure += 0.05
        case .fullyOpened:
            waterPressure -= 0.05
        }
        
        if waterPressure < 0 {
            waterPressure = 0
        }
    }
    
    mutating private func updateBatteryCharge() {
        if outsidePowerOpened {
            switch flowControl {
            case .closed:
                batteryCharge -= 0.1
            case .halfOpened:
                batteryCharge -= 0.05
            case .fullyOpened:
                batteryCharge += 0.05
            }
        } else {
            timeWithoutPower += 1
            switch flowControl {
            case .closed:
                break
            case .halfOpened:
                batteryCharge += 0.05
            case .fullyOpened:
                batteryCharge += 0.1
            }
        }
        
        if batteryCharge > 1 {
            batteryCharge = 1
        }
        
        if batteryCharge < 0 {
            batteryCharge = 0
        }
    }
        
    enum SetFlowStateError: Error {
        case insufficientBatteryCharge
    }
    
    func trySetWaterFlowTo(_ waterFlow: WaterFlowControlState) -> Result<Turbine, SetFlowStateError> {
        guard batteryCharge > 0.3 else {
            return .failure(.insufficientBatteryCharge)
        }
        
        var updatedTurbine = self
        updatedTurbine.batteryCharge -= 0.3
        updatedTurbine.flowControl = waterFlow
        return .success(updatedTurbine)
    }
}
