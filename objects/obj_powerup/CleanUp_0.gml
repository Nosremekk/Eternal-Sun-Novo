if (variable_instance_exists(id, "som_emitido")) 
{
    if (audio_exists(som_emitido)) 
    {
        audio_stop_sound(som_emitido);
    }
}
