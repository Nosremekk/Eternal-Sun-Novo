// Gerencia o Pause e Slow Motion
if (!global.pause)
{
    // Atualiza o sistema manualmente. 
    // O "1" significa 1 step normal. Se tiver slow motion, pode usar global.vel_scale.
    // Mas cuidado: part_system_update aceita inteiros ou funciona melhor com updates fixos.
    // Para simplificar, vamos atualizar normal se não estiver pausado.
    
    part_system_update(sistema_particulas);
}