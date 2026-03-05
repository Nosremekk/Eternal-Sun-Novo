draw_sprite_ext(sprite_index, image_index, x, y, xscale * escala_x, escala_y, image_angle, image_blend, image_alpha);

if (image_alpha < .65)
{
    shader_set(sh_cor);
    draw_sprite_ext(sprite_index, image_index, x, y, xscale * escala_x, escala_y, image_angle, c_white, image_alpha);
    shader_reset();
}

if (global.inimigo_marcado == id)
{
    draw_sprite(spr_player_marca, 0, x, y - sprite_height - 10);
}