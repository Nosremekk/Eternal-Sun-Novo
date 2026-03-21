init_dano();

cura_chave = get_inimigo_key();

if (!infinito)
{
    if (variable_struct_exists(global.inimigos_mortos_temp, cura_chave))
    {
        instance_destroy();
    }
}
