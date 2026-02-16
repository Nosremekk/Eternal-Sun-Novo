// Fade out
if (audio_exists(fade_out_musica))
{
    var _gain = audio_sound_get_gain(fade_out_musica);
    _gain -= fade_speed;
    
    if (_gain <= 0) {
        audio_stop_sound(fade_out_musica);
        fade_out_musica = noone;
    } else {
        audio_sound_gain(fade_out_musica, _gain, 0);
    }
}

// Fade in
if (audio_exists(musica_atual))
{
    var _current_gain = audio_sound_get_gain(musica_atual);
    // O alvo é a configuração global do jogador
    var _target_gain_instancia = global.music_volume; 

    if (_current_gain < _target_gain_instancia) {
        _current_gain += fade_speed;
        if (_current_gain > _target_gain_instancia) _current_gain = _target_gain_instancia;
    } else if (_current_gain > _target_gain_instancia) {
        _current_gain -= fade_speed;
        if (_current_gain < _target_gain_instancia) _current_gain = _target_gain_instancia;
    }
    
    audio_sound_gain(musica_atual, _current_gain, 0);
}

// Pausando a musica
if (global.pause) gain_alvo_grupo = 0.2; // Volume abafado
else gain_alvo_grupo = 1.0; // Volume normal

// Faz o Lerp
if (gain_atual_grupo != gain_alvo_grupo)
{
    gain_atual_grupo = lerp(gain_atual_grupo, gain_alvo_grupo, fade_pause_vel);
    
    if (abs(gain_atual_grupo - gain_alvo_grupo) < 0.01) {
        gain_atual_grupo = gain_alvo_grupo;
    }
    
    // Aplica ao grupo inteiro (Música + SFX de gameplay)
    audio_group_set_gain(ag_gameplay, gain_atual_grupo, 0);
}

//Audio 3d
// Pega o centro da câmera
var _cam_x = camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0]) * 0.5);
var _cam_y = camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0]) * 0.5);

// Posiciona o ouvinte no centro da tela 
audio_listener_position(_cam_x, _cam_y, -50);

if (global.mute_on_focus_lost)
{
    if (os_is_paused() or !window_has_focus()) {
        audio_master_gain(0);
    } else {
        audio_master_gain(global.master_volume);
    }
}
else 
{
    audio_master_gain(global.master_volume);
}