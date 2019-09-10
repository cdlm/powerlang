/*
 * Copyright (c) 2019 Javier Pimas, Jan Vrany

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <fstream>

#include <ImageSegment.h>
#include <Object.h>
#include <Classes.h>
#include <Dispatch.h>

using namespace S9;

int
main(const int argc, const char** argv)
{
    if (argc != 2) {
        printf("Usage: %s <KERNEL_SEGMENT>\n", argv[0]);
        return 1;
    }
    std::ifstream segment_file(argv[1], std::ifstream::binary);
    if (!segment_file) {
        printf("No such file: %s\n", argv[0]);
        return 1;
    }

    ImageSegment* kernel = ImageSegment::load(&segment_file);

    printf("Loaded kernel at %p, size %lu, TOC at %p\n",
           kernel,
           kernel->header.size,
           kernel->header.toc.get());

    VMObject::initializeSpecialObjects((*(kernel->begin())).get());

    OOP<pst::BeeModuleTOC> toc = kernel->header.toc;
    OOP<> entry = toc->s_actions->slot(0);

    OOP<> entry_method = Lookup(entry, Symbol_evaluate);

    printf("Entry method to execute %p\n", entry_method.get());
}