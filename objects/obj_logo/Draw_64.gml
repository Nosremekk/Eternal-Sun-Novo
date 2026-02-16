var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// 1. Fundo Preto
draw_set_color(c_black);
draw_set_alpha(1);
draw_rectangle(0, 0, _gui_w, _gui_h, false);
 
// 2. Logo Centralizada, Proporcional e Pulsante
if (sprite_exists(sprite_logo))
{
    var _cx = _gui_w / 2;
    var _cy = _gui_h / 2;
    
    // --- CÁLCULO DA ESCALA PROPORCIONAL ---
    var _margem = 0.8; 
    
    var _max_w = _gui_w * _margem;
    var _max_h = _gui_h * _margem;
    
    var _spr_w = sprite_get_width(sprite_logo);
    var _spr_h = sprite_get_height(sprite_logo);
    
    var _escala_x = _max_w / _spr_w;
    var _escala_y = _max_h / _spr_h;
    
    var _escala_final = min(_escala_x, _escala_y);
    
    if (_escala_final > 1) _escala_final = 1;

    // --- APLICA O PULSE ---
    // Multiplica a escala base pelo efeito de pulso calculado no estado WAIT
    var _escala_com_efeito = _escala_final * escala_pulse;

    // --- DESENHA O LOGO ---
    draw_sprite_ext(sprite_logo, 0, _cx, _cy, _escala_com_efeito, _escala_com_efeito, 0, c_white, alpha);
}

// Reset
draw_set_color(c_white);
draw_set_alpha(1);