/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 2.0.11
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

namespace RakNet {

using System;
using System.Runtime.InteropServices;

public class UnsignedIntPointer : IDisposable {
  private HandleRef swigCPtr;
  protected bool swigCMemOwn;

  internal UnsignedIntPointer(IntPtr cPtr, bool cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = new HandleRef(this, cPtr);
  }

  internal static HandleRef getCPtr(UnsignedIntPointer obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }

  ~UnsignedIntPointer() {
    Dispose();
  }

  public virtual void Dispose() {
    lock(this) {
      if (swigCPtr.Handle != IntPtr.Zero) {
        if (swigCMemOwn) {
          swigCMemOwn = false;
          RakNetPINVOKE.delete_UnsignedIntPointer(swigCPtr);
        }
        swigCPtr = new HandleRef(null, IntPtr.Zero);
      }
      GC.SuppressFinalize(this);
    }
  }

  public UnsignedIntPointer() : this(RakNetPINVOKE.new_UnsignedIntPointer(), true) {
  }

  public void assign(uint value) {
    RakNetPINVOKE.UnsignedIntPointer_assign(swigCPtr, value);
  }

  public uint value() {
    uint ret = RakNetPINVOKE.UnsignedIntPointer_value(swigCPtr);
    return ret;
  }

  public SWIGTYPE_p_unsigned_int cast() {
    IntPtr cPtr = RakNetPINVOKE.UnsignedIntPointer_cast(swigCPtr);
    SWIGTYPE_p_unsigned_int ret = (cPtr == IntPtr.Zero) ? null : new SWIGTYPE_p_unsigned_int(cPtr, false);
    return ret;
  }

  public static UnsignedIntPointer frompointer(SWIGTYPE_p_unsigned_int t) {
    IntPtr cPtr = RakNetPINVOKE.UnsignedIntPointer_frompointer(SWIGTYPE_p_unsigned_int.getCPtr(t));
    UnsignedIntPointer ret = (cPtr == IntPtr.Zero) ? null : new UnsignedIntPointer(cPtr, false);
    return ret;
  }

}

}
