
var _musica_sala = ds_map_find_value(mapa_musicas, room);

// 2. Verifica se encontramos uma música para esta sala
if (!is_undefined(_musica_sala))
{
    toca_musica(_musica_sala);
}
else
{
    // 4. (Opcional) Se a sala NÃO ESTIVER no mapa, o que fazer?
    //    Você pode querer parar a música:
    // parar_musicas(); 
    
    //    ...ou tocar uma música padrão de "silêncio" ou "ambiente"
    // toca_musica(snd_ambiente_vento);
    
    //    Por enquanto, não fazer nada (deixar a música anterior continuar)
    //    pode ser o comportamento desejado para salas pequenas de "corredor".
}
