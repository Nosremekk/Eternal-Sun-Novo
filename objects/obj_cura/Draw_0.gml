
draw_self();

// Verifica se esta cura específica é a que está marcada pelo player
if (global.inimigo_marcado == id)
{
    // Desenha o ícone da marca acima da cura
    draw_sprite(spr_player_marca, 0, x + sprite_width/2, y - sprite_height/2);
}