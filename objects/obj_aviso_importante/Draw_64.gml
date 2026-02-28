if (sprite == -1) exit;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _s = max(1, _gui_h / ESCALA_UI); 

// 1. Fundo escuro dramático
draw_set_color(c_black);
draw_set_alpha(alpha * 0.85); 
draw_rectangle(0, 0, _gui_w, _gui_h, false);

var _cx = _gui_w / 2;
var _cy = _gui_h / 2;
var _item_y = _cy - (100 * _s); 

// ==========================================
// 2. BRILHO MÁGICO MULTICAMADAS (SUAVIZADO)
// ==========================================
// Deixei o pulso do fundo um pouco mais lento também (600)
var _pulso = abs(sin(current_time / 600)) * 0.08; 

gpu_set_blendmode(bm_add);

// O truque de ouro: diminuímos a opacidade global do brilho para não engolir o sprite
draw_set_alpha(alpha * 0.6); 

// Auras trocadas para tons mais escuros. No bm_add, c_dkgray e c_gray somam formando uma luz aveludada!
draw_circle_color(_cx, _item_y, (280 * _s) * (escala_item + _pulso), c_dkgray, c_black, false);
draw_circle_color(_cx, _item_y, (160 * _s) * escala_item, c_dkgray, c_black, false);
draw_circle_color(_cx, _item_y, (80 * _s) * escala_item, c_gray, c_black, false); // Era c_white

gpu_set_blendmode(bm_normal);
draw_set_alpha(alpha); // Restaura o alpha normal para desenhar os itens

// ==========================================
// 3. SPRITE FLUTUANTE (HOVER EFFECT)
// ==========================================
if (sprite != -1) {
    var _escala_final = (_s * 5) * escala_item; 
    
    // Flutuada mais lenta e elegante
    var _float_y = sin(current_time / 300) * (8 * _s); 

    var _spr_w = sprite_get_width(sprite);
    var _spr_h = sprite_get_height(sprite);
    var _xoff = sprite_get_xoffset(sprite) * _escala_final;
    var _yoff = sprite_get_yoffset(sprite) * _escala_final;

    var _draw_x = _cx - ((_spr_w * _escala_final) / 2) + _xoff;
    var _draw_y = _item_y - ((_spr_h * _escala_final) / 2) + _yoff + _float_y; 

    draw_sprite_ext(sprite, 0, _draw_x, _draw_y, _escala_final, _escala_final, 0, c_white, alpha);
}

// ==========================================
// 4. TEXTOS (Com Sombra e Divisória Elegante)
// ==========================================
draw_set_font(fnt_dialogo);
draw_set_halign(fa_center);
draw_set_valign(fa_top); 

var _titulo = get_text(titulo_key);
var _texto  = get_text(texto_key);

var _ty = _cy + (60 * _s); 

// Sombra
draw_set_color(c_black); 
draw_text_transformed(_cx + (3*_s), _ty + (3*_s), _titulo, _s * 1.5, _s * 1.5, 0);
// Título
draw_set_color(c_yellow); 
draw_text_transformed(_cx, _ty, _titulo, _s * 1.5, _s * 1.5, 0);

// Linha charmosa
var _linha_w = string_width(_titulo) * _s * 1.5 + (80 * _s);
var _linha_y = _ty + (60 * _s);
draw_line_width_color(_cx - _linha_w/2, _linha_y, _cx + _linha_w/2, _linha_y, 2*_s, c_white, c_white);

// Descrição
draw_set_color(c_white);
var _desc_y = _linha_y + (30 * _s);
draw_text_ext_transformed(_cx, _desc_y, _texto, 35, 700 * _s, _s, _s, 0);

// ==========================================
// 5. PROMPT PISCANDO MAIOR E CENTRALIZADO
// ==========================================
if (estado_item == 1) { 
    // Mudei o divisor de 200 para 500 (fica bem mais lento e suave)
    // Reduzi a amplitude para ele não ficar muito transparente no momento mais fraco
    var _alpha_piscando = alpha * (0.6 + abs(sin(current_time / 500)) * 0.4);
    draw_set_alpha(_alpha_piscando);
    
    var _prompt_y = _gui_h - (120 * _s); 
    
    var _str_continuar = get_text("menu_continuar");
    var _escala_txt = _s * 1.5;  
    var _escala_btn = _s * 2.0;  
    
    var _largura_txt = string_width(_str_continuar) * _escala_txt;
    var _espaco_btn = 40 * _escala_btn; 
    var _largura_total = _largura_txt + _espaco_btn;
    
    var _start_x = _cx - (_largura_total / 2); 
    
    desenha_input_verbo(INPUT_VERB.JUMP, _start_x + (_espaco_btn/2), _prompt_y, _escala_btn);
    
    draw_set_halign(fa_left); 
    draw_set_valign(fa_middle);
    draw_text_transformed(_start_x + _espaco_btn, _prompt_y, _str_continuar, _escala_txt, _escala_txt, 0);
}

draw_set_halign(-1); draw_set_valign(-1); draw_set_font(-1); draw_set_alpha(1);