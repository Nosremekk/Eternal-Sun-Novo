if (instance_number(object_index) > 1) { instance_destroy(); exit; }    

// Inicia carregamento do grupo
//audio_group_load(ag_gameplay);
//Variaveis
musica_atual = noone;    
id_musica_atual = noone;     
fade_out_musica = noone;     

fade_speed = 0.01;             // Velocidade do fade
target_gain = 1.0;             // Volume máximo

gain_atual_grupo = 1;
gain_alvo_grupo = 1;
fade_pause_vel = .05;


// Pilha para músicas de "evento" (como chefes)
// Permite pausar a música da zona, tocar a do chefe, e depois voltar
music_stack = ds_stack_create();



/// @function toca_musica(new_music_id, [force_restart=false])
/// @description Toca uma nova música com crossfade.
/// @param {Asset.GMSound} new_music_id  Musica para tocar
/// @param {Bool}         [force_restart] Se true, reinicia a música mesmo se já for a atual.
toca_musica = function(new_music_id, force_restart = false)
{
    // Se a música já for a mesma e não for forçada, não faz nada
    if (new_music_id == id_musica_atual and !force_restart)
    {
        return;
    }

    if (audio_exists(musica_atual))
    {
        // Se já havia algo em fade out, pare imediatamente
        if (audio_exists(fade_out_musica))
        {
            audio_stop_sound(fade_out_musica);
        }
        fade_out_musica = musica_atual;
    }

    //Toca a nova música
    id_musica_atual = new_music_id;
    musica_atual = audio_play_sound(id_musica_atual, 1000, true); 
    audio_sound_gain(musica_atual, 0,0); 
}


// Este mapa define qual música toca em qual sala.
mapa_musicas = ds_map_create();

//Configurando audio 3d
audio_falloff_set_model(audio_falloff_linear_distance_clamped);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

// Define uma variável temporária para facilitar a leitura
var _mus;

// Exemplo
_mus = snd_fase1; // A música da zona de cavernas
ds_map_add(mapa_musicas, rm_level_demo, _mus);
//ds_map_add(mapa_musicas, rm_cavernas_02, _mus);
//ds_map_add(mapa_musicas, rm_cavernas_03_sala_secreta, _mus);

//Exemplo 2
_mus = snd_fase2; // A música da zona de lava
ds_map_add(mapa_musicas, rm_arena, _mus);


// Usada para detectar a mudança de sala
sala_atual = noone;


/// @function adiciona_musica(event_music_id)
/// @description "Empurra" uma música de evento (ex: chefe) para a pilha.
///              A música atual da zona será pausada e retomada com pop.
/// @param {Asset.GMSound} event_music_id A música do chefe/evento.
adiciona_musica = function(event_music_id)
{
    // Guarda a música atual na pilha
    ds_stack_push(music_stack, id_musica_atual);
    
    // Toca a nova música de evento (forçando o reinício)
    toca_musica(event_music_id, true);
}


/// @function remove_musica()
/// @description "Remove" a música de evento da pilha e retorna à música anterior.
remove_musica = function()
{
    if (!ds_stack_empty(music_stack))
    {
        // Pega a música anterior de volta da pilha
        var _previous_music = ds_stack_pop(music_stack);
        
        if (_previous_music != noone)
        {
             toca_musica(_previous_music, false);
        }
    }
}


/// @function parar_musicas()
/// @description Para toda a música imediatamente.
parar_musicas = function()
{
    if (audio_exists(musica_atual)) { audio_stop_sound(musica_atual); }
    if (audio_exists(fade_out_musica)) { audio_stop_sound(fade_out_musica); }
    musica_atual = noone;
    fade_out_musica = noone;
    id_musica_atual = noone;
    ds_stack_clear(music_stack); //Limpa
}

