" Tests for expressions.

func Test_equal()
  let base = {}
  func base.method()
    return 1
  endfunc
  func base.other() dict
    return 1
  endfunc
  let instance = copy(base)
  call assert_true(base.method == instance.method)
  call assert_true([base.method] == [instance.method])
  call assert_true(base.other == instance.other)
  call assert_true([base.other] == [instance.other])

  call assert_false(base.method == base.other)
  call assert_false([base.method] == [base.other])
  call assert_false(base.method == instance.other)
  call assert_false([base.method] == [instance.other])

  call assert_fails('echo base.method > instance.method')
endfunc

func Test_version()
  call assert_true(has('patch-7.4.001'))
  call assert_true(has('patch-7.4.01'))
  call assert_true(has('patch-7.4.1'))
  call assert_true(has('patch-6.9.999'))
  call assert_true(has('patch-7.1.999'))
  call assert_true(has('patch-7.4.123'))

  call assert_false(has('patch-7'))
  call assert_false(has('patch-7.4'))
  call assert_false(has('patch-7.4.'))
  call assert_false(has('patch-9.1.0'))
  call assert_false(has('patch-9.9.1'))
endfunc

func Test_dict()
  let d = {'': 'empty', 'a': 'a', 0: 'zero'}
  call assert_equal('empty', d[''])
  call assert_equal('a', d['a'])
  call assert_equal('zero', d[0])
  call assert_true(has_key(d, ''))
  call assert_true(has_key(d, 'a'))

  let d[''] = 'none'
  let d['a'] = 'aaa'
  call assert_equal('none', d[''])
  call assert_equal('aaa', d['a'])

  let d[ 'b' ] = 'bbb'
  call assert_equal('bbb', d[ 'b' ])
endfunc

func Test_strgetchar()
  call assert_equal(char2nr('a'), strgetchar('axb', 0))
  call assert_equal(char2nr('x'), 'axb'->strgetchar(1))
  call assert_equal(char2nr('b'), strgetchar('axb', 2))

  call assert_equal(-1, strgetchar('axb', -1))
  call assert_equal(-1, strgetchar('axb', 3))
  call assert_equal(-1, strgetchar('', 0))
endfunc

func Test_strcharpart()
  call assert_equal('a', strcharpart('axb', 0, 1))
  call assert_equal('x', 'axb'->strcharpart(1, 1))
  call assert_equal('b', strcharpart('axb', 2, 1))
  call assert_equal('xb', strcharpart('axb', 1))

  call assert_equal('', strcharpart('axb', 1, 0))
  call assert_equal('', strcharpart('axb', 1, -1))
  call assert_equal('', strcharpart('axb', -1, 1))
  call assert_equal('', strcharpart('axb', -2, 2))

  call assert_equal('a', strcharpart('axb', -1, 2))
endfunc

func Test_loop_over_null_list()
  let null_list = submatch(1, 1)
  for i in null_list
    call assert_report('should not get here')
  endfor
endfunc

func Test_compare_null_dict()
  call assert_fails('let x = v:_null_dict[10]')
  call assert_equal({}, {})
  call assert_equal(v:_null_dict, v:_null_dict)
  call assert_notequal({}, v:_null_dict)
endfunc

func Test_set_reg_null_list()
  call setreg('x', v:_null_list)
endfunc

func Test_special_char()
  " The failure is only visible using valgrind.
  call assert_fails('echo "\<C-">')
endfunc

func Test_option_value()
  " boolean
  set bri
  call assert_equal(1, &bri)
  set nobri
  call assert_equal(0, &bri)

  " number
  set ts=1
  call assert_equal(1, &ts)
  set ts=8
  call assert_equal(8, &ts)

  " string
  exe "set cedit=\<Esc>"
  call assert_equal("\<Esc>", &cedit)
  set cpo=
  call assert_equal("", &cpo)
  set cpo=abcdefi
  call assert_equal("abcdefi", &cpo)
  set cpo&vim
endfunc

function Test_printf_64bit()
  call assert_equal("123456789012345", printf('%d', 123456789012345))
endfunc

function Test_printf_spec_s()
  " number
  call assert_equal("1234567890", printf('%s', 1234567890))

  " string
  call assert_equal("abcdefgi", printf('%s', "abcdefgi"))

  " float
  call assert_equal("1.23", printf('%s', 1.23))

  " list
  let value = [1, 'two', ['three', 4]]
  call assert_equal(string(value), printf('%s', value))

  " dict
  let value = {'key1' : 'value1', 'key2' : ['list', 'value'], 'key3' : {'dict' : 'value'}}
  call assert_equal(string(value), printf('%s', value))

  " funcref
  call assert_equal('printf', printf('%s', 'printf'->function()))

  " partial
  call assert_equal(string(function('printf', ['%s'])), printf('%s', function('printf', ['%s'])))
endfunc

function Test_printf_spec_b()
  call assert_equal("0", printf('%b', 0))
  call assert_equal("00001100", printf('%08b', 12))
  call assert_equal("11111111", printf('%08b', 0xff))
  call assert_equal("   1111011", printf('%10b', 123))
  call assert_equal("0001111011", printf('%010b', 123))
  call assert_equal(" 0b1111011", printf('%#10b', 123))
  call assert_equal("0B01111011", printf('%#010B', 123))
  call assert_equal("1001001100101100000001011010010", printf('%b', 1234567890))
  call assert_equal("11100000100100010000110000011011101111101111001", printf('%b', 123456789012345))
  call assert_equal("1111111111111111111111111111111111111111111111111111111111111111", printf('%b', -1))
endfunc

function Test_printf_misc()
  call assert_equal('123', printf('123'))
  call assert_fails("call printf('123', 3)", "E767:")

  call assert_equal('123', printf('%d', 123))
  call assert_equal('123', printf('%i', 123))
  call assert_equal('123', printf('%D', 123))
  call assert_equal('123', printf('%U', 123))
  call assert_equal('173', printf('%o', 123))
  call assert_equal('173', printf('%O', 123))
  call assert_equal('7b', printf('%x', 123))
  call assert_equal('7B', printf('%X', 123))

  call assert_equal('123', printf('%hd', 123))
  call assert_equal('-123', printf('%hd', -123))
  call assert_equal('-1', printf('%hd', 0xFFFF))
  call assert_equal('-1', printf('%hd', 0x1FFFFF))

  call assert_equal('123', printf('%hu', 123))
  call assert_equal('65413', printf('%hu', -123))
  call assert_equal('65535', printf('%hu', 0xFFFF))
  call assert_equal('65535', printf('%hu', 0x1FFFFF))

  call assert_equal('123', printf('%ld', 123))
  call assert_equal('-123', printf('%ld', -123))
  call assert_equal('65535', printf('%ld', 0xFFFF))
  call assert_equal('131071', printf('%ld', 0x1FFFF))

  call assert_equal('{', printf('%c', 123))
  call assert_equal('abc', printf('%s', 'abc'))
  call assert_equal('abc', printf('%S', 'abc'))

  call assert_equal('+123', printf('%+d', 123))
  call assert_equal('-123', printf('%+d', -123))
  call assert_equal('+123', printf('%+ d', 123))
  call assert_equal(' 123', printf('% d', 123))
  call assert_equal(' 123', printf('%  d', 123))
  call assert_equal('-123', printf('% d', -123))

  call assert_equal('123', printf('%2d', 123))
  call assert_equal('   123', printf('%6d', 123))
  call assert_equal('000123', printf('%06d', 123))
  call assert_equal('+00123', printf('%+06d', 123))
  call assert_equal(' 00123', printf('% 06d', 123))
  call assert_equal('  +123', printf('%+6d', 123))
  call assert_equal('   123', printf('% 6d', 123))
  call assert_equal('  -123', printf('% 6d', -123))

  " Test left adjusted.
  call assert_equal('123   ', printf('%-6d', 123))
  call assert_equal('+123  ', printf('%-+6d', 123))
  call assert_equal(' 123  ', printf('%- 6d', 123))
  call assert_equal('-123  ', printf('%- 6d', -123))

  call assert_equal('  00123', printf('%7.5d', 123))
  call assert_equal(' -00123', printf('%7.5d', -123))
  call assert_equal(' +00123', printf('%+7.5d', 123))
  " Precision field should not be used when combined with %0
  call assert_equal('  00123', printf('%07.5d', 123))
  call assert_equal(' -00123', printf('%07.5d', -123))

  call assert_equal('  123', printf('%*d', 5, 123))
  call assert_equal('123  ', printf('%*d', -5, 123))
  call assert_equal('00123', printf('%.*d', 5, 123))
  call assert_equal('  123', printf('% *d', 5, 123))
  call assert_equal(' +123', printf('%+ *d', 5, 123))

  call assert_equal('foobar', printf('%.*s',  9, 'foobar'))
  call assert_equal('foo',    printf('%.*s',  3, 'foobar'))
  call assert_equal('',       printf('%.*s',  0, 'foobar'))
  call assert_equal('foobar', printf('%.*s', -1, 'foobar'))

  " Simple quote (thousand grouping char) is ignored.
  call assert_equal('+00123456', printf("%+'09d", 123456))

  " Unrecognized format specifier kept as-is.
  call assert_equal('_123', printf("%_%d", 123))

  " Test alternate forms.
  call assert_equal('0x7b', printf('%#x', 123))
  call assert_equal('0X7B', printf('%#X', 123))
  call assert_equal('0173', printf('%#o', 123))
  call assert_equal('0173', printf('%#O', 123))
  call assert_equal('abc', printf('%#s', 'abc'))
  call assert_equal('abc', printf('%#S', 'abc'))
  call assert_equal('  0173', printf('%#6o', 123))
  call assert_equal(' 00173', printf('%#6.5o', 123))
  call assert_equal('  0173', printf('%#6.2o', 123))
  call assert_equal('  0173', printf('%#6.2o', 123))
  call assert_equal('0173', printf('%#2.2o', 123))

  call assert_equal(' 00123', printf('%6.5d', 123))
  call assert_equal(' 0007b', printf('%6.5x', 123))

  call assert_equal('123', printf('%.2d', 123))
  call assert_equal('0123', printf('%.4d', 123))
  call assert_equal('0000000123', printf('%.10d', 123))
  call assert_equal('123', printf('%.0d', 123))

  call assert_equal('abc', printf('%2s', 'abc'))
  call assert_equal('abc', printf('%2S', 'abc'))
  call assert_equal('abc', printf('%.4s', 'abc'))
  call assert_equal('abc', printf('%.4S', 'abc'))
  call assert_equal('ab', printf('%.2s', 'abc'))
  call assert_equal('ab', printf('%.2S', 'abc'))
  call assert_equal('', printf('%.0s', 'abc'))
  call assert_equal('', printf('%.s', 'abc'))
  call assert_equal(' abc', printf('%4s', 'abc'))
  call assert_equal(' abc', printf('%4S', 'abc'))
  call assert_equal('0abc', printf('%04s', 'abc'))
  call assert_equal('0abc', printf('%04S', 'abc'))
  call assert_equal('abc ', printf('%-4s', 'abc'))
  call assert_equal('abc ', printf('%-4S', 'abc'))

  call assert_equal('🐍', printf('%.2S', '🐍🐍'))
  call assert_equal('', printf('%.1S', '🐍🐍'))

  call assert_equal('1%', printf('%d%%', 1))
endfunc

function Test_printf_float()
  call assert_equal('1.000000', printf('%f', 1))
  call assert_equal('1.230000', printf('%f', 1.23))
  call assert_equal('1.230000', printf('%F', 1.23))
  call assert_equal('9999999.9', printf('%g', 9999999.9))
  call assert_equal('9999999.9', printf('%G', 9999999.9))
  call assert_equal('1.00000001e7', printf('%.8g', 10000000.1))
  call assert_equal('1.00000001E7', printf('%.8G', 10000000.1))
  call assert_equal('1.230000e+00', printf('%e', 1.23))
  call assert_equal('1.230000E+00', printf('%E', 1.23))
  call assert_equal('1.200000e-02', printf('%e', 0.012))
  call assert_equal('-1.200000e-02', printf('%e', -0.012))
  call assert_equal('0.33', printf('%.2f', 1.0/3.0))
  call assert_equal('  0.33', printf('%6.2f', 1.0/3.0))
  call assert_equal(' -0.33', printf('%6.2f', -1.0/3.0))
  call assert_equal('000.33', printf('%06.2f', 1.0/3.0))
  call assert_equal('-00.33', printf('%06.2f', -1.0/3.0))
  call assert_equal('-00.33', printf('%+06.2f', -1.0/3.0))
  call assert_equal('+00.33', printf('%+06.2f', 1.0/3.0))
  call assert_equal(' 00.33', printf('% 06.2f', 1.0/3.0))
  call assert_equal('000.33', printf('%06.2g', 1.0/3.0))
  call assert_equal('-00.33', printf('%06.2g', -1.0/3.0))
  call assert_equal('0.33', printf('%3.2f', 1.0/3.0))
  call assert_equal('003.33e-01', printf('%010.2e', 1.0/3.0))
  call assert_equal(' 03.33e-01', printf('% 010.2e', 1.0/3.0))
  call assert_equal('+03.33e-01', printf('%+010.2e', 1.0/3.0))
  call assert_equal('-03.33e-01', printf('%010.2e', -1.0/3.0))

  " When precision is 0, the dot should be omitted.
  call assert_equal('  2', printf('%3.f', 7.0/3.0))
  call assert_equal('  2', printf('%3.g', 7.0/3.0))
  call assert_equal('  2e+00', printf('%7.e', 7.0/3.0))

  " Float zero can be signed.
  call assert_equal('+0.000000', printf('%+f', 0.0))
  call assert_equal('0.000000', printf('%f', 1.0/(1.0/0.0)))
  call assert_equal('-0.000000', printf('%f', 1.0/(-1.0/0.0)))
  call assert_equal('0.0', printf('%s', 1.0/(1.0/0.0)))
  call assert_equal('-0.0', printf('%s', 1.0/(-1.0/0.0)))
  call assert_equal('0.0', printf('%S', 1.0/(1.0/0.0)))
  call assert_equal('-0.0', printf('%S', 1.0/(-1.0/0.0)))

  " Float infinity can be signed.
  call assert_equal('inf', printf('%f', 1.0/0.0))
  call assert_equal('-inf', printf('%f', -1.0/0.0))
  call assert_equal('inf', printf('%g', 1.0/0.0))
  call assert_equal('-inf', printf('%g', -1.0/0.0))
  call assert_equal('inf', printf('%e', 1.0/0.0))
  call assert_equal('-inf', printf('%e', -1.0/0.0))
  call assert_equal('INF', printf('%F', 1.0/0.0))
  call assert_equal('-INF', printf('%F', -1.0/0.0))
  call assert_equal('INF', printf('%E', 1.0/0.0))
  call assert_equal('-INF', printf('%E', -1.0/0.0))
  call assert_equal('INF', printf('%E', 1.0/0.0))
  call assert_equal('-INF', printf('%G', -1.0/0.0))
  call assert_equal('+inf', printf('%+f', 1.0/0.0))
  call assert_equal('-inf', printf('%+f', -1.0/0.0))
  call assert_equal(' inf', printf('% f',  1.0/0.0))
  call assert_equal('   inf', printf('%6f', 1.0/0.0))
  call assert_equal('  -inf', printf('%6f', -1.0/0.0))
  call assert_equal('   inf', printf('%6g', 1.0/0.0))
  call assert_equal('  -inf', printf('%6g', -1.0/0.0))
  call assert_equal('  +inf', printf('%+6f', 1.0/0.0))
  call assert_equal('   inf', printf('% 6f', 1.0/0.0))
  call assert_equal('  +inf', printf('%+06f', 1.0/0.0))
  call assert_equal('inf   ', printf('%-6f', 1.0/0.0))
  call assert_equal('-inf  ', printf('%-6f', -1.0/0.0))
  call assert_equal('+inf  ', printf('%-+6f', 1.0/0.0))
  call assert_equal(' inf  ', printf('%- 6f', 1.0/0.0))
  call assert_equal('-INF  ', printf('%-6F', -1.0/0.0))
  call assert_equal('+INF  ', printf('%-+6F', 1.0/0.0))
  call assert_equal(' INF  ', printf('%- 6F', 1.0/0.0))
  call assert_equal('INF   ', printf('%-6G', 1.0/0.0))
  call assert_equal('-INF  ', printf('%-6G', -1.0/0.0))
  call assert_equal('INF   ', printf('%-6E', 1.0/0.0))
  call assert_equal('-INF  ', printf('%-6E', -1.0/0.0))
  call assert_equal("str2float('inf')", printf('%s', 1.0/0.0))
  call assert_equal("-str2float('inf')", printf('%s', -1.0/0.0))

  " Test special case where max precision is truncated at 340.
  call assert_equal('1.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', printf('%.330f', 1.0))
  call assert_equal('1.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', printf('%.340f', 1.0))
  call assert_equal('1.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', printf('%.350f', 1.0))

  " Float nan (not a number) has no sign.
  call assert_equal('nan', printf('%f', sqrt(-1.0)))
  call assert_equal('nan', printf('%f', 0.0/0.0))
  call assert_equal('nan', printf('%f', -0.0/0.0))
  call assert_equal('nan', printf('%g', 0.0/0.0))
  call assert_equal('nan', printf('%e', 0.0/0.0))
  call assert_equal('NAN', printf('%F', 0.0/0.0))
  call assert_equal('NAN', printf('%G', 0.0/0.0))
  call assert_equal('NAN', printf('%E', 0.0/0.0))
  call assert_equal('NAN', printf('%F', -0.0/0.0))
  call assert_equal('NAN', printf('%G', -0.0/0.0))
  call assert_equal('NAN', printf('%E', -0.0/0.0))
  call assert_equal('   nan', printf('%6f', 0.0/0.0))
  call assert_equal('   nan', printf('%06f', 0.0/0.0))
  call assert_equal('nan   ', printf('%-6f', 0.0/0.0))
  call assert_equal('nan   ', printf('%- 6f', 0.0/0.0))
  call assert_equal("str2float('nan')", printf('%s', 0.0/0.0))
  call assert_equal("str2float('nan')", printf('%s', -0.0/0.0))
  call assert_equal("str2float('nan')", printf('%S', 0.0/0.0))
  call assert_equal("str2float('nan')", printf('%S', -0.0/0.0))

  call assert_fails('echo printf("%f", "a")', 'E807:')
endfunc

function Test_printf_errors()
  call assert_fails('echo printf("%d", {})', 'E728:')
  call assert_fails('echo printf("%d", [])', 'E745:')
  call assert_fails('echo printf("%d", 1, 2)', 'E767:')
  call assert_fails('echo printf("%*d", 1)', 'E766:')
  call assert_fails('echo printf("%s")', 'E766:')
  if has('float')
    call assert_fails('echo printf("%d", 1.2)', 'E805:')
    call assert_fails('echo printf("%f")')
  endif
endfunc

function Test_max_min_errors()
  call assert_fails('call max(v:true)', 'E712:')
  call assert_fails('call max(v:true)', 'max()')
  call assert_fails('call min(v:true)', 'E712:')
  call assert_fails('call min(v:true)', 'min()')
endfunc

func Test_substitute_expr()
  let g:val = 'XXX'
  call assert_equal('XXX', substitute('yyy', 'y*', '\=g:val', ''))
  call assert_equal('XXX', substitute('yyy', 'y*', {-> g:val}, ''))
  call assert_equal("-\u1b \uf2-", substitute("-%1b %f2-", '%\(\x\x\)',
			   \ '\=nr2char("0x" . submatch(1))', 'g'))
  call assert_equal("-\u1b \uf2-", substitute("-%1b %f2-", '%\(\x\x\)',
			   \ {-> nr2char("0x" . submatch(1))}, 'g'))

  call assert_equal('231', substitute('123', '\(.\)\(.\)\(.\)',
	\ {-> submatch(2) . submatch(3) . submatch(1)}, ''))

  func Recurse()
    return substitute('yyy', 'y\(.\)y', {-> submatch(1)}, '')
  endfunc
  " recursive call works
  call assert_equal('-y-x-', substitute('xxx', 'x\(.\)x', {-> '-' . Recurse() . '-' . submatch(1) . '-'}, ''))
endfunc

func Test_invalid_submatch()
  " This was causing invalid memory access in Vim-7.4.2232 and older
  call assert_fails("call substitute('x', '.', {-> submatch(10)}, '')", 'E935:')
endfunc

func Test_substitute_expr_arg()
  call assert_equal('123456789-123456789=', substitute('123456789',
	\ '\(.\)\(.\)\(.\)\(.\)\(.\)\(.\)\(.\)\(.\)\(.\)',
	\ {m -> m[0] . '-' . m[1] . m[2] . m[3] . m[4] . m[5] . m[6] . m[7] . m[8] . m[9] . '='}, ''))

  call assert_equal('123456-123456=789', substitute('123456789',
	\ '\(.\)\(.\)\(.\)\(a*\)\(n*\)\(.\)\(.\)\(.\)\(x*\)',
	\ {m -> m[0] . '-' . m[1] . m[2] . m[3] . m[4] . m[5] . m[6] . m[7] . m[8] . m[9] . '='}, ''))

  call assert_equal('123456789-123456789x=', substitute('123456789',
	\ '\(.\)\(.\)\(.*\)',
	\ {m -> m[0] . '-' . m[1] . m[2] . m[3] . 'x' . m[4] . m[5] . m[6] . m[7] . m[8] . m[9] . '='}, ''))

  call assert_fails("call substitute('xxx', '.', {m -> string(add(m, 'x'))}, '')", 'E742:')
  call assert_fails("call substitute('xxx', '.', {m -> string(insert(m, 'x'))}, '')", 'E742:')
  call assert_fails("call substitute('xxx', '.', {m -> string(extend(m, ['x']))}, '')", 'E742:')
  call assert_fails("call substitute('xxx', '.', {m -> string(remove(m, 1))}, '')", 'E742:')
endfunc

func Test_function_with_funcref()
  let s:f = function('type')
  let s:fref = function(s:f)
  call assert_equal(v:t_string, s:fref('x'))
  call assert_fails("call function('s:f')", 'E700:')

  call assert_fails("call function('foo()')", 'E475:')
  call assert_fails("call function('foo()')", 'foo()')
endfunc

func Test_funcref()
  func! One()
    return 1
  endfunc
  let OneByName = function('One')
  let OneByRef = funcref('One')
  func! One()
    return 2
  endfunc
  call assert_equal(2, OneByName())
  call assert_equal(1, OneByRef())
  let OneByRef = 'One'->funcref()
  call assert_equal(2, OneByRef())
  call assert_fails('echo funcref("{")', 'E475:')
  let OneByRef = funcref("One", repeat(["foo"], 20))
  call assert_fails('let OneByRef = funcref("One", repeat(["foo"], 21))', 'E118:')
endfunc

func Test_setmatches()
  hi def link 1 Comment
  hi def link 2 PreProc
  let set = [{"group": 1, "pattern": 2, "id": 3, "priority": 4}]
  let exp = [{"group": '1', "pattern": '2', "id": 3, "priority": 4}]
  if has('conceal')
    let set[0]['conceal'] = 5
    let exp[0]['conceal'] = '5'
  endif
  eval set->setmatches()
  call assert_equal(exp, getmatches())
endfunc

func Test_empty_concatenate()
  call assert_equal('b', 'a'[4:0] . 'b')
  call assert_equal('b', 'b' . 'a'[4:0])
endfunc

func Test_broken_number()
  let X = 'bad'
  call assert_fails('echo 1X', 'E15:')
  call assert_fails('echo 0b1X', 'E15:')
  call assert_fails('echo 0b12', 'E15:')
  call assert_fails('echo 0x1X', 'E15:')
  call assert_fails('echo 011X', 'E15:')
  call assert_equal(2, str2nr('2a'))
  call assert_fails('inoremap <Char-0b1z> b', 'E474:')
endfunc

func Test_eval_after_if()
  let s:val = ''
  func SetVal(x)
    let s:val ..= a:x
  endfunc
  if 0 | eval SetVal('a') | endif | call SetVal('b')
  call assert_equal('b', s:val)
endfunc
