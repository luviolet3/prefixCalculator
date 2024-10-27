# Prefix notation calculator

This is a recursion based calculator written in MIPS assembly using the MARS mips simulator.


## Supported Operations

| Operator          | Syntax                | Description                                                                                   |
| :---------------- | :-------------------- | :-------------------------------------------------------------------------------------------- |
| <code>+</code>    | <code>+ a b</code>    | returns the result of `a` summed with `b`                                                     |
| <code>-</code>    | <code>- a b</code>    | returns the result of `b` subtracted from `a`                                                 |
| <code>*</code>    | <code>* a b</code>    | returns the result of `a` multiplied by `b`                                                   |
| <code>/</code>    | <code>/ a b</code>    | returns the result of `a` divided by `b` truncating the result to an integer                  |
| <code>%</code>    | <code>% a b</code>    | returns the remainder of `a` divided by `b`                                                   |
| <code>&&</code>   | <code>&& a b</code>   | returns `1` if both `a` and `b` are non-zero, `0` otherwise                                   |
| <code>\|\|</code> | <code>\|\| a b</code> | returns `0` if both `a` and `b` are zero, `1` otherwise                                       |
| <code>!</code>    | <code>! a</code>      | returns `1` if `a` is zero, `0` otherwise                                                     |
| <code>&</code>    | <code>& a b</code>    | returns the result of `a` ANDed with `b` bitwise                                              |
| <code>\|</code>   | <code>\| a b</code>   | returns the result of `a` ORed with `b` bitwise                                               |
| <code>~</code>    | <code>~ a</code>      | returns `a` with all the bits inverted                                                        |
| <code>^</code>    | <code>^ a b</code>    | returns the result of `a` XORed with `b` bitwise                                              |
| <code>>></code>   | <code>>> a b</code>   | returns the result of shifting all the bits in `a` to the right `b` times with signed padding |
| <code><<</code>   | <code><< a b</code>   | returns the result of shifting all the bits in `a` to the left `b` times                      |
| <code>==</code>   | <code>== a b</code>   | returns `1` if `a` equals `b`, `0` otherwise                                                  |
| <code>!=</code>   | <code>!= a b</code>   | returns `1` if `a` does not equal `b`, `0` otherwise                                          |
| <code>\<</code>   | <code>\< a b</code>   | returns `1` if `a` is less than `b`, `0` otherwise                                            |
| <code>\<=</code>  | <code>\<= a b<</code> | returns `1` if `a` is less than or equal to `b`, `0` otherwise                                |
| <code>\></code>   | <code>\> a b</code>   | returns `1` if `a` is greater than `b`, `0` otherwise                                         |
| <code>\>=</code>  | <code>\>= a b</code>  | returns `1` if `a` is greater than or equal to `b`, `0` otherwise                             |
| <code>=</code>    | <code>= A b</code>    | assigns `b` to `A`, then returns `A`                                                          |
| <code>+=</code>   | <code>+= A b</code>   | increments `A` by `b`, then returns `A`                                                       |
| <code>-=</code>   | <code>-= A b</code>   | decrements `A` by `b`, then returns `A`                                                       |
| <code>*=</code>   | <code>*= A b</code>   | multiplies `A` by `b`, then returns `A`                                                       |
| <code>/=</code>   | <code>/= A b</code>   | divides `A` by `b`, truncating to an integer, then returns `A`                                |
| <code>%=</code>   | <code>%= A b</code>   | assigns `A` to the remainder of `A` divided by `b`, then returns `A`                          |
| <code>&=</code>   | <code>&= A b</code>   | bitwise ANDs `A` with `b`, then returns `A`                                                   |
| <code>\|=</code>  | <code>\|= A b</code>  | bitwise ORs `A` with `b`, then returns `A`                                                    |
| <code>^=</code>   | <code>^= A b</code>   | bitwise XORs `A` with `b`, then returns `A`                                                   |
| <code>++</code>   | <code>++ A</code>     | increments `A`, then returns `A`                                                              |
| <code>--</code>   | <code>-- A</code>     | decrements `A`, then returns `A`                                                              |
| <code>.</code>    | <code>. a b</code>    | returns `b`                                                                                   |

Variables are case sensitive and are single letters (`[a-zA-Z]`)

## Examples
`+ 1 2`: adds 1 and 2, returning 3
`. = a 4 + a 8`: assigns 4 to `a`, then adds `a` and 8, returning 12