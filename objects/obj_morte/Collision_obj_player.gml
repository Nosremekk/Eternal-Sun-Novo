if (other.inv) exit;

// Colisão com Player
if (other.vida_atual > 0)
{
    if (other.estado_atual != other.estado_espinho and other.estado_atual != other.estado_dead)
    {
        with (other) troca_estado(estado_espinho);
    }
}
