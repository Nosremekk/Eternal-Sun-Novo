som_emitido = gerencia_som_loop_3d(som_emitido,snd_test,raio_som,200);

switch(lista_powerup) //Me destruindo caso ja tenha o powerup
{
    case "dash":
        if (global.powerups[powerup.DASH] == true) instance_destroy();
    break;
    case "wall":
        if (global.powerups[powerup.WALL] == true) instance_destroy(); 
    break;        
    case "double":
        if (global.powerups[powerup.DOUBLE_J] > 0) instance_destroy();
    break;    
    case "combo":
        if (global.powerups[powerup.COMBO] == true) instance_destroy();
    break;     
    case "float":  if (global.powerups[powerup.FLOAT] == true) instance_destroy(); break;  
        
    case "tiro":    if (global.powerups[powerup.MARK] == true) instance_destroy(); break;
    
    case "celeste":    if (global.powerups[powerup.DASH_CELESTE] == true) instance_destroy(); break;
        
    case "fantasma":    if (global.powerups[powerup.DASH_FANTASMA] == true) instance_destroy(); break;
        
    case "bumerangue":    if (global.powerups[powerup.MAGIC_BUMERANGUE] == true) instance_destroy(); break;
        
    case "groundpound":    if (global.powerups[powerup.MAGIC_GROUNDPOUND] == true) instance_destroy(); break;
        
    case "teleporte":    if (global.powerups[powerup.MAGIC_TELEPORT] == true) instance_destroy(); break; 
        }