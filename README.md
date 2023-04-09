# surround-obj

**surround-obj** is a Vim plugin to provide three operations: "add", "change", and "delete" for the surround object, which represent the text surrounded by any delimiter strings. It has built-in surround objects such as parentheses, quotes, tags, and so on, and you can also define your own one.

## Requirements

- Vim 8.0 or later

## Usage

The plugin does not provide any default key mappings and settings. You have to configure like the following:

```vim
map ys  <Plug>(surround-obj-add)
nmap cs  <Plug>(surround-obj-change)
nmap ds  <Plug>(surround-obj-delete)

call surround_obj#define_built_in_objects()
```

## Documentation

You can access the [documentation](https://github.com/emonkak/vim-surround-obj/blob/master/doc/surround-obj.txt) from within Vim using `:help surround-obj`.