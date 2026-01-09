# bomb lab solution
In this lab I am going to solve the bomb set by Mr.Evil.
The main purpose is to guess the input string according to the assembly code of `bomb` program. There are 6 phases in total for this bomb, covering all the structures for **Chapter3 Machine Level Programming**.

## Prerequsites
1. GDB(debug tool)
    `gdb ./bomb`
    official manual for the debugger can be seen [here](https://man7.org/linux/man-pages/man1/gdb.1.html)
2. objdump(disassemble the executable program)
    `objdump -d bomb > bomb.asm`

## Phase 1 
In **gdb**, we set breakpoint at **phase_1** and then check the disassemble code of **phase_1** and we get:
```
0000000000400ee0 <phase_1>:
  400ee0:	48 83 ec 08          	sub    $0x8,%rsp
  400ee4:	be 00 24 40 00       	mov    $0x402400,%esi
  400ee9:	e8 4a 04 00 00       	call   401338 <strings_not_equal>
  400eee:	85 c0                	test   %eax,%eax
  400ef0:	74 05                	je     400ef7 <phase_1+0x17>
  400ef2:	e8 43 05 00 00       	call   40143a <explode_bomb>
  400ef7:	48 83 c4 08          	add    $0x8,%rsp
  400efb:	c3                   	ret
```
Here are the important takeaways:
### Stack Adjustment
```
0000000000400ee0 <phase_1>:
  400ee0: 48 83 ec 08        sub    $0x8,%rsp
```

The program reserves 8 bytes on the stack and this required before function calls on x86-64.
### Loading constant pointer
``` 
 400ee4:	be 00 24 40 00       	mov    $0x402400,%esi
```
`%esi` is the **2nd argument** in the x86-64 System V ABI. 
After loading the constant pointer (this pointer points to a certain constant slot in the memory), we make a comparasion by calling `string_not_equal`. This function automatically compare the input (stored in `rdi`) and the constant (stored in `rsi`). 
###  Check the return value
We will then test `%eax`, where the return value of `string_not_equal` is stored by `test %eax, %eax`, which is equivalent to `if (eax == 0)`.

### Secret answer
According to the analysis above, the answer string is hidden at the address `0x402400`.
We can use `gdb` to check the value by `(gdb) x/s 0x402400`

## Phase 2
The second phase present a loop according to the assemble code. The loop block is :
```
  400f15:	eb 19                	jmp    400f30 <phase_2+0x34>
  400f17:	8b 43 fc             	mov    -0x4(%rbx),%eax
  400f1a:	01 c0                	add    %eax,%eax
  400f1c:	39 03                	cmp    %eax,(%rbx)
  400f1e:	74 05                	je     400f25 <phase_2+0x29>
  400f20:	e8 15 05 00 00       	call   40143a <explode_bomb>
  400f25:	48 83 c3 04          	add    $0x4,%rbx
  400f29:	48 39 eb             	cmp    %rbp,%rbx
  400f2c:	75 e9                	jne    400f17 <phase_2+0x1b>
  400f2e:	eb 0c                	jmp    400f3c <phase_2+0x40>
  400f30:	48 8d 5c 24 04       	lea    0x4(%rsp),%rbx
  400f35:	48 8d 6c 24 18       	lea    0x18(%rsp),%rbp
  400f3a:	eb db                	jmp    400f17 <phase_2+0x1b>
```
### Loop
The boundaries for this loop is stored in `&rbx, %rbp`. The loop first set 1 to the `%eax` and double the value for each loop and compare the value with the input value( already stored in the stack ) if not equal, blow the bomb.

### Read numbers from the input
Before executing the loop, the program called `read_six_number` and blow the bomb unless it has read no less than 6 numbers. The structure of this functions is shown below:
```
000000000040145c <read_six_numbers>:
  40145c:	48 83 ec 18          	sub    $0x18,%rsp
  401460:	48 89 f2             	mov    %rsi,%rdx
  401463:	48 8d 4e 04          	lea    0x4(%rsi),%rcx
  401467:	48 8d 46 14          	lea    0x14(%rsi),%rax
  40146b:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  401470:	48 8d 46 10          	lea    0x10(%rsi),%rax
  401474:	48 89 04 24          	mov    %rax,(%rsp)
  401478:	4c 8d 4e 0c          	lea    0xc(%rsi),%r9
  40147c:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  401480:	be c3 25 40 00       	mov    $0x4025c3,%esi
  401485:	b8 00 00 00 00       	mov    $0x0,%eax
  40148a:	e8 61 f7 ff ff       	call   400bf0 <__isoc99_sscanf@plt>
  40148f:	83 f8 05             	cmp    $0x5,%eax
  401492:	7f 05                	jg     401499 <read_six_numbers+0x3d>
  401494:	e8 a1 ff ff ff       	call   40143a <explode_bomb>
  401499:	48 83 c4 18          	add    $0x18,%rsp
  40149d:	c3                   	ret
```
Remember the `%rdi` is the first argument, which is our input string, and the second argument is `%rsi`, which is loaded with `$0x4025c3` (checked using `gdb` and the value is `"%d %d %d %d %d %d"`).
Remember: `int` = 4 bytes. All the elements are stored in a array `a[0], a[1], ... , a[5]`. They are loaded by :
```
mov %rsi, %rdx          ; &a[0]
lea 0x4(%rsi), %rcx    ; &a[1]
lea 0x8(%rsi), %r8     ; &a[2]
lea 0xc(%rsi), %r9     ; &a[3]
lea 0x10(%rsi), %rax
mov %rax, (%rsp)       ; &a[4]
lea 0x14(%rsi), %rax
mov %rax, 0x8(%rsp)    ; &a[5]
```


## Phase 3
This phase implement a **switch** quite straightforward.

### Input Reading
```
0000000000400f43 <phase_3>:
  400f43:	48 83 ec 18          	sub    $0x18,%rsp
  400f47:	48 8d 4c 24 0c       	lea    0xc(%rsp),%rcx
  400f4c:	48 8d 54 24 08       	lea    0x8(%rsp),%rdx
  400f51:	be cf 25 40 00       	mov    $0x4025cf,%esi
  400f56:	b8 00 00 00 00       	mov    $0x0,%eax
  400f5b:	e8 90 fc ff ff       	call   400bf0 <__isoc99_sscanf@plt>
  400f60:	83 f8 01             	cmp    $0x1,%eax
  400f63:	7f 05                	jg     400f6a <phase_3+0x27>
  400f65:	e8 d0 04 00 00       	call   40143a <explode_bomb>
``` 
Remember the `sscanf` takes arguments in the form **(input, format, variable, ...)**.
It takes at least 2 arguments and stored them in `%rcx, %rdx` seperately and we check if the return value (the taken arugments number) is no less than 2.

### Switch Implementation
```
  400f6a:	83 7c 24 08 07       	cmpl   $0x7,0x8(%rsp)
  400f6f:	77 3c               	ja     400fad <phase_3+0x6a>
  400f71:	8b 44 24 08          	mov    0x8(%rsp),%eax
  400f75:	ff 24 c5 70 24 40 00 	jmp    *0x402470(,%rax,8)
  400f7c:	b8 cf 00 00 00       	mov    $0xcf,%eax
  400f81:	eb 3b                	jmp    400fbe <phase_3+0x7b>
  400f83:	b8 c3 02 00 00       	mov    $0x2c3,%eax
  400f88:	eb 34                	jmp    400fbe <phase_3+0x7b>
  400f8a:	b8 00 01 00 00       	mov    $0x100,%eax
  400f8f:	eb 2d                	jmp    400fbe <phase_3+0x7b>
  400f91:	b8 85 01 00 00       	mov    $0x185,%eax
  400f96:	eb 26                	jmp    400fbe <phase_3+0x7b>
  400f98:	b8 ce 00 00 00       	mov    $0xce,%eax
  400f9d:	eb 1f                	jmp    400fbe <phase_3+0x7b>
  400f9f:	b8 aa 02 00 00       	mov    $0x2aa,%eax
  400fa4:	eb 18                	jmp    400fbe <phase_3+0x7b>
  400fa6:	b8 47 01 00 00       	mov    $0x147,%eax
  400fab:	eb 11                	jmp    400fbe <phase_3+0x7b>
  400fad:	e8 88 04 00 00       	call   40143a <explode_bomb>
  400fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  400fb7:	eb 05                	jmp    400fbe <phase_3+0x7b>
  400fb9:	b8 37 01 00 00       	mov    $0x137,%eax
  400fbe:	3b 44 24 0c          	cmp    0xc(%rsp),%eax
  400fc2:	74 05                	je     400fc9 <phase_3+0x86>
  400fc4:	e8 71 04 00 00       	call   40143a <explode_bomb>
``` 
First we determine if the value in `%rdx`(syn as 'x') is no more than 8, this is the **default branch** for the switch.
Then comes the most important jumping operation with:
`400f75:	ff 24 c5 70 24 40 00 	jmp    *0x402470(,%rax,8)`. This means `jmp *BASE(, INDEX, SCALE)`->BASE + INDEX × SCALE. The base address stored at `0x402470` can be examined by `(gdb) x 0x402470`.
And the whole assembly code be translated as:
```
switch (x) {
    case 0: ...
    case 1: ...
    ...
    case 7: ...
}
```
For each branch, it will set a certain value in `%rax` and compare this value with previous input value stored in `%rcx`. So the answer should be a integer `x <= 7` and the corresponding value in that branch. 