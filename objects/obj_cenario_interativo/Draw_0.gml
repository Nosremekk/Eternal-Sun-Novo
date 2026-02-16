draw_self();

if (estado_atual == estado_idle and !global.pause and !instance_exists(obj_dialogo) and obj_player.chao) 
{
    var _margem = 16;
    var _x1 = bbox_left - _margem;
    var _x2 = bbox_right + _margem; 
    var _y1 = bbox_top - 40;
    var _y2 = bbox_bottom;

    if (collision_rectangle(_x1, _y1, _x2, _y2, obj_player, false, true))
    {
        draw_sprite(spr_ui_interage, 0, x, bbox_top - 20);
    }
}

