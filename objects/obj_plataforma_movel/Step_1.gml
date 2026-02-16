if (global.pause || !comeca) exit;

// =========================================================
// 1. CÁLCULO DE MOVIMENTO (Senoide)
// =========================================================
var _tem_player_ativador = false;
if (instance_exists(obj_player)) {
    // Sensor generoso para ativação
    if (place_meeting(x, y - 4, obj_player) && obj_player.velv >= 0) _tem_player_ativador = true;
}

if (ativa_player) {
    if (_tem_player_ativador) {
        if (move_dir < 450) move_dir = min(450, move_dir + velocidade); 
    } else {
        if (move_dir > 270) move_dir = max(270, move_dir - velocidade);
    }
} else {
    move_dir += velocidade;
}

var _target_x = ancora_x + dsin(move_dir) * range_x;
var _target_y = ancora_y + dsin(move_dir) * range_y; 

// Sistema de Sub-pixel
var _hsp_real = _target_x - x;
var _vsp_real = _target_y - y;

hsp_decimal += _hsp_real;
vsp_decimal += _vsp_real;

hsp = round(hsp_decimal);
vsp = round(vsp_decimal);

hsp_decimal -= hsp;
vsp_decimal -= vsp;

// Se não move, não processa física
if (hsp == 0 && vsp == 0) exit;

// =========================================================
// 2. FASE DE TRANSPORTE (Carregar quem já está em cima)
// =========================================================
var _p = instance_place(x, y - 2, obj_player);
var _carregou_player = false; 

if (_p != noone) {
    // Só carrega se o player estiver apoiado (não subindo/pulando através)
    if (_p.bbox_bottom <= bbox_top + 8 && _p.velv >= 0) {
        _carregou_player = true;
        
        // Carrega X (com verificação de parede)
        if (!place_meeting(_p.x + hsp, _p.y, _p.colisor)) _p.x += hsp;
        
        // Carrega Y (com verificação de teto/chão)
        if (!place_meeting(_p.x, _p.y + vsp, _p.colisor)) _p.y += vsp;
    }
}

// =========================================================
// 3. MOVER A PLATAFORMA
// =========================================================
x += hsp;
y += vsp;

// =========================================================
// 4. RESOLUÇÃO DE CONFLITOS (Blindada)
// =========================================================
// Se após mover, a plataforma e o player estão sobrepostos...
if (instance_exists(obj_player) && place_meeting(x, y, obj_player) && !_carregou_player) {
    var _overlap = instance_place(x, y, obj_player);
    
    // --- Prioridade 1: Correção de Pouso (Anti-Engolimento) ---
    var _centro_plat = y + (sprite_height / 2);
    
    // CORREÇÃO 1: Detecta se a plataforma está subindo CONTRA o player
    var _plataforma_subindo_contra = (vsp < 0 && _overlap.velv >= 0);
    
    // Aceita o pouso se: Pé está alto OU plataforma desce OU plataforma sobe contra player
    if (_overlap.bbox_bottom < _centro_plat || (vsp > 0 && _overlap.velv >= 0) || _plataforma_subindo_contra) {
        
        // Tenta empurrar para o TOPO (Snap)
        var _topo_destino = bbox_top - (_overlap.bbox_bottom - _overlap.y) - 1;
        
        // Verifica se há teto bloqueando a subida
        if (!place_meeting(_overlap.x, _topo_destino, _overlap.colisor)) {
            _overlap.y = _topo_destino;
            _overlap.velv = 0;
            _overlap.chao = true;
            return; // Conflito resolvido, sai do script!
        } else {
            // Tem teto = Esmagamento Real
            // CORREÇÃO 2: Só mata se já não estiver morto
            if (!_overlap.inv && _overlap.estado_atual != _overlap.estado_espinho && _overlap.estado_atual != _overlap.estado_dead) {
                with(_overlap) troca_estado(estado_espinho);
            }
            return;
        }
    }
    
    // --- Prioridade 2: Empurrão Lateral (Se não deu pra subir) ---
    if (hsp != 0) {
        var _dir = sign(hsp);
        var _max_push = abs(hsp) + 4; 
        var _dist = 0;
        var _safe = true;
        
        while (place_meeting(x, y, _overlap) && _dist < _max_push) {
            _overlap.x += _dir;
            _dist++;
            if (place_meeting(_overlap.x, _overlap.y, _overlap.colisor)) {
                _safe = false; // Bateu na parede
                break;
            }
        }
        
        if (!_safe) {
            // CORREÇÃO 2: Só mata se já não estiver morto
            if (!_overlap.inv && _overlap.estado_atual != _overlap.estado_espinho && _overlap.estado_atual != _overlap.estado_dead) {
                with(_overlap) troca_estado(estado_espinho);
            }
        }
        return; // Sai se resolveu ou matou
    }

    // --- Prioridade 3: Empurrão Vertical (Para baixo) ---
    if (vsp > 0) {
        var _max_push_v = abs(vsp) + 4;
        var _dist_v = 0;
        var _safe_v = true;
        
        while (place_meeting(x, y, _overlap) && _dist_v < _max_push_v) {
            _overlap.y++;
            _dist_v++;
            if (place_meeting(_overlap.x, _overlap.y, _overlap.colisor)) {
                _safe_v = false; // Esmagado no chão
                break;
            }
        }
        
        if (!_safe_v) {
             // CORREÇÃO 2: Só mata se já não estiver morto
             if (!_overlap.inv && _overlap.estado_atual != _overlap.estado_espinho && _overlap.estado_atual != _overlap.estado_dead) {
                with(_overlap) troca_estado(estado_espinho);
            }
        }
    }
}

// Atualiza sombra
if (variable_instance_exists(id, "meu_oclusor") && is_struct(meu_oclusor)) {
    meu_oclusor.x = x;
    meu_oclusor.y = y;
}