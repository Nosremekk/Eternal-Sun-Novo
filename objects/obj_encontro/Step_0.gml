if (global.pause) exit;

if (!encontro_ativo)
{
    if (instance_place(x, y, obj_player) != noone)
    {
        encontro_ativo = true;
        spawna_onda();
    }
    exit;
}

if (timer_proxima_onda > 0)
{
    timer_proxima_onda -= desconta_timer();
    exit;
}

var _vivos = 0;
for (var i = 0; i < array_length(inimigos_vivos); i++)
{
    if (instance_exists(inimigos_vivos[i])) _vivos++;
}

if (_vivos == 0 and encontro_ativo)
{
    onda_atual++;
    
    if (onda_atual < array_length(ondas))
    {
        spawna_onda();
    }
    else
    {
        encontro_completo();
    }
}

