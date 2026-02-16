// Se não tiver sprite (estado invisível), não desenha nada
if (sprite_index == -1) exit;

// Desenha o sprite na posição X + Shake
draw_sprite_ext(
    sprite_index, 
    image_index, 
    x + shake_x, // AQUI APLICAMOS O TREMOR VISUAL
    y + shake_y, // AQUI TAMBÉM
    image_xscale, 
    image_yscale, 
    image_angle, 
    image_blend, 
    image_alpha
);