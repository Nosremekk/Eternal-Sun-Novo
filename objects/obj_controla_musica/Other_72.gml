// Verifica se o carregamento é do grupo que queremos
if (ds_map_find_value(async_load, "type") == "audiogroup_load")
{
    if (ds_map_find_value(async_load, "group_id") == ag_gameplay)
    {
        var _musica_sala = ds_map_find_value(mapa_musicas, room);
        if (!is_undefined(_musica_sala)) toca_musica(_musica_sala);
    }
}