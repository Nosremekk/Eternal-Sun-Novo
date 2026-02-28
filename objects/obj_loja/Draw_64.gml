var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _s = max(1, _gui_h / ESCALA_UI); 

// Fundo escurecido
draw_set_color(c_black);
draw_set_alpha(0.6 * anim_escala);
draw_rectangle(0, 0, _gui_w, _gui_h, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Medidas da Caixa Principal
var _box_w = 900 * _s;
var _box_h = 500 * _s;
var _x = (_gui_w / 2) - ((_box_w * anim_escala) / 2);
var _y = (_gui_h / 2) - ((_box_h * anim_escala) / 2);

if (anim_escala < 0.1) exit;

// Janela
draw_sprite_stretched(spr_dialog_box, 0, _x, _y, _box_w * anim_escala, _box_h * anim_escala);

draw_set_font(fnt_dialogo); // Use sua fonte de UI
draw_set_valign(fa_top);

// Dinheiro do Player (Topo Direito) - TRADUZIDO
draw_set_halign(fa_right);
draw_text_transformed(_x + _box_w * anim_escala - (30*_s), _y + (30*_s), get_text("loja_dinheiro") + string(global.dinheiro), _s, _s, 0);

draw_set_halign(fa_left);

// --- LISTA DE PRODUTOS (Esquerda) ---
var _list_x = _x + (40 * _s);
var _list_y = _y + (80 * _s);

for (var i = 0; i < array_length(produtos); i++) 
{
    var _item = produtos[i];
    var _cor = (i == index_selecionado) ? c_yellow : c_white; // Amarelo se for o selecionado
    
    draw_set_color(_cor);
    draw_text_transformed(_list_x, _list_y + (i * 45 * _s), _item.nome, _s*0.9, _s*0.9, 0);
    
    if (_item.tipo != "none") 
    {
        draw_set_halign(fa_right);
        draw_text_transformed(_x + (_box_w/2) - (20*_s), _list_y + (i * 45 * _s), string(_item.preco), _s*0.9, _s*0.9, 0);
        draw_set_halign(fa_left);
    }
}
draw_set_color(c_white);

// --- DETALHES DO ITEM (Direita) ---
var _detalhe_x = _x + (_box_w / 2) + (20 * _s);
var _detalhe_y = _y + (80 * _s);
var _selecionado = produtos[index_selecionado];

if (_selecionado.tipo != "none") 
{
    // Desenha o Ícone centralizado independentemente da Origin
    if (sprite_exists(_selecionado.spr)) {
        var _escala_spr = _s * 2.5; // Um pouco maior para destaque
        
        // Coordenadas centrais de onde queremos que o meio da sprite fique
        var _cx = _detalhe_x + (64 * _s); 
        var _cy = _detalhe_y + (64 * _s);
        
        // Informações matemáticas da sprite
        var _sw = sprite_get_width(_selecionado.spr);
        var _sh = sprite_get_height(_selecionado.spr);
        var _ox = sprite_get_xoffset(_selecionado.spr);
        var _oy = sprite_get_yoffset(_selecionado.spr);
        
        // Posição x/y exata para usar no draw_sprite_ext()
        var _draw_x = _cx - (_sw / 2 * _escala_spr) + (_ox * _escala_spr);
        var _draw_y = _cy - (_sh / 2 * _escala_spr) + (_oy * _escala_spr);
        
        draw_sprite_ext(_selecionado.spr, 0, _draw_x, _draw_y, _escala_spr, _escala_spr, 0, c_white, 1);
    }
    
    // Textos do item
    draw_set_color(c_yellow);
    draw_text_transformed(_detalhe_x, _detalhe_y + (150*_s), _selecionado.nome, _s, _s, 0);
    draw_set_color(c_white);
    draw_text_ext_transformed(_detalhe_x, _detalhe_y + (200*_s), _selecionado.desc, 30*_s, (_box_w/2 - 60*_s), _s*0.8, _s*0.8, 0);
}

// --- RODAPÉ COM BOTÕES MAIORES E TRADUZIDOS ---
var _rodape_y = _y + _box_h - (50 * _s); // Subi um pouco para caber o botão maior
var _escala_btn = _s * 1.5; // Escala extra para os botões e texto

desenha_input_verbo(INPUT_VERB.JUMP, _x + (60 * _s), _rodape_y, _escala_btn);
draw_text_transformed(_x + (100 * _s), _rodape_y - (10 * _s), get_text("loja_comprar"), _s, _s, 0);

desenha_input_verbo(INPUT_VERB.DASH, _x + (280 * _s), _rodape_y, _escala_btn);
draw_text_transformed(_x + (320 * _s), _rodape_y - (10 * _s), get_text("loja_sair"), _s, _s, 0);

draw_set_font(-1);