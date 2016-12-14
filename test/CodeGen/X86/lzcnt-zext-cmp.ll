; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Test patterns which generates lzcnt instructions.
; Eg: zext(or(setcc(cmp), setcc(cmp))) -> shr(or(lzcnt, lzcnt))
; RUN: llc < %s -mtriple=x86_64-pc-linux -mcpu=btver2 | FileCheck %s
; RUN: llc < %s -mtriple=x86_64-pc-linux -mcpu=btver2 -mattr=-fast-lzcnt | FileCheck --check-prefix=NOFASTLZCNT %s

; Test one 32-bit input, output is 32-bit, no transformations expected.
define i32 @test_zext_cmp0(i32 %a) {
; CHECK-LABEL: test_zext_cmp0:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp0:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    xorl %eax, %eax
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i32 %a, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Test two 32-bit inputs, output is 32-bit.
define i32 @test_zext_cmp1(i32 %a, i32 %b) {
; CHECK-LABEL: test_zext_cmp1:
; CHECK:       # BB#0:
; CHECK-NEXT:    lzcntl %edi, %ecx
; CHECK-NEXT:    lzcntl %esi, %eax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    shrl $5, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp1:
; NOFASTLZCNT:       # BB#0:
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testl %esi, %esi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
  %cmp = icmp eq i32 %a, 0
  %cmp1 = icmp eq i32 %b, 0
  %or = or i1 %cmp, %cmp1
  %lor.ext = zext i1 %or to i32
  ret i32 %lor.ext
}

; Test two 64-bit inputs, output is 64-bit.
define i64 @test_zext_cmp2(i64 %a, i64 %b) {
; CHECK-LABEL: test_zext_cmp2:
; CHECK:       # BB#0:
; CHECK-NEXT:    lzcntq %rdi, %rcx
; CHECK-NEXT:    lzcntq %rsi, %rax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    shrl $6, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp2:
; NOFASTLZCNT:       # BB#0:
; NOFASTLZCNT-NEXT:    testq %rdi, %rdi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testq %rsi, %rsi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
  %cmp = icmp eq i64 %a, 0
  %cmp1 = icmp eq i64 %b, 0
  %or = or i1 %cmp, %cmp1
  %lor.ext = zext i1 %or to i64
  ret i64 %lor.ext
}

; Test two 16-bit inputs, output is 16-bit.
; The transform is disabled for the 16-bit case, as we still have to clear the
; upper 16-bits, adding one more instruction.
define i16 @test_zext_cmp3(i16 %a, i16 %b) {
; CHECK-LABEL: test_zext_cmp3:
; CHECK:       # BB#0:
; CHECK-NEXT:    testw %di, %di
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    testw %si, %si
; CHECK-NEXT:    sete %cl
; CHECK-NEXT:    orb %al, %cl
; CHECK-NEXT:    movzbl %cl, %eax
; CHECK-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp3:
; NOFASTLZCNT:       # BB#0:
; NOFASTLZCNT-NEXT:    testw %di, %di
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testw %si, %si
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; NOFASTLZCNT-NEXT:    retq
  %cmp = icmp eq i16 %a, 0
  %cmp1 = icmp eq i16 %b, 0
  %or = or i1 %cmp, %cmp1
  %lor.ext = zext i1 %or to i16
  ret i16 %lor.ext
}

; Test two 32-bit inputs, output is 64-bit.
define i64 @test_zext_cmp4(i32 %a, i32 %b) {
; CHECK-LABEL: test_zext_cmp4:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lzcntl %edi, %ecx
; CHECK-NEXT:    lzcntl %esi, %eax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    shrl $5, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp4:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testl %esi, %esi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i32 %a, 0
  %cmp1 = icmp eq i32 %b, 0
  %0 = or i1 %cmp, %cmp1
  %conv = zext i1 %0 to i64
  ret i64 %conv
}

; Test two 64-bit inputs, output is 32-bit.
define i32 @test_zext_cmp5(i64 %a, i64 %b) {
; CHECK-LABEL: test_zext_cmp5:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lzcntq %rdi, %rcx
; CHECK-NEXT:    lzcntq %rsi, %rax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    shrl $6, %eax
; CHECK-NEXT:    # kill: %EAX<def> %EAX<kill> %RAX<kill>
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp5:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    testq %rdi, %rdi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testq %rsi, %rsi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i64 %a, 0
  %cmp1 = icmp eq i64 %b, 0
  %0 = or i1 %cmp, %cmp1
  %lor.ext = zext i1 %0 to i32
  ret i32 %lor.ext
}

; Test three 32-bit inputs, output is 32-bit.
define i32 @test_zext_cmp6(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: test_zext_cmp6:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lzcntl %edi, %eax
; CHECK-NEXT:    lzcntl %esi, %ecx
; CHECK-NEXT:    orl %eax, %ecx
; CHECK-NEXT:    lzcntl %edx, %eax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    shrl $5, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp6:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testl %esi, %esi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    testl %edx, %edx
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    orb %cl, %al
; NOFASTLZCNT-NEXT:    movzbl %al, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i32 %a, 0
  %cmp1 = icmp eq i32 %b, 0
  %or.cond = or i1 %cmp, %cmp1
  %cmp2 = icmp eq i32 %c, 0
  %.cmp2 = or i1 %or.cond, %cmp2
  %lor.ext = zext i1 %.cmp2 to i32
  ret i32 %lor.ext
}

; Test three 32-bit inputs, output is 32-bit, but compared to test_zext_cmp6 test,
; %.cmp2 inputs' order is inverted.
define i32 @test_zext_cmp7(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: test_zext_cmp7:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lzcntl %edi, %eax
; CHECK-NEXT:    lzcntl %esi, %ecx
; CHECK-NEXT:    orl %eax, %ecx
; CHECK-NEXT:    lzcntl %edx, %eax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    shrl $5, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp7:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testl %esi, %esi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    testl %edx, %edx
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    orb %cl, %al
; NOFASTLZCNT-NEXT:    movzbl %al, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i32 %a, 0
  %cmp1 = icmp eq i32 %b, 0
  %or.cond = or i1 %cmp, %cmp1
  %cmp2 = icmp eq i32 %c, 0
  %.cmp2 = or i1 %cmp2, %or.cond
  %lor.ext = zext i1 %.cmp2 to i32
  ret i32 %lor.ext
}

; Test four 32-bit inputs, output is 32-bit.
define i32 @test_zext_cmp8(i32 %a, i32 %b, i32 %c, i32 %d) {
; CHECK-LABEL: test_zext_cmp8:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lzcntl %edi, %eax
; CHECK-NEXT:    lzcntl %esi, %esi
; CHECK-NEXT:    lzcntl %edx, %edx
; CHECK-NEXT:    orl %eax, %esi
; CHECK-NEXT:    lzcntl %ecx, %eax
; CHECK-NEXT:    orl %edx, %eax
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    shrl $5, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp8:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %dil
; NOFASTLZCNT-NEXT:    testl %esi, %esi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    orb %dil, %al
; NOFASTLZCNT-NEXT:    testl %edx, %edx
; NOFASTLZCNT-NEXT:    sete %dl
; NOFASTLZCNT-NEXT:    testl %ecx, %ecx
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %dl, %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i32 %a, 0
  %cmp1 = icmp eq i32 %b, 0
  %or.cond = or i1 %cmp, %cmp1
  %cmp3 = icmp eq i32 %c, 0
  %or.cond5 = or i1 %or.cond, %cmp3
  %cmp4 = icmp eq i32 %d, 0
  %.cmp4 = or i1 %or.cond5, %cmp4
  %lor.ext = zext i1 %.cmp4 to i32
  ret i32 %lor.ext
}

; Test one 32-bit input, one 64-bit input, output is 32-bit.
define i32 @test_zext_cmp9(i32 %a, i64 %b) {
; CHECK-LABEL: test_zext_cmp9:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lzcntq %rsi, %rax
; CHECK-NEXT:    lzcntl %edi, %ecx
; CHECK-NEXT:    shrl $5, %ecx
; CHECK-NEXT:    shrl $6, %eax
; CHECK-NEXT:    orl %ecx, %eax
; CHECK-NEXT:    # kill: %EAX<def> %EAX<kill> %RAX<kill>
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp9:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    testl %edi, %edi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    testq %rsi, %rsi
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %cmp = icmp eq i32 %a, 0
  %cmp1 = icmp eq i64 %b, 0
  %0 = or i1 %cmp, %cmp1
  %lor.ext = zext i1 %0 to i32
  ret i32 %lor.ext
}

; Test 2 128-bit inputs, output is 32-bit, no transformations expected.
define i32 @test_zext_cmp10(i64 %a.coerce0, i64 %a.coerce1, i64 %b.coerce0, i64 %b.coerce1) {
; CHECK-LABEL: test_zext_cmp10:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    orq %rsi, %rdi
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    orq %rcx, %rdx
; CHECK-NEXT:    sete %cl
; CHECK-NEXT:    orb %al, %cl
; CHECK-NEXT:    movzbl %cl, %eax
; CHECK-NEXT:    retq
;
; NOFASTLZCNT-LABEL: test_zext_cmp10:
; NOFASTLZCNT:       # BB#0: # %entry
; NOFASTLZCNT-NEXT:    orq %rsi, %rdi
; NOFASTLZCNT-NEXT:    sete %al
; NOFASTLZCNT-NEXT:    orq %rcx, %rdx
; NOFASTLZCNT-NEXT:    sete %cl
; NOFASTLZCNT-NEXT:    orb %al, %cl
; NOFASTLZCNT-NEXT:    movzbl %cl, %eax
; NOFASTLZCNT-NEXT:    retq
entry:
  %a.sroa.2.0.insert.ext = zext i64 %a.coerce1 to i128
  %a.sroa.2.0.insert.shift = shl nuw i128 %a.sroa.2.0.insert.ext, 64
  %a.sroa.0.0.insert.ext = zext i64 %a.coerce0 to i128
  %a.sroa.0.0.insert.insert = or i128 %a.sroa.2.0.insert.shift, %a.sroa.0.0.insert.ext
  %b.sroa.2.0.insert.ext = zext i64 %b.coerce1 to i128
  %b.sroa.2.0.insert.shift = shl nuw i128 %b.sroa.2.0.insert.ext, 64
  %b.sroa.0.0.insert.ext = zext i64 %b.coerce0 to i128
  %b.sroa.0.0.insert.insert = or i128 %b.sroa.2.0.insert.shift, %b.sroa.0.0.insert.ext
  %cmp = icmp eq i128 %a.sroa.0.0.insert.insert, 0
  %cmp3 = icmp eq i128 %b.sroa.0.0.insert.insert, 0
  %0 = or i1 %cmp, %cmp3
  %lor.ext = zext i1 %0 to i32
  ret i32 %lor.ext
}
