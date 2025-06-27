{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    extraConfig = ''
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
      syntax enable
      colorscheme solarized8
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
    '';
    extraLuaConfig = ''
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

      require('nvim-treesitter.configs').setup({ highlight = { enable = true } })

      require('render-markdown').setup({
        html = {
          -- Turn on / off all HTML rendering.
          enabled = true,
          -- Additional modes to render HTML.
          render_modes = false,
          comment = {
              -- Turn on / off HTML comment concealing.
              conceal = true,
              -- Optional text to inline before the concealed comment.
              text = nil,
              -- Highlight for the inlined text.
              highlight = 'RenderMarkdownHtmlComment',
          },
          -- HTML tags whose start and end will be hidden and icon shown.
          -- The key is matched against the tag name, value type below.
          -- | icon      | gets inlined at the start |
          -- | highlight | highlight for the icon    |
          tag = {},
        },
        pipe_table = {
            -- Turn on / off pipe table rendering.
            enabled = true,
            -- Additional modes to render pipe tables.
            render_modes = false,
            -- Pre configured settings largely for setting table border easier.
            -- | heavy  | use thicker border characters     |
            -- | double | use double line border characters |
            -- | round  | use round border corners          |
            -- | none   | does nothing                      |
            preset = 'none',
            -- Determines how the table as a whole is rendered.
            -- | none   | disables all rendering                                                  |
            -- | normal | applies the 'cell' style rendering to each row of the table             |
            -- | full   | normal + a top & bottom line that fill out the table when lengths match |
            style = 'full',
            -- Determines how individual cells of a table are rendered.
            -- | overlay | writes completely over the table, removing conceal behavior and highlights |
            -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
            -- | padded  | raw + cells are padded to maximum visual width for each column             |
            -- | trimmed | padded except empty space is subtracted from visual width calculation      |
            cell = 'trimmed',
            -- Amount of space to put between cell contents and border.
            padding = 1,
            -- Minimum column width to use for padded or trimmed cell.
            min_width = 0,
        }
      })
    '';

    plugins = with pkgs.vimPlugins; [
      ale
      git-blame-nvim
      { plugin = neo-tree-nvim;
        config = ''
          nnoremap <leader>nt <cmd>Neotree source=filesystem position=left reveal=true toggle<cr>
        '';
      }
      { plugin = nerdtree;
        config = "nmap <F2> :NERDTreeToggle<CR>";
      }
      { plugin = lazy-nvim;
      }
      nerdtree-git-plugin

      render-markdown-nvim
      nvim-web-devicons
      nvim-treesitter
      nvim-treesitter-parsers.html
      nvim-treesitter-parsers.markdown
      nvim-treesitter-parsers.markdown_inline
      nvim-treesitter-parsers.nix
      nvim-treesitter-parsers.terraform

      telescope-fzf-native-nvim
      { plugin = telescope-nvim;
        config = ''
          " Find files using Telescope command-line sugar.
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        '';
      }
      { plugin = toggleterm-nvim;
        config = ''
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
        config = ''
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
      vim-gitgutter
      { plugin = vim-terraform;
        config = ''
          let g:terraform_fmt_on_save=1
          let g:terraform_align=1
        '';
      }
      vim-terraform-completion
      xterm-color-table-vim
      zoomwintab-vim
    ];
    vimAlias = true;
  };
}

