/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(5,.45,,,,0,200,0);

meu_id_bestiario = "inimigo_voa";

//Este inimigo vai ficar andando... e só mesmo
//Iniciando estados
estado_walk = new estado();

//Andando
estado_walk.inicia = function()
{
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
//Iniciando state machine
inicia_estado(estado_walk);



