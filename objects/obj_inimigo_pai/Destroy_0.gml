// --- REGISTRO DO BESTIÁRIO ---
if (meu_id_bestiario != "") 
{
    // 1. Soma a morte
    if (!variable_struct_exists(global.bestiario_kills, meu_id_bestiario)) 
    {
        global.bestiario_kills[$ meu_id_bestiario] = 0;
    }
    global.bestiario_kills[$ meu_id_bestiario] += 1;
    
    // 2. Verifica a Notificação
    var _kills_atuais = global.bestiario_kills[$ meu_id_bestiario];
    var _data = global.db_bestiario[$ meu_id_bestiario];
    
    // Confirma se o inimigo existe no BD
    if (_data != undefined)
    {
        // Regra de Ouro: Acabou de bater a meta exata E a meta exige mais de 1 morte?
        if (_kills_atuais == _data.mortes_req and _data.mortes_req > 1)
        {
            // Cria o pop-up na tela
            var _aviso = instance_create_depth(0, 0, 0, obj_aviso_item);
            _aviso.titulo_key = "ui_bestiario_get";
            _aviso.texto_key = _data.nome_key; // Exibe o nome do monstro!
            _aviso.sprite = _data.spr;
        }
    }
}
