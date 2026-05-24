return {
    'milanglacier/minuet-ai.nvim',
    event = 'InsertEnter',
    opts = {
        virtualtext = {
            auto_trigger_ft = {
                -- 'python',
                -- 'lua',
            },
            keymap = {
                -- accept whole completion
                accept = '<A-e>',
                -- accept one line
                accept_line = '<A-a>',
                -- accept n lines (prompts for number)
                -- e.g. "A-z 2 CR" will accept 2 lines
                accept_n_lines = '<A-z>',
                -- Cycle to prev completion item, or manually invoke completion
                prev = '<A-[>',
                -- Cycle to next completion item, or manually invoke completion
                next = '<A-]>',
                dismiss = '<A-x>',
            },
        },
        n_completions = 3,
        context_window = 2048,
        provider = 'openai_fim_compatible',
        provider_options = {
            openai_fim_compatible = {
                api_key = 'TERM',
                name = 'Ollama',
                end_point = 'http://localhost:11434/v1/completions',
                model = 'qwen2.5-coder:14b',
                optional = {
                    max_tokens = 64,
                    temperature = 0.4,
                    top_p = 0.96,
                },
                -- for online users:
                -- api_key = 'DEEPSEEK_API_KEY',
                -- name = 'deepseek',
                -- optional = {
                --     max_tokens = 512,
                --     temperature = 0.9,
                --     top_p = 0.96,
                -- },
            },
        },
    },
}
