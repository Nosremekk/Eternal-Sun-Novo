if (global.pause) exit;
draw_self();

// Config Texto
draw_set_halign(fa_center);
draw_set_font(fnt_dialogo);

// Verifica se o Titulo de Area esta na tela
var _esconde_prompt = false;
if (instance_exists(obj_hud))
{
    if (obj_hud.area_display_alpha > 0) _esconde_prompt = true;
}

// Feedback Visual
if (timer_save > 0)
{
    draw_set_color(c_yellow);
    draw_text(x + sprite_width/2, bbox_top - 40, saved_text);
}
else if (interagiu and !_esconde_prompt)
{
    draw_set_color(c_white);
    
    draw_sprite(spr_ui_interage, 0, x + sprite_width/2, bbox_top - 25);
}

// Reset
draw_set_halign(-1);
draw_set_color(c_white);