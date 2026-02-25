if (global.pause || !comeca) exit;

// =========================================================
// 1. CÁLCULO DE MOVIMENTO (Senoide)
// =========================================================
var _tem_player_ativador = false;
if (instance_exists(obj_player)) {
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

hsp_decimal += (_target_x - x);
vsp_decimal += (_target_y - y);

hsp = round(hsp_decimal);
vsp = round(vsp_decimal);

hsp_decimal -= hsp;
vsp_decimal -= vsp;

if (hsp == 0 && vsp == 0) exit;

// =========================================================
// 2. FÍSICA E COLISÃO (EIXOS SEPARADOS)
// =========================================================
var _p = obj_player;

if (instance_exists(_p)) {
    
    // --- FASE A. DETECTAR SE O PLAYER ESTÁ EM CIMA ---
    var _em_cima = false;
    // Só verificamos se ele estiver caindo ou já parado
    if (_p.velv >= 0) {
        // A hitbox do player está colada 1 pixel acima de nós?
        if (place_meeting(x, y - 1, _p) || place_meeting(x, y - max(1, vsp), _p)) {
            // Confirmação matemática: O pé dele não pode estar abaixo do nosso topo!
            if (round(_p.bbox_bottom) <= round(bbox_top) + max(4, abs(vsp))) {
                _em_cima = true;
            }
        }
    }
    
    // Se confirmou que está em cima, a plataforma carrega ele:
    if (_em_cima) {
        if (!place_meeting(_p.x + hsp, _p.y, _p.colisor)) _p.x += hsp;
        if (!place_meeting(_p.x, _p.y + vsp, _p.colisor)) _p.y += vsp;
        _p.velv = 0;
        _p.chao = true;
    }

    // --- FASE B. MOVER NO EIXO X (Trata colisões laterais) ---
    x += hsp;
    if (hsp != 0 && place_meeting(x, y, _p) && !_em_cima) {
        // Bateu de lado! Empurra o player para fora.
        var _dir = sign(hsp);
        while (place_meeting(x, y, _p)) {
            _p.x += _dir;
        }
        // Depois de empurrar, checa se ele foi esmagado contra uma parede real
        if (place_meeting(_p.x, _p.y, _p.colisor)) {
            with (_p) { if (!inv && estado_atual != estado_espinho && estado_atual != estado_dead) troca_estado(estado_espinho); }
        }
    }

    // --- FASE C. MOVER NO EIXO Y (Trata teto e esmagamentos de chão) ---
    y += vsp;
    if (vsp != 0 && place_meeting(x, y, _p) && !_em_cima) {
        // Bateu por cima ou por baixo. Empurra o player!
        var _dir = sign(vsp);
        while (place_meeting(x, y, _p)) {
            _p.y += _dir;
        }
        // Checa se foi esmagado no teto ou no chão verdadeiro
        if (place_meeting(_p.x, _p.y, _p.colisor)) {
            with (_p) { if (!inv && estado_atual != estado_espinho && estado_atual != estado_dead) troca_estado(estado_espinho); }
        } else if (vsp < 0) {
            // Se a plataforma subiu e bateu no pé do player, ele apenas pousou nela de baixo pra cima
            _p.velv = 0;
            _p.chao = true;
        }
    }
    
} else {
    // Player não existe, apenas se move normalmente
    x += hsp;
    y += vsp;
}

// =========================================================
// 3. ATUALIZA SOMBRA
// =========================================================
if (variable_instance_exists(id, "meu_oclusor") && is_struct(meu_oclusor)) {
    meu_oclusor.x = x;
    meu_oclusor.y = y;
}