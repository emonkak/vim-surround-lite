runtime! plugin/surround_obj.vim

call surround_obj#define_built_in_objects([
\   "'",
\   '"',
\   '(',
\   ')',
\   '_',
\   'b',
\   'f',
\   't',
\   '{',
\   '}',
\ ])

call surround_obj#define_object('e', {
\   'type': 'alias',
\   'key': '_',
\ })

call surround_obj#define_object('E', {
\   'type': 'inline',
\   'delimiter': '**',
\   'pattern': '\*\*',
\ })

call surround_obj#define_object('jb', {
\   'type': 'block',
\   'delimiter': ['（', '）'],
\   'pattern': ['（', '）'],
\ })

call surround_obj#define_object('jB', {
\   'type': 'block',
\   'delimiter': ['｛', '｝'],
\   'pattern': ['｛', '｝'],
\ })

function! s:test_add_block() abort
  call s:do_test('yse(', '#foo bar baz', '(foo) bar baz')
  call s:do_test('yse(', 'foo #bar baz', 'foo (bar) baz')
  call s:do_test('yse(', 'foo bar #baz', 'foo bar (baz)')
  call s:do_test('ys$(', '#foo bar baz', '(foo bar baz)')

  call s:do_test('yse)', '#foo bar baz', '( foo ) bar baz')
  call s:do_test('yse)', 'foo #bar baz', 'foo ( bar ) baz')
  call s:do_test('yse)', 'foo bar #baz', 'foo bar ( baz )')
  call s:do_test('ys$)', '#foo bar baz', '( foo bar baz )')

  call s:do_test('ysejb', '#foo bar baz', '（foo） bar baz')
  call s:do_test('ysejb', 'foo #bar baz', 'foo （bar） baz')
  call s:do_test('ysejb', 'foo bar #baz', 'foo bar （baz）')
  call s:do_test('ys$jb', '#foo bar baz', '（foo bar baz）')

  call s:do_test('ysejB', '#foo bar baz', '｛foo｝ bar baz')
  call s:do_test('ysejB', 'foo #bar baz', 'foo ｛bar｝ baz')
  call s:do_test('ysejB', 'foo bar #baz', 'foo bar ｛baz｝')
  call s:do_test('ys$jB', '#foo bar baz', '｛foo bar baz｝')

  call s:do_test("yseff\<CR>", '#foo bar baz', 'f(foo) bar baz')
  call s:do_test("yseff\<CR>", 'foo #bar baz', 'foo f(bar) baz')
  call s:do_test("yseff\<CR>", 'foo bar #baz', 'foo bar f(baz)')
  call s:do_test("ys$ff\<CR>", '#foo bar baz', 'f(foo bar baz)')
endfunction

function! s:test_add_function_call() abort
  call s:do_test("yseff\<CR>", '#foo bar baz', 'f(foo) bar baz')
  call s:do_test("yseff\<CR>", 'foo #bar baz', 'foo f(bar) baz')
  call s:do_test("yseff\<CR>", 'foo bar #baz', 'foo bar f(baz)')
  call s:do_test("ys$ff\<CR>", '#foo bar baz', 'f(foo bar baz)')
endfunction

function! s:test_add_inline() abort
  call s:do_test('yse"', '#foo bar baz', '"foo" bar baz')
  call s:do_test('yse"', 'foo #bar baz', 'foo "bar" baz')
  call s:do_test('yse"', 'foo bar #baz', 'foo bar "baz"')
  call s:do_test('ys$"', '#foo bar baz', '"foo bar baz"')

  call s:do_test("yse'", '#foo bar baz', "'foo' bar baz")
  call s:do_test("yse'", 'foo #bar baz', "foo 'bar' baz")
  call s:do_test("yse'", 'foo bar #baz', "foo bar 'baz'")
  call s:do_test("ys$'", '#foo bar baz', "'foo bar baz'")

  call s:do_test("yseE", '#foo bar baz', "**foo** bar baz")
  call s:do_test("yseE", 'foo #bar baz', "foo **bar** baz")
  call s:do_test("yseE", 'foo bar #baz', "foo bar **baz**")
  call s:do_test("ys$E", '#foo bar baz', "**foo bar baz**")
endfunction

function! s:test_add_repeat() abort
  if !has('patch-8.0.0548')
    return '"." command does not work inside functions.'
  endif
  call s:do_test('ys$(.', '#foo', '((foo))')
  call s:do_test('ys$(..', '#foo', '(((foo)))')
  call s:do_test('ys$(...', '#foo', '((((foo))))')
endfunction

function! s:test_add_tag() abort
  call s:do_test("ysetdiv\<CR>", '#foo bar baz', '<div>foo</div> bar baz')
  call s:do_test("ysetdiv\<CR>", 'foo #bar baz', 'foo <div>bar</div> baz')
  call s:do_test("ysetdiv\<CR>", 'foo bar #baz', 'foo bar <div>baz</div>')
  call s:do_test("ys$tdiv\<CR>", '#foo bar baz', '<div>foo bar baz</div>')
endfunction

function! s:test_change_block() abort
  call s:do_test('cs({', '#()', '{}')
  call s:do_test('cs({', '(#)', '{}')
  call s:do_test('cs({', '#(foo)', '{foo}')
  call s:do_test('cs({', '(#foo)', '{foo}')
  call s:do_test('cs({', '(foo#)', '{foo}')
  call s:do_test('cs({', '#\(foo\)', '\(foo\)')
  call s:do_test('cs({', '\#(foo\)', '\(foo\)')
  call s:do_test('cs({', '\(foo#\)', '\(foo\)')
  call s:do_test('cs({', '\(foo\#)', '\(foo\)')
  call s:do_test('cs({', '#(\(foo\))', '{\(foo\)}')
  call s:do_test('cs({', '(#\(foo\))', '{\(foo\)}')
  call s:do_test('cs({', '(\#(foo\))', '{\(foo\)}')
  call s:do_test('cs({', '(\(foo#\))', '{\(foo\)}')
  call s:do_test('cs({', '(\(foo\#))', '{\(foo\)}')
  call s:do_test('cs({', '(\(foo\)#)', '{\(foo\)}')
  call s:do_test('cs({', '#\\(foo\\)', '\\(foo\\)')
  call s:do_test('cs({', '\\#(foo\\)', '\\{foo\\}')
  call s:do_test('cs({', '\\(#foo\\)', '\\{foo\\}')
  call s:do_test('cs({', '\\(foo#\\)', '\\{foo\\}')
  call s:do_test('cs({', '\\(foo#\\)', '\\{foo\\}')
  call s:do_test('cs({', '\\(foo\\#)', '\\{foo\\}')
  call s:do_test('cs({', '# ( foo ) ', ' ( foo ) ')
  call s:do_test('cs({', ' #( foo ) ', ' { foo } ')
  call s:do_test('cs({', ' (# foo ) ', ' { foo } ')
  call s:do_test('cs({', ' ( foo #) ', ' { foo } ')
  call s:do_test('cs({', ' ( foo )# ', ' ( foo ) ')
  call s:do_test('cs({', '#(foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('cs({', '(#foo)bar(baz)', '{foo}bar(baz)')
  call s:do_test('cs({', '(foo#)bar(baz)', '{foo}bar(baz)')
  call s:do_test('cs({', '(foo)#bar(baz)', '(foo)bar(baz)')
  call s:do_test('cs({', '(foo)bar#(baz)', '(foo)bar{baz}')
  call s:do_test('cs({', '(foo)bar(#baz)', '(foo)bar{baz}')
  call s:do_test('cs({', '(foo)bar(baz#)', '(foo)bar{baz}')
  call s:do_test('cs({', "#(((foo)\nbar)\nbaz)", "{((foo)\nbar)\nbaz}")
  call s:do_test('cs({', "(#((foo)\nbar)\nbaz)", "({(foo)\nbar}\nbaz)")
  call s:do_test('cs({', "((#(foo)\nbar)\nbaz)", "(({foo}\nbar)\nbaz)")
  call s:do_test('cs({', "(((#foo)\nbar)\nbaz)", "(({foo}\nbar)\nbaz)")
  call s:do_test('cs({', "(((foo#)\nbar)\nbaz)", "(({foo}\nbar)\nbaz)")
  call s:do_test('cs({', "(((foo)\n#bar)\nbaz)", "({(foo)\nbar}\nbaz)")
  call s:do_test('cs({', "(((foo)\nbar#)\nbaz)", "({(foo)\nbar}\nbaz)")
  call s:do_test('cs({', "(((foo)\nbar)\n#baz)", "{((foo)\nbar)\nbaz}")
  call s:do_test('cs({', "(((foo)\nbar)\nbaz#)", "{((foo)\nbar)\nbaz}")

  call s:do_test('cs)}', '#()', '{  }')
  call s:do_test('cs)}', '(#)', '{  }')
  call s:do_test('cs)}', '#(foo)', '{ foo }')
  call s:do_test('cs)}', '(#foo)', '{ foo }')
  call s:do_test('cs)}', '(foo#)', '{ foo }')
  call s:do_test('cs)}', '#(\(foo\))', '{ \(foo\) }')
  call s:do_test('cs)}', '(#\(foo\))', '{ \(foo\) }')
  call s:do_test('cs)}', '(\#(foo\))', '{ \(foo\) }')
  call s:do_test('cs)}', '(\(foo#\))', '{ \(foo\) }')
  call s:do_test('cs)}', '(\(foo\#))', '{ \(foo\) }')
  call s:do_test('cs)}', '(\(foo\)#)', '{ \(foo\) }')
  call s:do_test('cs)}', '#\\(foo\\)', '\\(foo\\)')
  call s:do_test('cs)}', '\\#(foo\\)', '\\{ foo\\ }')
  call s:do_test('cs)}', '\\(#foo\\)', '\\{ foo\\ }')
  call s:do_test('cs)}', '\\(foo#\\)', '\\{ foo\\ }')
  call s:do_test('cs)}', '\\(foo#\\)', '\\{ foo\\ }')
  call s:do_test('cs)}', '\\(foo\\#)', '\\{ foo\\ }')
  call s:do_test('cs)}', '# ( foo ) ', ' ( foo ) ')
  call s:do_test('cs)}', ' #( foo ) ', ' { foo } ')
  call s:do_test('cs)}', ' (# foo ) ', ' { foo } ')
  call s:do_test('cs)}', ' ( foo #) ', ' { foo } ')
  call s:do_test('cs)}', ' ( foo )# ', ' ( foo ) ')
  call s:do_test('cs)}', '#(foo)bar(baz)', '{ foo }bar(baz)')
  call s:do_test('cs)}', '(#foo)bar(baz)', '{ foo }bar(baz)')
  call s:do_test('cs)}', '(foo#)bar(baz)', '{ foo }bar(baz)')
  call s:do_test('cs)}', '(foo)#bar(baz)', '(foo)bar(baz)')
  call s:do_test('cs)}', '(foo)bar#(baz)', '(foo)bar{ baz }')
  call s:do_test('cs)}', '(foo)bar(#baz)', '(foo)bar{ baz }')
  call s:do_test('cs)}', '(foo)bar(baz#)', '(foo)bar{ baz }')
  call s:do_test('cs)}', "#(((foo)\nbar)\nbaz)", "{ ((foo)\nbar)\nbaz }")
  call s:do_test('cs)}', "(#((foo)\nbar)\nbaz)", "({ (foo)\nbar }\nbaz)")
  call s:do_test('cs)}', "((#(foo)\nbar)\nbaz)", "(({ foo }\nbar)\nbaz)")
  call s:do_test('cs)}', "(((#foo)\nbar)\nbaz)", "(({ foo }\nbar)\nbaz)")
  call s:do_test('cs)}', "(((foo#)\nbar)\nbaz)", "(({ foo }\nbar)\nbaz)")
  call s:do_test('cs)}', "(((foo)\n#bar)\nbaz)", "({ (foo)\nbar }\nbaz)")
  call s:do_test('cs)}', "(((foo)\nbar#)\nbaz)", "({ (foo)\nbar }\nbaz)")
  call s:do_test('cs)}', "(((foo)\nbar)\n#baz)", "{ ((foo)\nbar)\nbaz }")
  call s:do_test('cs)}', "(((foo)\nbar)\nbaz#)", "{ ((foo)\nbar)\nbaz }")

  call s:do_test('csjbjB', '#（）', '｛｝')
  call s:do_test('csjbjB', '（#）', '｛｝')
  call s:do_test('csjbjB', '#（foo）', '｛foo｝')
  call s:do_test('csjbjB', '（#foo）', '｛foo｝')
  call s:do_test('csjbjB', '（foo#）', '｛foo｝')
  call s:do_test('csjbjB', '# （ foo ） ', ' （ foo ） ')
  call s:do_test('csjbjB', ' #（ foo ） ', ' ｛ foo ｝ ')
  call s:do_test('csjbjB', ' （# foo ） ', ' ｛ foo ｝ ')
  call s:do_test('csjbjB', ' （ foo #） ', ' ｛ foo ｝ ')
  call s:do_test('csjbjB', ' （ foo ）# ', ' （ foo ） ')
  call s:do_test('csjbjB', '#（foo）bar（baz）', '｛foo｝bar（baz）')
  call s:do_test('csjbjB', '（#foo）bar（baz）', '｛foo｝bar（baz）')
  call s:do_test('csjbjB', '（foo#）bar（baz）', '｛foo｝bar（baz）')
  call s:do_test('csjbjB', '（foo）#bar（baz）', '（foo）bar（baz）')
  call s:do_test('csjbjB', '（foo）bar#（baz）', '（foo）bar｛baz｝')
  call s:do_test('csjbjB', '（foo）bar（#baz）', '（foo）bar｛baz｝')
  call s:do_test('csjbjB', '（foo）bar（baz#）', '（foo）bar｛baz｝')
  call s:do_test('csjbjB', "#（（（foo）\nbar）\nbaz）", "｛（（foo）\nbar）\nbaz｝")
  call s:do_test('csjbjB', "（#（（foo）\nbar）\nbaz）", "（｛（foo）\nbar｝\nbaz）")
  call s:do_test('csjbjB', "（（#（foo）\nbar）\nbaz）", "（（｛foo｝\nbar）\nbaz）")
  call s:do_test('csjbjB', "（（（#foo）\nbar）\nbaz）", "（（｛foo｝\nbar）\nbaz）")
  call s:do_test('csjbjB', "（（（foo#）\nbar）\nbaz）", "（（｛foo｝\nbar）\nbaz）")
  call s:do_test('csjbjB', "（（（foo）\n#bar）\nbaz）", "（｛（foo）\nbar｝\nbaz）")
  call s:do_test('csjbjB', "（（（foo）\nbar#）\nbaz）", "（｛（foo）\nbar｝\nbaz）")
  call s:do_test('csjbjB', "（（（foo）\nbar）\n#baz）", "｛（（foo）\nbar）\nbaz｝")
  call s:do_test('csjbjB', "（（（foo）\nbar）\nbaz#）", "｛（（foo）\nbar）\nbaz｝")
endfunction

function! s:test_change_function_call() abort
  call s:do_test("csffg\<CR>", '#f()', 'g()')
  call s:do_test("csffg\<CR>", 'f#()', 'g()')
  call s:do_test("csffg\<CR>", 'f(#)', 'g()')
  call s:do_test("csffg\<CR>", '#f(foo)', 'g(foo)')
  call s:do_test("csffg\<CR>", 'f#(foo)', 'g(foo)')
  call s:do_test("csffg\<CR>", 'f(#foo)', 'g(foo)')
  call s:do_test("csffg\<CR>", 'f(foo#)', 'g(foo)')
  call s:do_test("csffg\<CR>", '# f( foo ) ', ' f( foo ) ')
  call s:do_test("csffg\<CR>", ' #f( foo ) ', ' g( foo ) ')
  call s:do_test("csffg\<CR>", ' f#( foo ) ', ' g( foo ) ')
  call s:do_test("csffg\<CR>", ' f(# foo ) ', ' g( foo ) ')
  call s:do_test("csffg\<CR>", ' f( foo #) ', ' g( foo ) ')
  call s:do_test("csffg\<CR>", ' f( foo )# ', ' f( foo ) ')
  call s:do_test("csffg\<CR>", '#f(f(f(foo)))', 'g(f(f(foo)))')
  call s:do_test("csffg\<CR>", 'f#(f(f(foo)))', 'g(f(f(foo)))')
  call s:do_test("csffg\<CR>", 'f(#f(f(foo)))', 'f(g(f(foo)))')
  call s:do_test("csffg\<CR>", 'f(f#(f(foo)))', 'f(g(f(foo)))')
  call s:do_test("csffg\<CR>", 'f(f(#f(foo)))', 'f(f(g(foo)))')
  call s:do_test("csffg\<CR>", 'f(f(f#(foo)))', 'f(f(g(foo)))')
  call s:do_test("csffg\<CR>", 'f(f(f(#foo)))', 'f(f(g(foo)))')
  call s:do_test("csffg\<CR>", 'f(f(f(foo#)))', 'f(f(g(foo)))')
  call s:do_test("csffg\<CR>", 'f(f(f(foo)#))', 'f(g(f(foo)))')
  call s:do_test("csffg\<CR>", 'f(f(f(foo))#)', 'g(f(f(foo)))')
endfunction

function! s:test_change_inline() abort
  call s:do_test('cs"(', '#""', '()')
  call s:do_test('cs"(', '"#"', '()')
  call s:do_test('cs"(', '#"foo"', '(foo)')
  call s:do_test('cs"(', '"#foo"', '(foo)')
  call s:do_test('cs"(', '"foo#"', '(foo)')
  call s:do_test('cs"(', '#\"foo\"', '\"foo\"')
  call s:do_test('cs"(', '\#"foo\"', '\"foo\"')
  call s:do_test('cs"(', '\"#foo\"', '\"foo\"')
  call s:do_test('cs"(', '\"foo#\"', '\"foo\"')
  call s:do_test('cs"(', '\"foo\#"', '\"foo\"')
  call s:do_test('cs"(', '#"\"foo\""', '(\"foo\")')
  call s:do_test('cs"(', '"#\"foo\""', '(\"foo\")')
  call s:do_test('cs"(', '"\#"foo\""', '(\"foo\")')
  call s:do_test('cs"(', '"\"foo#\""', '(\"foo\")')
  call s:do_test('cs"(', '"\"foo\#""', '(\"foo\")')
  call s:do_test('cs"(', '"\"foo\"#"', '(\"foo\")')
  call s:do_test('cs"(', '#\\"foo\\"', '\\"foo\\"')
  call s:do_test('cs"(', '\\#"foo\\"', '\\(foo\\)')
  call s:do_test('cs"(', '\\"#foo\\"', '\\(foo\\)')
  call s:do_test('cs"(', '\\"foo#\\"', '\\(foo\\)')
  call s:do_test('cs"(', '\\"foo#\\"', '\\(foo\\)')
  call s:do_test('cs"(', '\\"foo\\#"', '\\(foo\\)')
  call s:do_test('cs"(', '# " foo " ', ' " foo " ')
  call s:do_test('cs"(', ' "# foo " ', ' ( foo ) ')
  call s:do_test('cs"(', ' " foo #" ', ' ( foo ) ')
  call s:do_test('cs"(', ' " foo "# ', ' " foo " ')
  call s:do_test('cs"(', '#"foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('cs"(', '"#foo"bar"baz"', '(foo)bar"baz"')
  call s:do_test('cs"(', '"foo#"bar"baz"', '(foo)bar"baz"')
  call s:do_test('cs"(', '"foo"#bar"baz"', '"foo"bar"baz"')
  call s:do_test('cs"(', '"foo"bar#"baz"', '"foo"bar(baz)')
  call s:do_test('cs"(', '"foo"bar"#baz"', '"foo"bar(baz)')
  call s:do_test('cs"(', '"foo"bar"baz#"', '"foo"bar(baz)')

  call s:do_test('csEe', '#****', '__')
  call s:do_test('csEe', '*#***', '__')
  call s:do_test('csEe', '**#**', '__')
  call s:do_test('csEe', '***#*', '__')
  call s:do_test('csEe', '#**foo**', '_foo_')
  call s:do_test('csEe', '*#*foo**', '_foo_')
  call s:do_test('csEe', '**#foo**', '_foo_')
  call s:do_test('csEe', '**foo#**', '_foo_')
  call s:do_test('csEe', '**foo*#*', '_foo_')
  call s:do_test('csEe', '# ** foo ** ', ' ** foo ** ')
  call s:do_test('csEe', ' #** foo ** ', ' _ foo _ ')
  call s:do_test('csEe', ' *#* foo ** ', ' _ foo _ ')
  call s:do_test('csEe', ' **# foo ** ', ' _ foo _ ')
  call s:do_test('csEe', ' ** foo #** ', ' _ foo _ ')
  call s:do_test('csEe', ' ** foo *#* ', ' _ foo _ ')
  call s:do_test('csEe', ' ** foo **# ', ' ** foo ** ')
  call s:do_test('csEe', '#**foo**bar**baz**', '_foo_bar**baz**')
  call s:do_test('csEe', '*#*foo**bar**baz**', '_foo_bar**baz**')
  call s:do_test('csEe', '**#foo**bar**baz**', '_foo_bar**baz**')
  call s:do_test('csEe', '**foo#**bar**baz**', '_foo_bar**baz**')
  call s:do_test('csEe', '**foo*#*bar**baz**', '_foo_bar**baz**')
  call s:do_test('csEe', '**foo**#bar**baz**', '**foo**bar**baz**')
  call s:do_test('csEe', '**foo**bar#**baz**', '**foo**bar_baz_')
  call s:do_test('csEe', '**foo**bar*#*baz**', '**foo**bar_baz_')
  call s:do_test('csEe', '**foo**bar**baz#**', '**foo**bar_baz_')
  call s:do_test('csEe', '**foo**bar**baz*#*', '**foo**bar_baz_')
endfunction

function! s:test_change_repeat() abort
  if !has('patch-8.0.0548')
    return '"." command does not work inside functions.'
  endif
  call s:do_test('cs({.', '((((#foo))))', '(({{foo}}))')
  call s:do_test('cs({..', '((((#foo))))', '({{{foo}}})')
  call s:do_test('cs({...', '((((#foo))))', '{{{{foo}}}}')
endfunction

function! s:test_change_tag() abort
  call s:do_test("csttp\<CR>", '#<div></div>', '<p></p>')
  call s:do_test("csttp\<CR>", '<div#></div>', '<p></p>')
  call s:do_test("csttp\<CR>", '<div>#</div>', '<p></p>')
  call s:do_test("csttp\<CR>", '<div></div#>', '<p></p>')
  call s:do_test("csttp\<CR>", '#<div>foo</div>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '<div#>foo</div>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '<div>#foo</div>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '<div>foo#</div>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '<div>foo</div#>', '<p>foo</p>')
  call s:do_test("csttp\<CR>", '# <div> foo </div> ', ' <div> foo </div> ')
  call s:do_test("csttp\<CR>", ' #<div> foo </div> ', ' <p> foo </p> ')
  call s:do_test("csttp\<CR>", ' <div#> foo </div> ', ' <p> foo </p> ')
  call s:do_test("csttp\<CR>", ' <div># foo </div> ', ' <p> foo </p> ')
  call s:do_test("csttp\<CR>", ' <div> foo #</div> ', ' <p> foo </p> ')
  call s:do_test("csttp\<CR>", ' <div> foo </div#> ', ' <p> foo </p> ')
  call s:do_test("csttp\<CR>", ' <div> foo </div># ', ' <div> foo </div> ')
  call s:do_test("csttp\<CR>", '#<div>foo</div>bar<div>baz</div>', '<p>foo</p>bar<div>baz</div>')
  call s:do_test("csttp\<CR>", '<div#>foo</div>bar<div>baz</div>', '<p>foo</p>bar<div>baz</div>')
  call s:do_test("csttp\<CR>", '<div>#foo</div>bar<div>baz</div>', '<p>foo</p>bar<div>baz</div>')
  call s:do_test("csttp\<CR>", '<div>foo#</div>bar<div>baz</div>', '<p>foo</p>bar<div>baz</div>')
  call s:do_test("csttp\<CR>", '<div>foo</div#>bar<div>baz</div>', '<p>foo</p>bar<div>baz</div>')
  call s:do_test("csttp\<CR>", '<div>foo</div>#bar<div>baz</div>', '<div>foo</div>bar<div>baz</div>')
  call s:do_test("csttp\<CR>", '<div>foo</div>bar#<div>baz</div>', '<div>foo</div>bar<p>baz</p>')
  call s:do_test("csttp\<CR>", '<div>foo</div>bar<div#>baz</div>', '<div>foo</div>bar<p>baz</p>')
  call s:do_test("csttp\<CR>", '<div>foo</div>bar<div>#baz</div>', '<div>foo</div>bar<p>baz</p>')
  call s:do_test("csttp\<CR>", '<div>foo</div>bar<div>baz#</div>', '<div>foo</div>bar<p>baz</p>')
  call s:do_test("csttp\<CR>", '<div>foo</div>bar<div>baz</div#>', '<div>foo</div>bar<p>baz</p>')
  call s:do_test("csttp\<CR>", "#<div><div><div>foo</div>\nbar</div>\nbaz</div>", "<p><div><div>foo</div>\nbar</div>\nbaz</p>")
  call s:do_test("csttp\<CR>", "<div#><div><div>foo</div>\nbar</div>\nbaz</div>", "<p><div><div>foo</div>\nbar</div>\nbaz</p>")
  call s:do_test("csttp\<CR>", "<div>#<div><div>foo</div>\nbar</div>\nbaz</div>", "<div><p><div>foo</div>\nbar</p>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div#><div>foo</div>\nbar</div>\nbaz</div>", "<div><p><div>foo</div>\nbar</p>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div>#<div>foo</div>\nbar</div>\nbaz</div>", "<div><div><p>foo</p>\nbar</div>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div#>foo</div>\nbar</div>\nbaz</div>", "<div><div><p>foo</p>\nbar</div>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div>#foo</div>\nbar</div>\nbaz</div>", "<div><div><p>foo</p>\nbar</div>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo#</div>\nbar</div>\nbaz</div>", "<div><div><p>foo</p>\nbar</div>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo</div#>\nbar</div>\nbaz</div>", "<div><div><p>foo</p>\nbar</div>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo</div>\n#bar</div>\nbaz</div>", "<div><p><div>foo</div>\nbar</p>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo</div>\nbar#</div>\nbaz</div>", "<div><p><div>foo</div>\nbar</p>\nbaz</div>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo</div>\nbar</div>\n#baz</div>", "<p><div><div>foo</div>\nbar</div>\nbaz</p>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo</div>\nbar</div>\nbaz#</div>", "<p><div><div>foo</div>\nbar</div>\nbaz</p>")
  call s:do_test("csttp\<CR>", "<div><div><div>foo</div>\nbar</div>\nbaz</div#>", "<p><div><div>foo</div>\nbar</div>\nbaz</p>")
endfunction

function! s:test_delete_block() abort
  call s:do_test('ds(', '#()', '')
  call s:do_test('ds(', '(#)', '')
  call s:do_test('ds(', '#(foo)', 'foo')
  call s:do_test('ds(', '(#foo)', 'foo')
  call s:do_test('ds(', '(foo#)', 'foo')
  call s:do_test('ds(', '#\(foo\)', '\(foo\)')
  call s:do_test('ds(', '\#(foo\)', '\(foo\)')
  call s:do_test('ds(', '\(foo#\)', '\(foo\)')
  call s:do_test('ds(', '\(foo\#)', '\(foo\)')
  call s:do_test('ds(', '#(\(foo\))', '\(foo\)')
  call s:do_test('ds(', '(#\(foo\))', '\(foo\)')
  call s:do_test('ds(', '(\#(foo\))', '\(foo\)')
  call s:do_test('ds(', '(\(foo#\))', '\(foo\)')
  call s:do_test('ds(', '(\(foo\#))', '\(foo\)')
  call s:do_test('ds(', '(\(foo\)#)', '\(foo\)')
  call s:do_test('ds(', '#\\(foo\\)', '\\(foo\\)')
  call s:do_test('ds(', '\\#(foo\\)', '\\foo\\')
  call s:do_test('ds(', '\\(#foo\\)', '\\foo\\')
  call s:do_test('ds(', '\\(foo#\\)', '\\foo\\')
  call s:do_test('ds(', '\\(foo#\\)', '\\foo\\')
  call s:do_test('ds(', '\\(foo\\#)', '\\foo\\')
  call s:do_test('ds(', '# ( foo ) ', ' ( foo ) ')
  call s:do_test('ds(', ' #( foo ) ', '  foo  ')
  call s:do_test('ds(', ' (# foo ) ', '  foo  ')
  call s:do_test('ds(', ' ( foo #) ', '  foo  ')
  call s:do_test('ds(', ' ( foo )# ', ' ( foo ) ')
  call s:do_test('ds(', '#(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('ds(', '(#foo)bar(baz)', 'foobar(baz)')
  call s:do_test('ds(', '(foo#)bar(baz)', 'foobar(baz)')
  call s:do_test('ds(', '(foo)#bar(baz)', '(foo)bar(baz)')
  call s:do_test('ds(', '(foo)bar#(baz)', '(foo)barbaz')
  call s:do_test('ds(', '(foo)bar(#baz)', '(foo)barbaz')
  call s:do_test('ds(', '(foo)bar(baz#)', '(foo)barbaz')
  call s:do_test('ds(', "#(((foo)\nbar)\nbaz)", "((foo)\nbar)\nbaz")
  call s:do_test('ds(', "(#((foo)\nbar)\nbaz)", "((foo)\nbar\nbaz)")
  call s:do_test('ds(', "((#(foo)\nbar)\nbaz)", "((foo\nbar)\nbaz)")
  call s:do_test('ds(', "(((#foo)\nbar)\nbaz)", "((foo\nbar)\nbaz)")
  call s:do_test('ds(', "(((foo#)\nbar)\nbaz)", "((foo\nbar)\nbaz)")
  call s:do_test('ds(', "(((foo)\n#bar)\nbaz)", "((foo)\nbar\nbaz)")
  call s:do_test('ds(', "(((foo)\nbar#)\nbaz)", "((foo)\nbar\nbaz)")
  call s:do_test('ds(', "(((foo)\nbar)\n#baz)", "((foo)\nbar)\nbaz")
  call s:do_test('ds(', "(((foo)\nbar)\nbaz#)", "((foo)\nbar)\nbaz")

  call s:do_test('ds)', '#()', '')
  call s:do_test('ds)', '(#)', '')
  call s:do_test('ds)', '#(foo)', 'foo')
  call s:do_test('ds)', '(#foo)', 'foo')
  call s:do_test('ds)', '(foo#)', 'foo')
  call s:do_test('ds)', '#\(foo\)', '\(foo\)')
  call s:do_test('ds)', '\#(foo\)', '\(foo\)')
  call s:do_test('ds)', '\(foo#\)', '\(foo\)')
  call s:do_test('ds)', '\(foo\#)', '\(foo\)')
  call s:do_test('ds)', '#(\(foo\))', '\(foo\)')
  call s:do_test('ds)', '(#\(foo\))', '\(foo\)')
  call s:do_test('ds)', '(\#(foo\))', '\(foo\)')
  call s:do_test('ds)', '(\(foo#\))', '\(foo\)')
  call s:do_test('ds)', '(\(foo\#))', '\(foo\)')
  call s:do_test('ds)', '(\(foo\)#)', '\(foo\)')
  call s:do_test('ds)', '#\\(foo\\)', '\\(foo\\)')
  call s:do_test('ds)', '\\#(foo\\)', '\\foo\\')
  call s:do_test('ds)', '\\(#foo\\)', '\\foo\\')
  call s:do_test('ds)', '\\(foo#\\)', '\\foo\\')
  call s:do_test('ds)', '\\(foo#\\)', '\\foo\\')
  call s:do_test('ds)', '\\(foo\\#)', '\\foo\\')
  call s:do_test('ds)', '# ( foo ) ', ' ( foo ) ')
  call s:do_test('ds)', ' #( foo ) ', ' foo ')
  call s:do_test('ds)', ' (# foo ) ', ' foo ')
  call s:do_test('ds)', ' ( foo #) ', ' foo ')
  call s:do_test('ds)', ' ( foo )# ', ' ( foo ) ')
  call s:do_test('ds)', '#(foo)bar(baz)', 'foobar(baz)')
  call s:do_test('ds)', '(#foo)bar(baz)', 'foobar(baz)')
  call s:do_test('ds)', '(foo#)bar(baz)', 'foobar(baz)')
  call s:do_test('ds)', '(foo)#bar(baz)', '(foo)bar(baz)')
  call s:do_test('ds)', '(foo)bar#(baz)', '(foo)barbaz')
  call s:do_test('ds)', '(foo)bar(#baz)', '(foo)barbaz')
  call s:do_test('ds)', '(foo)bar(baz#)', '(foo)barbaz')
  call s:do_test('ds)', "#(((foo)\nbar)\nbaz)", "((foo)\nbar)\nbaz")
  call s:do_test('ds)', "(#((foo)\nbar)\nbaz)", "((foo)\nbar\nbaz)")
  call s:do_test('ds)', "((#(foo)\nbar)\nbaz)", "((foo\nbar)\nbaz)")
  call s:do_test('ds)', "(((#foo)\nbar)\nbaz)", "((foo\nbar)\nbaz)")
  call s:do_test('ds)', "(((foo#)\nbar)\nbaz)", "((foo\nbar)\nbaz)")
  call s:do_test('ds)', "(((foo)\n#bar)\nbaz)", "((foo)\nbar\nbaz)")
  call s:do_test('ds)', "(((foo)\nbar#)\nbaz)", "((foo)\nbar\nbaz)")
  call s:do_test('ds)', "(((foo)\nbar)\n#baz)", "((foo)\nbar)\nbaz")
  call s:do_test('ds)', "(((foo)\nbar)\nbaz#)", "((foo)\nbar)\nbaz")

  call s:do_test('dsjb', '#（）', '')
  call s:do_test('dsjb', '（#）', '')
  call s:do_test('dsjb', '#（foo）', 'foo')
  call s:do_test('dsjb', '（#foo）', 'foo')
  call s:do_test('dsjb', '（foo#）', 'foo')
  call s:do_test('dsjb', '# （ foo ） ', ' （ foo ） ')
  call s:do_test('dsjb', ' #（ foo ） ', '  foo  ')
  call s:do_test('dsjb', ' （# foo ） ', '  foo  ')
  call s:do_test('dsjb', ' （ foo #） ', '  foo  ')
  call s:do_test('dsjb', ' （ foo ）# ', ' （ foo ） ')
  call s:do_test('dsjb', '#（foo）bar（baz）', 'foobar（baz）')
  call s:do_test('dsjb', '（#foo）bar（baz）', 'foobar（baz）')
  call s:do_test('dsjb', '（foo#）bar（baz）', 'foobar（baz）')
  call s:do_test('dsjb', '（foo）#bar（baz）', '（foo）bar（baz）')
  call s:do_test('dsjb', '（foo）bar#（baz）', '（foo）barbaz')
  call s:do_test('dsjb', '（foo）bar（#baz）', '（foo）barbaz')
  call s:do_test('dsjb', '（foo）bar（baz#）', '（foo）barbaz')
  call s:do_test('dsjb', "#（（（foo）\nbar）\nbaz）", "（（foo）\nbar）\nbaz")
  call s:do_test('dsjb', "（#（（foo）\nbar）\nbaz）", "（（foo）\nbar\nbaz）")
  call s:do_test('dsjb', "（（#（foo）\nbar）\nbaz）", "（（foo\nbar）\nbaz）")
  call s:do_test('dsjb', "（（（#foo）\nbar）\nbaz）", "（（foo\nbar）\nbaz）")
  call s:do_test('dsjb', "（（（foo#）\nbar）\nbaz）", "（（foo\nbar）\nbaz）")
  call s:do_test('dsjb', "（（（foo）\n#bar）\nbaz）", "（（foo）\nbar\nbaz）")
  call s:do_test('dsjb', "（（（foo）\nbar#）\nbaz）", "（（foo）\nbar\nbaz）")
  call s:do_test('dsjb', "（（（foo）\nbar）\n#baz）", "（（foo）\nbar）\nbaz")
  call s:do_test('dsjb', "（（（foo）\nbar）\nbaz#）", "（（foo）\nbar）\nbaz")
endfunction

function! s:test_delete_function_call() abort
  call s:do_test('dsf', '#f()', '')
  call s:do_test('dsf', 'f#()', '')
  call s:do_test('dsf', 'f(#)', '')
  call s:do_test('dsf', '#f(foo)', 'foo')
  call s:do_test('dsf', 'f#(foo)', 'foo')
  call s:do_test('dsf', 'f(#foo)', 'foo')
  call s:do_test('dsf', 'f(foo#)', 'foo')
  call s:do_test('dsf', '# f( foo ) ', ' f( foo ) ')
  call s:do_test('dsf', ' #f( foo ) ', '  foo  ')
  call s:do_test('dsf', ' f#( foo ) ', '  foo  ')
  call s:do_test('dsf', ' f(# foo ) ', '  foo  ')
  call s:do_test('dsf', ' f( foo #) ', '  foo  ')
  call s:do_test('dsf', ' f( foo )# ', ' f( foo ) ')
  call s:do_test('dsf', '#f(f(f(foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f#(f(f(foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(#f(f(foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f#(f(foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f(#f(foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f(f#(foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f(f(#foo)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f(f(foo#)))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f(f(foo)#))', 'f(f(foo))')
  call s:do_test('dsf', 'f(f(f(foo))#)', 'f(f(foo))')
endfunction

function! s:test_delete_inline() abort
  call s:do_test('ds"', '#""', '')
  call s:do_test('ds"', '"#"', '')
  call s:do_test('ds"', '#"foo"', 'foo')
  call s:do_test('ds"', '"#foo"', 'foo')
  call s:do_test('ds"', '"foo#"', 'foo')
  call s:do_test('ds"', '#\"foo\"', '\"foo\"')
  call s:do_test('ds"', '\#"foo\"', '\"foo\"')
  call s:do_test('ds"', '\"foo#\"', '\"foo\"')
  call s:do_test('ds"', '\"foo\#"', '\"foo\"')
  call s:do_test('ds"', '#"\"foo\""', '\"foo\"')
  call s:do_test('ds"', '"#\"foo\""', '\"foo\"')
  call s:do_test('ds"', '"\#"foo\""', '\"foo\"')
  call s:do_test('ds"', '"\"foo#\""', '\"foo\"')
  call s:do_test('ds"', '"\"foo\#""', '\"foo\"')
  call s:do_test('ds"', '"\"foo\"#"', '\"foo\"')
  call s:do_test('ds"', '#\\"foo\\"', '\\"foo\\"')
  call s:do_test('ds"', '\\#"foo\\"', '\\foo\\')
  call s:do_test('ds"', '\\"#foo\\"', '\\foo\\')
  call s:do_test('ds"', '\\"foo#\\"', '\\foo\\')
  call s:do_test('ds"', '\\"foo#\\"', '\\foo\\')
  call s:do_test('ds"', '\\"foo\\#"', '\\foo\\')
  call s:do_test('ds"', '# " foo " ', ' " foo " ')
  call s:do_test('ds"', ' #" foo " ', '  foo  ')
  call s:do_test('ds"', ' "# foo " ', '  foo  ')
  call s:do_test('ds"', ' " foo #" ', '  foo  ')
  call s:do_test('ds"', ' " foo "# ', ' " foo " ')
  call s:do_test('ds"', '#"foo"bar"baz"', 'foobar"baz"')
  call s:do_test('ds"', '"#foo"bar"baz"', 'foobar"baz"')
  call s:do_test('ds"', '"foo#"bar"baz"', 'foobar"baz"')
  call s:do_test('ds"', '"foo"#bar"baz"', '"foo"bar"baz"')
  call s:do_test('ds"', '"foo"bar#"baz"', '"foo"barbaz')
  call s:do_test('ds"', '"foo"bar"#baz"', '"foo"barbaz')
  call s:do_test('ds"', '"foo"bar"baz#"', '"foo"barbaz')

  call s:do_test('dsE', '#****', '')
  call s:do_test('dsE', '*#***', '')
  call s:do_test('dsE', '**#**', '')
  call s:do_test('dsE', '***#*', '')
  call s:do_test('dsE', '#**foo**', 'foo')
  call s:do_test('dsE', '*#*foo**', 'foo')
  call s:do_test('dsE', '**#foo**', 'foo')
  call s:do_test('dsE', '**foo#**', 'foo')
  call s:do_test('dsE', '**foo*#*', 'foo')
  call s:do_test('dsE', '# ** foo ** ', ' ** foo ** ')
  call s:do_test('dsE', ' #** foo ** ', '  foo  ')
  call s:do_test('dsE', ' *#* foo ** ', '  foo  ')
  call s:do_test('dsE', ' **# foo ** ', '  foo  ')
  call s:do_test('dsE', ' ** foo #** ', '  foo  ')
  call s:do_test('dsE', ' ** foo *#* ', '  foo  ')
  call s:do_test('dsE', ' ** foo **# ', ' ** foo ** ')
  call s:do_test('dsE', '#**foo**bar**baz**', 'foobar**baz**')
  call s:do_test('dsE', '*#*foo**bar**baz**', 'foobar**baz**')
  call s:do_test('dsE', '**#foo**bar**baz**', 'foobar**baz**')
  call s:do_test('dsE', '**foo#**bar**baz**', 'foobar**baz**')
  call s:do_test('dsE', '**foo*#*bar**baz**', 'foobar**baz**')
  call s:do_test('dsE', '**foo**#bar**baz**', '**foo**bar**baz**')
  call s:do_test('dsE', '**foo**bar#**baz**', '**foo**barbaz')
  call s:do_test('dsE', '**foo**bar*#*baz**', '**foo**barbaz')
  call s:do_test('dsE', '**foo**bar**baz#**', '**foo**barbaz')
  call s:do_test('dsE', '**foo**bar**baz*#*', '**foo**barbaz')
endfunction

function! s:test_delete_repeat() abort
  if !has('patch-8.0.0548')
    return '"." command does not work inside functions.'
  endif
  call s:do_test('ds(.', '((((#foo))))', '((foo))')
  call s:do_test('ds(..', '((((#foo))))', '(foo)')
  call s:do_test('ds(...', '((((#foo))))', 'foo')
endfunction

function! s:test_delete_tag() abort
  call s:do_test('dst', '#<div></div>', '')
  call s:do_test('dst', '<div#></div>', '')
  call s:do_test('dst', '<div>#</div>', '')
  call s:do_test('dst', '<div></div#>', '')
  call s:do_test('dst', '#<div>foo</div>', 'foo')
  call s:do_test('dst', '<div#>foo</div>', 'foo')
  call s:do_test('dst', '<div>#foo</div>', 'foo')
  call s:do_test('dst', '<div>foo#</div>', 'foo')
  call s:do_test('dst', '<div>foo</div#>', 'foo')
  call s:do_test('dst', '# <div> foo </div> ', ' <div> foo </div> ')
  call s:do_test('dst', ' #<div> foo </div> ', '  foo  ')
  call s:do_test('dst', ' <div#> foo </div> ', '  foo  ')
  call s:do_test('dst', ' <div># foo </div> ', '  foo  ')
  call s:do_test('dst', ' <div> foo #</div> ', '  foo  ')
  call s:do_test('dst', ' <div> foo </div#> ', '  foo  ')
  call s:do_test('dst', ' <div> foo </div># ', ' <div> foo </div> ')
  call s:do_test('dst', '#<div>foo</div>bar<div>baz</div>', 'foobar<div>baz</div>')
  call s:do_test('dst', '<div#>foo</div>bar<div>baz</div>', 'foobar<div>baz</div>')
  call s:do_test('dst', '<div>#foo</div>bar<div>baz</div>', 'foobar<div>baz</div>')
  call s:do_test('dst', '<div>foo#</div>bar<div>baz</div>', 'foobar<div>baz</div>')
  call s:do_test('dst', '<div>foo</div#>bar<div>baz</div>', 'foobar<div>baz</div>')
  call s:do_test('dst', '<div>foo</div>#bar<div>baz</div>', '<div>foo</div>bar<div>baz</div>')
  call s:do_test('dst', '<div>foo</div>bar#<div>baz</div>', '<div>foo</div>barbaz')
  call s:do_test('dst', '<div>foo</div>bar<div#>baz</div>', '<div>foo</div>barbaz')
  call s:do_test('dst', '<div>foo</div>bar<div>#baz</div>', '<div>foo</div>barbaz')
  call s:do_test('dst', '<div>foo</div>bar<div>baz#</div>', '<div>foo</div>barbaz')
  call s:do_test('dst', '<div>foo</div>bar<div>baz</div#>', '<div>foo</div>barbaz')
  call s:do_test('dst', "#<div><div><div>foo</div>\nbar</div>\nbaz</div>", "<div><div>foo</div>\nbar</div>\nbaz")
  call s:do_test('dst', "<div#><div><div>foo</div>\nbar</div>\nbaz</div>", "<div><div>foo</div>\nbar</div>\nbaz")
  call s:do_test('dst', "<div>#<div><div>foo</div>\nbar</div>\nbaz</div>", "<div><div>foo</div>\nbar\nbaz</div>")
  call s:do_test('dst', "<div><div#><div>foo</div>\nbar</div>\nbaz</div>", "<div><div>foo</div>\nbar\nbaz</div>")
  call s:do_test('dst', "<div><div>#<div>foo</div>\nbar</div>\nbaz</div>", "<div><div>foo\nbar</div>\nbaz</div>")
  call s:do_test('dst', "<div><div><div#>foo</div>\nbar</div>\nbaz</div>", "<div><div>foo\nbar</div>\nbaz</div>")
  call s:do_test('dst', "<div><div><div>#foo</div>\nbar</div>\nbaz</div>", "<div><div>foo\nbar</div>\nbaz</div>")
  call s:do_test('dst', "<div><div><div>foo#</div>\nbar</div>\nbaz</div>", "<div><div>foo\nbar</div>\nbaz</div>")
  call s:do_test('dst', "<div><div><div>foo</div#>\nbar</div>\nbaz</div>", "<div><div>foo\nbar</div>\nbaz</div>")
  call s:do_test('dst', "<div><div><div>foo</div>\n#bar</div>\nbaz</div>", "<div><div>foo</div>\nbar\nbaz</div>")
  call s:do_test('dst', "<div><div><div>foo</div>\nbar#</div>\nbaz</div>", "<div><div>foo</div>\nbar\nbaz</div>")
  call s:do_test('dst', "<div><div><div>foo</div>\nbar</div>\n#baz</div>", "<div><div>foo</div>\nbar</div>\nbaz")
  call s:do_test('dst', "<div><div><div>foo</div>\nbar</div>\nbaz#</div>", "<div><div>foo</div>\nbar</div>\nbaz")
  call s:do_test('dst', "<div><div><div>foo</div>\nbar</div>\nbaz</div#>", "<div><div>foo</div>\nbar</div>\nbaz")
endfunction

function! s:test_local_object() abort
  call s:do_test("ysef", '#foo', 'function() { foo }', function('s:setup_local_object'))
  call s:do_test('cs(f', '#(foo)', 'function() { foo }', function('s:setup_local_object'))
  call s:do_test('csf(', '#function() { foo }', '(foo)', function('s:setup_local_object'))
  call s:do_test("dsf", '#function() { foo }', 'foo', function('s:setup_local_object'))
endfunction

function! s:test_textobj_block_a() abort
  call s:do_test("d\<Plug>(surround-obj-a:b)", '# ( foo ) ', ' ( foo ) ')
  call s:do_test("d\<Plug>(surround-obj-a:b)", ' #( foo ) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:b)", ' (# foo ) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:b)", ' ( foo #) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:b)", ' ( foo )# ', ' ( foo ) ')
endfunction

function! s:test_textobj_block_i() abort
  call s:do_test("d\<Plug>(surround-obj-i:b)", '# ( foo ) ', ' ( foo ) ')
  call s:do_test("d\<Plug>(surround-obj-i:b)", ' #( foo ) ', ' () ')
  call s:do_test("d\<Plug>(surround-obj-i:b)", ' (# foo ) ', ' () ')
  call s:do_test("d\<Plug>(surround-obj-i:b)", ' ( foo #) ', ' () ')
  call s:do_test("d\<Plug>(surround-obj-i:b)", ' ( foo )# ', ' ( foo ) ')
endfunction

function! s:test_textobj_function_call_a() abort
  call s:do_test("d\<Plug>(surround-obj-a:f)", '# foo(bar) ', ' foo(bar) ')
  call s:do_test("d\<Plug>(surround-obj-a:f)", ' #foo(bar) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:f)", ' foo#(bar) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:f)", ' foo(#bar) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:f)", ' foo(bar#) ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:f)", ' foo(bar)# ', ' foo(bar) ')
endfunction

function! s:test_textobj_function_call_i() abort
  call s:do_test("d\<Plug>(surround-obj-i:f)", '# foo(bar) ', ' foo(bar) ')
  call s:do_test("d\<Plug>(surround-obj-i:f)", ' #foo(bar) ', ' foo() ')
  call s:do_test("d\<Plug>(surround-obj-i:f)", ' foo#(bar) ', ' foo() ')
  call s:do_test("d\<Plug>(surround-obj-i:f)", ' foo(#bar) ', ' foo() ')
  call s:do_test("d\<Plug>(surround-obj-i:f)", ' foo(bar#) ', ' foo() ')
  call s:do_test("d\<Plug>(surround-obj-i:f)", ' foo(bar)# ', ' foo(bar) ')
endfunction

function! s:test_textobj_inline_a() abort
  call s:do_test("d\<Plug>(surround-obj-a:\")", '# " foo " ', ' " foo " ')
  call s:do_test("d\<Plug>(surround-obj-a:\")", ' #" foo " ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:\")", ' "# foo " ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:\")", ' " foo #" ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:\")", ' " foo "# ', ' " foo " ')
endfunction

function! s:test_textobj_inline_i() abort
  call s:do_test("d\<Plug>(surround-obj-i:\")", '# " foo " ', ' " foo " ')
  call s:do_test("d\<Plug>(surround-obj-i:\")", ' #" foo " ', ' "" ')
  call s:do_test("d\<Plug>(surround-obj-i:\")", ' "# foo " ', ' "" ')
  call s:do_test("d\<Plug>(surround-obj-i:\")", ' " foo #" ', ' "" ')
  call s:do_test("d\<Plug>(surround-obj-i:\")", ' " foo "# ', ' " foo " ')
endfunction

function! s:test_textobj_tag_a() abort
  call s:do_test("d\<Plug>(surround-obj-a:t)", '# <div> foo </div> ', ' <div> foo </div> ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' #<div> foo </div> ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' <div#> foo </div> ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' <div># foo </div> ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' <div> foo #</div> ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' <div> foo </div#> ', '  ')
  call s:do_test("d\<Plug>(surround-obj-a:t)", ' <div> foo </div># ', ' <div> foo </div> ')
endfunction

function! s:test_textobj_tag_i() abort
  call s:do_test("d\<Plug>(surround-obj-i:t)", '# <div> foo </div> ', ' <div> foo </div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' #<div> foo </div> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' <div#> foo </div> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' <div># foo </div> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' <div> foo #</div> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' <div> foo </div#> ', ' <div></div> ')
  call s:do_test("d\<Plug>(surround-obj-i:t)", ' <div> foo </div># ', ' <div> foo </div> ')
endfunction

function! s:do_test(key_sequence, source, expected_result, ...) abort
  new
  try 
    map <buffer> ys  <Plug>(surround-obj-add)
    nmap <buffer> cs  <Plug>(surround-obj-change)
    nmap <buffer> ds  <Plug>(surround-obj-delete)
    if a:0 > 0
      call a:1()
    endif
    silent put =a:source
    normal! ggdd0
    if search('#', 'Wc') isnot 0
      normal! x
    endif
    0verbose call feedkeys(a:key_sequence, 'x')
    call assert_equal(a:expected_result, join(getline(1, line('$')), "\n"))
  finally
    close!
  endtry
endfunction

function! s:setup_local_object() abort
  call surround_obj#define_local_object('f', {
  \   'type': 'block',
  \   'delimiter': ['function() { ', ' }'],
  \   'pattern': ['\<function\s*(\s*)\s*{\s*', '\s*}'],
  \ })
endfunction
