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


## Phase 4
### Finding the middle of two point
```
  400fd2:	89 d0                	mov    %edx,%eax
  400fd4:	29 f0                	sub    %esi,%eax
  400fd6:	89 c1                	mov    %eax,%ecx
  400fd8:	c1 e9 1f             	shr    $0x1f,%ecx
  400fdb:	01 c8                	add    %ecx,%eax
  400fdd:	d1 f8                	sar    $1,%eax    --> diff/=2
  400fdf:	8d 0c 30             	lea    (%rax,%rsi,1),%ecx -->mid = low + (high - low)/2
```
When trying to find out the middle of two value: `low(%rsi), high(%rax)`, we need to calculate the `diff` between them and then divide the `diff` by 2 and add the result to the `low`.
Here is a simple detail: to prevent mismatch of division on negative number, i.e., the `diff` could be negative, we first calculate the signed bit of `diff` and add it to the `%eax`.

### Binary Search
We compare the target value: `%rdi` with the `mid` we calculate before.
According to the result, we have 3 cases:
+ `mid` > `target` -> go left
```
lea    -0x1(%rcx),%edx  ; high = mid - 1
call   func4            ; func4(target, low, high)
add    %eax,%eax        ; return = 2 * result
```
+ `mid` < `target` -> go right
```
lea    0x1(%rcx),%esi   ; low = mid + 1
call   func4            ; func4(target, low, high)
lea    0x1(%rax,%rax,1),%eax ; return = 2*result + 1
```
+ `mid` == `target` -> ret 

### Main Test
First we need to read 2 integers. The first stored in `%rdx`(x), the second stored in `%rcx`. 
The value of x should satisfy that the func4(x, low, high) return 0,
which means the searching process never went to the right branch.
The value of low and high is 0x0 and 0xe. Thereby we can figure out the value of x.
For the second value stored in `%rcx`, we just compare it with 0x0. 


## Phase 5
In this phase we learn about how to calculate the lenght of a string and how to convert a string to another one using a table.

### Calculate the length of a string
```
000000000040131b <string_length>:
  40131b:	80 3f 00             	cmpb   $0x0,(%rdi)
  40131e:	74 12                	je     401332 <string_length+0x17>
  401320:	48 89 fa             	mov    %rdi,%rdx    -> record the first address of this char[]
  401323:	48 83 c2 01          	add    $0x1,%rdx    -> add one each time to tranverse the array
  401327:	89 d0                	mov    %edx,%eax
  401329:	29 f8                	sub    %edi,%eax    -> return the total length of this array
  40132b:	80 3a 00             	cmpb   $0x0,(%rdx)
  40132e:	75 f3                	jne    401323 <string_length+0x8>
  401330:	f3 c3                	repz ret
  401332:	b8 00 00 00 00       	mov    $0x0,%eax
  401337:	c3                   	ret
```

### Convert a string to another by a loop
```
  40108b:	0f b6 0c 03          	movzbl (%rbx,%rax,1),%ecx
  40108f:	88 0c 24             	mov    %cl,(%rsp)
  401092:	48 8b 14 24          	mov    (%rsp),%rdx
  401096:	83 e2 0f             	and    $0xf,%edx
  401099:	0f b6 92 b0 24 40 00 	movzbl 0x4024b0(%rdx),%edx
  4010a0:	88 54 04 10          	mov    %dl,0x10(%rsp,%rax,1)
  4010a4:	48 83 c0 01          	add    $0x1,%rax
  4010a8:	48 83 f8 06          	cmp    $0x6,%rax
  4010ac:	75 dd                	jne    40108b <phase_5+0x29>
```  
Here we are trying to access a table stored in `$0x4024b0`. 
For the input string char[], each time we read 1 byte, named input[i], thereby we load the byte into `%edx`, and then convert it into another string by:
`output[i] = table[input[i] & 0xF]`.
We only use the lower 4 bits of this character.
And finally we compare this output string with a constant string stored in `0x40245e`.
How can we defuse this bomb? 
To check the contents of the table, we can use gdb by: `(gdb) x/16cb 0x4024b0`.
Here is a [link]https://visualgdb.com/gdbreference/commands/x of usage of `x` command in `gdb`.

## Phase 6
This phase consists of a sequence of operations, including reading six numbers and determine if it is a permutation of {1, 2, 3, 4, 5, 6}.
After transformation on this permutation, we use them to reorder a linked list.
The expected result should be a descending list.
### Reading and Range Check and Uniquess Check
`read_six_numbers()` stored the 6 numbers at `rsp+0, rsp+4, rsp+8, rsp+0xc, rsp+0x10, rsp+0x14`.
The implementation of feasibily check is quite simple. We just increment each `i` and check if `input[i]` is in `[1, 2, 3, 4, 5, 6]` and make sure there is no duplicate.

### Transformation
```
  401153:	48 8d 74 24 18       	lea    0x18(%rsp),%rsi
  401158:	4c 89 f0             	mov    %r14,%rax
  40115b:	b9 07 00 00 00       	mov    $0x7,%ecx
  401160:	89 ca                	mov    %ecx,%edx
  401162:	2b 10                	sub    (%rax),%edx
  401164:	89 10                	mov    %edx,(%rax)
  401166:	48 83 c0 04          	add    $0x4,%rax
  40116a:	48 39 f0             	cmp    %rsi,%rax
  40116d:	75 f1                	jne    401160 <phase_6+0x6c>
```
Here we reverse each number to `7-x`.
The transformed number are used as an index into a linked list of 6 nodes.
```
  401197: mov (%rsp,%rsi,1),%ecx   ; ecx = a[i] (note: rsi goes 0,4,8,...)
  40119a: cmp $0x1,%ecx
  40119d: jle 401183               ; if a[i] <= 1, just take head
  40119f: mov $1,%eax              ; eax = step counter
  4011a4: mov $0x6032d0,%edx       ; edx = head pointer (node1)
  401176: mov 0x8(%rdx),%rdx       ; rdx = rdx->next
  40117a: add $1,%eax              ; steps++
  40117d: cmp %ecx,%eax
  40117f: jne 401176
```

### Re-link the nodes 
```
  4011ab: mov 0x20(%rsp),%rbx      ; rbx = ptrs[0] (new head)
  4011b0: lea 0x28(%rsp),%rax      ; rax = &ptrs[1]
  4011b5: lea 0x50(%rsp),%rsi      ; rsi = &ptrs[6] (end)
  4011ba: mov %rbx,%rcx            ; rcx = current node
  
  loop:
  4011bd: mov (%rax),%rdx          ; rdx = next chosen node
  4011c0: mov %rdx,0x8(%rcx)       ; current->next = rdx
  4011c4: add $0x8,%rax            ; advance ptrs
  4011c8: cmp %rsi,%rax
  4011cb: je 4011d2
  4011cd: mov %rdx,%rcx            ; current = rdx
  4011d0: jmp loop
  
  4011d2: movq $0x0,0x8(%rdx)      ; last->next = NULL
```
Here we are trying to relink the nodes and finally we get 

### Verify descending order 

```
  4011da: mov $0x5,%ebp            ; compare 5 links
  4011df: mov 0x8(%rbx),%rax       ; rax = rbx->next
  4011e3: mov (%rax),%eax          ; eax = next->value
  4011e5: cmp %eax,(%rbx)          ; compare current->value with next->value
  4011e7: jge 4011ee               ; ok if current >= next
  4011e9: call explode_bomb
  4011ee: mov 0x8(%rbx),%rbx       ; rbx = rbx->next
  4011f2: sub $1,%ebp
  4011f5: jne 4011df
```
This enforces:
`value(node0) >= value(node1) >= ... >= value(node5)`
So the chosen nodes must be ordered by descending node values.

### How to solve this phase
We need to check the value of each link node and order them and thereby we get the right order.
The address of the linked list is `0x6032d0`. We can check the value of these nodes by `x/24gx 0x6032d0` 

## Secret Phase
There is a secret phase that hidding in this bomb.
### How to Ignite the Secret Phase
Check the asm code of `phase_defused()`:
```
  401604:	be 22 26 40 00       	mov    $0x402622,%esi
  401609:	48 8d 7c 24 10       	lea    0x10(%rsp),%rdi
  40160e:	e8 25 fd ff ff       	call   401338 <strings_not_equal>
  401613:	85 c0                	test   %eax,%eax
  401615:	75 1e                	jne    401635 <phase_defused+0x71>
  401617:	bf f8 24 40 00       	mov    $0x4024f8,%edi
  40161c:	e8 ef f4 ff ff       	call   400b10 <puts@plt>
  401621:	bf 20 25 40 00       	mov    $0x402520,%edi
  401626:	e8 e5 f4 ff ff       	call   400b10 <puts@plt>
  40162b:	b8 00 00 00 00       	mov    $0x0,%eax
  401630:	e8 0d fc ff ff       	call   401242 <secret_phase>
```
We can check each magic address here and figured out how to ignite it.
Anyway it wait for a secret keyword that stores in `$0x402622`.
And where should it be put? ...

### Binary Search Tree
This phase is about how we can perform a binary search on BST.
Each node is stored in a certain address occupying total 24bytes to store: its own value, the left pointer, the right pointer.
```
  40120f:	39 f2                	cmp    %esi,%edx            ; we compare the searching value with the root and determine to go left or right
  401211:	7e 0d                	jle    401220 <fun7+0x1c>
  401213:	48 8b 7f 08          	mov    0x8(%rdi),%rdi
  401217:	e8 e8 ff ff ff       	call   401204 <fun7>
  40121c:	01 c0                	add    %eax,%eax            ; double the ret value if go to the right branch
  40121e:	eb 1d                	jmp    40123d <fun7+0x39>
  401220:	b8 00 00 00 00       	mov    $0x0,%eax
  401225:	39 f2                	cmp    %esi,%edx
  401227:	74 14                	je     40123d <fun7+0x39>
  401229:	48 8b 7f 10          	mov    0x10(%rdi),%rdi
  40122d:	e8 d2 ff ff ff       	call   401204 <fun7>
  401232:	8d 44 00 01          	lea    0x1(%rax,%rax,1),%eax ; return the sub_ret* 2 + 1 if go to the left branch
  401236:	eb 05                	jmp    40123d <fun7+0x39>
```
This is the asm version of the BST and binary search.

### How to Solve the Secret Phase
We can read the code and find out that the program read a integer first and then target it in the BST whose tree root is `$0x6030f0`.
Easily we can check the value at tree root and its left and right pointer as well. Finally the code requires that the searching function should return 2, which points to a certain node in the BST.


## Some thoughts after the lab
I have spent quite a lot time on this lab and actually it takes a very long period about a month. This is a real interesting lab and brings me the fundamental acknowlegement of machine level programming. It worth a try anyway.