; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown -mattr=+sse2 | FileCheck %s

define <4 x i32> @t(i32 %x, i32 %y) nounwind  {
; CHECK-LABEL: t:
; CHECK:       # BB#0:
; CHECK-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    retl
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %x, i32 0
  %tmp2 = insertelement <4 x i32> %tmp1, i32 %y, i32 1
  ret <4 x i32> %tmp2
}
