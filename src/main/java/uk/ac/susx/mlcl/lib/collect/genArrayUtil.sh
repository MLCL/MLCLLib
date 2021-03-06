#!/bin/sh
#
# Copyright (c) 2011-2012, University of Sussex
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
#  * Neither the name of the University of Sussex nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#



class=ArrayUtil
outfile=${class}.java

if [[ -e ${outfile} ]]; then
    rm ${outfile}
fi

PRIMTYP=("boolean" "byte" "char" "short" "int" "long" "float" "double" "Object" "T")
GENTYPE[9]=" <T>"
NEWINSTANCE=("new boolean" "new byte" "new char" "new short" "new int" "new long"
    "new float" "new double" "new Object" "(T[])new Object")
BOXTYPE=("Boolean" "Byte" "Character" "Short" "Integer" "Long" "Float" "Double" "Object")

ARGSIN[9]=", Comparator<T> comp"
ARGSOUT[9]=", comp"

COMP=("(\$1==\$2?1:0)" "(byte)(\$1-\$2)" "(char)(\$1-\$2)" "(short)(\$1-\$2)" "\$1-\$2" "\$1-\$2"
     "\$1-\$2" "\$1-\$2" "((Comparable)\$1).compareTo(\$2)" "comp.compare(\$1,\$2)")


PrimToStringClass=("" Integer Integer Integer Integer Long Float Double "" "")

symbolic=(1 1 1 1 1 1 1 1 1 0)
ordered=(1 1 1 1 1 1 1 1 1 1)
numeric=(0 1 1 1 1 1 1 1 0 0)
tooctal=(0 1 1 1 1 1 0 0 0 0)
floatp=(0 0 0 0 0 0 1 1 0 0)
primitive=(1 1 1 1 1 1 1 1 0 0)


perl -pe "s/__CLASS__/${class}/g;" << "---EOF---" >> ${outfile}
/*
 * Copyright (c) 2011-2012, University of Sussex
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 *  * Neither the name of the University of Sussex nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package uk.ac.susx.mlcl.lib.collect;

import java.util.Comparator;
import java.util.Random;
import java.util.HashMap;
import java.util.Map;
import uk.ac.susx.mlcl.lib.Checks;

/**
 * Static utility class for symbolic manipulation of arrays.
 *
 * @author Hamish Morgan &lt;hamish.morgan@sussex.ac.uk&gt;
 */
@SuppressWarnings("unchecked")
public final class __CLASS__ {

    private __CLASS__() {}

    private static final class Lazy {
        private static final Random RND = new Random();
        private Lazy() {}
    }

    public static int countEQ(boolean[] logical, boolean value) {
        int n = 0;
        for (int i = 0; i < logical.length; i++)
            n += logical[i] == value ? 1 : 0;
        return n;
    }

    public static int[] find(boolean[] logical) {
        int[] result = new int[countEQ(logical, true)];
        for (int i = 0, j = 0; i < logical.length; i++)
            if (logical[i])
                result[j++] = i;
        return result;
    }

---EOF---


for ((i=0; i<${#PRIMTYP[@]}; i++))
do


if (( ${primitive[i]} == 1 ))
then
cat << "---EOF---" \
    | perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g;" \
    | perl -pe "s/BOXTYPE/${BOXTYPE[i]}/g;"

    public static BOXTYPE[] box(final PRIMTYP[] src) {
        return box(src, 0, src.length);
    }

    public static BOXTYPE[] box(final PRIMTYP[] src, final int offset) {
        return box(src, offset, src.length - offset);
    }

    public static BOXTYPE[] box(final PRIMTYP[] src, final int offset, final int len) {
        BOXTYPE[] dst = new BOXTYPE[len];
        for(int i = 0; i < len; i++)
            dst[i] = (BOXTYPE)src[offset + i];
        return dst;
    }

    public static PRIMTYP[] unbox(final BOXTYPE[] src) {
        return unbox(src, 0, src.length);
    }

    public static PRIMTYP[] unbox(final BOXTYPE[] src, final int offset) {
        return unbox(src, offset, src.length - offset);
    }

    public static PRIMTYP[] unbox(final BOXTYPE[] src, final int offset, final int len) {
        PRIMTYP[] dst = new PRIMTYP[len];
        for(int i = 0; i < len; i++)
            dst[i] = (PRIMTYP)src[offset + i];
        return dst;
    }

---EOF---

fi

if (( ${symbolic[i]} == 1 ))
then
cat << "---EOF---" \
    | perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g;" \
    | perl -pe "s/BOXTYPE/${BOXTYPE[i]}/g;" \
    | perl -pe "s/NEWINSTANCE/${NEWINSTANCE[i]}/g;" \
    | perl -pe "s/(public static)/\$1${GENTYPE[i]}/g;"


    /*
     * ==================
     *  Type: PRIMTYP
     * ==================
     */

    public static PRIMTYP[] copyOf(final PRIMTYP[] src) {
        return copyOf(src, 0, src.length);
    }

    public static PRIMTYP[] copyOf(final PRIMTYP[] src, final int offset) {
        return copyOf(src, offset, src.length - offset);
    }

    public static PRIMTYP[] copyOf(final PRIMTYP[] src, final int offset, final int len) {
        PRIMTYP[] dst = NEWINSTANCE[len];
        System.arraycopy(src, offset, dst, 0, len);
        return dst;
    }

    public static PRIMTYP[] cat(final PRIMTYP[]... arrs) {
        int n = 0;
        for (int i = 0; i < arrs.length; i++)
            n += arrs[i].length;
        PRIMTYP[] result = NEWINSTANCE[n];
        int offset = 0;
        for (int i = 0; i < arrs.length; i++) {
            System.arraycopy(arrs[i], 0, result, offset, arrs[i].length);
            offset += arrs[i].length;
        }
        return result;
    }

    public static int firstIndexOf(final PRIMTYP[] arr, final PRIMTYP val) {
        return firstIndexOf(arr, val, 0, arr.length);
    }

    public static int firstIndexOf(final PRIMTYP[] arr, final PRIMTYP val, int fromIndex) {
        return firstIndexOf(arr, val, fromIndex, arr.length);
    }

    public static int firstIndexOf(final PRIMTYP[] arr, final PRIMTYP val, int fromIndex, int toIndex) {
        for (int i = fromIndex; i < toIndex; i++)
            if (arr[i] == val)
                return i;
        return -1;
    }

    public static int lastIndexOf(final PRIMTYP[] arr, final PRIMTYP val) {
        return lastIndexOf(arr, val, 0, arr.length);
    }

    public static int lastIndexOf(final PRIMTYP[] arr, final PRIMTYP val, int fromIndex) {
        return lastIndexOf(arr, val, fromIndex, arr.length);
    }

    public static int lastIndexOf(final PRIMTYP[] arr, final PRIMTYP val, int fromIndex, int toIndex) {
        for (int i = toIndex - 1; i >= fromIndex; i--)
            if (arr[i] == val)
                return i;
        return -1;
    }

    public static boolean contains(final PRIMTYP[] arr, final PRIMTYP val) {
        return firstIndexOf(arr, val) != -1;
    }

    public static boolean contains(final PRIMTYP[] arr, final PRIMTYP val, int fromIndex) {
        return firstIndexOf(arr, val, fromIndex) != -1;
    }

    public static boolean contains(final PRIMTYP[] arr, final PRIMTYP val, int fromIndex, int toIndex) {
        return firstIndexOf(arr, val, fromIndex, toIndex) != -1;
    }

    public static PRIMTYP[] unique(final PRIMTYP... arr) {
        // This is way to slow O(n^2) - can be done in
        // O(n log n) by sorting in input first.
        PRIMTYP[] result = NEWINSTANCE[arr.length];
        int j = 0;
        for (int i = 0; i < arr.length; i++) {
            if (!contains(result, arr[i])) {
                result[j] = arr[i];
                j++;
            }
        }
        return copyOf(result, 0, j);
    }

    public static void reverse(final PRIMTYP[] a) {
        reverse(a, 0, a.length);
    }

    public static void reverse(final PRIMTYP[] a, final int fromIndex) {
        reverse(a, fromIndex, a.length);
    }

    public static void reverse(final PRIMTYP[] a, final int fromIndex, final int toIndex) {
        for (int i = fromIndex, j = toIndex - 1; i < j; i++, j--) {
            swap(a, i, j);
        }
    }

    public static void swap(final PRIMTYP[] a, final int i, final int j) {
        final PRIMTYP tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
    }

    public static PRIMTYP[] elementsOf(PRIMTYP[] arr, int[] idx) {
        PRIMTYP[] result = NEWINSTANCE[idx.length];
        for (int i = 0, j = 0; i < idx.length; i++)
            result[i] = arr[idx[i]];
        return result;
    }

    public static PRIMTYP[] elementsOf(PRIMTYP[] arr, boolean[] logical) {
        return elementsOf(arr, find(logical));
    }

    public static boolean[] valuesEq(PRIMTYP[] arr, PRIMTYP val) {
        boolean[] result = new boolean[arr.length];
        for (int i = 0; i < arr.length; i++)
            result[i] = arr[i] == val;
        return result;
    }

    public static boolean[] valuesNeq(PRIMTYP[] arr, PRIMTYP val) {
        boolean[] result = new boolean[arr.length];
        for (int i = 0; i < arr.length; i++)
            result[i] = arr[i] != val;
        return result;
    }

    public static PRIMTYP[] ensureCapacity(PRIMTYP[] arr, int minCap) {
        int oldCap = arr.length;
        if (minCap > oldCap) {
            int newCap = (oldCap * 3) / 2 + 1;
            if (newCap < minCap)
                newCap = minCap;
            return copyOf(arr, 0, newCap);
        } else {
            return arr;
        }
    }

    public static PRIMTYP mode(PRIMTYP[] arr) {
        Map<BOXTYPE, Integer> map = new HashMap<BOXTYPE, Integer>();
        for (int i = 0; i < arr.length; i++) {
            if (map.containsKey(arr[i]))
                map.put(arr[i], map.get(arr[i]) + 1);
            else
                map.put(arr[i], 1);
        }
        int maxCount = -1;
        BOXTYPE maxValue = arr[0];
        for (BOXTYPE key : map.keySet()) {
            int count = map.get(key);
            if (count > maxCount) {
                maxCount = count;
                maxValue = key;
            }
        }
        return maxValue;
    }

---EOF---

fi

if (( ${ordered[i]} == 1 ))
then
cat << "---EOF---" \
    | perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g;" \
    | perl -pe "s/NEWINSTANCE/${NEWINSTANCE[i]}/g;" \
    | perl -pe "s/(public static)/\$1${GENTYPE[i]}/g;" \
    | perl -pe "s/ARGSIN/${ARGSIN[i]}/g;" \
    | perl -pe "s/ARGSOUT/${ARGSOUT[i]}/g;" \
    | perl -pe "s/COMP\(([^,]*),([^)]*)\)/${COMP[i]}/g"


    public static void permute(final PRIMTYP[] aARGSIN) {
        permute(aARGSOUT, 0, a.length);
    }

    public static void permute(final PRIMTYP[] aARGSIN, final int toIndex) {
        permute(aARGSOUT, toIndex, a.length);
    }

    /**
     * Takes an array a and rearranges it into the next permutation in
     * lexicographic order.
     *
     * Use an algorithm defined in
     * http://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order
     * which probably isnt the most efficient solution.
     *
     * @param a the array to be permuted
     * @param toIndex index of the first element (inclusive) to be permuted
     * @param fromIndex index of the last element (exclusive) to be permuted
     */
    public static void permute(final PRIMTYP[] aARGSIN, final int fromIndex, final int toIndex) {
        if (toIndex - fromIndex < 2)
            return;

        // Find the largest index k such that a[k] < a[k + 1]. If no such index
        // exists, the permutation is the last permutation.
        int k = toIndex - 2;
        while (k >= fromIndex && COMP(a[k],a[k + 1])>=0)
            k--;

        if (k < fromIndex) {
            // Reached end of permutation cycle - reverse the
            // whole array and start over
            reverse(a, fromIndex, toIndex);

        } else {

            // Find the largest index l such that a[k] < a[l]. Since k + 1 is
            // such an index, l is well defined and satisfies k < l.
            int l = toIndex - 1;
            while (l >= fromIndex && COMP(a[k],a[l])>=0)
                l--;

            // Swap a[k] with a[l].
            swap(a, k, l);

            // Reverse the sequence from a[k + 1] up to and including the final
            // element a[n].
            reverse(a, k + 1, toIndex);
        }
    }

    public static PRIMTYP min(PRIMTYP[] values ARGSIN) {
        return values[argmin(values ARGSOUT, 0, values.length - 1)];
    }

    public static PRIMTYP min(PRIMTYP[] values ARGSIN, int fromIndex, int toIndex) {
        return values[argmin(values ARGSOUT, fromIndex, toIndex)];
    }

    public static PRIMTYP max(PRIMTYP[] values ARGSIN) {
        return values[argmax(values ARGSOUT, 0, values.length - 1)];
    }

    public static PRIMTYP max(PRIMTYP[] values ARGSIN, int fromIndex, int toIndex) {
        return values[argmax(values ARGSOUT, fromIndex, toIndex)];
    }

    public static int argmin(PRIMTYP[] values ARGSIN) {
        return argmin(values ARGSOUT, 0, values.length - 1);
    }

    public static int argmin(PRIMTYP[] values ARGSIN, int fromIndex, int toIndex) {
        int argmin = fromIndex;
        for (int i = fromIndex + 1; i <= toIndex; i++)
            if (COMP(values[i],values[argmin])<0)
                argmin = i;
        return argmin;
    }

    public static int argmax(PRIMTYP[] values ARGSIN) {
        return argmax(values ARGSOUT, 0, values.length - 1);
    }

    public static int argmax(PRIMTYP[] values ARGSIN, int fromIndex, int toIndex) {
        int argmax = fromIndex;
        for (int i = fromIndex + 1; i <= toIndex; i++)
            if (COMP(values[i],values[argmax])>0)
                argmax = i;
        return argmax;
    }

    public static int[] argminmax(PRIMTYP[] values ARGSIN, int fromIndex, int toIndex) {
        int argmax = fromIndex;
        int argmin = fromIndex;
        for (int i = fromIndex + 1; i <= toIndex; i++) {
            if (COMP(values[i],values[argmax])>0)
                argmax = i;
            else if (COMP(values[i],values[argmin])<0)
                argmin = i;
        }
        return new int[]{argmin, argmax};
    }

    public static PRIMTYP[] minmax(PRIMTYP[] values ARGSIN) {
        return minmax(values ARGSOUT, 0, values.length - 1);
    }

    public static PRIMTYP[] minmax(PRIMTYP[] values ARGSIN, int fromIndex, int toIndex) {
        int[] mm = argminmax(values ARGSOUT, fromIndex, toIndex);
        return NEWINSTANCE[]{values[mm[1]], values[mm[0]]};
    }

    public static void clamp(PRIMTYP[] src ARGSIN, PRIMTYP min, PRIMTYP max, PRIMTYP[] dst) {
        Checks.checkEqual(src.length, dst.length);
        for (int i = 0; i < src.length; i++) {
            if (COMP(src[i], max) > 0)
                dst[i] = max;
            else if (COMP(src[i], min) < 0)
                dst[i] = min;
            else
                dst[i] = src[i];
        }
    }

    public static PRIMTYP[] clamp(PRIMTYP[] src ARGSIN, PRIMTYP min, PRIMTYP max) {
        PRIMTYP[] dst = NEWINSTANCE[src.length];
        clamp(src, min, max, dst);
        return dst;
    }

    public static void clampMin(PRIMTYP[] src ARGSIN, PRIMTYP min, PRIMTYP[] dst) {
        Checks.checkEqual(src.length, dst.length);
        for (int i = 0; i < src.length; i++) {
            if (COMP(src[i], min) < 0)
                dst[i] = min;
            else
                dst[i] = src[i];
        }
    }

    public static PRIMTYP[] clampMin(PRIMTYP[] src ARGSIN, PRIMTYP min) {
        PRIMTYP[] dst = NEWINSTANCE[src.length];
        clampMin(src, min, dst);
        return dst;
    }

    public static void clampMax(PRIMTYP[] src ARGSIN, PRIMTYP max, PRIMTYP[] dst) {
        Checks.checkEqual(src.length, dst.length);
        for (int i = 0; i < src.length; i++) {
            if (COMP(src[i], max) > 0)
                dst[i] = max;
            else
                dst[i] = src[i];
        }
    }

    public static PRIMTYP[] clampMax(PRIMTYP[] src ARGSIN, PRIMTYP max) {
        PRIMTYP[] dst = NEWINSTANCE[src.length];
        clampMax(src, max, dst);
        return dst;
    }

---EOF---
fi

if (( ${numeric[i]} == 1 ))
then
cat << "---EOF---" \
    | perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g;" \
    | perl -pe "s/COMP\(([^,]*),([^)]*)\)/${COMP[i]}/g"


---EOF---

if (( ${floatp[i]} == 1 ))
then
cat << "---EOF---" \
    | perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g;" \
    | perl -pe "s/COMP\(([^,]*),([^)]*)\)/${COMP[i]}/g"



---EOF---
fi


perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g; s/PrimToStringClass/${PrimToStringClass[i]}/g; " << "---EOF---" >> ${outfile}

    public static String toHexString(final PRIMTYP[] arr) {
        final StringBuilder sbuf = new StringBuilder();
        sbuf.append('[');
        if (arr.length > 0)
            sbuf.append(PrimToStringClass.toHexString(arr[0]));
        for (int i = 1; i < arr.length; i++) {
            sbuf.append(' ');
            sbuf.append(PrimToStringClass.toHexString(arr[i]));
        }
        sbuf.append(']');
        return sbuf.toString();
    }

---EOF---


if [[ -n ${PrimToStringClass[i]} ]] && [[ -n ${toOctalString[i]} ]]; then

perl -pe "s/PRIMTYP/${PRIMTYP[i]}/g; s/PrimToStringClass/${PrimToStringClass[i]}/g; " << "---EOF---" >> ${outfile}

    public static String toOctalString(final PRIMTYP[] arr) {
        final StringBuilder sbuf = new StringBuilder();
        sbuf.append('[');
        if (arr.length > 0)
            sbuf.append(PrimToStringClass.toOctalString(arr[0]));
        for (int i = 1; i < arr.length; i++) {
            sbuf.append(' ');
            sbuf.append(PrimToStringClass.toOctalString(arr[i]));
        }
        sbuf.append(']');
        return sbuf.toString();
    }

    public static String toBinaryString(final PRIMTYP[] arr) {
        final StringBuilder sbuf = new StringBuilder();
        sbuf.append('[');
        if (arr.length > 0)
            sbuf.append(PrimToStringClass.toBinaryString(arr[0]));
        for (int i = 1; i < arr.length; i++) {
            sbuf.append(' ');
            sbuf.append(PrimToStringClass.toBinaryString(arr[i]));
        }
        sbuf.append(']');
        return sbuf.toString();
    }

---EOF---
fi


fi
done  >> ${outfile}

cat << "---EOF---" >> ${outfile}

}

---EOF---


