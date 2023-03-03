//
//  File.swift
//  
//
//  Created by Maarten Engels on 08/11/2021.
//

import Foundation

func createUser(session: Session, username: String, password: String) async -> [MudResponse] {
    var updatedSession = session
    let response: MudResponse
    
    do {
        let newUser = try await User.create(username: username, password: password)
        updatedSession.playerID = newUser.id
        response = MudResponse(session: updatedSession, message: "Welcome, \(newUser.username)!\n\n\(newUser.turbine.warnings)")
    } catch {
        response = MudResponse(session: updatedSession, message: "Error creating user: \(error)")
    }
    
    return [response]
}

func login(session: Session, username: String, password: String) async -> [MudResponse] {
    var updatedSession = session
    let response: MudResponse
    
    //var notifications = [MudResponse]()
    
    do {
        let existingUser = try await User.login(username: username, password: password)
        updatedSession.playerID = existingUser.id
        response = MudResponse(session: updatedSession, message: "Welcome back, \(existingUser.username)!\n\n\(existingUser.turbine.warnings)")
        
    } catch {
        response = MudResponse(session: updatedSession, message: "Error logging in user: \(error)")
    }
    
//    var result = [response]
//    result.append(contentsOf: notifications)
    return [response]
}

func status(session: Session) async -> [MudResponse] {
    guard let player = await User.find(session.playerID) else {
        return [MudResponse(session: session, message: "Player not found in session.")]
    }
    
    guard player.turbine.gameState == .running else {
        return [createWinLoseMessage(player: player, session: session)]
    }
    
    var response = player.turbine.status
    
    let warnings = player.turbine.warnings
    
    if warnings != "" {
        response += "\n\n\(warnings)"
    }
    return [MudResponse(session: session, message: response)]
}

func setWaterflow(intendedFlowControlState: Turbine.WaterFlowControlState, session: Session) async -> [MudResponse] {
    guard var player = await User.find(session.playerID) else {
        return [MudResponse(session: session, message: "Player not found in session.")]
    }
    
    guard player.turbine.gameState == .running else {
        return [createWinLoseMessage(player: player, session: session)]
    }
        
    let result = player.turbine.trySetWaterFlowTo(intendedFlowControlState)
    
    switch result {
    case .success(let turbine):
        player.turbine = turbine.update()
        await player.save()
        return [MudResponse(session: session, message: "Water flow set to \(turbine.flowControl.rawValue).")]
    case .failure(let error):
        switch error {
        case .insufficientBatteryCharge:
            return [MudResponse(session: session, message: "Insufficient battery charge. You need at least 0.3 to change flow control.")]
        }
    }
}

func setPoweroutput(outsidePowerOpened: Bool, session: Session) async -> [MudResponse] {
    guard var player = await User.find(session.playerID) else {
        return [MudResponse(session: session, message: "Player not found in session.")]
    }
    
    guard player.turbine.gameState == .running else {
        return [createWinLoseMessage(player: player, session: session)]
    }
    
    player.turbine.outsidePowerOpened = outsidePowerOpened
    player.turbine = player.turbine.update()
    
    await player.save()
    
    return [MudResponse(session: session, message: "Power delivery has now been set to: \(player.turbine.outsidePowerOpened)")]
}

func wait(session: Session) async -> [MudResponse] {
    guard var player = await User.find(session.playerID) else {
        return [MudResponse(session: session, message: "Player not found in session.")]
    }
    
    guard player.turbine.gameState == .running else {
        return [createWinLoseMessage(player: player, session: session)]
    }
    
    player.turbine = player.turbine.update()
    
    await player.save()
    
    return [MudResponse(session: session, message: "Time is now: \(Date())")]
}

func reset(session: Session) async -> [MudResponse] {
    guard var player = await User.find(session.playerID) else {
        return [MudResponse(session: session, message: "Player not found in session.")]
    }
    
    player.turbine = Turbine()
    
    await player.save()
    
    return [MudResponse(session: session, message: "Simulation reset.\n\n\(player.turbine.warnings)")]
}

func createWinLoseMessage(player: User, session: Session) -> MudResponse {
    let response: String
    switch player.turbine.gameState {
    case .villageSaved:
        response = """
        <OK>Powerplant restored to nominal working conditions.
        
        The nearby ant colony thanks you for continuing to provide power.
        And not letting them drown.</OK>
        
        <B>This is the end of the simulation</B>
        Thank you for playing.
        If you want to play again, use the 'RESET' command.
        """
    case .villageFlood:
        response = """
        <ERROR>Turbine water pressure exceeded maximum value.
        
        Nearby colony flooded, drowning 50.000 colonists.</ERROR>
        
        <B>This is the end of the simulation</B>
        Thank you for playing.
        If you want to try again, use the 'RESET' command.
        """
    case .tooLongWithoutPower:
        response = """
        <ERROR>The nearby colonists grew tired of the blackouts.
        They packed their stuff and left for nicer sands.</ERROR>
        
        <B>This is the end of the simulation</B>
        Thank you for playing.
        If you want to try again, use the 'RESET' command.
        """
    default:
        response = ""
    }
    
    return MudResponse(session: session, message: response)
}

func help(session: Session) -> [MudResponse] {
    let response = """
    
    ================================================================================
    <B>INSTRUCTION MANUAL</B>
    
    Welcome to the SIMSA RIVER HYDROPOWER PLANT!
    This powerplant uses a T-Tech T5000 micro-hydro-batterybacked turbine.
    <I>This turbine is able to provide hydro electric power to colonies up to
    100.000 colonists.</I>
    
    <B>Safety instructions</B>
    <WARNING>* For use in rivers only!</WARNING>
    <WARNING>* Water pressure should not rise above 1.0!</WARNING>
    * Please make sure that Waterflow is set to 'FULL'.
    * Please make sure you have enough battery charge to change waterflow.
      (if you quickly need to charge the battery, cut poweroutput)
    
    <B>You are currently in the admin interface.</B>
    Use the prompt to enter commands to control the powerplant.
    
    <B>Generic commands:</B>
    <B>CREATE_USER <username> <password></B>: Create a new user.
    <B>LOGIN <username> <password></B>: Login with a previously generated user.
    <B>CLOSE</B>: Close the connection.
    <B>RESET</B>: Resets the simulation (so you can try again).
    <B>HELP</B>: Shows this help message.
    
    <B>Control the power plant</B>
    <B>SET_POWEROUTPUT</B> <enabled|disabled>: Enables/disables poweroutput to the colony
    <I>   Disabling poweroutput helps charge the battery, but colonists won't be happy.</I>
    <B>SET_WATERFLOW</B> <closed|half|full>: Sets the amount of waterflow.
    <I>   'Closed' and 'Half' increase water pressure. 'Full' provides the most power.</I>
    <B>WAIT</B>: Advances the simulation time.
    <I>   You will need this because changes to the powerplant take some time.</I>
    <B>STATUS</B>: Shows statistics/information about the power plant.
    
    <OK>We thank you for choosing <I>T-Tech</I> <OK>for all your power needs.</OK>
    ================================================================================
    
    """
    
    return [MudResponse(session: session, message: response)]
}

