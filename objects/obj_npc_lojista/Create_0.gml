// Inherit the parent event
event_inherited();

// Puxa o nome do JSON
nome_npc = get_text("npc_mercador"); 

// Cada mercador no mapa terá seu próprio array de produtos
estoque = [
    { tipo: "item", id: KEY_MAPA_MUNDO, preco: 1 },
    { tipo: "amuleto", id: 0, preco: 1 },   // 0 é o amuleto da vida
    { tipo: "amuleto", id: 1, preco: 1 },   // 1 é o amuleto de força
    
    // Nossos dois fragmentos de teste (usando IDs únicos de string para o Save)
    { tipo: "fragmento", id: "frag_loja_teste_1", preco: 1 },
    { tipo: "fragmento", id: "frag_loja_teste_2", preco: 1 },
    { tipo: "fragmento_tempo", id: "frag_temp_loja_1", preco: 1 }
];

interagir = function()
{
    // Puxando as falas do JSON
    var _txt = [get_text("loja_boas_vindas_1"), get_text("loja_boas_vindas_2")];
    
    // A SOLUÇÃO: method(id, ...) garante que o callback rode no contexto deste mercador
    var _cb = method(id, function() 
    {
        
        // Como o contexto foi amarrado ao mercador, ele acha o 'estoque' perfeitamente
        instance_create_layer(0, 0, "Controladores", obj_loja, {
            estoque_recebido: estoque 
        });
    });
    
    criar_dialogo(_txt, nome_npc, _cb);
}