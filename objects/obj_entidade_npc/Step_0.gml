if (global.pause) exit;
    
//depth = -bbox_bottom;

roda_estado();

if (talk_cooldown > 0) talk_cooldown -= desconta_timer();

move_and_collide(velh, velv, colisor);

if (xscale != 0) image_xscale = -xscale;