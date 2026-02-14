Config = {}

-- 🎨 Configuración Visual (NUI)
Config.UI = {
    Title = "BIENVENIDO A LA CIUDAD",
    Description = "Gracias por unirte. Reclama tu kit de ciudadano para comenzar tu historia.",
    ServerName = "Costa Sur RP",
    PrimaryColor = "#ffffff", -- Color de acento (verde ox por defecto)
    ButtonText = "RECLAMAR KIT"
}

-- 👤 NPC de Bienvenida
Config.NPC = {
    Model = 'a_m_y_business_03', -- Modelo del ped
    Coords = vector4(-1037.8544, -2731.1504, 20.1693, 173.3571), -- Aeropuerto LS (ejemplo)
    Scenario = 'WORLD_HUMAN_CLIPBOARD', -- Animación idle
    Icon = 'fa-solid fa-gift',
    Label = 'Hablar con Recepcionista',
    RenderDistance = 20.0
}

-- 🎒 Contenido del Kit
Config.Rewards = {
    Money = {
        Cash = 7500,
    },
    Items = {
        -- nombre_item = cantidad
        ['water_bottle'] = 5,
        ['burger'] = 5,
        ['phone'] = 1,
    }
}

-- 🚗 Vehículo de Inicio
Config.Vehicle = {
    Enable = true, -- ¿Dar vehículo?
    Model = 'Panto', -- Modelo
    SpawnPoint = vector4(-1041.0844, -2724.4060, 20.1448, 241.4147), -- Donde aparece el auto
    WarpPlayer = true, -- ¿Teletransportar al jugador dentro del auto?
    Colors = {
        Primary = 111, -- Blanco Metálico
        Secondary = 0  -- Negro
    },
    Livery = -1, -- -1 para ninguno
    PlatePrefix = "NEW" -- Prefijo de la placa
}

-- 🔔 Notificaciones
Config.Notify = {
    Success = "¡Has recibido tu kit de inicio correctamente!",
    Error = "Ha ocurrido un error al entregar el kit.",
    AlreadyClaimed = "Ya has reclamado tu kit de inicio anteriormente.",
    VehicleBlocked = "La zona de entrega de vehículos está bloqueada, intenta en un momento."
}