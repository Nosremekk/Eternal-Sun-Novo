
if (item.pega_item(true))
{
    instance_destroy();
    cria_particula(x, y, TIPO_PARTICULA.COLETAVEL, 1);
}