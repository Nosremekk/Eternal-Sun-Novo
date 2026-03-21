if (global.pause) exit;
var _player = instance_place(x, y, obj_player);
interagiu = (_player != noone);

if (interagiu)
{

    if (InputPressed(btn_interage) and timer_save <= 0 and _player.estado_atual != _player.estado_rest and _player.chao) 
    {
        with(_player) troca_estado(estado_rest);

        global.vida_atual = global.vida_max; 
        
        restart_powerups(); 
        
        

        global.inimigos_mortos_temp = {};
        
        // Salva
        salvando_jogo(global.save, true); 
        
        // Feedback
        efeito_sonoro(sfx_menu_click, 100, 0.1); 
        timer_save = 2; 
    }
}

// 3. Timer Feedback
if (timer_save > 0) timer_save -= desconta_timer();