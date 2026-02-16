som_emitido = gerencia_som_loop_3d(som_emitido,snd_fase2,raio_som,200);

switch(lista_powerup) //Me destruindo caso ja tenha o powerup
{
    case "dash":
        if (global.powerups[powerup.DASH] == true) instance_destroy();
    break;
    case "wall":
        if (global.powerups[powerup.WALL == true]) instance_destroy();
    break;        
    case "double":
        if (global.powerups[powerup.DOUBLE_J] > 0) instance_destroy();
    break;    
    case "combo":
        if (global.powerups[powerup.COMBO] == true) instance_destroy();
            break;     
    case "float":  if (global.powerups[powerup.FLOAT] == true) instance_destroy(); break;  
        
    case "tiro":    if (global.powerups[powerup.MARK] == true) instance_destroy(); break;
    
}
