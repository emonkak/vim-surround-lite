let g:surround_objects = {
\   'u': { 'type': 'single', 'delimiter': '_' },
\   'U': { 'type': 'single', 'delimiter': '__' },
\ }

runtime! plugin/surround.vim

function! s:test_surround_add() abort
  call s:do_test('yse"', 'foo bar baz', '"foo" bar baz')
  call s:do_test('wyse"', 'foo bar baz', 'foo "bar" baz')
  call s:do_test('ys$"', 'foo bar baz', '"foo bar baz"')

  call s:do_test('yse''', 'foo bar baz', '''foo'' bar baz')
  call s:do_test('wyse''', 'foo bar baz', 'foo ''bar'' baz')
  call s:do_test('ys$''', 'foo bar baz', '''foo bar baz''')

  call s:do_test('yseb', 'foo bar baz', '(foo) bar baz')
  call s:do_test('wyseb', 'foo bar baz', 'foo (bar) baz')
  call s:do_test('ys$b', 'foo bar baz', '(foo bar baz)')
  call s:do_test('ys$bwyseb', 'foo bar baz', '((foo) bar baz)')
  call s:do_test('wyseb', '  foo', '  (foo)')

  call s:do_test("ysetdiv\<CR>", 'foo bar baz', '<div>foo</div> bar baz')
  call s:do_test("wysetdiv\<CR>", 'foo bar baz', 'foo <div>bar</div> baz')
  call s:do_test("ys$tdiv\<CR>", 'foo bar baz', '<div>foo bar baz</div>')
  call s:do_test("ys$tdiv\<CR>wysetdiv\<CR>", 'foo bar baz', '<div><div>foo</div> bar baz</div>')
  call s:do_test("wysetdiv\<CR>", '  foo', '  <div>foo</div>')

  call s:do_test('ys$b..', '', '((()))')
  call s:do_test('ys$b..', 'foo', '(((foo)))')
endfunction

function! s:test_surround_change() abort
  call s:do_test('cs"b', '""', '()')
  call s:do_test('cs"b', '"foo"', '(foo)')
  call s:do_test('cs"b', '"foo "', '(foo )')
  call s:do_test('cs"b', '" foo"', '( foo)')
  call s:do_test('cs"b', '" foo "', '( foo )')
  call s:do_test('cs"b', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('cs"b', '" \foo\ "', '( \foo\ )')
  call s:do_test('f"cs"b', '  "foo"  ', '  (foo)  ')

  call s:do_test('$cs"b', '""', '()')
  call s:do_test('$cs"b', '"foo"', '(foo)')
  call s:do_test('$cs"b', '"foo "', '(foo )')
  call s:do_test('$cs"b', '" foo"', '( foo)')
  call s:do_test('$cs"b', '" foo "', '( foo )')
  call s:do_test('$cs"b', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('$cs"b', '" \foo\ "', '( \foo\ )')
  call s:do_test('2f"cs"b', '  "foo"  ', '  (foo)  ')

  call s:do_test('ffcs"b', '"foo"', '(foo)')
  call s:do_test('ffcs"b', '"foo "', '(foo )')
  call s:do_test('ffcs"b', '" foo"', '( foo)')
  call s:do_test('ffcs"b', '" foo "', '( foo )')
  call s:do_test('ffcs"b', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('ffcs"b', '" \foo\ "', '( \foo\ )')
  call s:do_test('f"cs"b', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('2f"cs"b', '" \"foo\" "', '( \"foo\" )')
  call s:do_test('ffcs"b', '  "foo"  ', '  (foo)  ')

  call s:do_test('cs"b', '"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('ffcs"b', '"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('f"cs"b', '"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('2f"cs"b', '"foo"bar"baz"', '"foo"bar(baz)')
  call s:do_test('fbcs"b', '"foo"bar"baz"', '"foo(bar)baz"')
  call s:do_test('2fbcs"b', '"foo"bar"baz"', '"foo"bar(baz)')
  call s:do_test('$cs"b', '"foo"bar"baz"', '"foo"bar(baz)')

  call s:do_test('csbB', '()', '{}')
  call s:do_test('csbB', '(foo)', '{foo}')
  call s:do_test('csbB', '(foo )', '{foo }')
  call s:do_test('csbB', '( foo)', '{ foo}')
  call s:do_test('csbB', '( foo )', '{ foo }')
  call s:do_test('csbB', '(foo())', '{foo()}')
  call s:do_test('f(csbB', '(foo())', '(foo{})')
  call s:do_test('f(csbB', '  ()  ', '  {}  ')
  call s:do_test('f(csbB', '  (foo)  ', '  {foo}  ')

  call s:do_test('csbB', '( \(foo )', '{ \(foo }')
  call s:do_test('csbB', '( foo\) )', '{ foo\) }')
  call s:do_test('csbB', '( \(foo\) )', '{ \(foo\) }')

  call s:do_test('csbB', "(\na)", "{\na}")
  call s:do_test('csbB', "(a\n)", "{a\n}")
  call s:do_test('csbB', "((\na))", "{(\na)}")
  call s:do_test('csbB', "((a\n))", "{(a\n)}")

  call s:do_test('$csbB', '()', '{}')
  call s:do_test('$csbB', '(foo )', '{foo }')
  call s:do_test('$csbB', '( foo)', '{ foo}')
  call s:do_test('$csbB', '( foo )', '{ foo }')
  call s:do_test('$csbB', '(foo())', '{foo()}')
  call s:do_test('f)csbB', '(foo())', '(foo{})')
  call s:do_test('f)csbB', '  ()  ', '  {}  ')
  call s:do_test('f)csbB', '  (foo)  ', '  {foo}  ')

  call s:do_test('ffcsbB', '(foo)', '{foo}')
  call s:do_test('ffcsbB', '(foo )', '{foo }')
  call s:do_test('ffcsbB', '( foo)', '{ foo}')
  call s:do_test('ffcsbB', '( foo )', '{ foo }')
  call s:do_test('ffcsbB', '(foo())', '{foo()}')
  call s:do_test('ffcsbB', '  (foo)  ', '  {foo}  ')

  call s:do_test('csbB', '(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('ffcsbB', '(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('f)csbB', '(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('f(csbB', '(foo)bar(baz)', '(foo)bar{baz}')
  call s:do_test('2fbcsbB', '(foo)bar(baz)', '(foo)bar{baz}')
  call s:do_test('$csbB', '(foo)bar(baz)', '(foo)bar{baz}')

  call s:do_test("csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("f<cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("f<csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f<csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test("f>csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("f>csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("f>csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("f>csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("f>csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("f>csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("2f>cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("f>csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f>csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test("f<csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("f<csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("f<csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("f<csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("f<csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("3f<csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("f<cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("f<csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("f<csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')

  call s:do_test("$csttp\<CR>", '<div></div>', '<p></p>')
  call s:do_test("$csttp\<CR>", '<div>foo</div>', '<p>foo</p>')
  call s:do_test("$csttp\<CR>", '<div>foo </div>', '<p>foo </p>')
  call s:do_test("$csttp\<CR>", '<div> foo</div>', '<p> foo</p>')
  call s:do_test("$csttp\<CR>", '<div> foo </div>', '<p> foo </p>')
  call s:do_test("$csttp\<CR>", '<div>foo<b>bar</b></div>', '<p>foo<b>bar</b></p>')
  call s:do_test("2f>cstti\<CR>", '<div>foo<b>bar</b></div>', '<div>foo<i>bar</i></div>')
  call s:do_test("2f>csttp\<CR>", '  <div></div>  ', '  <p></p>  ')
  call s:do_test("2f>csttp\<CR>", '  <div>foo</div>  ', '  <p>foo</p>  ')
endfunction

function! s:test_surround_delete() abort
  call s:do_test('ds"b', '""', '')
  call s:do_test('ds"b', '"foo"', 'foo')
  call s:do_test('ds"b', '"foo "', 'foo')
  call s:do_test('ds"b', '" foo"', 'foo')
  call s:do_test('ds"b', '" foo "', 'foo')
  call s:do_test('ds"b', '" \"foo\" "', '\"foo\"')
  call s:do_test('ds"b', '" \foo\ "', '\foo\')
  call s:do_test('f"ds"b', '  "foo"  ', '  foo  ')

  call s:do_test('$ds"b', '""', '')
  call s:do_test('$ds"b', '"foo"', 'foo')
  call s:do_test('$ds"b', '"foo "', 'foo')
  call s:do_test('$ds"b', '" foo"', 'foo')
  call s:do_test('$ds"b', '" foo "', 'foo')
  call s:do_test('$ds"b', '" \"foo\" "', '\"foo\"')
  call s:do_test('$ds"b', '" \foo\ "', '\foo\')
  call s:do_test('2f"ds"b', '  "foo"  ', '  foo  ')

  call s:do_test('ffds"b', '"foo"', 'foo')
  call s:do_test('ffds"b', '"foo "', 'foo')
  call s:do_test('ffds"b', '" foo"', 'foo')
  call s:do_test('ffds"b', '" foo "', 'foo')
  call s:do_test('ffds"b', '" \"foo\" "', '\"foo\"')
  call s:do_test('ffds"b', '" \foo\ "', '\foo\')
  call s:do_test('ffds"b', '  "foo"  ', '  foo  ')

  call s:do_test('ds"b', '"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('ffds"b', '"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('f"ds"b', '"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('2f"ds"b', '"foo"bar"baz"', '"foo"barbaz')
  call s:do_test('fbds"b', '"foo"bar"baz"', '"foobarbaz"')
  call s:do_test('2fbds"b', '"foo"bar"baz"', '"foo"barbaz')
  call s:do_test('$ds"b', '"foo"bar"baz"', '"foo"barbaz')

  call s:do_test('dsb', '()', '')
  call s:do_test('dsb', '(foo)', 'foo')
  call s:do_test('dsb', '(foo )', 'foo')
  call s:do_test('dsb', '( foo)', 'foo')
  call s:do_test('dsb', '( foo )', 'foo')
  call s:do_test('dsb', '(foo())', 'foo()')
  call s:do_test('f(dsb', '(foo())', '(foo)')
  call s:do_test('f(dsb', '  ()  ', '    ')
  call s:do_test('f(dsb', '  (foo)  ', '  foo  ')

  call s:do_test('dsb', '( \(foo )', '\(foo')
  call s:do_test('dsb', '( foo\) )', 'foo\)')
  call s:do_test('dsb', '( \(foo\) )', '\(foo\)')

  call s:do_test('dsb', "(\na)", "\na")
  call s:do_test('dsb', "(a\n)", "a\n")
  call s:do_test('dsb', "((\na))", "(\na)")
  call s:do_test('dsb', "((a\n))", "(a\n)")

  call s:do_test('$dsb', '()', '')
  call s:do_test('$dsb', '(foo)', 'foo')
  call s:do_test('$dsb', '(foo )', 'foo')
  call s:do_test('$dsb', '( foo)', 'foo')
  call s:do_test('$dsb', '( foo )', 'foo')
  call s:do_test('$dsb', '(foo())', 'foo()')
  call s:do_test('f)dsb', '(foo())', '(foo)')
  call s:do_test('f)dsb', '  ()  ', '    ')
  call s:do_test('f)dsb', '  (foo)  ', '  foo  ')

  call s:do_test('ffdsb', '(foo)', 'foo')
  call s:do_test('ffdsb', '(foo )', 'foo')
  call s:do_test('ffdsb', '( foo)', 'foo')
  call s:do_test('ffdsb', '( foo )', 'foo')
  call s:do_test('ffdsb', '(foo())', 'foo()')
  call s:do_test('ffdsb', '  (foo)  ', '  foo  ')

  call s:do_test('dsbB', '(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('ffdsbB', '(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('f)dsbB', '(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('f(dsbB', '(foo)bar(baz)', '(foo)barbaz')
  call s:do_test('2fbdsbB', '(foo)bar(baz)', '(foo)barbaz')
  call s:do_test('$dsbB', '(foo)bar(baz)', '(foo)barbaz')

  call s:do_test('dst', '<div></div>', '')
  call s:do_test('dst', '<div>foo</div>', 'foo')
  call s:do_test('dst', '<div>foo </div>', 'foo')
  call s:do_test('dst', '<div> foo</div>', 'foo')
  call s:do_test('dst', '<div> foo </div>', 'foo')
  call s:do_test('dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('f<dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('f<dst', '  <div></div>  ', '    ')
  call s:do_test('f<dst', '  <div>foo</div>  ', '  foo  ')

  call s:do_test('f>dst', '<div></div>', '')
  call s:do_test('f>dst', '<div>foo</div>', 'foo')
  call s:do_test('f>dst', '<div>foo </div>', 'foo')
  call s:do_test('f>dst', '<div> foo</div>', 'foo')
  call s:do_test('f>dst', '<div> foo </div>', 'foo')
  call s:do_test('f>dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('2f>dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('f>dst', '  <div></div>  ', '    ')
  call s:do_test('f>dst', '  <div>foo</div>  ', '  foo  ')

  call s:do_test('f<dst', '<div></div>', '')
  call s:do_test('f<dst', '<div>foo</div>', 'foo')
  call s:do_test('f<dst', '<div>foo </div>', 'foo')
  call s:do_test('f<dst', '<div> foo</div>', 'foo')
  call s:do_test('f<dst', '<div> foo </div>', 'foo')
  call s:do_test('3f<dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('2f<dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('2f<dst', '  <div></div>  ', '    ')
  call s:do_test('2f<dst', '  <div>foo</div>  ', '  foo  ')

  call s:do_test('$dst', '<div></div>', '')
  call s:do_test('$dst', '<div>foo</div>', 'foo')
  call s:do_test('$dst', '<div>foo </div>', 'foo')
  call s:do_test('$dst', '<div> foo</div>', 'foo')
  call s:do_test('$dst', '<div> foo </div>', 'foo')
  call s:do_test('$dst', '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test('3f>dst', '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test('2f>dst', '  <div></div>  ', '    ')

  call s:do_test("/foo\<CR>dst", '<div>foo</div>', 'foo')
  call s:do_test("/foo\<CR>dst", '<div>foo </div>', 'foo')
  call s:do_test("/foo\<CR>dst", '<div> foo</div>', 'foo')
  call s:do_test("/foo\<CR>dst", '<div> foo </div>', 'foo')
  call s:do_test("/foo\<CR>dst", '<div>foo<b>bar</b></div>', 'foo<b>bar</b>')
  call s:do_test("/bar\<CR>dst", '<div>foo<b>bar</b></div>', '<div>foobar</div>')
  call s:do_test("/foo\<CR>dst", '  <div>foo</div>  ', '  foo  ')
endfunction

function! s:test_surround_textobj() abort
  call s:do_test("d\<Plug>(surround-textobj-a:u)", '_a_', '')
  call s:do_test("$d\<Plug>(surround-textobj-a:u)", '_a_', '')
  call s:do_test("d\<Plug>(surround-textobj-a:u)", ' _a_ ', ' _a_ ')
  call s:do_test("$d\<Plug>(surround-textobj-a:u)", ' _a_ ', ' _a_ ')
  call s:do_test("fad\<Plug>(surround-textobj-a:u)", ' _a_ ', '  ')
  call s:do_test("d\<Plug>(surround-textobj-a:u)", '_a__b_', '_b_')
  call s:do_test("$d\<Plug>(surround-textobj-a:u)", '_a__b_', '_a_')
  call s:do_test("fad\<Plug>(surround-textobj-a:u)", '_a__b_', '_b_')
  call s:do_test("fbd\<Plug>(surround-textobj-a:u)", '_a__b_', '_a_')

  call s:do_test("d\<Plug>(surround-textobj-i:u)", '_a_', '__')
  call s:do_test("$d\<Plug>(surround-textobj-i:u)", '_a_', '__')
  call s:do_test("d\<Plug>(surround-textobj-i:u)", ' _a_ ', ' _a_ ')
  call s:do_test("$d\<Plug>(surround-textobj-i:u)", ' _a_ ', ' _a_ ')
  call s:do_test("fad\<Plug>(surround-textobj-i:u)", ' _a_ ', ' __ ')
  call s:do_test("d\<Plug>(surround-textobj-i:u)", '_a__b_', '___b_')
  call s:do_test("$d\<Plug>(surround-textobj-i:u)", '_a__b_', '_a___')
  call s:do_test("fad\<Plug>(surround-textobj-i:u)", '_a__b_', '___b_')
  call s:do_test("fbd\<Plug>(surround-textobj-i:u)", '_a__b_', '_a___')

  call s:do_test("d\<Plug>(surround-textobj-a:U)", '__a__', '')
  call s:do_test("$d\<Plug>(surround-textobj-a:U)", '__a__', '')
  call s:do_test("d\<Plug>(surround-textobj-a:U)", ' __a__ ', ' __a__ ')
  call s:do_test("$d\<Plug>(surround-textobj-a:U)", ' __a__ ', ' __a__ ')
  call s:do_test("fad\<Plug>(surround-textobj-a:U)", ' __a__ ', '  ')

  call s:do_test("d\<Plug>(surround-textobj-i:U)", '__a__', '____')
  call s:do_test("$d\<Plug>(surround-textobj-i:U)", '__a__', '____')
  call s:do_test("d\<Plug>(surround-textobj-i:U)", ' __a__ ', ' __a__ ')
  call s:do_test("$d\<Plug>(surround-textobj-i:U)", ' __a__ ', ' __a__ ')
  call s:do_test("fad\<Plug>(surround-textobj-i:U)", ' __a__ ', ' ____ ')

  call s:do_test("d\<Plug>(surround-textobj-a:t)", '<div>a</div>', '')
  call s:do_test("$d\<Plug>(surround-textobj-a:t)", '<div>a</div>', '')
  call s:do_test("d\<Plug>(surround-textobj-a:t)", ' <div>a</div> ', ' <div>a</div> ')
  call s:do_test("$d\<Plug>(surround-textobj-a:t)", ' <div>a</div> ', ' <div>a</div> ')
  call s:do_test("fad\<Plug>(surround-textobj-a:t)", ' <div>a</div> ', '  ')
  call s:do_test("d\<Plug>(surround-textobj-a:t)", '<div>a<div>b</div>c</div>', '')
  call s:do_test("$d\<Plug>(surround-textobj-a:t)", '<div>a<div>b</div>c</div>', '')
  call s:do_test("fad\<Plug>(surround-textobj-a:t)", '<div>a<div>b</div>c</div>', '')
  call s:do_test("fbd\<Plug>(surround-textobj-a:t)", '<div>a<div>b</div>c</div>', '<div>ac</div>')
  call s:do_test("fcd\<Plug>(surround-textobj-a:t)", '<div>a<div>b</div>c</div>', '')

  call s:do_test("d\<Plug>(surround-textobj-i:t)", '<div>a</div>', '<div></div>')
  call s:do_test("$d\<Plug>(surround-textobj-i:t)", '<div>a</div>', '<div></div>')
  call s:do_test("d\<Plug>(surround-textobj-i:t)", ' <div>a</div> ', ' <div>a</div> ')
  call s:do_test("$d\<Plug>(surround-textobj-i:t)", ' <div>a</div> ', ' <div>a</div> ')
  call s:do_test("fad\<Plug>(surround-textobj-i:t)", ' <div>a</div> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-textobj-i:t)", '<div>a<div>b</div>c</div>', '<div></div>')
  call s:do_test("$d\<Plug>(surround-textobj-i:t)", '<div>a<div>b</div>c</div>', '<div></div>')
  call s:do_test("fad\<Plug>(surround-textobj-i:t)", '<div>a<div>b</div>c</div>', '<div></div>')
  call s:do_test("fbd\<Plug>(surround-textobj-i:t)", '<div>a<div>b</div>c</div>', '<div>a<div></div>c</div>')
  call s:do_test("fcd\<Plug>(surround-textobj-i:t)", '<div>a<div>b</div>c</div>', '<div></div>')
endfunction

function! s:do_test(key_strokes, source, expected_result) abort
  new
  map <buffer> ys  <Plug>(surround-add)
  nmap <buffer> cs  <Plug>(surround-change)
  nmap <buffer> ds  <Plug>(surround-delete)
  silent put =a:source
  normal! ggdd0
  0verbose call feedkeys(a:key_strokes, 'x')
  call assert_equal(a:expected_result, join(getline(1, line('$')), "\n"))
  close!
endfunction
