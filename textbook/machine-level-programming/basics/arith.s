	.file	"arith.c"
	.text
	.globl	arith
	.type	arith, @function
arith:
.LFB0:
	.cfi_startproc
	endbr64
	movq	%rdi, %rcx
	xorq	%rsi, %rcx
	leaq	(%rsi,%rsi,2), %rax
	salq	$4, %rax
	andl	$252645135, %edi
	subq	%rdi, %rax
	addq	%rcx, %rax
	addq	%rdx, %rax
	ret
	.cfi_endproc
.LFE0:
	.size	arith, .-arith
	.globl	arith3
	.type	arith3, @function
arith3:
.LFB1:
	.cfi_startproc
	endbr64
	movl	%esi, %eax
	orl	%esi, %edx
	sarw	$9, %dx
	notl	%edx
	subl	%edx, %eax
	ret
	.cfi_endproc
.LFE1:
	.size	arith3, .-arith3
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
