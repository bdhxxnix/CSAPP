	.file	"switch.c"
	.text
	.globl	switch_eg
	.type	switch_eg, @function
switch_eg:
.LFB0:
	.cfi_startproc
	endbr64
	cmpq	$6, %rdi
	ja	.L11
	leaq	.L4(%rip), %rcx
	movslq	(%rcx,%rdi,4), %rdx
	addq	%rcx, %rdx
	notrack jmp	*%rdx
	.section	.rodata
	.align 4
	.align 4
.L4:
	.long	.L10-.L4
	.long	.L9-.L4
	.long	.L8-.L4
	.long	.L7-.L4
	.long	.L6-.L4
	.long	.L5-.L4
	.long	.L3-.L4
	.text
.L9:
	movq	%rdi, %rcx
	subq	%rsi, %rcx
.L1:
	movq	%rcx, %rax
	ret
.L10:
	movq	%rsi, %rcx
	subq	%rdi, %rcx
	jmp	.L1
.L8:
	movq	%rdi, %rcx
	imulq	%rsi, %rcx
	jmp	.L1
.L7:
	leaq	(%rdi,%rsi), %rcx
	jmp	.L1
.L6:
	addq	$1, %rsi
	movq	%rdi, %rax
	cqto
	idivq	%rsi
	movq	%rax, %rcx
	jmp	.L1
.L5:
	addq	$1, %rsi
	movq	%rdi, %rax
	cqto
	idivq	%rsi
	movq	%rdx, %rcx
	jmp	.L1
.L3:
	movq	%rdi, %rcx
	andq	%rsi, %rcx
	jmp	.L1
.L11:
	movl	$0, %ecx
	jmp	.L1
	.cfi_endproc
.LFE0:
	.size	switch_eg, .-switch_eg
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
