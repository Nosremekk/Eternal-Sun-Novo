var _tilt = 0;
if (estado_atual == estado_jump) _tilt = clamp(velv * 0.5, -8, 8);

draw_sprite_ext(sprite, image_index, x, y, xscale * escala_x, escala_y, _tilt, image_blend, image_alpha);

sprite_index = sprite;
if (image_alpha < 0.8)
{
    shader_set(sh_cor);
    draw_sprite_ext(sprite_index, image_index, x, y, xscale * escala_x, escala_y, _tilt, c_white, image_alpha);
    shader_reset();
}