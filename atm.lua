--[[
Copyright 2020 @ Jan Bebendorf
https://github.com/JanHolger/OnsetATMUI
]]

local web = CreateWebUI(0,0,0,0,1,16)
SetWebAlignment(web, 0, 0)
SetWebAnchors(web, 0, 0, 1, 1)
SetWebURL(web, "http://asset/atm/atm.html")
SetWebVisibility(web, WEB_HIDDEN)

local balance = 0
local page = "insert"
local input = ""
local transfer_target = ""

local function playSound(name)
    CreateSound("atm/"..name..".wav")
end

local function CloseATM(force)
    if force == true then
        page = "insert"
        ExecuteWebJS(web, "fnc['DisplayInsertCard']();")
        SetWebVisibility(web, WEB_HIDDEN)
        SetInputMode(INPUT_GAME)
        ShowMouseCursor(false)
        return
    end
    page = "ejecting"
    ExecuteWebJS(web, "fnc['DisplayLoading']();")
    ExecuteWebJS(web, "fnc['AnimCardOut']();")
    playSound("cardeject")
    Delay(1000, function()
        ExecuteWebJS(web, "fnc['DisplayInsertCard']();")
    end)
    Delay(1700, function()
        CloseATM(true)
    end)
end

AddRemoteEvent("CloseATM", CloseATM)

AddRemoteEvent("OpenATM", function()
    SetWebVisibility(web, WEB_VISIBLE)
    SetInputMode(INPUT_GAMEANDUI)
    ShowMouseCursor(true)
end)

AddRemoteEvent("ATMBalance", function(bal)
    balance = bal
    ExecuteWebJS(web, "fnc['DisplayMenu']('Balance: "..tostring(bal).." $', ['Withdraw','Deposit','Transfer','','Eject Card','']);")
    page = "menu"
end)

AddRemoteEvent("ATMWithdraw", function()
    ExecuteWebJS(web, "fnc['AnimWithdraw']();")
    playSound("withdraw")
    Delay(3000, function()
        CallRemoteEvent("ATMRequestBalance")
    end)
end)

AddRemoteEvent("ATMDeposit", function()
    ExecuteWebJS(web, "fnc['AnimDeposit']();")
    playSound("deposit")
    Delay(3000, function()
        CallRemoteEvent("ATMRequestBalance")
    end)
end)

AddEvent("ATMButton", function(button)
    if button ~= "card" then
        playSound("buttonpress")
    end
    if page == "insert" then
        if button == "card" then
            page = "inserting"
            ExecuteWebJS(web, "fnc['AnimCardIn']();")
            playSound("cardinsert")
            Delay(1000, function()
                ExecuteWebJS(web, "fnc['DisplayLoading']();")
            end)
            Delay(2000, function()
                CallRemoteEvent("ATMRequestBalance")
            end)
            return
        end
    end
    if page == "menu" then
        if button == "action1" then
            page = "withdraw"
            input = ""
            ExecuteWebJS(web, "fnc['DisplayLoading']();")
            Delay(1000, function()
                ExecuteWebJS(web, "fnc['DisplayInput']('Withdraw','Amount','');")
            end)
            return
        end
        if button == "action2" then
            page = "deposit"
            input = ""
            ExecuteWebJS(web, "fnc['DisplayLoading']();")
            Delay(1000, function()
                ExecuteWebJS(web, "fnc['DisplayInput']('Deposit','Amount','');")
            end)
        end
        if button == "action3" then
            page = "transfer_to"
            input = ""
            ExecuteWebJS(web, "fnc['DisplayLoading']();")
            Delay(1000, function()
                ExecuteWebJS(web, "fnc['DisplayInput']('Transfer','Receiver','"..input.."');")
            end)
        end
        if button == "action5" then
            CloseATM()
        end
    end
    if page == "withdraw" or page == "deposit" or page == "transfer" or page == "transfer_to" then
        if button == "cancel" then
            page = "cancelling"
            ExecuteWebJS(web, "fnc['DisplayLoading']();")
            Delay(1000, function()
                CallRemoteEvent("ATMRequestBalance")
            end)
            return
        end
        if button == "comma" then
            if page ~= "transfer_to" then
                input = input.."."
            end
        end
        if button:len() == 4 and button:sub(1,3) == "num" then
            if input:len() < 6 then
                input = input..button:sub(4,4)
            end
        end
        if button == "clear" then
            input = ""
        end
        if button == "enter" then
            if page == "withdraw" then
                page = "withdrawing"
                ExecuteWebJS(web, "fnc['DisplayLoading']();")
                Delay(1000, function()
                    CallRemoteEvent("ATMRequestWithdraw", tonumber(input))
                end)
            end
            if page == "deposit" then
                page = "depositing"
                ExecuteWebJS(web, "fnc['DisplayLoading']();")
                Delay(1000, function()
                    CallRemoteEvent("ATMRequestDeposit", tonumber(input))
                end)
            end
            if page == "transfer" then
                page = "transfering"
                ExecuteWebJS(web, "fnc['DisplayLoading']();")
                Delay(1000, function()
                    CallRemoteEvent("ATMRequestTransfer", transfer_target, tonumber(input))
                end)
            end
            if page == "transfer_to" then
                transfer_target = input
                input = ""
                page = "transfer"
                ExecuteWebJS(web, "fnc['DisplayLoading']();")
                Delay(1000, function()
                    ExecuteWebJS(web, "fnc['DisplayInput']('Transfer','Amount','"..input.."');")
                end)
            end
            return
        end
        if page == "withdraw" then
            ExecuteWebJS(web, "fnc['DisplayInput']('Withdraw','Amount','"..input.."');")
        end
        if page == "deposit" then
            ExecuteWebJS(web, "fnc['DisplayInput']('Deposit','Amount','"..input.."');")
        end
        if page == "transfer" then
            ExecuteWebJS(web, "fnc['DisplayInput']('Transfer','Amount','"..input.."');")
        end
        if page == "transfer_to" then
            ExecuteWebJS(web, "fnc['DisplayInput']('Transfer','Receiver','"..input.."');")
        end
    end
    if page ~= "ejecting" then
        if button == "card" then
            CloseATM()
        end
    end
end)