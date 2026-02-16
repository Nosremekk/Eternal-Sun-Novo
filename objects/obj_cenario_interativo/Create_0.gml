event_inherited();

grav = 0;
velv = 0;
nome_npc = undefined;
icone_offset_y = -sprite_height - 5;

checa_dialogo_area = function()
{
    if (talk_cooldown > 0) exit;

    var _margem = 16;
    var _x1 = bbox_left - _margem;
    var _x2 = bbox_right + _margem;
    var _y1 = bbox_top - 40;
    var _y2 = bbox_bottom;

    var _p = collision_rectangle(_x1, _y1, _x2, _y2, obj_player, false, true);

    if (_p)
    {
        if (InputPressed(INPUT_VERB.UP) and _p.chao)
        {
            interagir();
            troca_estado(estado_dialogo);
            talk_cooldown = .5; 
        }
        return true;
    }
    return false;
}