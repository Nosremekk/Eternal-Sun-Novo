
estado_idle    = new estado();
estado_dialogo = new estado();

velh     = 0;
velv     = 0;
grav     = 0.30;
max_velv = 4;
chao     = false;

xscale = image_xscale;

// Colisão
colisao_tile_map = layer_tilemap_get_id("Colisao_Tiles");
colisor = [obj_colisor,colisao_tile_map];

// Interação
area          = 45;
margem        = sprite_width;
talk_cooldown = 0; 
debug_npc     = false; 

nome_npc = "NPC";

//Sobrescreves nos filhos
interagir = function()
{
    var _txt = ["..."];
    criar_dialogo(_txt, nome_npc);
}

checa_dialogo_area = function() 
{
    if (talk_cooldown > 0) exit; 

    var _x1 = x + (margem * xscale);
    var _x2 = x + ((area/2 + margem) * xscale);
    var _y1 = y - 40; // Altura ajustada para cabeça do player

    var _p = collision_rectangle(min(_x1,_x2), _y1, max(_x1,_x2), y, obj_player, false, true);
    
    // Retorna true se player está na área (para desenhar ícone)
    if (_p) 
    {
        // Interação
        if (InputPressed(INPUT_VERB.UP) and _p.chao) 
        { 
            // Vira pro player 
            var _dir = sign(_p.x - x);
            if (_dir != 0) xscale = _dir;
            image_xscale = -xscale;

            // Player vira pro NPC
            with (_p)
            {
                var _dir_npc = sign(other.x - x);
                if (_dir_npc != 0) xscale = _dir_npc;
            }

            // Inicia Lógica
            interagir();
            troca_estado(estado_dialogo);
            talk_cooldown = 0.25; //delay
        }
        return true;
    }
    return false;
}

desenha_icone = function()
{
    if (estado_atual == estado_idle and !global.pause and !instance_exists(obj_dialogo))
{
    //Desenho?
    var _x1 = x + (margem * xscale);
    var _x2 = x + ((area/2 + margem) * xscale);
    var _y1 = y - 40;
    
    if (collision_rectangle(min(_x1,_x2), _y1, max(_x1,_x2), y, obj_player, false, true))
    {
        // Centralizado acima da cabeça
        draw_sprite(spr_ui_interage, 0, x, bbox_top - 20);
    }
}
}


// Configurando state machine dos npc
estado_idle.inicia = function() {};

estado_idle.roda = function() 
{
    chao = place_meeting(x, y+1, colisor);
    if (!chao) velv = min(velv + grav, max_velv);
    else velv = 0;

    checa_dialogo_area();

    // Debug
    if (keyboard_check_pressed(ord("G"))) debug_npc = !debug_npc;
};

estado_idle.finaliza = function() {};

estado_dialogo.inicia = function() 
{
    velh = 0; 
};

estado_dialogo.roda = function() 
{
    chao = place_meeting(x, y+1, colisor);
    if (!chao) velv = min(velv + grav, max_velv);
    else velv = 0;

    // se o dialogo nao existe sai do dialogo
    if (!instance_exists(obj_dialogo)) 
    {
        troca_estado(estado_idle);
        exit;
    }
};

estado_dialogo.finaliza = function() 
{
    talk_cooldown = 0.2; //segurança
};

inicia_estado(estado_idle);