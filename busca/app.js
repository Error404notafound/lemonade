import { initializeApp } from "https://gstatic.com";
import { getFirestore, collection, query, where, getDocs } from "https://gstatic.com";

// Configurações reais do seu Firebase Lemonade
const firebaseConfig = {
    apiKey: "AIzaSyA8l1HEX06pz732OkS0ao79RU9wpsUjRuE",
    authDomain: "://firebaseapp.com",
    projectId: "lemonade-aa1f0",
    storageBucket: "lemonade-aa1f0.firebasestorage.app",
    messagingSenderId: "763178048678",
    appId: "1:763178048678:android:5702a131240233a18ee867"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function executarBusca() {
    const termo = document.getElementById('search-input').value.toLowerCase().trim();
    const container = document.getElementById('results-container');
    
    if (!termo) return;
    container.innerHTML = '<p>Buscando de forma segura...</p>';

    try {
        const q = query(collection(db, "sites"), where("palavrasChave", "array-contains", termo));
        const querySnapshot = await getDocs(q);
        
        container.innerHTML = '';

        if (querySnapshot.empty) {
            container.innerHTML = '<p>Nenhum resultado privado encontrado.</p>';
            return;
        }

        querySnapshot.forEach((doc) => {
            const dados = doc.data();
            const item = document.createElement('div');
            item.className = 'result-item';
            item.innerHTML = `
                <a href="${dados.url}" target="_blank"><h3>${dados.titulo}</h3></a>
                <p>${dados.descricao}</p>
            `;
            container.appendChild(item);
        });
    } catch (erro) {
        console.error("Erro na busca: ", erro);
        container.innerHTML = '<p>Ocorreu um erro ao processar sua busca anônima.</p>';
    }
}

document.getElementById('search-btn').addEventListener('click', executarBusca);
document.getElementById('search-input').addEventListener('keypress', (e) => {
    if (e.key === 'Enter') executarBusca();
});
