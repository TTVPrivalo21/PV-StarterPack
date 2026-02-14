const app = document.getElementById('app');
const root = document.querySelector(':root');

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'open') {
        setupUI(data);
        app.classList.remove('hidden');
    }
});

function setupUI(data) {
    const cfg = data.config;
    const rw = data.rewards;

    // Configurar Textos y Colores
    document.getElementById('title').innerText = cfg.Title;
    document.getElementById('desc').innerText = cfg.Description;
    document.getElementById('claim-btn').innerText = cfg.ButtonText;
    root.style.setProperty('--primary', cfg.PrimaryColor);

    // Configurar Dinero
    document.getElementById('cash-amount').innerText = '$' + rw.Money.Cash.toLocaleString();
    document.getElementById('bank-amount').innerText = '$' + rw.Money.Bank.toLocaleString();

    // Configurar Vehículo
    if (data.vehicle) {
        document.getElementById('veh-name').innerText = data.vehicle.toUpperCase();
    } else {
        document.getElementById('veh-container').style.display = 'none';
    }

    // Listar Items
    const list = document.getElementById('items-ul');
    list.innerHTML = '';
    
    // Convertimos el objeto de items en array para iterar
    Object.entries(rw.Items).forEach(([name, count]) => {
        const li = document.createElement('li');
        // Formatear nombre del item (quitar guiones bajos y capitalizar)
        const friendlyName = name.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        li.innerHTML = `${friendlyName} <b>x${count}</b>`;
        list.appendChild(li);
    });
}

// Botón Reclamar
document.getElementById('claim-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/claim`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    app.classList.add('hidden');
});

// Cerrar con ESC
document.onkeyup = function(data) {
    if (data.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        app.classList.add('hidden');
    }
};