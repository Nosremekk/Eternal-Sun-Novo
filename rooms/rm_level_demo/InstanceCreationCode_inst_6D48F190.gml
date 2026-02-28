// Nome padrão
nome_npc = "Marco Papp";

interagir = function()
{
    var _txt = [];
    var _callback = undefined;
    var _nome_atual = nome_npc;

    // --- 1. VERIFICA BOSS MORTO (Prioridade Máxima) ---
    // Acesso direto e seguro. Se a chave não existir, retorna undefined (falsy).
    var _boss_morreu = global.bosses_mortos[$ "rm_arena_1024_544"];

    if (_boss_morreu == true)
    {
        _nome_atual = "Marco, o Grato";
        _txt = [
            "Os tremores pararam...",
            "Você derrotou o Tiago Dias!",
            "Eu sabia que não tinha errado em confiar em você.",
            "Você é o verdadeiro herói deste mundo."
        ];
    }
    // --- 2. VERIFICA SE JÁ TEM A CHAVE (Evita repetição) ---
    else if (tem_item_chave(KEY_MARCO_PAPP))
    {
        _txt = [
            "Você já tem a chave, o que faz aqui?",
            "Vá para a arena imediatamente!",
            "O 'Tiagão' não vai se matar sozinho."
        ];
    }
    // --- 3. PROGRESSÃO DE HISTÓRIA ---
    else
    {
        // SIMPLIFICAÇÃO: 
        // Não precisamos checar se 'global.eventos' ou 'global.eventos.npcs' existem,
        // pois o reset_variaveis_jogo garante isso. Checamos apenas a variável deste NPC.
        if (!variable_struct_exists(global.eventos.npcs, "marco_papp_count"))
        {
            global.eventos.npcs.marco_papp_count = 0;
        }

        var _count = global.eventos.npcs.marco_papp_count;

        // Primeira vez falando
        if (_count == 0)
        {
            _txt = [
                "Olá... Não costumo ver gente viva por aqui.",
                "Eu guardo um item perigoso.",
                "Volte a falar comigo se achar que aguenta o peso da responsabilidade."
            ];
            
            // Incrementa para o próximo diálogo
            global.eventos.npcs.marco_papp_count++;
        }
        // Segunda vez falando (Entrega o Item)
        else
        {
            _txt = [
                "Vejo que você voltou.",
                "Tu é foda, talvez consiga",
                "Tome esta chave. Ela abre a porta do Tiago Dias."
            ];

            // Callback para entregar o item ao fechar a caixa de texto
            _callback = function()
            {
                adiciona_item_chave(KEY_MARCO_PAPP,1,true);
                show_debug_message("CALLBACK: Chave entregue ao player.");
            };
        }
    }

    // Cria o diálogo com os parâmetros definidos acima
    criar_dialogo(_txt, _nome_atual, _callback);
};