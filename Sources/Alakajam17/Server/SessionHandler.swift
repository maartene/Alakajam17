//
//  File.swift
//  
//
//  Created by Maarten Engels on 01/11/2021.
//

import Foundation
import NIO
import NIOSSH

struct TextCommand {
    let session: Session
    let command: String
}

final class SessionHandler: ChannelInboundHandler {
    
    typealias InboundIn = SSHChannelData
    typealias InboundOut = TextCommand
    typealias OutboundOut = SSHChannelData
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inBuff = self.unwrapInboundIn(data)
        
        guard case .byteBuffer(let bytes) = inBuff.data else {
            fatalError("Unexpected read type")
        }
        
        guard case .channel = inBuff.type else {
            context.fireErrorCaught(SSHServerError.invalidDataType)
            return
        }
        
        let str = String(buffer: bytes)
        
        var session = SessionStorage.first(where: { $0.channel.remoteAddress == context.channel.remoteAddress }) ?? Session(id: UUID(), channel: context.channel, playerID: nil)
                
        session.currentString += str
        
        if str.contains("\n") || str.contains("\r") {
            let command = TextCommand(session: session.erasingCurrentString(), command: session.currentString)
            context.fireChannelRead(wrapInboundOut(command))
        } else {
            context.writeAndFlush(self.wrapOutboundOut(inBuff), promise: nil)
        }
        
        SessionStorage.replaceOrStoreSessionSync(session)
    }
    
    public func channelActive(context: ChannelHandlerContext) {
        let welcomeText = """
        ================================================================================
        =             WELCOME TO THE SIMSA RIVER HYDROPOWER PLANT ADMIN SYSTEM         =
        =                                                                              =
        =                        UNAUTHORIZED ACCESS PROHIBITED                        =
        =                                                                              =
        = Please use 'CREATE_USER <username> <password>' to begin.                     =
        = You can leave by using the 'CLOSE' command.                                  =
        = For a list of available commands, enter 'HELP'                               =
        =                                                                              =
        ================================================================================
        
        Current date/time: \(Date())
        
        <WARNING>WARNING: Turbine pressure rising</WARNING>
        """
        
        let ansiWelcomeText = AnsiFormatter.main.format(welcomeText) + "\n> "
        
        let sshAnsiWelcomeText = ansiWelcomeText.replacingOccurrences(of: "\n", with: "\r\n")
                
        var outBuff = context.channel.allocator.buffer(capacity: sshAnsiWelcomeText.count)
        outBuff.writeString(sshAnsiWelcomeText)
        
        let channelData = SSHChannelData(byteBuffer: outBuff)
        context.writeAndFlush(self.wrapOutboundOut(channelData), promise: nil)
    }
}
