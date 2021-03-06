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
package uk.ac.susx.mlcl.lib.io;

import java.io.IOException;
import java.util.Comparator;

/**
 * Decorating ObjectSink that encapsulates some other instances, and filters
 * the objects being consumed, such that only the first K sequential objects,
 * that are equal according to some comparator, are actually forwarded to the
 * encapsulated instance.
 *
 * @param <T> type of ObjectSink being encapsulated
 * @author Hamish I A Morgan &lt;hamish.morgan@sussex.ac.uk&gt;
 */
public final class KFirstReducingObjectSink<T>
        extends ForwardingObjectSink<ObjectSink<T>, T> {

    private Comparator<T> comparator = null;

    private int limit = 100;

    private T currentRecord = null;

    private int count = -1;

    public KFirstReducingObjectSink(ObjectSink<T> inner, Comparator<T> comparator, int limit) {
        super(inner);
        this.limit = limit;
        this.comparator = comparator;
    }

    @Override
    public void write(T o) throws IOException {
        if (currentRecord == null
                || comparator.compare(currentRecord, o) != 0) {
            currentRecord = o;
            count = 0;
        }
        ++count;

        if (count <= limit) {
            super.write(o);
        }
    }

}
