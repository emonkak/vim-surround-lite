# surround-obj

**surround-obj** is a Vim plugin to provide three operations: "add", "change", and "delete" for the surround object, which represent the text surrounded by any delimiter strings. It has built-in surround objects such as parentheses, quotes, tags, and so on, and you can also define your own one.

## Requirements

- Vim 8.0 or later

## Usage

The plugin does not provide any default key mappings. You have to configure like the following:

```vim
map ys  <Plug>(surround-obj-add)
nmap cs  <Plug>(surround-obj-change)
nmap ds  <Plug>(surround-obj-delete)

" Add some user-definied surround objects.
let g:surround_obj_objects = {
\   'a': { 'type': 'block', 'delimiter': ['<', '>'] },
\   'e': { 'type': 'inline', 'delimiter': '_' },
\   'r': { 'type': 'block', 'delimiter': ['[', ']'] },
\   's': { 'type': 'inline', 'delimiter': '**' },
\   'jA': {'type': 'block', 'delimiter': ['≪', '≫']},
\   'ja': {'type': 'block', 'delimiter': ['＜', '＞']},
\   'jb': {'type': 'block', 'delimiter': ['（', '）']},
\   'jB': {'type': 'block', 'delimiter': ['｛', '｝']},
\   'jk': {'type': 'block', 'delimiter': ['「', '」']},
\   'jK': {'type': 'block', 'delimiter': ['『', '』']},
\   'jr': {'type': 'block', 'delimiter': ['［', '］']},
\   'js': {'type': 'block', 'delimiter': ['【', '】']},
\   'jt': {'type': 'block', 'delimiter': ['〔', '〕']},
\   'jy': {'type': 'block', 'delimiter': ['〈', '〉']},
\   'jY': {'type': 'block', 'delimiter': ['《', '》']},
\ }
```

## Documentation

You can access the [documentation](https://github.com/emonkak/vim-surround-obj/blob/master/doc/surround-obj.txt) from within Vim using `:help surround-obj`.
