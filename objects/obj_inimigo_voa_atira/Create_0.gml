/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

formulario_inimigo(5,1,4,0,0,0,200,150);
formulario_tiro(4,2,3,false,false);

//Este inimigo vai ficar andando, quando ele ver o player ele vai ficar "urubuzando" até decidir dar uma investida e continuar a "urubuzar"
//Caso o player ataque e erre ele vai pra tras pra resenhar e tem chance de ir direto pro estado de ataque 
//Iniciando estados
estado_walk = new estado();
estado_hover = new estado();
estado_ataque = new estado();

//Andando
estado_walk.inicia = function()
{
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
}

estado_hover.roda = function()
{
    //Perseguindo e atirando
    persegue(true);
    if (estado_perseguicao == "parado") tiro(false);
    //Saindo do estado de hover
    if (dist_x() > 340) or (dist_y() > 275) or (!verifica_parede()) troca_estado(estado_walk);    
        
    
}

estado_hover.finaliza = function()
{
    duracao = random_range(2.5,4.25);
}


//Aplicando knock
inicia_knock(estado_walk,,0,true);


//Iniciando state machine
inicia_estado(estado_walk);



