ESX = nil 

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(niceESX) ESX = niceESX end)
    end
end)

local blip = {
    {x = -119.545,   y = -977.363,  z = 304.249},
    {x = 442.577,  y = 5569.2783,  z = 781.189}
}  

Citizen.CreateThread(function()
    for k, v in pairs(blip) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 94)
        SetBlipScale (blip, 0.8)
        SetBlipColour(blip, 39)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Saut en Parachute')
        EndTextCommandSetBlipName(blip)
    end
end)  

-- RageUI

local openedMenu = false 
local mainMenu = RageUI.CreateMenu('Parachute', 'Parachute')
local subMenu = RageUI.CreateSubMenu(mainMenu, "Parachute", "Parachute")
mainMenu.Closed = function() openedMenu = false FreezeEntityPosition(PlayerPedId(), false) end
mainMenu:SetRectangleBanner(0, 0, 0, 255)
subMenu:SetRectangleBanner(0, 0, 0 , 255)

function openMenu()
    if openedMenu then
        openedMenu = false
        return 
    else
        openedMenu = true
        FreezeEntityPosition(PlayerPedId(), false)
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while openedMenu do
                Wait(1.0)
                RageUI.IsVisible(mainMenu, function()
                    RageUI.Button("Parachute", nil, {RightLabel = "→→"}, true, {}, subMenu)
                end)
                RageUI.IsVisible(subMenu, function()
                    if #Config.Parachute.Shopping.Weapons[1] ~= 0 then
                        for k, v in pairs(Config.Parachute.Shopping.Weapons[1]) do 
                            RageUI.Button(v.label, nil, {RightLabel = "~r~Prendre~s~ →→"}, true, {
                                onSelected = function()
                                    TriggerServerEvent('savrinop:giveparachute', v.name, v.label)
                                end,
                            })
                        end
                    else
                        RageUI.Separator('')
                        RageUI.Separator('~r~Il n\'y a pas de parachute')
                        RageUI.Separator('') 
                    end
                end)
            end
        end)
    end
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.Parachute.Position.Shops) do 

        while not HasModelLoaded(v.pedModel) do
            RequestModel(v.pedModel)
            Wait(1)
        end
        Ped = CreatePed(2, GetHashKey(v.pedModel), v.pedPos, v.heading, 0, 0)
        FreezeEntityPosition(Ped, 1)
        TaskStartScenarioInPlace(Ped, v.pedModel, 0, false)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, 1)
    end
    while true do 
        local myCoords = GetEntityCoords(PlayerPedId())
        local nofps = false

        if not openedMenu then
            for k, v in pairs(Config.Parachute.Position.Shops) do 
                if #(myCoords - v.pos) < 1.0 then 
                    nofps = true
                    Visual.Subtitle("Appuyer sur ~o~[E]~s~ pour parler au ~o~Vendeur", 1) 
                    if IsControlJustPressed(0, 38) then                  
                        openMenu()
                    end 
                end 
            end 
        end
        if nofps then 
            Wait(1)
        else 
            Wait(1500)
        end 
    end
end) 

