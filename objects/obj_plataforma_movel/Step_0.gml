if (global.pause || !comeca) exit;      

// --- 1. CÁLCULO DE MOVIMENTO ---
move_dir += velocidade;

// Define alvo e diferença
var _target_x = ancora_x + dsin(move_dir) * range_x;
var _target_y = ancora_y + dsin(move_dir) * range_y; 

var _hsp_real = _target_x - x;
var _vsp_real = _target_y - y;

// --- 2. ACUMULADORES (Sub-pixel) ---
hsp_decimal += _hsp_real;
vsp_decimal += _vsp_real;

hsp = round(hsp_decimal);
vsp = round(vsp_decimal);

hsp_decimal -= hsp;
vsp_decimal -= vsp;

if (hsp == 0 && vsp == 0) exit;

// --- 3. FÍSICA E INTERAÇÃO ---
if (instance_exists(obj_player))
{
    var _p = obj_player;
    var _esta_em_cima = false; 
    
    // --- A. CARREGAR (Player em cima) ---
    var _margem = max(2, abs(vsp) + 2); // Margem dinâmica
    
    if (place_meeting(x, y - _margem, _p) && 
        (_p.bbox_bottom <= bbox_top + _margem) &&
        (_p.velv >= 0))
    {
        _esta_em_cima = true;
        
        // Move player antes da plataforma (se livre)
        if (!place_meeting(_p.x + hsp, _p.y, _p.colisor)) _p.x += hsp;
        if (!place_meeting(_p.x, _p.y + vsp, _p.colisor)) _p.y += vsp;
    }

    // --- B. EIXO X (Mover e Empurrar) ---
    x += hsp; 
    
    if (place_meeting(x, y, _p) && !_esta_em_cima)
    {
        // Calcula expulsão geométrica
        var _empurrao_x = (_p.x > x) ? (bbox_right - _p.bbox_left) + 1 : (bbox_left - _p.bbox_right) - 1;
        
        if (!place_meeting(_p.x + _empurrao_x, _p.y, _p.colisor))
        {
            _p.x += _empurrao_x;
        }
        else if (!_p.inv && _p.estado_atual != _p.estado_espinho) 
        {
            with(_p) troca_estado(estado_espinho); // Esmagamento
        }
    }

    // --- C. EIXO Y (Mover e Empurrar) ---
    y += vsp; 
    
    if (place_meeting(x, y, _p) && !_esta_em_cima)
    {
        // Calcula expulsão geométrica
        var _empurrao_y = (_p.y > y) ? (bbox_bottom - _p.bbox_top) + 1 : (bbox_top - _p.bbox_bottom) - 1;
        
        if (!place_meeting(_p.x, _p.y + _empurrao_y, _p.colisor))
        {
            _p.y += _empurrao_y;
            
            // Corrige cabeçada (zera pulo ao ser empurrado para baixo)
            if (_empurrao_y > 0 && _p.velv < 0) _p.velv = 0;
        }
        else if (!_p.inv && _p.estado_atual != _p.estado_espinho)
        {
            with(_p) troca_estado(estado_espinho); // Esmagamento
        }
    }
}
else
{
    // Sem player, apenas move
    x += hsp;
    y += vsp;
}

// --- 4. ATUALIZA SOMBRA (Bulb) ---
if (variable_instance_exists(id, "meu_oclusor") && is_struct(meu_oclusor))
{
    meu_oclusor.x = x;
    meu_oclusor.y = y;
}