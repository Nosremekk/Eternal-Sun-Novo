if (xscale != 0) and (!entrou_porta)
{
    global.xscale_player_transicao = xscale;
}

// Desfaz a marcação ao sair da sala
if (global.inimigo_marcado != noone)
{
    global.inimigo_marcado = noone;
    global.timer_marcado = 0;
}