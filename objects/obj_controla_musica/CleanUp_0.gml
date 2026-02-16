if (!audio_group_is_loaded(ag_gameplay)) exit;

ds_stack_destroy(music_stack);


ds_map_destroy(mapa_musicas);

// Para todos os sons para garantir
audio_stop_all();