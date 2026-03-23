/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(3,1,4,,,.3,250,0,true,sprite_index);


meu_id_bestiario = "inimigo_anda";


//Este inimigo vai ficar andando... e só mesmo
//Iniciando estados
estado_walk = new estado();

//Andando
estado_walk.inicia = function()
{

    max_velh = 1;
    image_blend = c_blue;
    velh = choose(-max_velh,max_velh);
}

estado_walk.roda = function()
{
    bate_parede();
    volta_x();
}

estado_walk.finaliza = function()
{
    
}

inicia_morte_inimigo();
//Aplicando knockback
inicia_knock();



//Iniciando state machine
inicia_estado(estado_walk);



