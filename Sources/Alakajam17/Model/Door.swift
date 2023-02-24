//
//  Door.swift
//  
//
//  Created by Maarten Engels on 17/02/2023.
//

import Foundation

struct Door: DBType {
    private static var allDoors: AwesomeDB<Door> = AwesomeDB()
    
    let id: UUID
    var isOpen = false
    
    func getRooms() async -> [Room] {
        await Room.filter { room in
            for exit in room.exits {
                if exit.door == id {
                    return true
                }
            }
            return false
        }
    }
    
    static func find(_ id: UUID?) async -> Door? {
        if id == nil {
            return nil
        }
        
        return await allDoors.first(where: {$0.id == id})
    }
    
    func save() async {
        await Self.allDoors.replaceOrAddDatabaseObject(self)
        
        await Self.allDoors.save()
    }
}
