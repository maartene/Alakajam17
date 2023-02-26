# Simsa River Power - Alakajam17 entry

Entry for the 17th Alakajam gamejam with theme "River".

Just want to play the game? You need an SSH client and connect to:
* host: `pi01-thedreamweb.ddnsgeek.com` (yes, this is a Raspberry Pi)
* port: `2222`

For example, on macOS/Linux:

`# ssh -p 2222 pi01-thedreamweb.ddnsgeek.com`

## Basic instructions:
Use the prompt to enter commands to control the powerplant.

### Generic commands:
* `CREATE_USER <username> <password>`: Create a new user.
* `LOGIN <username> <password>`: Login with a previously generated user.
* `CLOSE`: Close the connection.
* `RESET`: Resets the simulation (so you can try again).
* `HELP`: Shows commands and some more information.

### Control the power plant:
* `SET_POWEROUTPUT <enabled|disabled>`: Enables/disables poweroutput to the colony
Disabling poweroutput helps charge the battery, but colonists won't be happy.
* `SET_WATERFLOW <closed|half|full>`: Sets the amount of waterflow.
'Closed' and 'Half' increase water pressure. 'Full' provides the most power.
* `WAIT`: Advances the simulation time.
You will need this because changes to the powerplant take some time.

## Building
* You need the Swift 5.7 toolchain or higher.

`# git clone `
`# cd Alakajam17`
`# swift run`

### Environment variables
You can set the following environment variables:
* `ALAKAJAM17_HOSTNAME`: hostname to listen to (set to `0.0.0.0` if you want to listen to all connections. Set to `::1` by default.)
* `ALAKAJAM17_PORT`: port to listen to (default: 2222)

### About the entry
* Based on [NIOSwiftMUD](https://github.com/maartene/NIOSwiftMUD)
* If you have feedback, please leave it at the [entry page](https://alakajam.com/17th-alakajam/1431/simsa-river-hydropower/)
* Quick walkthrough here: 