if (global.pause or sprite == -1 or instance_exists(obj_dialogo)) exit;


var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _s = max(1, _gui_h / ESCALA_UI); 

draw_set_font(fnt_dialogo);

var _titulo = get_text(titulo_key);
var _texto  = get_text(texto_key);

// Configs de Layout
var _w_box = 300 * _s;
var _pad   = 15 * _s;
var _icon_size = 64 * _s;
var _icon_area_w = _icon_size + (_pad * 1.5);


var _max_w_txt = _w_box - _icon_area_w - _pad;
var _sep = string_height("M") * 1.2;

var _h_titulo = string_height(_titulo);
var _h_texto  = string_height_ext(_texto, _sep, _max_w_txt);

var _h_content = _pad + _h_titulo + (5*_s) + _h_texto + _pad;
var _h_box = max(_h_content, _icon_size + (_pad*2)); // Garante altura mínima

// Posição 
var _margin_scr = 20 * _s;
var _x = _gui_w - _w_box - _margin_scr;
var _y = _gui_h - _h_box - _margin_scr + anim_y;


draw_set_alpha(alpha * 0.85);
draw_set_color(c_black);
draw_roundrect_ext(_x, _y, _x + _w_box, _y + _h_box, 16*_s, 16*_s, false);

draw_set_alpha(alpha);
draw_set_color(c_dkgray);
draw_roundrect_ext(_x, _y, _x + _w_box, _y + _h_box, 16*_s, 16*_s, true);


draw_set_color(c_white);

var _spr_w = sprite_get_width(sprite);
var _spr_h = sprite_get_height(sprite);
var _scale_spr = 1;

// Ajusta sprite para caber em 64px
var _target = 64;
if (_spr_w > _target) _scale_spr = _target / _spr_w;
if (_spr_h > _target) _scale_spr = min(_scale_spr, _target / _spr_h);

var _final_scale = _scale_spr * _s;
var _final_w = _spr_w * _final_scale;
var _final_h = _spr_h * _final_scale;

// Posição central EXATA do quadrado escuro
var _cx = _x + _pad + (_icon_size / 2);
var _cy = _y + (_h_box / 2);

// --- COMPENSAÇÃO DINÂMICA DE ORIGEM ---
// Lê a origem da sprite e aplica a escala atual
var _xoff = sprite_get_xoffset(sprite) * _final_scale;
var _yoff = sprite_get_yoffset(sprite) * _final_scale;

// Calcula a posição de desenho subtraindo a metade do tamanho (para centralizar a caixa)
// e somando a origem real da sprite.
var _draw_x = _cx - (_final_w / 2) + _xoff;
var _draw_y = _cy - (_final_h / 2) + _yoff;

// Desenha a sprite usando as coordenadas corrigidas
draw_sprite_ext(sprite, 0, _draw_x, _draw_y, _final_scale, _final_scale, 0, c_white, alpha);


draw_set_halign(fa_left); draw_set_valign(fa_top);
var _tx = _x + _icon_area_w;

// Título
draw_set_color(c_yellow);
draw_text_transformed(_tx, _y + _pad, _titulo, _s, _s, 0);

// Descrição
draw_set_color(c_white);
var _ty = _y + _pad + _h_titulo + (5*_s);
draw_text_ext_transformed(_tx, _ty, _texto, _sep, _max_w_txt, _s, _s, 0);

// Reset
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(-1);