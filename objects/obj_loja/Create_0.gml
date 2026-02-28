produtos = [];
index_selecionado = 0;
anim_escala = 0;

adicionar_produto = function(_tipo, _id_referencia, _preco) 
{
    var _key_save = "comprado_" + string(_tipo) + "_" + string(_id_referencia);
    if (variable_struct_exists(global.permanentemente_quebrado, _key_save)) return;
    
    var _nome = "", _desc = "", _spr = noone;
    
    if (_tipo == "item") 
    {
        var _info = global.db_itens_info[$ _id_referencia]; 
        if (_info != undefined) {
            _nome = get_text(_info.nome_key);
            _desc = get_text(_info.desc_key);
            _spr  = _info.spr;
        }
    } 
    else if (_tipo == "amuleto") 
    {
        var _amuleto = global.amuletos[| _id_referencia]; 
        if (_amuleto != undefined) {
            _nome = get_text(_amuleto.nome_key);
            _desc = get_text(_amuleto.desc_key);
            _spr  = _amuleto.spr;
        }
    }
    
    array_push(produtos, {
        tipo: _tipo,
        ref_id: _id_referencia,
        preco: _preco,
        nome: _nome,
        desc: _desc,
        spr: _spr,
        chave: _key_save
    });
}

// --- LENDO O ESTOQUE DO MERCADOR ---
if (variable_instance_exists(id, "estoque_recebido"))
{
    for (var i = 0; i < array_length(estoque_recebido); i++)
    {
        var _prod = estoque_recebido[i];
        adicionar_produto(_prod.tipo, _prod.id, _prod.preco);
    }
}

if (array_length(produtos) == 0) 
{
    array_push(produtos, { nome: "Esgotado", desc: "Já comprei tudo...", preco: 0, spr: noone, tipo: "none" });
}
