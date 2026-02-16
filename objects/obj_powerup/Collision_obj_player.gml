switch(lista_powerup)
    { //Desbloqueando os powerups 
    case "dash":
        global.powerups[powerup.DASH] = true;
    break;
    case "wall":
        global.powerups[powerup.WALL] = true;
    break;        
    case "double":
        global.powerups[powerup.DOUBLE_J] = 1;
    break;        
    case "combo" : global.powerups[powerup.COMBO] = true; break;
    case "float" : global.powerups[powerup.FLOAT] = true; break;
    case "tiro" : global.powerups[powerup.MARK] = true; break;
    
}




aplica_screenshake();
aplica_hitstop();
instance_destroy();
