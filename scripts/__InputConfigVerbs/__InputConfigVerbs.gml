function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        // Gameplay
        UP, DOWN, LEFT, RIGHT,
        JUMP, ATTACK, DASH, HOOK, MAGIC, // <-- MAGIC adicionado aqui
        PAUSE, OPEN_INVENTORY,
        
        // Interface
        UI_CONFIRM,
        UI_CANCEL,
        UI_PAGE_LEFT,  
        UI_PAGE_RIGHT
    }
    
    enum INPUT_CLUSTER
    {
        NAVIGATION,
    }
    
    if (not INPUT_ON_SWITCH)
    {
        // Gameplay
        InputDefineVerb(INPUT_VERB.UP,             "up",             vk_up,     [-gp_axislv, gp_padu]);
        InputDefineVerb(INPUT_VERB.DOWN,           "down",           vk_down,   [ gp_axislv, gp_padd]);
        InputDefineVerb(INPUT_VERB.LEFT,           "left",           vk_left,   [-gp_axislh, gp_padl]);
        InputDefineVerb(INPUT_VERB.RIGHT,          "right",          vk_right,  [ gp_axislh, gp_padr]);
        InputDefineVerb(INPUT_VERB.JUMP,           "jump",           "Z",       gp_face1); // A (Xbox) / X (PS)
        InputDefineVerb(INPUT_VERB.ATTACK,         "attack",         "X",       gp_face3); // X (Xbox) / Quad (PS)
        InputDefineVerb(INPUT_VERB.DASH,           "dash",           "C",       gp_shoulderrb); // R1
        InputDefineVerb(INPUT_VERB.HOOK,           "hook",           "V",       gp_shoulderlb); // L1
        InputDefineVerb(INPUT_VERB.MAGIC,          "magic",          "F",       gp_face4); 
        InputDefineVerb(INPUT_VERB.PAUSE,          "pause",          vk_escape, gp_start);
        InputDefineVerb(INPUT_VERB.OPEN_INVENTORY, "open_inventory", "I",       gp_select);
        
        // Interface 
        InputDefineVerb(INPUT_VERB.UI_CONFIRM, "ui_confirm", vk_enter, gp_face1);
        InputDefineVerb(INPUT_VERB.UI_CANCEL,  "ui_cancel",  vk_escape, gp_face2);
        InputDefineVerb(INPUT_VERB.UI_PAGE_LEFT,  "ui_page_left",  ord("Q"), gp_shoulderlb);
        InputDefineVerb(INPUT_VERB.UI_PAGE_RIGHT, "ui_page_right", ord("E"), gp_shoulderrb);
    }
    else 
    {
        // Gameplay
        InputDefineVerb(INPUT_VERB.UP,             "up",             undefined, [-gp_axislv, gp_padu]);
        InputDefineVerb(INPUT_VERB.DOWN,           "down",           undefined, [ gp_axislv, gp_padd]);
        InputDefineVerb(INPUT_VERB.LEFT,           "left",           undefined, [-gp_axislh, gp_padl]);
        InputDefineVerb(INPUT_VERB.RIGHT,          "right",          undefined, [ gp_axislh, gp_padr]);
        InputDefineVerb(INPUT_VERB.JUMP,           "jump",           undefined, gp_face2);
        InputDefineVerb(INPUT_VERB.ATTACK,         "attack",         undefined, gp_face3);
        InputDefineVerb(INPUT_VERB.DASH,           "dash",           undefined, gp_shoulderrb);
        InputDefineVerb(INPUT_VERB.HOOK,           "hook",           undefined, gp_shoulderlb);
        InputDefineVerb(INPUT_VERB.MAGIC,          "magic",          undefined, gp_face4); // <-- Novo binding Switch
        InputDefineVerb(INPUT_VERB.PAUSE,          "pause",          undefined, gp_start);
        InputDefineVerb(INPUT_VERB.OPEN_INVENTORY, "open_inventory", undefined, gp_select);
        
        // Interface
        InputDefineVerb(INPUT_VERB.UI_CONFIRM, "ui_confirm", undefined, gp_face2);
        InputDefineVerb(INPUT_VERB.UI_CANCEL,  "ui_cancel",  undefined, gp_face1);
        InputDefineVerb(INPUT_VERB.UI_PAGE_LEFT,  "ui_page_left",  undefined, gp_shoulderlb);
        InputDefineVerb(INPUT_VERB.UI_PAGE_RIGHT, "ui_page_right", undefined, gp_shoulderrb);
    }
    
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
}