// =.il

.assembly extern mscorlib {}

.assembly EqCalc
{
	.ver	1:0:0:0
}

.module eqcalc.exe
.subsystem 0x0002  // no console window


.typedef [System.Windows.Forms]System.Windows.Forms.MessageBox as MessageBox
.typedef [System.Windows.Forms]System.Windows.Forms.DialogResult as DialogResult
.typedef [System.Windows.Forms]System.Windows.Forms.MessageBoxButtons as MessageBoxButtons
.typedef [System.Windows.Forms]System.Windows.Forms.Clipboard as Clipboard
.typedef [mscorlib]System.Collections.Generic.List`1 as List`1
.typedef [mscorlib]System.Collections.Generic.IEnumerable`1 as IEnumerable`1
.typedef [mscorlib]System.Collections.Generic.IEnumerator`1 as IEnumerator`1
.typedef [System.Core]System.Linq.Enumerable as Enumerable
.typedef [mscorlib]System.String as String


.method static void Main(string[] args) cil managed
{
	.entrypoint
	.maxstack	3
	.locals init (	[0] string res)
	.custom instance void [mscorlib]System.STAThreadAttribute::.ctor() = ( 01 00 00 00 )

	ldarg	args
	ldlen
	conv.i4
	brtrue.s	args_not_empty

	ldstr	"Usage: = 2*2"
	ldstr	"Input is empty"
	call		valuetype DialogResult MessageBox::Show(string,	string)
	pop
	br.s		done_with_main

args_not_empty:
	ldstr	" "
	ldarg	args
	call		string String::Join(string, string[])
	call		string calc(string)
	stloc	res
	ldloc	res
	ldstr	"Copy to clipboard\?"
	ldc.i4.4
	call		valuetype DialogResult MessageBox::Show(string, string,	valuetype MessageBoxButtons)
	ldc.i4.6
	ceq
	brfalse.s	done_with_main

yes_to_copy_to_clipboard:
	ldloc	res
	call		void Clipboard::SetText(string)

done_with_main:
	ret
}

.method private static float64 do_number(string number) cil managed
{
	.maxstack	1
	ldarg	number
	call		float64 [mscorlib]System.Double::Parse(string)
	ret
}

.method private static float64 do_divs(string formula) cil managed
{
	.maxstack	4
	.locals init (	[0] float64 res,
			[1] int32 chunks_index,
			[2] class IEnumerator`1<float64> enumerator_temp,
			[3] string[] chunks,
			[4] class List`1<float64> numbers,
			[5] char[] delimiter )


split_by_slash:
	ldarg	formula
	ldc.i4.1
	newarr	[mscorlib]System.Char
	stloc.s	delimiter
	ldloc.s	delimiter
	ldc.i4.0
	ldc.i4.s	47 // THE OPERATION SYMBOL '/'
	stelem.i2
	ldloc.s	delimiter
	callvirt	instance string[] String::Split(char[])
	stloc	chunks

	newobj	instance void class List`1<float64>::.ctor()
	stloc	numbers
	ldc.i4.0
	stloc.s	chunks_index
	br.s		check_chunks_index


in_loop_for_calculating_numbers:
	ldloc.s	numbers
	ldloc.s	chunks
	ldloc.s	chunks_index
	ldelem.ref

	call		float64 do_number(string)	// NEXT OPERATION
	callvirt	instance void class List`1<float64>::Add(!0)

	ldloc.s	chunks_index
	ldc.i4.1
	add
	stloc.s	chunks_index

check_chunks_index:
	ldloc.s	chunks_index
	ldloc.s	chunks
	ldlen
	conv.i4
	clt
	brtrue.s	in_loop_for_calculating_numbers


load_first_of_numbers_for_reduce:
	ldloc	numbers
	ldc.i4.0
	callvirt	instance !0 class List`1<float64>::get_Item(int32)
	stloc.s	res

	ldloc	numbers
	ldc.i4.1
	call		class IEnumerable`1<!!0> Enumerable::Skip<float64>(class IEnumerable`1<!!0>, int32)
	callvirt	instance class IEnumerator`1<!0> class IEnumerable`1<float64>::GetEnumerator()
	stloc.s	enumerator_temp

	.try
	{
		br.s		check_exit_condition_for_inner_loop
	inner_loop_of_reduce:

		ldloc.s	res
		ldloc.s	enumerator_temp
		callvirt	instance !0 class IEnumerator`1<float64>::get_Current()
		conv.r8
		div		//	THE OPERATION
		stloc.s	res

	check_exit_condition_for_inner_loop:
		ldloc.2	//	enumerator_temp
		callvirt	instance bool [mscorlib]System.Collections.IEnumerator::MoveNext()
		brtrue.s	inner_loop_of_reduce

		leave.s	return_res

	}
	finally
	{
		ldloc.s	enumerator_temp
		ldnull
		ceq
		brtrue.s	end_finally

		ldloc.s	enumerator_temp
		callvirt	instance void [mscorlib]System.IDisposable::Dispose()
	end_finally:
		endfinally
	}

return_res:
	ldloc.s	res
	ret
}


.method private static float64 do_muls(string formula) cil managed
{
	.maxstack  4
	.locals init (	[0] float64 res,
			[1] int32 chunks_index,
			[2] class IEnumerator`1<float64> enumerator_temp,
			[3] string[] chunks,
			[4] class List`1<float64> numbers,
			[5] char[] delimiter	)


split_by_slash:
	ldarg	formula
	ldc.i4.1
	newarr	[mscorlib]System.Char
	stloc.s	delimiter
	ldloc.s	delimiter
	ldc.i4.0
	ldc.i4.s	42 // THE OPERATION SYMBOL '*'
	stelem.i2
	ldloc.s	delimiter
	callvirt	instance string[] String::Split(char[])
	stloc	chunks


	newobj	instance void class List`1<float64>::.ctor()
	stloc	numbers
	ldc.i4.0
	stloc.s	chunks_index
	br.s		check_chunks_index


in_loop_for_calculating_numbers:
	ldloc	numbers
	ldloc.s	chunks
	ldloc.s	chunks_index
	ldelem.ref

	call		float64 do_divs(string)	// NEXT OPERATION
	callvirt	instance void class List`1<float64>::Add(!0)

	ldloc.s	chunks_index
	ldc.i4.1
	add
	stloc.s	chunks_index

check_chunks_index:
	ldloc.s	chunks_index
	ldloc.s	chunks
	ldlen
	conv.i4
	clt
	brtrue.s	in_loop_for_calculating_numbers


load_first_of_numbers_for_reduce:
	ldloc	numbers
	ldc.i4.0
	callvirt	instance !0 class List`1<float64>::get_Item(int32)
	stloc.s	res

	ldloc.s	numbers
	ldc.i4.1
	call		class IEnumerable`1<!!0> Enumerable::Skip<float64>(class IEnumerable`1<!!0>, int32)
	callvirt	instance class IEnumerator`1<!0> class IEnumerable`1<float64>::GetEnumerator()
	stloc.s	enumerator_temp

	.try
	{
		br.s		check_exit_condition_for_inner_loop
	inner_loop_of_reduce:

		ldloc.s	res
		ldloc.s	enumerator_temp
		callvirt	instance !0 class IEnumerator`1<float64>::get_Current()
		conv.r8
		mul		// THE OPERATION
		stloc.s	res

	check_exit_condition_for_inner_loop:
		ldloc.s	enumerator_temp
		callvirt	instance bool [mscorlib]System.Collections.IEnumerator::MoveNext()
		brtrue.s	inner_loop_of_reduce

		leave.s		return_res

	}
	finally
	{
		ldloc.s	enumerator_temp
		ldnull
		ceq
		brtrue.s	end_finally

		ldloc.s	enumerator_temp
		callvirt	instance void [mscorlib]System.IDisposable::Dispose()
	end_finally:
		endfinally
	}

return_res:
	ldloc.s	res
	ret
}


.method private static float64 do_minuses(string formula) cil managed
{
	.maxstack  4
	.locals init (	[0] float64 res,
			[1] int32 chunks_index,
			[2] class IEnumerator`1<float64> enumerator_temp,
			[3] string[] chunks,
			[4] class List`1<float64> numbers,
			[5] char[] delimiter	)


split_by_slash:
	ldarg	formula
	ldc.i4.1
	newarr	[mscorlib]System.Char
	stloc.s	delimiter
	ldloc.s	delimiter
	ldc.i4.0
	ldc.i4.s	45 // THE OPERATION SYMBOL '-'
	stelem.i2
	ldloc.s	delimiter
	callvirt	instance string[] String::Split(char[])
	stloc	chunks


	newobj	instance void class List`1<float64>::.ctor()
	stloc	numbers
	ldc.i4.0
	stloc.s	chunks_index
	br.s		check_chunks_index


in_loop_for_calculating_numbers:
	ldloc	numbers
	ldloc.s	chunks
	ldloc.s	chunks_index
	ldelem.ref

	callvirt	instance string String::Trim()
	dup
	ldstr	""
	call		bool String::op_Equality(string,
				string)
	brtrue.s	chunk_is_empty_string

chunk_is_not_empty_string:
	call		float64 do_muls(string)	// NEXT OPERATION
	callvirt	instance void class List`1<float64>::Add(!0)
	br.s		regardless_of_chunk_len

chunk_is_empty_string:
	pop
	ldc.r8	0
	callvirt	instance void class List`1<float64>::Add(!0)

regardless_of_chunk_len:

	ldloc.s	chunks_index
	ldc.i4.1
	add
	stloc.s	chunks_index

check_chunks_index:
	ldloc.s	chunks_index
	ldloc.s	chunks
	ldlen
	conv.i4
	clt
	brtrue.s	in_loop_for_calculating_numbers


load_first_of_numbers_for_reduce:
	ldloc	numbers
	ldc.i4.0
	callvirt	instance !0 class List`1<float64>::get_Item(int32)
	stloc.s	res

	ldloc	numbers
	ldc.i4.1
	call		class IEnumerable`1<!!0> Enumerable::Skip<float64>(class IEnumerable`1<!!0>, int32)
	callvirt	instance class IEnumerator`1<!0> class IEnumerable`1<float64>::GetEnumerator()
	stloc.s	enumerator_temp

	.try
	{
		br.s		check_exit_condition_for_inner_loop
	inner_loop_of_reduce:

		ldloc.s	res
		ldloc.s	enumerator_temp
		callvirt	instance !0 class IEnumerator`1<float64>::get_Current()
		conv.r8
		sub		// THE OPERATION
		stloc.s	res

	check_exit_condition_for_inner_loop:
		ldloc.s	enumerator_temp
		callvirt	instance bool [mscorlib]System.Collections.IEnumerator::MoveNext()
		brtrue.s	inner_loop_of_reduce

		leave.s	return_res

	}
	finally
	{
		ldloc.s	enumerator_temp
		ldnull
		ceq
		brtrue.s	end_finally

		ldloc.s	enumerator_temp
		callvirt	instance void [mscorlib]System.IDisposable::Dispose()
	end_finally:
		endfinally
	}

return_res:
	ldloc.s	res
	ret
}

.method private static float64 do_pluses(string formula) cil managed
{
	.maxstack  4
	.locals init (	[0] float64 res,
			[1] int32 chunks_index,
			[2] class IEnumerator`1<float64> enumerator_temp,
			[3] string[] chunks,
			[4] class List`1<float64> numbers,
			[5] char[] delimiter	)


split_by_slash:
	ldarg	formula
	ldc.i4.1
	newarr	[mscorlib]System.Char
	stloc.s	delimiter
	ldloc.s	delimiter
	ldc.i4.0
	ldc.i4.s	43 // THE OPERATION SYMBOL '+'
	stelem.i2
	ldloc.s	delimiter
	callvirt	instance string[] String::Split(char[])
	stloc	chunks


	newobj	instance void class List`1<float64>::.ctor()
	stloc	numbers
	ldc.i4.0
	stloc.s	chunks_index
	br.s		check_chunks_index



in_loop_for_calculating_numbers:
	ldloc	numbers
	ldloc.s	chunks
	ldloc.s	chunks_index
	ldelem.ref

	call		float64 do_minuses(string)	// NEXT OPERATION
	callvirt	instance void class List`1<float64>::Add(!0)

	ldloc.s	chunks_index
	ldc.i4.1
	add
	stloc.s	chunks_index

check_chunks_index:
	ldloc.s	chunks_index
	ldloc.s	chunks
	ldlen
	conv.i4
	clt
	brtrue.s	in_loop_for_calculating_numbers



load_first_of_numbers_for_reduce:
	ldloc		numbers
	ldc.i4.0
	callvirt	instance !0 class List`1<float64>::get_Item(int32)
	stloc.s	res

	ldloc	numbers
	ldc.i4.1
	call		class IEnumerable`1<!!0> Enumerable::Skip<float64>(class IEnumerable`1<!!0>, int32)
	callvirt	instance class IEnumerator`1<!0> class IEnumerable`1<float64>::GetEnumerator()
	stloc.s	enumerator_temp

	.try
	{
		br.s		check_exit_condition_for_inner_loop
	inner_loop_of_reduce:

		ldloc.s	res
		ldloc.s	enumerator_temp
		callvirt	instance !0 class IEnumerator`1<float64>::get_Current()
		conv.r8
		add		// THE OPERATION
		stloc.s	res

	check_exit_condition_for_inner_loop:
		ldloc.s	enumerator_temp
		callvirt	instance bool [mscorlib]System.Collections.IEnumerator::MoveNext()
		brtrue.s	inner_loop_of_reduce

		leave.s	return_res

	}
	finally
	{
		ldloc.s	enumerator_temp
		ldnull
		ceq
		brtrue.s	end_finally

		ldloc.s	enumerator_temp
		callvirt	instance void [mscorlib]System.IDisposable::Dispose()
	end_finally:
		endfinally
	}

return_res:
	ldloc.s	res
	ret
}


.method private static string calc_no_brackets(string formula) cil managed
{
	.maxstack  1
	.locals init (	[0] float64 temp_float)

	ldarg.0
	call		float64 do_pluses(string)
	stloc.s	temp_float
	ldloca.s	temp_float
	call		instance string [mscorlib]System.Double::ToString()

	ret
}


.method private static int32 find_matching_bracket(string where) cil managed
{
	.maxstack  2
	.locals init (	[0] int32 string_len,
           		[1] int32 bracket_counter,
           		[2] int32 i	)

	ldarg		where
	callvirt	instance int32 String::get_Length()
	stloc.s		string_len
	ldc.i4.0
	stloc.s		bracket_counter
	ldc.i4.0
	stloc.s	i
	br.s		loop_index_check

loop_starts:
	ldarg	where
	ldloc.s	i
	callvirt	instance char String::get_Chars(int32)
	ldc.i4.s	40	// '('
	bne.un.s	opening_bracket_not_found

opening_bracket_found:
	ldloc.s	bracket_counter
	ldc.i4.1
	add
	stloc.s	bracket_counter

opening_bracket_not_found:
	ldarg.s	where
	ldloc.s	i
	callvirt	instance char String::get_Chars(int32)
	ldc.i4.s	41	// ')'
	bne.un.s	loop_index_increment

closing_bracket_found:
	ldloc.s	bracket_counter
	ldc.i4.1
	bne.un.s	closing_bracket_found_and_counter_not_1

closing_bracket_found_and_counter_1:
	ldloc.s	i
	ret

closing_bracket_found_and_counter_not_1:
	ldloc.s	bracket_counter
	ldc.i4.1
	sub
	stloc.s	bracket_counter

loop_index_increment:
	ldloc.s	i
	ldc.i4.1
	add
	stloc.s	i

loop_index_check:
	ldloc.s	i
	ldloc.s	string_len
	blt.s	loop_starts
	ldc.i4.m1
	ret
}


.method private static string calc(string formula) cil managed
{
	.maxstack  4
	.locals init (	[0] int32 left_index,
			[1] int32 right_index,
			[2] string left,
			[3] string middle,
			[4] string right)

	ldarg	formula
	ldc.i4.s	40	// '('
	callvirt	instance int32 String::IndexOf(char)
	stloc.s	left_index
	ldloc.s	left_index
	ldc.i4.m1
	ceq
	brfalse.s   there_is_an_opening_bracket

no_opening_bracket:
	ldarg	formula
	call		string calc_no_brackets(string)
	br.s		done_with_calc

there_is_an_opening_bracket:
	ldarg	formula
	call		int32 find_matching_bracket(string)

	stloc.s	right_index
	ldloc.s	right_index
	ldc.i4.m1
	ceq
	ldc.i4.0
	ceq
	brtrue.s	there_is_a_closing_bracket

no_closing_bracket:
	ldstr	"Can't resolve '"
	ldarg	formula
	ldstr	"'"
	call		string String::Concat(string, string, string)
	br.s		done_with_calc

there_is_a_closing_bracket:
	ldarg	formula
	ldc.i4.0
	ldloc	left_index
	callvirt	instance string String::Substring(int32, int32)
	stloc.s	left
	ldarg	formula
	ldloc.s	left_index
	ldc.i4.1
	add
	ldloc.s	right_index
	ldloc.s	left_index
	sub
	ldc.i4.1
	sub
	callvirt   	instance string String::Substring(int32, int32)
	stloc.s	middle
	ldarg	formula
	ldloc.s	right_index
	ldc.i4.1
	add
	callvirt	instance string String::Substring(int32)
	stloc.s	right

	ldloc.s	left
	ldloc.s	middle
	call		string calc(string)
	ldloc.s	right

	call		string String::Concat(string, string, string)

	call		string calc(string)
done_with_calc:
	ret
}