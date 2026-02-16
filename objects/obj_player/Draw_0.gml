draw_sprite_ext(sprite,image_index,x,y,xscale,image_yscale,image_angle,image_blend,image_alpha);
sprite_index = sprite;

if (image_alpha < 0.8)
{
    shader_set(sh_cor);
    draw_sprite_ext(sprite_index,image_index,x,y,xscale,image_yscale,image_angle,c_white,image_alpha);
    shader_reset();
}

draw_text(x,y-64,velv);



