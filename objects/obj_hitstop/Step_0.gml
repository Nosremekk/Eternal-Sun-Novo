if (tempo > 0)
{
    global.vel_scale = 0
    
    tempo -= delta_time / 1000000; 
}
else 
{
    global.vel_scale = tempo_antigo;
    instance_destroy();
}