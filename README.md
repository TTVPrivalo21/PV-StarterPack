#🎁 PV STARTERKIT | Pack de Inicio QBCore
--------------------------------------------------
Un script de bienvenida intuitivo y moderno para servidores de FiveM. 
Permite a los nuevos jugadores reclamar un paquete inicial con dinero, ítems y vehículo personal a través de una interfaz NUI elegante y sistema de NPC.

# ✨ CARACTERÍSTICAS PRINCIPALES:
• Interacción con NPC: Sistema optimizado (solo spawnea por cercanía).
• Interfaz NUI Moderna: Diseño limpio, CSS moderno y animaciones fluidas.
• Recompensas: Entrega de dinero (Efectivo/Banco) y múltiples ítems.
• Sistema de Vehículos: Registro directo en DB con placa personalizada.
• Anti-Exploit: Control por metadatos para evitar doble reclamo.
• Optimización: Uso de ox_lib y ox_target (0.00ms).

# 📋 REQUISITOS:
* QBCore Framework
* [Ox Lib](https://github.com/overextended/ox_lib)
* [Ox Inventory](https://github.com/TheOrderFivem/ox_inventory)] (Recomiendo este Inventario ya que esta actualizado a la ultima version y adaptado para QBcore)
* [Ox Target](https://github.com/TheOrderFivem/ox_target) (Recomiendo este Target ya que esta actualizado a la ultima version y adaptado para QBcore)

# 🚀 INSTALACIÓN RÁPIDA:
1. Renombra la carpeta a: pv_starterkit.
2. Ejecuta el Archivo SQL en tu base de datos para registrar quien canjea el kit.
3. Items: Verifica que existan en tu ox_inventory/data/items.lua.

# ⚙️ CONFIGURACIÓN (Config.lua):
• Config.UI: Títulos, descripciones y colores.
• Config.NPC: Modelo del ped, coordenadas y animación.
• Config.Rewards: Cantidades de dinero e ítems.
• Config.Vehicle: Modelo, punto de spawn y prefijo de placa.

# 🛠️ COMANDOS DE ADMINISTRADOR:
• /resetstarter [ID]: Permite volver a reclamar el kit (Admin).

# 📡 EXPORTS PARA DESARROLLADORES:
exports['pv_starterkit']:HasClaimedKit(source)

# 📝 NOTAS ADICIONALES:
• El vehículo se guarda por defecto en: pillboxgarage.
• La interfaz se cierra automáticamente con la tecla ESC.
