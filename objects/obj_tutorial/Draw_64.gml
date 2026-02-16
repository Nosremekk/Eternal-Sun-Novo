if (global.pause) exit;

if (alpha_atual <= 0.01) exit;

// --- 1. CONFIGURAÇÃO ---
var _s = get_hud_scale(); 
var _final_scale = _s * 1.5; 

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

draw_set_font(fnt_dialogo);

// --- 2. CÁLCULO DE DIMENSÕES ---
var _txt_w = string_width(texto_final) * _final_scale;
var _icon_space = 50 * _final_scale; 
var _gap = 20 * _final_scale;       
var _padding = 60 * _final_scale;    // Mais gordura lateral para o fade

var _total_content_width = _icon_space + _gap + _txt_w;

// Posição Central
var _center_x = _gui_w / 2;
var _center_y = _gui_h * 0.88;

// --- 3. CURVAS DE ANIMAÇÃO (O Segredo do Polimento) ---
// Easing: Cubic Out (Começa rápido, termina suave)
// Isso faz a barra abrir com impacto
var _anim_abertura = 1 - power(1 - alpha_atual, 3); 

// Largura dinâmica baseada na animação
var _current_bg_width = (_total_content_width / 2 + _padding) * _anim_abertura;

// --- 4. RENDERIZAÇÃO ---

// A. Fundo "Faixa Horizontal" (Animado abrindo)
if (alpha_atual > 0)
{
    gpu_set_blendmode(bm_normal);
    
    var _bg_h = 35 * _final_scale; // Altura da faixa
    var _bg_alpha = 0.7 * alpha_atual; // Alpha máximo 0.7
    
    // A faixa desenha baseada no _current_bg_width que está crescendo
    draw_primitive_begin(pr_trianglelist);
    
    // Esquerda (Degradê Transparente -> Preto)
    draw_vertex_color(_center_x - _current_bg_width, _center_y - _bg_h, c_black, 0);
    draw_vertex_color(_center_x,                     _center_y - _bg_h, c_black, _bg_alpha);
    draw_vertex_color(_center_x,                     _center_y + _bg_h, c_black, _bg_alpha);
    
    draw_vertex_color(_center_x - _current_bg_width, _center_y - _bg_h, c_black, 0);
    draw_vertex_color(_center_x,                     _center_y + _bg_h, c_black, _bg_alpha);
    draw_vertex_color(_center_x - _current_bg_width, _center_y + _bg_h, c_black, 0);
    
    // Direita (Degradê Preto -> Transparente)
    draw_vertex_color(_center_x,                     _center_y - _bg_h, c_black, _bg_alpha);
    draw_vertex_color(_center_x + _current_bg_width, _center_y - _bg_h, c_black, 0);
    draw_vertex_color(_center_x + _current_bg_width, _center_y + _bg_h, c_black, 0);
    
    draw_vertex_color(_center_x,                     _center_y + _bg_h, c_black, _bg_alpha);
    draw_vertex_color(_center_x + _current_bg_width, _center_y + _bg_h, c_black, 0);
    draw_vertex_color(_center_x,                     _center_y - _bg_h, c_black, _bg_alpha);

    draw_primitive_end();
}

// --- CONTEÚDO (Só aparece depois que a barra abriu um pouco) ---
// Delay: O conteúdo só começa a aparecer quando o alpha global passa de 0.2
var _content_alpha = max(0, (alpha_atual - 0.2) / 0.8);

if (_content_alpha > 0)
{
    // Recalcula posições X finais
    var _start_x = _center_x - (_total_content_width / 2);
    var _icon_x  = _start_x + (_icon_space / 2);
    var _line_x  = _start_x + _icon_space + (_gap / 2);
    var _text_x  = _start_x + _icon_space + _gap;

    // B. Separador Vertical (Animação de Crescer)
    // A linha cresce verticalmente baseada no alpha do conteúdo
    var _line_h_max = 20 * _final_scale;
    var _line_h_atual = _line_h_max * _content_alpha; 
    
    draw_set_alpha(_content_alpha * 0.6);
    draw_set_color(c_white);
    draw_line_width(_line_x, _center_y - _line_h_atual, _line_x, _center_y + _line_h_atual, 2);
    
    // C. Ícone (Esquerda)
    // Pulso suave
    var _pulse = (sin(current_time / 250) * 0.05) + 1.0;
    
    // Nota: Se sua função não suporta alpha global, use draw_set_alpha antes
    draw_set_alpha(_content_alpha); 
    desenha_input_verbo(verbo, _icon_x, _center_y, 2.0 * _final_scale * _pulse);

    // D. Texto (Direita)
    draw_set_halign(fa_left); 
    draw_set_valign(fa_middle); 

    var _escala_txt = 1.0 * _final_scale;

    // Sombra (Com leve deslocamento para profundidade)
    draw_set_color(c_black);
    draw_set_alpha(_content_alpha * 0.8);
    draw_text_transformed(_text_x + (2*_s), _center_y + (2*_s), texto_final, _escala_txt, _escala_txt, 0);

    // Texto Principal
    draw_set_color(c_white); // Ou c_ltgray
    draw_set_alpha(_content_alpha);
    draw_text_transformed(_text_x, _center_y, texto_final, _escala_txt, _escala_txt, 0);
}

// --- 5. RESET ---
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);