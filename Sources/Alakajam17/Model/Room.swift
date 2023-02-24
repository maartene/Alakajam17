//
//  File.swift
//  
//
//  Created by Maarten Engels on 08/11/2021.
//

import Foundation

struct Room: DBType {
    private static var allRooms: AwesomeDB<Room> = AwesomeDB()
    
    let id: UUID
    
    let name: String
    let description: String
    let exits: [Exit]
    
    var formattedDescription: String {
        """
        \(name)
        \(description)
        There are exits: \(exitsAsString)
        
        """
    }
    
    static let STARTER_ROOM_ID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    var exitsAsString: String {
        let direction = exits.map { exit in
            var result = exit.direction.rawValue
            if exit.door != nil {
                result += " (door)"
            }
            return result
        }
        return direction.joined(separator: ", ")
    }
    
    static func find(_ id: UUID?) async -> Room? {
        if id == nil {
            return nil
        }
        
        return await allRooms.first(where: {$0.id == id})
    }
    
    static func filter(where predicate: (Room) -> Bool) async -> [Room] {
        await Self.allRooms.filter(where: predicate)
    }
}

struct Exit: Codable {
    let direction: Direction
    let targetRoomID: UUID
    let door: UUID?
    
    func getDoor() async -> Door? {
        await Door.find(door)
    }
}


enum Direction: String, Codable {
    case North
    case South
    case East
    case West
    case Up
    case Down
    case In
    case Out
    
    var opposite: Direction {
        switch self {
        case .North:
            return .South
        case .South:
            return .North
        case .East:
            return .West
        case .West:
            return .East
        case .Up:
            return .Down
        case .Down:
            return .Up
        case .In:
            return .Out
        case .Out:
            return .In
        }
    }
    
    public init?(stringValue: String) {
        let capitalizedStringValue = stringValue.capitalized // NORTH --> North,  north --> North
        self.init(rawValue: capitalizedStringValue)
    }
}
