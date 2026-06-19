{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    withRuby = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      glow
      imagemagick
      luajitPackages.magick
      luajitPackages.tiktoken_core
      lynx
      ripgrep
    ];
    extraConfig = /* vim */''
      " Styled and colored underline support
      let &t_AU = "\e[58:5:%dm"
      let &t_8u = "\e[58:2:%lu:%lu:%lum"
      let &t_Us = "\e[4:2m"
      let &t_Cs = "\e[4:3m"
      let &t_ds = "\e[4:4m"
      let &t_Ds = "\e[4:5m"
      let &t_Ce = "\e[4:0m"
      " Strikethrough
      let &t_Ts = "\e[9m"
      let &t_Te = "\e[29m"
      " Truecolor support
      let &t_8f = "\e[38:2:%lu:%lu:%lum"
      let &t_8b = "\e[48:2:%lu:%lu:%lum"
      let &t_RF = "\e]10;?\e\\"
      let &t_RB = "\e]11;?\e\\"
      " Bracketed paste
      let &t_BE = "\e[?2004h"
      let &t_BD = "\e[?2004l"
      let &t_PS = "\e[200~"
      let &t_PE = "\e[201~"
      " Cursor control
      let &t_RC = "\e[?12$p"
      let &t_SH = "\e[%d q"
      let &t_RS = "\eP$q q\e\\"
      let &t_SI = "\e[5 q"
      let &t_SR = "\e[3 q"
      let &t_EI = "\e[1 q"
      let &t_VS = "\e[?12l"
      " Focus tracking
      let &t_fe = "\e[?1004h"
      let &t_fd = "\e[?1004l"
      execute "set <FocusGained>=\<Esc>[I"
      execute "set <FocusLost>=\<Esc>[O"
      " Window title
      let &t_ST = "\e[22;2t"
      let &t_RT = "\e[23;2t"
      
      " vim hardcodes background color erase even if the terminfo file does
      " not contain bce. This causes incorrect background rendering when
      " using a color theme with a background color in terminals such as
      " kitty that do not support background color erase.
      let &t_ut=""

      set number
      set nowrap
      set termguicolors
      set background=dark
      set splitright
      syntax enable
      colorscheme solarized8
      
      " Make background transparent (inherit from terminal)
      highlight Normal guibg=NONE ctermbg=NONE
      highlight NonText guibg=NONE ctermbg=NONE
      highlight SignColumn guibg=NONE ctermbg=NONE
      highlight EndOfBuffer guibg=NONE ctermbg=NONE
      
      let g:airline_solarized_bg='dark'
      let g:airline_detect_truecolor = 1
      let g:airline_theme='solarized_flood'
      " autocmd vimenter * ++nested colorscheme solarized8

      " Set indentation
      " Use spaces instead of tabs
      set expandtab
      " Number of spaces to use for a tab
      set tabstop=2
      " Number of spaces to use for autoindenting
      set shiftwidth=2
      " Enable autoindenting
      set autoindent
      " Enable smart indenting
      set smartindent
      " Soft tabstop (optional, but often helpful)
      set softtabstop=2

      " Highlight trailing whitespace
      highlight ExtraWhitespace ctermbg=red guibg=red
      match ExtraWhitespace /\s\+$/
      autocmd BufWinEnter * if &filetype != 'neo-tree' | match ExtraWhitespace /\s\+$/ | endif
      autocmd InsertEnter * if &filetype != 'neo-tree' | match ExtraWhitespace /\s\+\%#\@<!$/ | endif
      autocmd InsertLeave * if &filetype != 'neo-tree' | match ExtraWhitespace /\s\+$/ | endif
      autocmd BufWinLeave * call clearmatches()
    '';
    initLua = /* lua */ ''
      -- require('lazy').setup({
      --   {
      --     "dustinblackman/oatmeal.nvim",
      --     cmd = { "Oatmeal" },
      --     keys = {
      --         { "<leader>om", mode = "n", desc = "Start Oatmeal session" },
      --     },
      --   },
      -- }),

      require("toggleterm").setup{
        -- size can be a number or function which is passed the current terminal
        function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-t>]],
        -- on_create = fun(t: Terminal), -- function to run when the terminal is first created
        -- on_open = fun(t: Terminal), -- function to run when the terminal opens
        -- on_close = fun(t: Terminal), -- function to run when the terminal closes
        -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
        -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
        -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
        shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
        shading_factor = '-15', -- the percentage by which to lighten dark terminal background, default: -30
        shading_ratio = '-3', -- the ratio of shading factor for light/dark terminal background, default: -3
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
        direction = 'tab',
        close_on_exit = true, -- close the terminal window when the process exits
        clear_env = false, -- use only environmental variables from `env`, passed to jobstart()
        auto_scroll = true, -- automatically scroll to the bottom on terminal output
        float_opts = {
          -- The border key is *almost* the same as 'nvim_open_win'
          -- see :h nvim_open_win for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          border = 'double',
          -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
          -- width = <value>,
          -- height = <value>,
          -- row = <value>,
          -- col = <value>,
          -- title_pos = 'left' | 'center' | 'right', position of the title of the floating window
        },
        winbar = {
          enabled = true,
          name_formatter = function(term) --  term: Terminal
            return term.name
          end
        },
        responsiveness = {
          -- breakpoint in terms of `vim.o.columns` at which terminals will start to stack on top of each other
          -- instead of next to each other
          -- default = 0 which means the feature is turned off
          horizontal_breakpoint = 135,
        }
      }

      require('nvim-treesitter').setup({ highlight = { enable = true } })

      vim.lsp.config('terraformls', {
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { 'terraform', 'hcl' },
        root_dir = vim.fs.root(0, { '.terraform', '.git' }),
      })
      vim.lsp.enable('terraformls')
      
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
      })

      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
      local code_root = vim.fn.expand("~/Code") .. "/"
      local manage_session = cwd:sub(1, #code_root) == code_root

      require("auto-session").setup({
        auto_session_enabled = manage_session,
        auto_save_enabled = manage_session,
        auto_restore_enabled = manage_session,
        session_lens = {
          load_on_setup = true,
        },
      })

      local telescope = require("telescope")
      telescope.load_extension("session-lens")
      telescope.load_extension("gh")
      vim.keymap.set(
        "n",
        "<leader>fs",
        telescope.extensions["session-lens"].search_session,
        { desc = "Find sessions" }
      )
      vim.keymap.set(
        "n",
        "<leader>pr",
        telescope.extensions.gh.pull_request,
        { desc = "GitHub Pull Requests" }
      )

      require("CopilotChat").setup({
        model = 'claude-sonnet-4.5',
        temperature = 0.1,
        resources = 'buffer', -- Include buffer context by default
        window = {
          layout = 'vertical', -- or 'horizontal', 'float'
          width = 0.4,  -- 40% of screen width for vertical split
          height = 0.8, -- 80% of screen height
          border = 'rounded',
          title = '\u{ec1e} AI Assistant',
          zindex = 100,
        },
        headers = {
          user = '\u{f007} You',
          assistant = '\u{ec1e} Copilot',
          tool = '\u{f0ad} Tool',
        },
        separator = '━━',
        auto_fold = true,
        auto_insert_mode = false,
        mappings = {
          reset = {
            normal = ''',
            insert = ''',
          },
        },
      })

      require("image").setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            filetypes = { "markdown", "vimwiki" },
          },
        },
        max_height_window_percentage = 50,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
      })
    '';

    plugins = let
      preludeLeader = pkgs.vimUtils.buildVimPlugin {
        pname = "prelude-leader";
        version = "0.1.0";
        src = pkgs.runCommand "prelude-leader-empty" {} "mkdir -p $out";
      };
    in with pkgs.vimPlugins; [
      { plugin = preludeLeader;
        type = "viml";
        config = /* vim */ ''
          let mapleader = " "
          let maplocalleader = " "
        '';
      }
      ale
      git-blame-nvim

      ## GitHub
      telescope-github-nvim
      open-browser-vim
      open-browser-github-vim
      plenary-nvim
      copilot-vim
      copilot-lsp
      { plugin = CopilotChat-nvim;
        type = "viml";
        config = /* vim */ ''
          " Toggle CopilotChat window
          nnoremap <leader>cc <cmd>CopilotChatToggle<cr>
          " Ask with buffer context
          nnoremap <leader>cq <cmd>lua require('CopilotChat').ask(vim.fn.input('Quick Chat: '), { selection = require('CopilotChat.select').buffer })<cr>
          " Quick prompts (work on visual selection or buffer)
          nnoremap <leader>ce <cmd>CopilotChatExplain<cr>
          vnoremap <leader>ce <cmd>CopilotChatExplain<cr>
          nnoremap <leader>cr <cmd>CopilotChatReview<cr>
          vnoremap <leader>cr <cmd>CopilotChatReview<cr>
          nnoremap <leader>cf <cmd>CopilotChatFix<cr>
          vnoremap <leader>cf <cmd>CopilotChatFix<cr>
          nnoremap <leader>co <cmd>CopilotChatOptimize<cr>
          vnoremap <leader>co <cmd>CopilotChatOptimize<cr>
        '';
      }

      { plugin = neo-tree-nvim;
        type = "viml";
        config = /* vim */ ''
          nnoremap <leader>nt <cmd>Neotree source=filesystem position=left reveal=true toggle<cr>
        '';
      }
      { plugin = lazy-nvim;
      }

      { plugin = markdown-preview-nvim;
        type = "viml";
        config = /* vim */ ''
          " Markdown preview in browser
          let g:mkdp_browser = 'qutebrowser'
          nmap <leader>mpb <Plug>MarkdownPreviewToggle
        '';
      }

      nvim-web-devicons
      nvim-treesitter
      nvim-treesitter-parsers.html
      nvim-treesitter-parsers.markdown
      nvim-treesitter-parsers.markdown_inline
      nvim-treesitter-parsers.nix
      nvim-treesitter-parsers.terraform
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      lspkind-nvim
      luasnip
      cmp_luasnip
      { plugin = copilot-vim;
        type = "viml";
        config = /* vim */ ''
          let g:copilot_filetypes = { '*': v:true }
        '';
      }

      nvim-window-picker

      auto-session

      telescope-fzf-native-nvim

      { plugin = telescope-nvim;
        type = "viml";
        config = /* vim */ ''
          " Find files using Telescope command-line sugar.
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        '';
      }
      { plugin = toggleterm-nvim;
        type = "viml";
        config = /* vim */ ''
          " set
          autocmd TermEnter term://*toggleterm#*
                \ tnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>

          " By applying the mappings this way you can pass a count to your
          " mapping to open a specific window.
          " For example: 2<C-t> will open terminal 2
          nnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
          inoremap <silent><C-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

          "function _G.set_terminal_keymaps()
          "  local opts = {buffer = 0}
          "  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
          "  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
          "  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
          "  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
          "  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
          "  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
          "  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
          "end
          "
          "-- if you only want these mappings for toggle term use term://*toggleterm#* instead
          "vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
        '';
      }
      vim-airline
      { plugin = vim-airline-themes;
        type = "viml";
        config = /* vim */ ''
          let g:airline_powerline_fonts = 1

          if !exists('g:airline_symbols')
            let g:airline_symbols = {}
          endif

          " unicode symbols
          let g:airline_left_sep = '»'
          let g:airline_left_sep = '▶'
          let g:airline_right_sep = '«'
          let g:airline_right_sep = '◀'
          let g:airline_symbols.crypt = '🔒'
          let g:airline_symbols.linenr = '☰'
          let g:airline_symbols.linenr = '␊'
          let g:airline_symbols.linenr = '␤'
          let g:airline_symbols.linenr = '¶'
          let g:airline_symbols.maxlinenr = ' '
          let g:airline_symbols.maxlinenr = '㏑'
          let g:airline_symbols.branch = '⎇'
          let g:airline_symbols.paste = 'ρ'
          let g:airline_symbols.paste = 'Þ'
          let g:airline_symbols.paste = '∥'
          let g:airline_symbols.spell = 'Ꞩ'
          let g:airline_symbols.notexists = 'Ɇ'
          let g:airline_symbols.whitespace = 'Ξ'

          " powerline symbols
          let g:airline_left_sep = ''
          let g:airline_left_alt_sep = ''
          let g:airline_right_sep = ''
          let g:airline_right_alt_sep = ''
          let g:airline_symbols.branch = ''
          let g:airline_symbols.readonly = ''
          let g:airline_symbols.linenr = '☰'
          let g:airline_symbols.maxlinenr = ''
        '';
      }
      vim-colors-solarized
      vim-solarized8
      #vim-colorschemes
      NeoSolarized
      vim-fugitive
      { plugin = vim-gitgutter;
        type = "viml";
        config = /* vim */ ''
          nmap <leader>hs <Plug>(GitGutterStageHunk)
        '';
      }
      { plugin = vim-terraform;
        type = "viml";
        config = /* vim */ ''
          let g:terraform_fmt_on_save=1
          let g:terraform_align=1
        '';
      }
      vim-terraform-completion
      vim-tmux-navigator
      { plugin = vimwiki;
        type = "viml";
        config = /* vim */ ''
          let g:vimwiki_list = [{'path': '~/Documents/zennotes', 'syntax': 'markdown', 'ext': '.md'}]
        '';
      }
      image-nvim
      xterm-color-table-vim
      zoomwintab-vim
    ];
    vimAlias = true;
  };
}
