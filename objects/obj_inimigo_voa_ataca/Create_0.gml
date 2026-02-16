/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(5,1,4,0,0,0,180,200);
timer_atk = 0;
duracao_timer = random_range(2.5,4.25);//Em segundos
duracao_atk = .3;


//Este inimigo vai ficar andando, quando ele ver o player ele vai ficar "urubuzando" até decidir dar uma investida e continuar a "urubuzar"
//Caso o player ataque e erre ele vai pra tras pra resenhar e tem chance de ir direto pro estado de ataque 
//Iniciando estados
estado_walk = new estado();
estado_hover = new estado();
estado_ataque = new estado();
estado_wait = new estado();
estado_knock = new estado();

//Andando
estado_walk.inicia = function()
{
    socavel = false;
    //Reiniciando as variaveis pós hover 
    velh = 0;
    velv = 0;
    //Escolhendo dir
    image_blend = c_blue;
    velh = choose(-max_velh,max_velh);
    
    forca_x_knock = max_velh*1.25;
    forca_y_knock = -max_velv/50;
}

estado_walk.roda = function()
{
    bate_parede();
    volta_x();

    //Se eu estou a 250 px do inimigo(e num y parecido) ele me segue 
    if (seguindo(250,135)) troca_estado(estado_hover);
        
    


}

estado_walk.finaliza = function()
{

}

//Urubu
estado_hover.inicia = function()
{
    image_blend = c_red;
    timer_atk = 0;
}

estado_hover.roda = function()
{ 
    persegue(true,120,65);
    if (dist_x() > 340) or (dist_y() > 250) or (!verifica_parede()) troca_estado(estado_walk);    
        
    //Atacando o player com um dash insano
    timer_atk += desconta_timer();
    if (timer_atk >= duracao_timer) troca_estado(estado_ataque)
    
}

estado_hover.finaliza = function()
{
    timer_atk = 0;
    duracao_timer = random_range(2.5,4.25);
}

//Atacando
estado_ataque.inicia = function()
{
    image_blend = c_purple;
    var _dir = point_direction(x, y, obj_player.x, obj_player.y)
    
    var _dirx = lengthdir_x(3,_dir);
    var _diry = lengthdir_y(3,_dir); 
    
    velh = _dirx 
    velv = _diry 
    
    socavel = true;
    
    forca_x_knock = max_velh*2;
    forca_y_knock = -max_velv;
    
}

estado_ataque.roda = function()
{
    timer_atk += desconta_timer();
    if (timer_atk >= duracao_atk) troca_estado(estado_walk);
}

estado_ataque.finaliza = function()
{
    timer_atk = 0;
}

inicia_knock_wait(2,estado_walk,,,true);


//Iniciando state machine
inicia_estado(estado_walk);



