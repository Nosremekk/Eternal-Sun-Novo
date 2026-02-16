if (global.pause) exit; 
var _player = instance_place(x, y - 5, obj_player);

if (_player != noone)
{
    // Só ativa se o player estiver caindo
    if (_player.velv > 0) and (!_player.chao)
    {
        var _forca_final = forca_pulo; 
        var _efeito_extra = false;    
        

        if (InputCheck(INPUT_VERB.JUMP))
        {
            _forca_final *= 1.25; // +25% de altura
        }

        if (_player.dir_atk == "vertical_down") and (_player.estado_atual == _player.estado_attack)
        {
            _forca_final *= 1.5; 
            _efeito_extra = true;
        }

        with (_player)
        {
            velv = -_forca_final; 
            
            if (estado_atual != estado_attack) troca_estado(estado_jump);
            restart_powerups();
            
            // Efeitos visuais básicos
            cria_particula(x, bbox_bottom, TIPO_PARTICULA.POEIRA_PULO, 5);
            
            if (_efeito_extra)
            {
                cria_particula(x, bbox_bottom, TIPO_PARTICULA.FAISCA, 10);
                aplica_screenshake(4); // Treme a tela
                InputVibrateConstant(0.5, 0.0, 200); // Vibra controle
            }
        }

        if (image_speed == 0)
        {
            image_index = 1;
            image_speed = 1;
            
            if (_efeito_extra) efeito_sonoro(sfx_wallhit, 60, 0.1); 
            else               efeito_sonoro(sfx_jump, 50, 0.1);    
        }
    }
}