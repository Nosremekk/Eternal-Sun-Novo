// --- LIMPEZA INICIAL ---
if (renderer != undefined) renderer.Free();

// Garante câmera válida
var _cam = view_camera[0];
if (_cam == -1) _cam = 0; // Fallback de segurança

renderer = new BulbRenderer(_cam);
renderer.smooth = true;
renderer.normalMap = false; 

var _cfg = pegar_config_luz();
renderer.ambientColor = _cfg.ambiente;


// --- 1. OCLUSORES DE OBJETOS (Colisores e Dinâmicos) ---
with(obj_colisor) 
{
    // Verifica se sou uma plataforma móvel (ou filho dela)
    var _eh_dinamico = (object_index == obj_plataforma_movel) or (object_is_ancestor(object_index, obj_plataforma_movel)) or (object_index == obj_plataforma_quebravel);

    if (_eh_dinamico)
    {
        // DINÂMICO: Para coisas que se movem
        meu_oclusor = new BulbDynamicOccluder(other.renderer);
        
        var _w = bbox_right - bbox_left;
        var _h = bbox_bottom - bbox_top;
        
        // Coordenadas Locais (Relativas ao x,y do objeto)
        var _x1 = -sprite_xoffset;
        var _y1 = -sprite_yoffset;
        var _x2 = _w - sprite_xoffset;
        var _y2 = _h - sprite_yoffset;

        meu_oclusor.AddEdge(_x1, _y1, _x2, _y1); // Topo
        meu_oclusor.AddEdge(_x2, _y1, _x2, _y2); // Direita
        meu_oclusor.AddEdge(_x2, _y2, _x1, _y2); // Baixo
        meu_oclusor.AddEdge(_x1, _y2, _x1, _y1); // Esquerda
        
        meu_oclusor.x = x;
        meu_oclusor.y = y;
    }
    else
    {
        // ESTÁTICO: Para paredes fixas
        meu_oclusor = new BulbStaticOccluder(other.renderer);
        
        meu_oclusor.AddEdge(bbox_left, bbox_top, bbox_right, bbox_top);
        meu_oclusor.AddEdge(bbox_right, bbox_top, bbox_right, bbox_bottom);
        meu_oclusor.AddEdge(bbox_right, bbox_bottom, bbox_left, bbox_bottom);
        meu_oclusor.AddEdge(bbox_left, bbox_bottom, bbox_left, bbox_top);
    }
}

// --- 2. OCLUSORES DE PLATAFORMAS ONE-WAY (NOVO) ---
with(obj_colisor_fino)
{
    // Criamos um oclusor estático separado, pois ele não é filho de obj_colisor
    meu_oclusor = new BulbStaticOccluder(other.renderer);

    // Usa o Bbox. Como o sprite é fino, a sombra será fina.
    meu_oclusor.AddEdge(bbox_left, bbox_top, bbox_right, bbox_top);
    meu_oclusor.AddEdge(bbox_right, bbox_top, bbox_right, bbox_bottom);
    meu_oclusor.AddEdge(bbox_right, bbox_bottom, bbox_left, bbox_bottom);
    meu_oclusor.AddEdge(bbox_left, bbox_bottom, bbox_left, bbox_top);
}


// --- 3. OCLUSORES DE TILES (OTIMIZADO) ---
var _layer_id = layer_get_id("Colisao_Tiles");

if (_layer_id != -1)
{
    var _map_id = layer_tilemap_get_id(_layer_id);
    
    tile_occluder = new BulbStaticOccluder(renderer);
    
    var _w = tilemap_get_width(_map_id);
    var _h = tilemap_get_height(_map_id);
    var _tw = tilemap_get_tile_width(_map_id);
    var _th = tilemap_get_tile_height(_map_id);
    
    // PASSADA 1: HORIZONTAL
    for (var _y = 0; _y < _h; _y++) 
    {
        var _start_top = -1;    
        var _start_bottom = -1; 
        
        for (var _x = 0; _x <= _w; _x++) 
        {
            var _t = (_x < _w) ? tilemap_get(_map_id, _x, _y) : 0;
            var _is_solid = (_t > 0);
            
            // Borda Superior
            var _top_empty = (_y == 0) or (tilemap_get(_map_id, _x, _y - 1) == 0);
            if (_is_solid and _top_empty) {
                if (_start_top == -1) _start_top = _x;
            } else {
                if (_start_top != -1) {
                    tile_occluder.AddEdge(_start_top * _tw, _y * _th, _x * _tw, _y * _th);
                    _start_top = -1;
                }
            }

            // Borda Inferior
            var _bottom_empty = (_y == _h - 1) or (tilemap_get(_map_id, _x, _y + 1) == 0);
            if (_is_solid and _bottom_empty) {
                if (_start_bottom == -1) _start_bottom = _x;
            } else {
                if (_start_bottom != -1) {
                    tile_occluder.AddEdge(_x * _tw, (_y + 1) * _th, _start_bottom * _tw, (_y + 1) * _th);
                    _start_bottom = -1;
                }
            }
        }
    }
    
    // PASSADA 2: VERTICAL
    for (var _x = 0; _x < _w; _x++) 
    {
        var _start_left = -1;
        var _start_right = -1;
        
        for (var _y = 0; _y <= _h; _y++) 
        {
            var _t = (_y < _h) ? tilemap_get(_map_id, _x, _y) : 0;
            var _is_solid = (_t > 0);
            
            // Borda Esquerda
            var _left_empty = (_x == 0) or (tilemap_get(_map_id, _x - 1, _y) == 0);
            if (_is_solid and _left_empty) {
                if (_start_left == -1) _start_left = _y;
            } else {
                if (_start_left != -1) {
                    var _px = _x * _tw;
                    tile_occluder.AddEdge(_px, _y * _th, _px, _start_left * _th); 
                    _start_left = -1;
                }
            }
            
            // Borda Direita
            var _right_empty = (_x == _w - 1) or (tilemap_get(_map_id, _x + 1, _y) == 0);
            if (_is_solid and _right_empty) {
                if (_start_right == -1) _start_right = _y;
            } else {
                if (_start_right != -1) {
                    var _px = (_x + 1) * _tw;
                    tile_occluder.AddEdge(_px, _start_right * _th, _px, _y * _th);
                    _start_right = -1;
                }
            }
        }
    }
}

// --- OCLUSOR DE MOLAS ---
with(obj_mola)
{
    meu_oclusor = new BulbStaticOccluder(other.renderer);
    
    // Cria uma sombra apenas na base (tijolinho de baixo)
    // Supondo uma mola de 16px de largura
    var _h_sombra = 4; // Altura da sombra
    
    meu_oclusor.AddEdge(bbox_left, bbox_bottom - _h_sombra, bbox_right, bbox_bottom - _h_sombra); // Topo
    meu_oclusor.AddEdge(bbox_right, bbox_bottom - _h_sombra, bbox_right, bbox_bottom); // Direita
    meu_oclusor.AddEdge(bbox_right, bbox_bottom, bbox_left, bbox_bottom); // Baixo
    meu_oclusor.AddEdge(bbox_left, bbox_bottom, bbox_left, bbox_bottom - _h_sombra); // Esquerda
}

// --- FINALIZAÇÃO ---

// Reconstrói a geometria (Agora extremamente otimizada)
renderer.RefreshStaticOccluders();

// Aplicando o sol
sol = undefined; 
if (_cfg.tem_sol)
{
    sol = new BulbSunlight(renderer, _cfg.sol_angulo);
    sol.intensity = _cfg.sol_forca;
    sol.blend = _cfg.sol_cor;
}