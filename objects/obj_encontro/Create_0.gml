var _key = get_permanentemente_quebrados_key();
if (variable_struct_exists(global.permanentemente_quebrado, _key))
{
    instance_destroy();
    exit;
}

encontro_ativo = false;
onda_atual     = 0;
inimigos_vivos = [];
timer_proxima_onda = 0;

ondas = [
    [obj_inimigo_atira, obj_inimigo_anda],
    [obj_inimigo_atira, obj_inimigo_dash],
    [obj_inimigo_voa,   obj_inimigo_voa_ataca]
];

spawn_points = [];

spawna_onda = function()
{
    var _onda = ondas[onda_atual];
    inimigos_vivos = [];
    
    for (var i = 0; i < array_length(_onda); i++)
    {
        var _sp = (array_length(spawn_points) > 0)
                  ? spawn_points[i mod array_length(spawn_points)]
                  : {x: x, y: y};
        
        // Em vez de spawnar o inimigo, nós spawnamos o AVISO
        // E mandamos pra ele qual bicho ele deve criar depois!
        var _aviso = instance_create_layer(_sp.x, _sp.y, "Instances", obj_aviso_spawn, {
            inimigo_obj: _onda[i],
            encontro_id: id,
            array_index: i
        });
        
        // Guarda o aviso na lista (ele conta como vivo enquanto estiver piscando)
        array_push(inimigos_vivos, _aviso);
    }
    
    timer_proxima_onda = 0.5;
}

encontro_completo = function()
{
    var _key = get_permanentemente_quebrados_key();
    global.permanentemente_quebrado[$ _key] = true;
    instance_destroy();
}