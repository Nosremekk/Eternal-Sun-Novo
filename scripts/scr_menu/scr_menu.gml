function controles_menu() 
{

    var _confirma = InputPressed(INPUT_VERB.UI_CONFIRM);
    var _voltar   = InputPressed(INPUT_VERB.UI_CANCEL);

    _confirma = _confirma || InputPressed(INPUT_VERB.JUMP);
    

    _voltar   = _voltar   || InputPressed(INPUT_VERB.DASH) || InputPressed(INPUT_VERB.ATTACK);

    return {
        cima:            InputRepeat(INPUT_VERB.UP),
        baixo:           InputRepeat(INPUT_VERB.DOWN), 
        esquerda:        InputRepeat(INPUT_VERB.LEFT),
        direita:         InputRepeat(INPUT_VERB.RIGHT),
        confirma:        _confirma,
        voltar_btn:      _voltar, 
        abre_inventario: InputPressed(INPUT_VERB.OPEN_INVENTORY),
        aplica_pause:    InputPressed(INPUT_VERB.PAUSE),
        pag_esq:         InputPressed(INPUT_VERB.UI_PAGE_LEFT),
        pag_dir:         InputPressed(INPUT_VERB.UI_PAGE_RIGHT)
    };
}
// Navegação de Lista
function up_down(_id_menu, _menu_array) 
{
    var _inputs = controles_menu();
    var _max_opts = array_length(_menu_array) - 1;
    var _new_id = _id_menu;

    if (_inputs.cima)
    {
        _new_id--;
        if (_new_id < 0) _new_id = _max_opts;
        efeito_sonoro(sfx_menu_click, 50, 0.1)
    }
    
    if (_inputs.baixo)
    {
        _new_id++;
        if (_new_id > _max_opts) _new_id = 0;
        efeito_sonoro(sfx_menu_click, 50, 0.1)
    }
    
    return _new_id;
}
