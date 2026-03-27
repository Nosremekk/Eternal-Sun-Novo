event_inherited();
formulario_inimigo(3, 1, 4, 0, 0, 0.3, 64, 0, true, spr_inimigo_devoto_errante_morto);



// Estado principal (Patrulha Ritualística)
estado_patrulha = new estado();

estado_patrulha.inicia = function()
{
    sprite_index = spr_inimigo_devoto_errante_walk;
    image_index = 0;
    socavel = true;
    

    velh = max_velh * choose(1, -1);
}

estado_patrulha.roda = function()
{

    volta_x(); 
    
    
    bate_parede(); 
}


//inicia_knock_wait(sprite_index,sprite_index,1,estado_patrulha); 
inicia_knock(estado_patrulha);
inicia_morte_inimigo(); // Prepara o estado de morte
inicia_estado(estado_patrulha);
