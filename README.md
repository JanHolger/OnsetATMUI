# OnsetATMUI
An ATM UI for Onset

## Usage
The ui was made for a private roleplay mode written in groovy so this repository only contains the client files.
To use it you need to implement the serversided transaction logic in your own project.

### Hooks to implement
```lua
AddRemoteEvent("ATMRequestBalance", function(player)
    CallRemoteEvent(player, "ATMBalance", PLAYER_BALANCE)
end)

AddRemoteEvent("ATMRequestWithdraw", function(player, amount)
    -- DO WITHDRAW
    if(SUCCESS) then
        CallRemoteEvent(player, "ATMWithdraw")
    else
        CallRemoteEvent(player, "ATMBalance", PLAYER_BALANCE)
    end
end)

AddRemoteEvent("ATMRequestDeposit", function(player, amount)
    -- DO DEPOSIT
    if(SUCCESS) then
        CallRemoteEvent(player, "ATMDeposit")
    else
        CallRemoteEvent(player, "ATMBalance", PLAYER_BALANCE)
    end
end)

AddRemoteEvent("ATMRequestTransfer", function(player, amount)
    -- DO TRANSFER
    CallRemoteEvent(player, "ATMBalance", PLAYER_BALANCE)
end)
```
### Opening / Closing
```lua
CallRemoteEvent(player, "OpenATM")
CallRemoteEvent(player, "CloseATM")
```

## License
You are allowed to edit and use parts of this repository or the entire repository in open source licensed projects as long as you keep the copyright section in the files or mention the original repository (https://github.com/JanHolger/OnsetATMUI) in a seperate LICENSE or README file.