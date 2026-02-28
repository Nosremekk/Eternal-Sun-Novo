// Inherit the parent event
event_inherited();

nome_npc = "Lucinao"; // Pode usar uma key do get_text() se quiser

// Cada mercador no mapa terá seu próprio array de produtos
estoque = [
    { tipo: "item", id: KEY_MAPA_MUNDO, preco: 1 },
    { tipo: "amuleto", id: 0, preco: 1 },   // 0 é o amuleto da vida
    { tipo: "amuleto", id: 1, preco: 1 }  // 1 é o amuleto de força
];

interagir = function()
{
    var _txt = ["Bem-vindo a minha lojita", "Dê uma olhada nos meus bagulhos."];
    
    // A SOLUÇÃO: method(id, ...) garante que o callback rode no contexto deste mercador
    var _cb = method(id, function() 
    {
        global.pause = true; 
        
        // Como o contexto foi amarrado ao mercador, ele acha o 'estoque' perfeitamente
        instance_create_layer(0, 0, "Controladores", obj_loja, {
            estoque_recebido: estoque 
        });
    });
    
    criar_dialogo(_txt, nome_npc, _cb);
}