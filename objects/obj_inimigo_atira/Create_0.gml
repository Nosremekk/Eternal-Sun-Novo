/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(4,,,,,,320)
formulario_tiro(3,2,3.5,false,true);




//Este inimigo vai ficar andando e quando ele me ver ele atira
//Iniciando estados
estado_walk = new estado();
estado_shot = new estado();

//Andando
estado_walk.inicia = function()
{

    max_velh = 2;
    image_blend = c_blue;
    velh = choose(-max_velh,max_velh);
}

estado_walk.roda = function()
{
    bate_parede();
    volta_x();
    
    if (seguindo(200,200)) troca_estado(estado_shot);
}

estado_walk.finaliza = function()
{
    
}

estado_shot.inicia = function()
{
    velh = 0;
    image_blend = c_red;
}

estado_shot.roda = function()
{
    tiro(true);
    //Saindo do estado de tiro
    if (!seguindo(295,295)) troca_estado(estado_walk);
    
}

estado_shot.finaliza = function()
{

}

inicia_morte_inimigo();
inicia_knock();
//Iniciando state machine
inicia_estado(estado_walk);



