enum INVENTARIO_TAB { AMULETOS, ITENS, MELHORIAS, ESSENCIAS }
// --- MACROS (IDs CONSTANTES) ---
#macro KEY_MARCO_PAPP "key_dungeon_marco"
#macro KEY_MAPA_MUNDO "key_map_world"
#macro KEY_DOUBLE_JUMP "key_skill_dj"
#macro KEY_WALL_JUMP "key_skill_wj"
#macro KEY_DASH "key_skill_dash"
#macro KEY_TESTE1 "key_skill_test1"
#macro KEY_TESTE2 "key_skill_test2"
#macro KEY_TESTE3 "key_skill_test3"
#macro KEY_TESTE4 "key_skill_test4"
#macro KEY_TESTE5 "key_skill_test5"
#macro KEY_TESTE6 "key_skill_test6"
#macro KEY_TESTE7 "key_skill_test7"
#macro KEY_TESTE8 "key_skill_test8"
#macro KEY_TESTE9 "key_skill_test9"
#macro KEY_TESTE10 "key_skill_test10"
#macro KEY_TESTE11 "key_skill_test11"

// --- GLOBAIS DO INVENTÁRIO ---
global.abre_inventario = false;
global.inventario = ds_grid_create(4,4);
ds_grid_clear(global.inventario, 0);

global.player_slots_maximos = 3; 
global.player_slots_usados = 0;   
global.amuletos_equipados = ds_list_create(); 

// --- SISTEMA DE NOTIFICAÇÃO ---
global.fila_notificacao = ds_list_create();

function notificar_item(_nome_key, _sprite)
{
    ds_list_add(global.fila_notificacao, { key: _nome_key, spr: _sprite });
}

function gerencia_notificacoes()
{
    if (!instance_exists(obj_aviso_item)) and (!ds_list_empty(global.fila_notificacao))
    {
        var _dados = global.fila_notificacao[| 0];
        
        var _aviso = instance_create_layer(0, 0, "Controladores", obj_aviso_item);
        _aviso.texto_key = _dados.key;
        _aviso.sprite    = _dados.spr;
        
        ds_list_delete(global.fila_notificacao, 0);
    }
}

// --- DB VISUAL (ITENS CHAVE) ---
global.db_itens_info = {};

function registra_info_item(_id, _nome, _desc, _spr, _categoria)
{
    global.db_itens_info[$ _id] = 
    { 
        nome_key: _nome, 
        desc_key: _desc, 
        spr: _spr,
        categoria: _categoria
    };
}

// CADASTRO DOS ITENS
registra_info_item(KEY_MARCO_PAPP, "item_marco_nome", "item_marco_desc", spr_powerup, INVENTARIO_TAB.ITENS);
registra_info_item(KEY_MAPA_MUNDO, "item_mapa_nome", "item_mapa_desc", spr_boss, INVENTARIO_TAB.ITENS);
registra_info_item(KEY_DOUBLE_JUMP, "skill_dj_nome", "skill_dj_desc", spr_powerup, INVENTARIO_TAB.MELHORIAS);
registra_info_item(KEY_TESTE1, "item_alma1_nome", "item_alma1_desc", spr_inimigo, INVENTARIO_TAB.ESSENCIAS);

enum EFEITO { VIDA_MAXIMA, DANO_EXTRA, VELOCIDADE_MOV }

// --- STRUCT AMULETO ---
function cria_amuleto(_nome_key, _desc_key, _spr, _tipo_efeito, _valor_efeito, _custo_slot) constructor 
{
    static qtd_amuletos = 0;
    meu_id = qtd_amuletos;
    qtd_amuletos++;
    
    // Dados visuais
    nome_key = _nome_key;
    desc_key = _desc_key;
    spr = _spr;
    
    // Dados Mecânicos
    tipo_efeito = _tipo_efeito;
    valor_efeito = _valor_efeito;
    custo_slot = _custo_slot; 
    equipado = false;            
    
    // --- MÉTODOS OBSOLETOS (Mantidos Vazios para Compatibilidade) ---
    // A lógica real agora está em 'atualiza_stats_player()' no scr_var
    aplica_efeito = function() 
    { 
        // Não faz mais matemática aqui para evitar bugs.
        // Pode colocar efeitos sonoros/visuais de "equipar" aqui se quiser.
    }
    
    remove_efeito = function() 
    { 
        // Não faz mais matemática aqui.
    }
    
    // --- MÉTODO PRINCIPAL DE TROCA ---
    alterna_equipamento = function()
    {
        if (equipado)
        {
            // DESEQUIPAR
            global.player_slots_usados -= custo_slot;
            equipado = false;
            
            var _index = ds_list_find_index(global.amuletos_equipados, self);
            if (_index != -1) ds_list_delete(global.amuletos_equipados, _index);
            
            // O PULO DO GATO: Recalcula tudo do zero baseado na nova lista
            atualiza_stats_player();
            
            InputVibrateConstant(0.15, 0.0, 60);
        }
        else
        {
            // EQUIPAR
            var _slots_livres = global.player_slots_maximos - global.player_slots_usados;
            if (custo_slot <= _slots_livres)
            {
                global.player_slots_usados += custo_slot;
                equipado = true;
                ds_list_add(global.amuletos_equipados, self);
                
                // O PULO DO GATO: Recalcula tudo do zero com o novo item
                atualiza_stats_player();
                
                InputVibrateConstant(0.25, 0.0, 100);
            }
            else InputVibrateConstant(0.2, 0.0, 150);
        }
    }
    
    pega_item = function()
    {
        var _cols = ds_grid_width(global.inventario);
        var _lins = ds_grid_height(global.inventario);
        for (var _i = 0; _i < _lins; _i++)
        {
            for (var _j = 0; _j < _cols; _j++)
            {
                var _atual = global.inventario[# _j,_i]
                if (!_atual)
                {
                    global.inventario[# _j,_i] = global.amuletos[| meu_id];
                    notificar_item(nome_key, spr);
                    return true;
                }
            }
        }
        return false;
    }
}

enum amuletos { vida, forca, rapidez }

global.amuletos = ds_list_create();

// Instanciação Amuletos
// Nota: Ajustei o valor da vida para 1 ou 2, 10 é muita coisa se a base é 5
var _a = new cria_amuleto("amulet_vida_nome",    "amulet_vida_desc",    spr_amuletos, EFEITO.VIDA_MAXIMA, 2, 1); 
var _b = new cria_amuleto("amulet_forca_nome",   "amulet_forca_desc",   spr_amuletos, EFEITO.DANO_EXTRA, 1, 2); 
var _c = new cria_amuleto("amulet_rapidez_nome", "amulet_rapidez_desc", spr_amuletos, EFEITO.VELOCIDADE_MOV, .75, 1);

ds_list_add(global.amuletos, _a, _b, _c);

// --- FUNÇÕES DE CONTROLE ---

function reset_inventario_completo()
{
    if (ds_exists(global.inventario, ds_type_grid)) ds_grid_clear(global.inventario, 0);
    
    if (ds_exists(global.amuletos_equipados, ds_type_list))
    {
        var _lista = global.amuletos_equipados;
        // Apenas desmarca o flag 'equipado' nas structs originais
        for (var i = 0; i < ds_list_size(_lista); i++)
        {
            var _amuleto = _lista[| i];
            if (is_struct(_amuleto))
            {
                _amuleto.equipado = false; 
            }
        }
        ds_list_clear(_lista);
    }
    
    global.player_slots_usados = 0;
    
    // Garante que o inventário global de amuletos (a lista mestra) também esteja limpa de flags
    if (ds_exists(global.amuletos, ds_type_list))
    {
        var _lista_all = global.amuletos;
        for (var i = 0; i < ds_list_size(_lista_all); i++)
        {
            var _amuleto = _lista_all[| i];
            if (is_struct(_amuleto)) _amuleto.equipado = false; 
        }
    }
    
    // IMPORTANTE: Atualiza os stats para remover os bônus antigos
    atualiza_stats_player();
    
    ds_list_clear(global.fila_notificacao);
}

function inicializa_sistema_itens_chave()
{
    if (!variable_global_exists("itens_chave"))
    {
        global.itens_chave = ds_map_create();
    }
    else
    {
        if (!ds_exists(global.itens_chave, ds_type_map)) global.itens_chave = ds_map_create();
    }
}

function adiciona_item_chave(_item_id, _quantidade = 1)
{
    var _qtd = ds_map_find_value(global.itens_chave, _item_id) ?? 0;
    ds_map_replace(global.itens_chave, _item_id, _qtd + _quantidade);
    
    var _info = variable_struct_get(global.db_itens_info, _item_id);
    
    if (_info != undefined)
    {
        notificar_item(_info.nome_key, _info.spr);
    }
    else
    {
        notificar_item("item_unknown_name", spr_boss);
    }
    
    show_debug_message("Item Chave: " + _item_id + " (Total: " + string(_qtd + _quantidade) + ")");
}

function usa_item_chave(_item_id, _quantidade = 1)
{
    var _qtd = ds_map_find_value(global.itens_chave, _item_id) ?? 0;
    if (_qtd >= _quantidade)
    {
        ds_map_replace(global.itens_chave, _item_id, _qtd - _quantidade);
        return true; 
    }
    return false; 
}

function tem_item_chave(_item_id, _quantidade = 1)
{
    var _qtd = ds_map_find_value(global.itens_chave, _item_id) ?? 0;
    return (_qtd >= _quantidade);
}