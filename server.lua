RegisterCommand('adres', function(source)
    if not IsPlayerAceAllowed(source, 'death.admin') then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Access Denied',
            description = 'You do not have permission to use this command.',
            type = 'error',
            position = 'top-center'
        })
        return
    end
    TriggerClientEvent('death:adminRespawn', source)
end, false)

RegisterCommand('adrev', function(source)
    if not IsPlayerAceAllowed(source, 'death.admin') then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Access Denied',
            description = 'You do not have permission to use this command.',
            type = 'error',
            position = 'top-center'
        })
        return
    end
    TriggerClientEvent('death:adminRevive', source)
end, false)
